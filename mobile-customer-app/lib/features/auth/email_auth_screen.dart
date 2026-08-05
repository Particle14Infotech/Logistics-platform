import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_textfield.dart';

enum _Step { login, register, verifyEmail }

// Email/password login is the only auth path - Firebase owns the credential
// and email-verification state; this screen only calls
// AuthService.syncFirebaseSession() once Firebase confirms the email is
// verified, which exchanges the Firebase ID token for this app's own JWT
// session.
class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _Step _step = _Step.login;
  bool _loading = false;
  String? _error;
  bool _resendSent = false;

  // Alternative to the emailed link at the verify-email step - the user's
  // choice between either, both stay available.
  bool _useOtpEntry = false;
  bool _otpSent = false;
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!_isValidEmail(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Enter your password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await _authService.loginWithEmail(email, password);
      if (!user.emailVerified) {
        setState(() {
          _step = _Step.verifyEmail;
          _resendSent = false;
        });
        return;
      }
      await _syncSessionAndContinue();
    } on fb.FirebaseAuthException catch (e) {
      setState(() => _error = _messageFor(e));
    } catch (e, st) {
      debugPrint('[_login] EXCEPTION: $e\n$st');
      setState(() => _error = 'Could not log in. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!_isValidEmail(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.registerWithEmail(email, password);
      setState(() {
        _step = _Step.verifyEmail;
        _resendSent = false;
      });
    } on fb.FirebaseAuthException catch (e) {
      setState(() => _error = _messageFor(e));
    } catch (e, st) {
      debugPrint('[_register] EXCEPTION: $e\n$st');
      setState(() => _error = 'Could not create your account. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkVerifiedAndContinue() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final verified = await _authService.checkEmailVerified();
      if (!verified) {
        setState(() => _error = "Not verified yet - tap the link in the email we sent you.");
        return;
      }
      await _syncSessionAndContinue();
    } catch (e, st) {
      debugPrint('[_checkVerifiedAndContinue] EXCEPTION: $e\n$st');
      setState(() => _error = 'Could not check verification status. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resendVerification() async {
    try {
      await _authService.resendVerificationEmail();
      setState(() => _resendSent = true);
    } catch (e) {
      setState(() => _error = 'Could not resend the email. Try again.');
    }
  }

  Future<void> _sendOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.sendEmailVerificationOtp();
      setState(() => _otpSent = true);
    } catch (e) {
      setState(() => _error = 'Could not send the code. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final valid = await _authService.verifyEmailOtp(_otpController.text.trim());
      if (!valid) {
        setState(() => _error = 'Incorrect or expired code.');
        return;
      }
      await _syncSessionAndContinue();
    } catch (e) {
      setState(() => _error = 'Could not verify that code. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _syncSessionAndContinue() async {
    final result = await _authService.syncFirebaseSession(role: 'customer');
    await ref.read(authProvider.notifier).setSession(
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          user: result.user,
        );
    if (mounted) context.go('/home');
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      setState(() => _error = 'Enter your email above first, then tap "Forgot password?".');
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset link sent to $email')),
        );
      }
    } on fb.FirebaseAuthException catch (e) {
      setState(() => _error = _messageFor(e));
    }
  }

  String _messageFor(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists for that email. Try logging in instead.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a moment.';
      default:
        return e.message ?? 'Something went wrong. Try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_step == _Step.verifyEmail)
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _step = _Step.login),
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                )
              else ...[
                const SizedBox(height: 24),
                Image.asset('assets/images/logo.png', width: 90, height: 90, fit: BoxFit.contain),
                const SizedBox(height: 16),
              ],
              Text(
                _titleFor(_step),
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.textDark),
              ),
              const SizedBox(height: 10),
              Text(
                _subtitleFor(_step),
                style: GoogleFonts.poppins(fontSize: 15, height: 1.5, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 32),

              if (_step == _Step.login) _buildLoginStep(),
              if (_step == _Step.register) _buildRegisterStep(),
              if (_step == _Step.verifyEmail) _buildVerifyEmailStep(),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: GoogleFonts.poppins(color: AppTheme.error, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _titleFor(_Step step) => switch (step) {
        _Step.login => 'Welcome Back!',
        _Step.register => 'Create Account',
        _Step.verifyEmail => 'Verify Your Email',
      };

  String _subtitleFor(_Step step) => switch (step) {
        _Step.login => 'Log in with your email to continue',
        _Step.register => 'Sign up with your email to get started',
        _Step.verifyEmail =>
          "We've sent a verification link to\n${_emailController.text.trim()}",
      };

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: FilledButton(
        onPressed: _loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _loading
            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  Widget _buildLoginStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _emailController,
          hintText: 'Email address',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Password',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            child: Text('Forgot password?', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.primary)),
          ),
        ),
        const SizedBox(height: 12),
        _buildPrimaryButton('Log In', _login),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _step = _Step.register;
              _error = null;
            }),
            child: Text("Don't have an account? Sign up", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _emailController,
          hintText: 'Email address',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Password (min 6 characters)',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: 'Confirm password',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton('Sign Up', _register),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _step = _Step.login;
              _error = null;
            }),
            child: Text('Already have an account? Log in', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyEmailStep() {
    if (_useOtpEntry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_otpSent) ...[
            _buildPrimaryButton('Send code', _sendOtp),
          ] else ...[
            CustomTextField(
              controller: _otpController,
              hintText: '6-digit code',
              prefixIcon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            _buildPrimaryButton('Verify code', _verifyOtp),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _sendOtp,
                child: Text('Resend code', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => setState(() {
                _useOtpEntry = false;
                _error = null;
              }),
              child: Text('Use the link instead', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPrimaryButton("I've verified my email", _checkVerifiedAndContinue),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _resendVerification,
            child: Text(
              _resendSent ? 'Verification email sent again' : 'Resend verification email',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _useOtpEntry = true;
              _otpSent = false;
              _error = null;
            }),
            child: Text('Enter code instead', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
          ),
        ),
      ],
    );
  }
}

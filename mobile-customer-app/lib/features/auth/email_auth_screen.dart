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
enum _AuthMethod { email, phone }
enum _PhoneStep { enterNumber, enterOtp }

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

  // Phone/SMS sign-in - a second method alongside email/password, not a
  // replacement (see auth_service.dart's phone auth section). Firebase
  // treats "new phone number" and "phone number that's signed in before"
  // identically (signInWithCredential creates the account if needed), so
  // unlike the email method there's no separate login/register step here.
  _AuthMethod _method = _AuthMethod.email;
  _PhoneStep _phoneStep = _PhoneStep.enterNumber;
  final _phoneController = TextEditingController();
  final _phoneOtpController = TextEditingController();
  String? _verificationId;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _phoneController.dispose();
    _phoneOtpController.dispose();
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

  bool _isValidPhone(String value) => RegExp(r'^[6-9]\d{9}$').hasMatch(value);

  Future<void> _sendPhoneOtp() async {
    final phone = _phoneController.text.trim();
    if (!_isValidPhone(phone)) {
      setState(() => _error = 'Enter a valid 10-digit mobile number.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final verificationId = await _authService.sendPhoneOtp('+91$phone');
      setState(() {
        _verificationId = verificationId;
        _phoneStep = _PhoneStep.enterOtp;
      });
    } on fb.FirebaseAuthException catch (e) {
      setState(() => _error = _messageFor(e));
    } catch (e, st) {
      debugPrint('[_sendPhoneOtp] EXCEPTION: $e\n$st');
      setState(() => _error = 'Could not send the code. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyPhoneOtp() async {
    final code = _phoneOtpController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.verifyPhoneOtp(_verificationId!, code);
      await _syncSessionAndContinue();
    } on fb.FirebaseAuthException catch (e) {
      setState(() => _error = _messageFor(e));
    } catch (e, st) {
      debugPrint('[_verifyPhoneOtp] EXCEPTION: $e\n$st');
      setState(() => _error = 'Could not verify that code. Try again.');
    } finally {
      setState(() => _loading = false);
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
      case 'quota-exceeded':
        return 'Too many attempts. Try again in a moment.';
      case 'invalid-phone-number':
        return 'That phone number looks invalid.';
      case 'invalid-verification-code':
      case 'invalid-otp':
        return 'Incorrect or expired code.';
      case 'session-expired':
        return 'That code expired - request a new one.';
      default:
        return e.message ?? 'Something went wrong. Try again.';
    }
  }

  // True on the two "mid-verification" screens (email link/OTP pending,
  // phone OTP pending) - both get a plain back arrow instead of the
  // logo+method-toggle header the entry screens share.
  bool get _onVerificationStep =>
      (_method == _AuthMethod.email && _step == _Step.verifyEmail) ||
      (_method == _AuthMethod.phone && _phoneStep == _PhoneStep.enterOtp);

  void _backFromVerification() => setState(() {
        if (_method == _AuthMethod.email) {
          _step = _Step.login;
        } else {
          _phoneStep = _PhoneStep.enterNumber;
        }
        _error = null;
      });

  String get _title {
    if (_method == _AuthMethod.phone) {
      return _phoneStep == _PhoneStep.enterOtp ? 'Verify Your Number' : 'Welcome!';
    }
    return _titleFor(_step);
  }

  String get _subtitle {
    if (_method == _AuthMethod.phone) {
      return _phoneStep == _PhoneStep.enterOtp
          ? "We've sent a 6-digit code to\n+91 ${_phoneController.text.trim()}"
          : 'Log in or sign up with your mobile number';
    }
    return _subtitleFor(_step);
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
              if (_onVerificationStep)
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: _backFromVerification,
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                )
              else ...[
                const SizedBox(height: 24),
                Image.asset('assets/images/logo.png', width: 90, height: 90, fit: BoxFit.contain),
                const SizedBox(height: 16),
              ],
              Text(
                _title,
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.textDark),
              ),
              const SizedBox(height: 10),
              Text(
                _subtitle,
                style: GoogleFonts.poppins(fontSize: 15, height: 1.5, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 24),

              if (!_onVerificationStep && _step != _Step.register) _buildMethodToggle(),
              if (!_onVerificationStep && _step != _Step.register) const SizedBox(height: 24),

              if (_method == _AuthMethod.email && _step == _Step.login) _buildLoginStep(),
              if (_method == _AuthMethod.email && _step == _Step.register) _buildRegisterStep(),
              if (_method == _AuthMethod.email && _step == _Step.verifyEmail) _buildVerifyEmailStep(),
              if (_method == _AuthMethod.phone) _buildPhoneStep(),

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

  Widget _buildMethodToggle() {
    Widget tab(String label, _AuthMethod method) {
      final selected = _method == method;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() {
            _method = method;
            _error = null;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [tab('Email', _AuthMethod.email), tab('Phone', _AuthMethod.phone)]),
    );
  }

  Widget _buildPhoneStep() {
    if (_phoneStep == _PhoneStep.enterOtp) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _phoneOtpController,
            hintText: '6-digit code',
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          const SizedBox(height: 16),
          _buildPrimaryButton('Verify & Continue', _verifyPhoneOtp),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _sendPhoneOtp,
              child: Text('Resend code', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _phoneController,
          hintText: '10-digit mobile number',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          maxLength: 10,
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton('Send OTP', _sendPhoneOtp),
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

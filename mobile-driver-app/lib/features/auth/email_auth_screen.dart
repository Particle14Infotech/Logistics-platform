import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/selected_role_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_text_field.dart';

enum _Step { login, register, verifyEmail, personalDetails }

// Email/password login is the only auth path - Firebase owns the credential
// and email-verification state; this screen only calls
// AuthService.syncFirebaseSession() once Firebase confirms the email is
// verified, which exchanges the Firebase ID token for this app's own JWT
// session, so router redirects (vehicle-setup/fleet-setup/dashboard) work.
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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  _Step _step = _Step.login;
  bool _loading = false;
  String? _error;
  bool _resendSent = false;
  DateTime? _dob;
  // Tokens from syncFirebaseSession() for a brand-new user - held here
  // rather than committed via setSession() until the personal-details step
  // completes.
  AuthResult? _pendingAuthResult;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
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

  Future<void> _syncSessionAndContinue() async {
    final role = ref.read(selectedRoleProvider);
    final result = await _authService.syncFirebaseSession(role: role);

    if (result.isNewUser) {
      // Don't call setSession() here - it updates global auth state, which
      // the router watches, and would redirect away from this screen
      // before the personal-details step below (which calls
      // /auth/profile) ever runs. updateAccessToken() only stashes the
      // token (for DioClient's interceptor) without touching `user`, so
      // isAuthenticated stays false until the personal-details step below.
      _pendingAuthResult = result;
      await ref.read(authProvider.notifier).updateAccessToken(result.accessToken);
      setState(() => _step = _Step.personalDetails);
      return;
    }

    await ref.read(authProvider.notifier).setSession(
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          user: result.user,
        );
    if (mounted) context.go('/splash');
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'Date of birth',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _submitPersonalDetails() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter your full name.');
      return;
    }
    if (phone.length < 10) {
      setState(() => _error = 'Enter a valid 10-digit phone number.');
      return;
    }
    if (_dob == null) {
      setState(() => _error = 'Select your date of birth.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final updatedUser = await _authService.updateProfile(
        name: name,
        phone: phone,
        dob: _dob!.toIso8601String(),
      );
      final pending = _pendingAuthResult!;
      await ref.read(authProvider.notifier).setSession(
            accessToken: pending.accessToken,
            refreshToken: pending.refreshToken,
            user: updatedUser,
          );
      if (mounted) context.go('/splash');
    } catch (e) {
      setState(() => _error = 'Could not save your details. Try again.');
    } finally {
      setState(() => _loading = false);
    }
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
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_step == _Step.verifyEmail)
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _step = _Step.login),
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                )
              else
                const SizedBox(height: 44),
              const SizedBox(height: 8),

              Text(
                _titleFor(_step),
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                _subtitleFor(_step),
                style: GoogleFonts.poppins(fontSize: 15, color: AppTheme.textGrey, height: 1.5),
              ),
              const SizedBox(height: 32),

              if (_step == _Step.login) _buildLoginStep(),
              if (_step == _Step.register) _buildRegisterStep(),
              if (_step == _Step.verifyEmail) _buildVerifyEmailStep(),
              if (_step == _Step.personalDetails) _buildPersonalDetailsStep(),

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
        _Step.personalDetails => 'Tell Us About Yourself',
      };

  String _subtitleFor(_Step step) => switch (step) {
        _Step.login => 'Log in with your email to continue',
        _Step.register => 'Sign up with your email to get started',
        _Step.verifyEmail =>
          "We've sent a verification link to\n${_emailController.text.trim()}",
        _Step.personalDetails => 'This helps customers and support identify you.',
      };

  Widget _buildLoginStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          label: 'Email',
          hint: 'you@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Password',
          hint: 'Your password',
          controller: _passwordController,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            child: Text('Forgot password?', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.amber)),
          ),
        ),
        const SizedBox(height: 8),
        AuthButton(label: 'Log In', onPressed: _login, isLoading: _loading),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _step = _Step.register;
              _error = null;
            }),
            child: Text("Don't have an account? Sign up", style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          label: 'Email',
          hint: 'you@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Password',
          hint: 'Min 6 characters',
          controller: _passwordController,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Confirm password',
          hint: 'Re-enter password',
          controller: _confirmPasswordController,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 24),
        AuthButton(label: 'Sign Up', onPressed: _register, isLoading: _loading),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _step = _Step.login;
              _error = null;
            }),
            child: Text('Already have an account? Log in', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey)),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthButton(label: "I've verified my email", onPressed: _checkVerifiedAndContinue, isLoading: _loading),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _resendVerification,
            child: Text(
              _resendSent ? 'Verification email sent again' : 'Resend verification email',
              style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          label: 'Full name',
          hint: 'Your name',
          controller: _nameController,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Phone number',
          hint: '98765 43210',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          maxLength: 10,
        ),
        const SizedBox(height: 16),
        Text('Date of birth', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDob,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: AppTheme.textGrey, size: 20),
                const SizedBox(width: 12),
                Text(
                  _dob == null
                      ? 'Select your date of birth'
                      : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: _dob == null ? AppTheme.textGrey : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        AuthButton(label: 'Continue', onPressed: _submitPersonalDetails, isLoading: _loading),
      ],
    );
  }
}

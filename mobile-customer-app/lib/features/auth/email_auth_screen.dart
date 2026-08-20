import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
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

  // Shared by both the email- and phone-OTP "Resend code" buttons - a real
  // user impatiently mashing resend is the one realistic way to trigger
  // Firebase's own per-number anti-abuse throttle (it blocks rapid repeat
  // sends to protect the phone's owner from being SMS-bombed - not
  // something this app can raise or configure, it's Google's own
  // infrastructure). A simple cooldown here stops that before it happens.
  Timer? _resendTimer;
  int _resendSecondsLeft = 0;

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsLeft = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
      } else {
        setState(() => _resendSecondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _phoneController.dispose();
    _phoneOtpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  bool _isValidEmail(String value) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!_isValidEmail(email)) {
      setState(() => _error = l10n.enterValidEmail);
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = l10n.enterYourPassword);
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
    } catch (e, st) {
      debugPrint('[_login] EXCEPTION: $e\n$st');
      setState(() => _error = _extractErrorMessage(e, l10n.couldNotLogInTryAgain));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!_isValidEmail(email)) {
      setState(() => _error = l10n.enterValidEmail);
      return;
    }
    if (password.length < 6) {
      setState(() => _error = l10n.passwordMinLength);
      return;
    }
    if (password != _confirmPasswordController.text) {
      setState(() => _error = l10n.passwordsDoNotMatch);
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
      setState(() => _error = l10n.couldNotCreateAccountTryAgain);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkVerifiedAndContinue() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final verified = await _authService.checkEmailVerified();
      if (!verified) {
        setState(() => _error = l10n.notVerifiedYetTapLink);
        return;
      }
      await _syncSessionAndContinue();
    } catch (e, st) {
      debugPrint('[_checkVerifiedAndContinue] EXCEPTION: $e\n$st');
      setState(() => _error = _extractErrorMessage(e, l10n.couldNotCheckVerificationTryAgain));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resendVerification() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _authService.resendVerificationEmail();
      setState(() => _resendSent = true);
    } catch (e) {
      setState(() => _error = _extractErrorMessage(e, l10n.couldNotResendEmailTryAgain));
    }
  }

  Future<void> _sendOtp() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.sendEmailVerificationOtp();
      setState(() => _otpSent = true);
      _startResendCooldown();
    } catch (e) {
      setState(() => _error = _extractErrorMessage(e, l10n.couldNotSendCodeTryAgain));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context)!;
    if (_otpController.text.trim().length != 6) {
      setState(() => _error = l10n.enterSixDigitCode);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final valid = await _authService.verifyEmailOtp(_otpController.text.trim());
      if (!valid) {
        setState(() => _error = l10n.incorrectOrExpiredCode);
        return;
      }
      await _syncSessionAndContinue();
    } catch (e) {
      setState(() => _error = _extractErrorMessage(e, l10n.couldNotVerifyCodeTryAgain));
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
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      setState(() => _error = l10n.enterEmailFirstThenForgot);
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.passwordResetLinkSentTo(email))),
        );
      }
    } on fb.FirebaseAuthException catch (e) {
      setState(() => _error = _messageFor(e));
    }
  }

  bool _isValidPhone(String value) => RegExp(r'^[6-9]\d{9}$').hasMatch(value);

  Future<void> _sendPhoneOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final phone = _phoneController.text.trim();
    if (!_isValidPhone(phone)) {
      setState(() => _error = l10n.enterValidMobileNumber);
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
      _startResendCooldown();
    } on fb.FirebaseAuthException catch (e) {
      setState(() => _error = _messageFor(e));
    } catch (e, st) {
      debugPrint('[_sendPhoneOtp] EXCEPTION: $e\n$st');
      setState(() => _error = l10n.couldNotSendCodeTryAgain);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyPhoneOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _phoneOtpController.text.trim();
    if (code.length != 6) {
      setState(() => _error = l10n.enterSixDigitCode);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.verifyPhoneOtp(_verificationId!, code);
      await _syncSessionAndContinue();
    } catch (e, st) {
      debugPrint('[_verifyPhoneOtp] EXCEPTION: $e\n$st');
      setState(() => _error = _extractErrorMessage(e, l10n.couldNotVerifyCodeTryAgain));
    } finally {
      setState(() => _loading = false);
    }
  }

  String _messageFor(fb.FirebaseAuthException e) {
    final l10n = AppLocalizations.of(context)!;
    switch (e.code) {
      case 'email-already-in-use':
        return l10n.accountExistsForEmailTryLogin;
      case 'invalid-email':
        return l10n.emailLooksInvalid;
      case 'weak-password':
        return l10n.chooseStrongerPassword;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return l10n.incorrectEmailOrPassword;
      case 'too-many-requests':
      case 'quota-exceeded':
        return l10n.tooManyAttemptsTryAgain;
      case 'invalid-phone-number':
        return l10n.phoneNumberLooksInvalid;
      case 'invalid-verification-code':
      case 'invalid-otp':
        return l10n.incorrectOrExpiredCode;
      case 'session-expired':
        return l10n.codeExpiredRequestNew;
      default:
        return e.message ?? l10n.somethingWentWrongTryAgain;
    }
  }

  // Every call site that reaches _syncSessionAndContinue() (password,
  // email OTP, phone OTP - the Firebase step already succeeded by then)
  // can still fail at OUR backend's /auth/firebase-session, e.g. this
  // phone number already belongs to a different-role account. That's a
  // real, specific, useful reason - it was previously getting swallowed
  // by a generic catch-all that always showed "Could not verify that
  // code", which was actively misleading (the code itself was correct;
  // the phone/account it belonged to was the actual problem).
  String _extractErrorMessage(Object error, String fallback) {
    if (error is fb.FirebaseAuthException) return _messageFor(error);
    if (error is DioException) {
      final message = error.response?.data?['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return fallback;
  }

  // True on the two "mid-verification" screens (email link/OTP pending,
  // phone OTP pending) - both get a plain back arrow instead of the
  // logo+method-toggle header the entry screens share.
  bool get _onVerificationStep =>
      (_method == _AuthMethod.email && _step == _Step.verifyEmail) ||
      (_method == _AuthMethod.phone && _phoneStep == _PhoneStep.enterOtp);

  void _backFromVerification() {
    _resendTimer?.cancel();
    setState(() {
      if (_method == _AuthMethod.email) {
        _step = _Step.login;
      } else {
        _phoneStep = _PhoneStep.enterNumber;
      }
      _error = null;
      _resendSecondsLeft = 0;
    });
  }

  String get _title {
    final l10n = AppLocalizations.of(context)!;
    if (_method == _AuthMethod.phone) {
      return _phoneStep == _PhoneStep.enterOtp ? l10n.verifyYourNumber : l10n.welcomeExclaim;
    }
    return _titleFor(_step);
  }

  String get _subtitle {
    final l10n = AppLocalizations.of(context)!;
    if (_method == _AuthMethod.phone) {
      return _phoneStep == _PhoneStep.enterOtp
          ? l10n.weveSentCodeToPhone(_phoneController.text.trim())
          : l10n.logInOrSignUpWithMobile;
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

  String _titleFor(_Step step) {
    final l10n = AppLocalizations.of(context)!;
    return switch (step) {
      _Step.login => l10n.welcomeBack,
      _Step.register => l10n.createAccount,
      _Step.verifyEmail => l10n.verifyYourEmail,
    };
  }

  String _subtitleFor(_Step step) {
    final l10n = AppLocalizations.of(context)!;
    return switch (step) {
      _Step.login => l10n.logInWithEmailToContinue,
      _Step.register => l10n.signUpWithEmailToGetStarted,
      _Step.verifyEmail => l10n.weveSentVerificationLinkTo(_emailController.text.trim()),
    };
  }

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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _emailController,
          hintText: l10n.emailAddress,
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _passwordController,
          hintText: l10n.password,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            child: Text(l10n.forgotPassword, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.primary)),
          ),
        ),
        const SizedBox(height: 12),
        _buildPrimaryButton(l10n.logIn, _login),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _step = _Step.register;
              _error = null;
            }),
            child: Text(l10n.dontHaveAccountSignUp, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodToggle() {
    final l10n = AppLocalizations.of(context)!;
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
      child: Row(children: [tab(l10n.emailMethod, _AuthMethod.email), tab(l10n.phoneMethod, _AuthMethod.phone)]),
    );
  }

  Widget _buildPhoneStep() {
    final l10n = AppLocalizations.of(context)!;
    if (_phoneStep == _PhoneStep.enterOtp) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _phoneOtpController,
            hintText: l10n.sixDigitCode,
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofillHints: const [AutofillHints.oneTimeCode],
          ),
          const SizedBox(height: 16),
          _buildPrimaryButton(l10n.verifyAndContinue, _verifyPhoneOtp),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _resendSecondsLeft > 0 ? null : _sendPhoneOtp,
              child: Text(
                _resendSecondsLeft > 0 ? l10n.resendCodeInSeconds(_resendSecondsLeft) : l10n.resendCode,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
              ),
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
          hintText: l10n.tenDigitMobileNumber,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          maxLength: 10,
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(l10n.sendOtp, _sendPhoneOtp),
      ],
    );
  }

  Widget _buildRegisterStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _emailController,
          hintText: l10n.emailAddress,
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _passwordController,
          hintText: l10n.passwordMinCharsHint,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: l10n.confirmPassword,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(l10n.signUp, _register),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _step = _Step.login;
              _error = null;
            }),
            child: Text(l10n.alreadyHaveAccountLogIn, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyEmailStep() {
    final l10n = AppLocalizations.of(context)!;
    if (_useOtpEntry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_otpSent) ...[
            _buildPrimaryButton(l10n.sendCode, _sendOtp),
          ] else ...[
            CustomTextField(
              controller: _otpController,
              hintText: l10n.sixDigitCode,
              prefixIcon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofillHints: const [AutofillHints.oneTimeCode],
            ),
            const SizedBox(height: 16),
            _buildPrimaryButton(l10n.verifyCode, _verifyOtp),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _resendSecondsLeft > 0 ? null : _sendOtp,
                child: Text(
                  _resendSecondsLeft > 0 ? l10n.resendCodeInSeconds(_resendSecondsLeft) : l10n.resendCode,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
                ),
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
              child: Text(l10n.useLinkInstead, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPrimaryButton(l10n.iveVerifiedMyEmail, _checkVerifiedAndContinue),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _resendVerification,
            child: Text(
              _resendSent ? l10n.verificationEmailSentAgain : l10n.resendVerificationEmail,
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
            child: Text(l10n.enterCodeInstead, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
          ),
        ),
      ],
    );
  }
}

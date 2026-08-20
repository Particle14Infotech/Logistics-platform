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
import '../../providers/selected_role_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_text_field.dart';

enum _Step { login, register, verifyEmail, personalDetails }
enum _AuthMethod { email, phone }
enum _PhoneStep { enterNumber, enterOtp }

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

  // Alternative to the emailed link at the verify-email step - the user's
  // choice between either, both stay available.
  bool _useOtpEntry = false;
  bool _otpSent = false;
  final _otpController = TextEditingController();
  DateTime? _dob;
  // Tokens from syncFirebaseSession() for a brand-new user - held here
  // rather than committed via setSession() until the personal-details step
  // completes.
  AuthResult? _pendingAuthResult;

  // Phone/SMS sign-in - a second method alongside email/password, not a
  // replacement (see auth_service.dart's phone auth section). Firebase
  // treats "new phone number" and "phone number that's signed in before"
  // identically (signInWithCredential creates the account if needed), so
  // unlike the email method there's no separate login/register step here -
  // _syncSessionAndContinue()'s existing isNewUser branch into
  // personalDetails already covers a brand-new phone signup too.
  // Deliberately reuses _phoneController (already declared above for the
  // personalDetails step) rather than a second one - the number entered to
  // request an OTP is the same number personalDetails would otherwise ask
  // for again, so it arrives there pre-filled instead of asked for twice.
  _AuthMethod _method = _AuthMethod.email;
  _PhoneStep _phoneStep = _PhoneStep.enterNumber;
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
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
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
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: l10n.dateOfBirth,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _submitPersonalDetails() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.enterFullName);
      return;
    }
    if (phone.length < 10) {
      setState(() => _error = l10n.enterValidPhoneNumber10Digit);
      return;
    }
    if (_dob == null) {
      setState(() => _error = l10n.selectYourDob);
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
      setState(() => _error = l10n.couldNotSaveDetailsTryAgain);
    } finally {
      setState(() => _loading = false);
    }
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
  // spacer+method-toggle header the entry screens share.
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
    if (_method == _AuthMethod.phone && _step != _Step.personalDetails) {
      return _phoneStep == _PhoneStep.enterOtp ? l10n.verifyYourNumber : l10n.welcomeExclaim;
    }
    return _titleFor(_step);
  }

  String get _subtitle {
    final l10n = AppLocalizations.of(context)!;
    if (_method == _AuthMethod.phone && _step != _Step.personalDetails) {
      return _phoneStep == _PhoneStep.enterOtp
          ? l10n.weveSentCodeToPhone(_phoneController.text.trim())
          : l10n.logInOrSignUpWithMobile;
    }
    return _subtitleFor(_step);
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
              if (_step == _Step.verifyEmail || _onVerificationStep)
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: _backFromVerification,
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                )
              else
                const SizedBox(height: 44),
              const SizedBox(height: 8),

              Text(
                _title,
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                _subtitle,
                style: GoogleFonts.poppins(fontSize: 15, color: AppTheme.textGrey, height: 1.5),
              ),
              const SizedBox(height: 32),

              if (!_onVerificationStep && _step == _Step.login) _buildMethodToggle(),
              if (!_onVerificationStep && _step == _Step.login) const SizedBox(height: 24),

              if (_method == _AuthMethod.email && _step == _Step.login) _buildLoginStep(),
              if (_method == _AuthMethod.email && _step == _Step.register) _buildRegisterStep(),
              if (_method == _AuthMethod.email && _step == _Step.verifyEmail) _buildVerifyEmailStep(),
              if (_method == _AuthMethod.phone && _step == _Step.login) _buildPhoneStep(),
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

  String _titleFor(_Step step) {
    final l10n = AppLocalizations.of(context)!;
    return switch (step) {
      _Step.login => l10n.welcomeBack,
      _Step.register => l10n.createAccount,
      _Step.verifyEmail => l10n.verifyYourEmail,
      _Step.personalDetails => l10n.tellUsAboutYourself,
    };
  }

  String _subtitleFor(_Step step) {
    final l10n = AppLocalizations.of(context)!;
    return switch (step) {
      _Step.login => l10n.logInWithEmailToContinue,
      _Step.register => l10n.signUpWithEmailToGetStarted,
      _Step.verifyEmail => l10n.weveSentVerificationLinkTo(_emailController.text.trim()),
      _Step.personalDetails => l10n.thisHelpsCustomersSupportIdentifyYou,
    };
  }

  Widget _buildLoginStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          label: l10n.emailLabel,
          hint: l10n.emailExampleHint,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: l10n.passwordLabel,
          hint: l10n.yourPasswordHint,
          controller: _passwordController,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            child: Text(l10n.forgotPassword, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.amber)),
          ),
        ),
        const SizedBox(height: 8),
        AuthButton(label: l10n.logIn, onPressed: _login, isLoading: _loading),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _step = _Step.register;
              _error = null;
            }),
            child: Text(l10n.dontHaveAccountSignUp, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey)),
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
              color: selected ? AppTheme.amber : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? AppTheme.textDark : AppTheme.textGrey,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppTheme.cardWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
      child: Row(children: [tab(l10n.emailMethod, _AuthMethod.email), tab(l10n.phoneMethod, _AuthMethod.phone)]),
    );
  }

  Widget _buildPhoneStep() {
    final l10n = AppLocalizations.of(context)!;
    if (_phoneStep == _PhoneStep.enterOtp) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: l10n.verificationCode,
            hint: l10n.sixDigitCodeHint,
            controller: _phoneOtpController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.pin_outlined,
            maxLength: 6,
            autofillHints: const [AutofillHints.oneTimeCode],
          ),
          const SizedBox(height: 16),
          AuthButton(label: l10n.verifyAndContinue, onPressed: _verifyPhoneOtp, isLoading: _loading),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _resendSecondsLeft > 0 ? null : _sendPhoneOtp,
              child: Text(
                _resendSecondsLeft > 0 ? l10n.resendCodeInSeconds(_resendSecondsLeft) : l10n.resendCode,
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          label: l10n.phoneNumberLabel,
          hint: l10n.phoneNumberSampleHint,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          maxLength: 10,
        ),
        const SizedBox(height: 24),
        AuthButton(label: l10n.sendOtp, onPressed: _sendPhoneOtp, isLoading: _loading),
      ],
    );
  }

  Widget _buildRegisterStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          label: l10n.emailLabel,
          hint: l10n.emailExampleHint,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: l10n.passwordLabel,
          hint: l10n.min6CharsHintPassword,
          controller: _passwordController,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: l10n.confirmPasswordLabel,
          hint: l10n.reEnterPasswordHint,
          controller: _confirmPasswordController,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 24),
        AuthButton(label: l10n.signUp, onPressed: _register, isLoading: _loading),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _step = _Step.login;
              _error = null;
            }),
            child: Text(l10n.alreadyHaveAccountLogIn, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey)),
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
            AuthButton(label: l10n.sendCode, onPressed: _sendOtp, isLoading: _loading),
          ] else ...[
            AuthTextField(
              label: l10n.verificationCode,
              hint: l10n.sixDigitCodeHint,
              controller: _otpController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.pin_outlined,
              maxLength: 6,
              autofillHints: const [AutofillHints.oneTimeCode],
            ),
            const SizedBox(height: 16),
            AuthButton(label: l10n.verifyCode, onPressed: _verifyOtp, isLoading: _loading),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _resendSecondsLeft > 0 ? null : _sendOtp,
                child: Text(
                  _resendSecondsLeft > 0 ? l10n.resendCodeInSeconds(_resendSecondsLeft) : l10n.resendCode,
                  style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey),
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
              child: Text(l10n.useLinkInstead, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey)),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthButton(label: l10n.iveVerifiedMyEmail, onPressed: _checkVerifiedAndContinue, isLoading: _loading),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _resendVerification,
            child: Text(
              _resendSent ? l10n.verificationEmailSentAgain : l10n.resendVerificationEmail,
              style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey),
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
            child: Text(l10n.enterCodeInstead, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey)),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDetailsStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          label: l10n.fullNameLabel,
          hint: l10n.yourNameHint,
          controller: _nameController,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: l10n.phoneNumberLabel,
          hint: l10n.phoneNumberSampleHint,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          maxLength: 10,
        ),
        const SizedBox(height: 16),
        Text(l10n.dateOfBirth, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
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
                      ? l10n.selectYourDateOfBirth
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
        AuthButton(label: l10n.continueLabel, onPressed: _submitPersonalDetails, isLoading: _loading),
      ],
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/feature_item.dart';

enum _Step { phone, otp, name }

// OTP-based login with auto-resend countdown (SRS 3.1.2).
// UI layout matches the reference RaahMitr customer app's login_screen.dart:
// big bold "Welcome Back!" heading, plain background, pill text field,
// solid purple button, feature-icon row.
class OtpLoginScreen extends ConsumerStatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  ConsumerState<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends ConsumerState<OtpLoginScreen> {
  final _authService = AuthService();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();

  _Step _step = _Step.phone;
  bool _loading = false;
  String? _error;
  Timer? _resendTimer;
  int _resendSeconds = 0;
  String? _pendingUserId;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() => _error = 'Enter a valid 10-digit phone number.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.sendOtp(phone);
      setState(() => _step = _Step.otp);
      _startResendTimer();
    } catch (e) {
      setState(() => _error = 'Could not send OTP. Check your connection and try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _authService.verifyOtp(_phoneController.text.trim(), otp);
      if (result.isNewUser) {
        // Don't call setSession() here - it updates global auth state, which
        // the router watches, and would immediately redirect to /home
        // (since 'logged in + on an auth route' triggers a redirect) before
        // this person ever reaches the name step below - meaning they'd
        // land on Home having never actually set their name.
        // completeProfile() below is what finally calls setSession().
        _pendingUserId = result.user.id;
        setState(() => _step = _Step.name);
      } else {
        await ref.read(authProvider.notifier).setSession(
              accessToken: result.accessToken,
              refreshToken: result.refreshToken,
              user: result.user,
            );
        if (mounted) context.go('/home');
      }
    } catch (e) {
      setState(() => _error = 'Invalid or expired code. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _completeProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter your name to continue.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _authService.completeProfile(userId: _pendingUserId!, name: name);
      await ref.read(authProvider.notifier).setSession(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            user: result.user,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = 'Could not save your name. Try again.');
    } finally {
      setState(() => _loading = false);
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
              if (_step != _Step.phone)
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _step = _Step.phone),
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                )
              else ...[
                const SizedBox(height: 24),
                Image.asset('assets/images/logo.png', width: 90, height: 90, fit: BoxFit.contain),
                const SizedBox(height: 16),
              ],
              Text(
                _titleFor(_step),
                style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700, color: AppTheme.textDark),
              ),
              const SizedBox(height: 12),
              Text(
                _subtitleFor(_step),
                style: GoogleFonts.poppins(fontSize: 18, height: 1.5, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 40),

              if (_step == _Step.phone) _buildPhoneStep(),
              if (_step == _Step.otp) _buildOtpStep(),
              if (_step == _Step.name) _buildNameStep(),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: GoogleFonts.poppins(color: AppTheme.primary.withOpacity(0.9), fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _titleFor(_Step step) => switch (step) {
        _Step.phone => 'Welcome Back!',
        _Step.otp => 'Verify your number',
        _Step.name => 'What should we call you?',
      };

  String _subtitleFor(_Step step) => switch (step) {
        _Step.phone => 'Login to continue your\nshipping journey',
        _Step.otp => 'Enter the 6-digit code sent to\n+91 ${_phoneController.text}',
        _Step.name => 'This is how drivers and support\nwill address you.',
      };

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 62,
      width: double.infinity,
      child: FilledButton(
        onPressed: _loading ? null : onPressed,
        style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
        child: _loading
            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(controller: _phoneController, hintText: 'Phone Number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, maxLength: 10),
        const SizedBox(height: 35),
        _buildPrimaryButton('Send OTP', _sendOtp),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FeatureItem(icon: Icons.shield_outlined, text: 'Secure & Safe'),
            FeatureItem(icon: Icons.inventory_2_outlined, text: 'Fast Delivery'),
            FeatureItem(icon: Icons.support_agent_outlined, text: '24/7 Support'),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(controller: _otpController, hintText: '6-digit code', prefixIcon: Icons.lock_outline, keyboardType: TextInputType.number, maxLength: 6),
        const SizedBox(height: 35),
        _buildPrimaryButton('Verify & Continue', _verifyOtp),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _resendSeconds > 0 ? null : _sendOtp,
            child: Text(
              _resendSeconds > 0 ? 'Resend code in ${_resendSeconds}s' : 'Resend code',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(controller: _nameController, hintText: 'Full name', prefixIcon: Icons.person_outline),
        const SizedBox(height: 35),
        _buildPrimaryButton('Continue', _completeProfile),
      ],
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/selected_role_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/otp_box_input.dart';
import '../../widgets/numeric_keypad.dart';

enum _Step { phone, otp, name }

// OTP login + verification/approval status tracking (SRS 3.2.2).
// Matches the provided reference design: plain background, boxed-digit
// OTP display driven by a custom on-screen keypad instead of the system
// keyboard, and styled (non-functional) social sign-in buttons.
//
// Two deliberate departures from a literal copy:
// - Google/Apple buttons are visual only - wired to a 'not available yet'
//   message rather than faking real OAuth, which needs credentials/setup
//   we don't have (same situation as Maps/Firebase elsewhere).
// - Shows 6 OTP boxes, not 4 - the backend generates 6-digit codes and
//   that's already tested extensively; shrank the visual box count to
//   match backend reality rather than shrinking OTP entropy to match a
//   screenshot.
class OtpLoginScreen extends ConsumerStatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  ConsumerState<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends ConsumerState<OtpLoginScreen> {
  final _authService = AuthService();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  String _otp = '';

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
      setState(() {
        _step = _Step.otp;
        _otp = '';
      });
      _startResendTimer();
    } catch (e) {
      setState(() => _error = 'Could not send OTP. Check your connection and try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _authService.verifyOtp(_phoneController.text.trim(), _otp);
      if (result.isNewUser) {
        // Don't call setSession() here - it updates global auth state, which
        // the router watches, and would redirect away from this screen
        // before the name step below (which actually calls /auth/register)
        // ever runs. completeProfile() is what finally calls setSession().
        _pendingUserId = result.user.id;
        setState(() => _step = _Step.name);
      } else {
        await ref.read(authProvider.notifier).setSession(
              accessToken: result.accessToken,
              refreshToken: result.refreshToken,
              user: result.user,
            );
        if (mounted) context.go('/splash');
      }
    } catch (e) {
      setState(() => _error = 'Invalid or expired code. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onKeypadDigit(String digit) {
    if (_otp.length >= 6) return;
    setState(() {
      _otp += digit;
      _error = null;
    });
    if (_otp.length == 6) _verifyOtp();
  }

  void _onKeypadBackspace() {
    if (_otp.isEmpty) return;
    setState(() => _otp = _otp.substring(0, _otp.length - 1));
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
      final role = ref.read(selectedRoleProvider);
      final result = await _authService.completeProfile(userId: _pendingUserId!, name: name, role: role);
      await ref.read(authProvider.notifier).setSession(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            user: result.user,
          );
      if (mounted) context.go('/splash');
    } catch (e) {
      setState(() => _error = 'Could not save your name. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showNotAvailable(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in is not available yet - use your phone number for now.')),
    );
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
              if (_step != _Step.phone)
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _step = _Step.phone),
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

              if (_step == _Step.phone) _buildPhoneStep(),
              if (_step == _Step.otp) _buildOtpStep(),
              if (_step == _Step.name) _buildNameStep(),

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
        _Step.phone => 'Welcome Back!',
        _Step.otp => 'Verify OTP',
        _Step.name => 'What should we call you?',
      };

  String _subtitleFor(_Step step) => switch (step) {
        _Step.phone => 'Enter your mobile number to continue',
        _Step.otp => 'Enter the 6-digit code sent to\n+91 ${_phoneController.text}',
        _Step.name => 'This is how customers and support will address you.',
      };

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Single rounded field: flag + country code + number, matching the
        // reference design. Country is fixed to India (+91) - not a real
        // interactive picker, since the rest of this platform (backend OTP
        // format, seed data, etc.) assumes Indian 10-digit numbers throughout.
        Container(
          height: 58,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderColor)),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Text('🇮🇳', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text('+91', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
              const SizedBox(width: 8),
              Container(width: 1, height: 24, color: AppTheme.borderColor),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: GoogleFonts.poppins(fontSize: 15, color: AppTheme.textDark),
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    hintText: '98765 43210',
                    hintStyle: GoogleFonts.poppins(color: AppTheme.textGrey),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AuthButton(label: 'Send OTP', onPressed: _sendOtp, isLoading: _loading),
        const SizedBox(height: 28),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Or continue with', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textGrey)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _SocialButton(label: 'Google', icon: Icons.g_mobiledata, onTap: () => _showNotAvailable('Google'))),
            const SizedBox(width: 12),
            Expanded(child: _SocialButton(label: 'Apple', icon: Icons.apple, onTap: () => _showNotAvailable('Apple'))),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OtpBoxInput(value: _otp),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _resendSeconds > 0 ? null : _sendOtp,
            child: Text(
              _resendSeconds > 0 ? 'Resend OTP in ${_resendSeconds.toString().padLeft(2, '0')}s' : 'Resend OTP',
              style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
        else
          NumericKeypad(onDigit: _onKeypadDigit, onBackspace: _onKeypadBackspace),
      ],
    );
  }

  Widget _buildNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(label: 'Full name', hint: 'Your name', controller: _nameController, prefixIcon: Icons.person_outline),
        const SizedBox(height: 32),
        AuthButton(label: 'Continue', onPressed: _completeProfile, isLoading: _loading),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppTheme.borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, color: AppTheme.textDark, size: 20),
      label: Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
    );
  }
}

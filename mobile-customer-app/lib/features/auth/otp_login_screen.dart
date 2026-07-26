import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

enum _Step { phone, otp, name }

// OTP-based login with auto-resend countdown (SRS 3.1.2).
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
  String? _pendingUserId; // set after OTP verify if this is a brand-new user

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
        _pendingUserId = result.user.id;
        // Stash tokens now so completeProfile's authenticated request works,
        // but don't mark auth "complete" in the UI until name is set.
        await ref.read(authProvider.notifier).setSession(
              accessToken: result.accessToken,
              refreshToken: result.refreshToken,
              user: result.user,
            );
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
      final user = await _authService.completeProfile(userId: _pendingUserId!, name: name);
      final current = ref.read(authProvider);
      await ref.read(authProvider.notifier).setSession(
            accessToken: current.accessToken!,
            refreshToken: current.refreshToken!,
            user: user,
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
      appBar: AppBar(
        leading: _step != _Step.phone
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _step = _Step.phone))
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_titleFor(_step), style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(_subtitleFor(_step), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              if (_step == _Step.phone) _buildPhoneStep(),
              if (_step == _Step.otp) _buildOtpStep(),
              if (_step == _Step.name) _buildNameStep(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _titleFor(_Step step) => switch (step) {
        _Step.phone => 'Enter your phone number',
        _Step.otp => 'Verify your number',
        _Step.name => 'What should we call you?',
      };

  String _subtitleFor(_Step step) => switch (step) {
        _Step.phone => "We'll send a one-time code to verify it's you.",
        _Step.otp => 'Enter the 6-digit code sent to +91 ${_phoneController.text}',
        _Step.name => 'This is how drivers and support will address you.',
      };

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(prefixText: '+91  ', labelText: 'Phone number', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loading ? null : _sendOtp,
          child: _loading ? const _ButtonSpinner() : const Text('Send OTP'),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(labelText: '6-digit code', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loading ? null : _verifyOtp,
          child: _loading ? const _ButtonSpinner() : const Text('Verify & continue'),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _resendSeconds > 0 ? null : _sendOtp,
            child: Text(_resendSeconds > 0 ? 'Resend code in ${_resendSeconds}s' : 'Resend code'),
          ),
        ),
      ],
    );
  }

  Widget _buildNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loading ? null : _completeProfile,
          child: _loading ? const _ButtonSpinner() : const Text('Continue'),
        ),
      ],
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}

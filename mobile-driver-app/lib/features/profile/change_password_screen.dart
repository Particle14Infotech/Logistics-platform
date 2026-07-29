import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_text_field.dart';

// Only reachable for accounts signed in via Firebase email/password - the
// Firebase SDK owns the credential, so this posts nothing to our backend.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _authService = AuthService();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_currentController.text.isEmpty) {
      setState(() => _error = 'Enter your current password.');
      return;
    }
    if (_newController.text.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    if (_newController.text != _confirmController.text) {
      setState(() => _error = 'New passwords do not match.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _authService.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated')),
        );
        Navigator.of(context).pop();
      }
    } on fb.FirebaseAuthException catch (e) {
      setState(() => _error = e.code == 'wrong-password' || e.code == 'invalid-credential'
          ? 'Current password is incorrect.'
          : e.message ?? 'Could not update password.');
    } catch (e) {
      setState(() => _error = 'Could not update password. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                label: 'Current password',
                hint: 'Your current password',
                controller: _currentController,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'New password',
                hint: 'Min 6 characters',
                controller: _newController,
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Confirm new password',
                hint: 'Re-enter new password',
                controller: _confirmController,
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: GoogleFonts.poppins(color: AppTheme.error, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              AuthButton(label: 'Update Password', onPressed: _submit, isLoading: _saving),
            ],
          ),
        ),
      ),
    );
  }
}

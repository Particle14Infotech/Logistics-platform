import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    if (_currentController.text.isEmpty) {
      setState(() => _error = l10n.enterCurrentPassword);
      return;
    }
    if (_newController.text.length < 6) {
      setState(() => _error = l10n.newPasswordMinLength);
      return;
    }
    if (_newController.text != _confirmController.text) {
      setState(() => _error = l10n.newPasswordsDoNotMatch);
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
          SnackBar(content: Text(l10n.passwordUpdated)),
        );
        Navigator.of(context).pop();
      }
    } on fb.FirebaseAuthException catch (e) {
      setState(() => _error = e.code == 'wrong-password' || e.code == 'invalid-credential'
          ? l10n.currentPasswordIncorrect
          : e.message ?? l10n.couldNotUpdatePassword);
    } catch (e) {
      setState(() => _error = l10n.couldNotUpdatePasswordTryAgain);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(title: Text(l10n.changePassword)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                label: l10n.currentPassword,
                hint: l10n.yourCurrentPasswordHint,
                controller: _currentController,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: l10n.newPassword,
                hint: l10n.min6CharsHint,
                controller: _newController,
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: l10n.confirmNewPassword,
                hint: l10n.reEnterNewPasswordHint,
                controller: _confirmController,
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: GoogleFonts.poppins(color: AppTheme.error, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              AuthButton(label: l10n.updatePassword, onPressed: _submit, isLoading: _saving),
            ],
          ),
        ),
      ),
    );
  }
}

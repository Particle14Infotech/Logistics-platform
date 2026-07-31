import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/auth_text_field.dart';

// Feeds Driver.bankDetails - the reference admin uses when manually
// processing a wallet payout (AdminDriverDetailPage.jsx's "Mark as paid
// out" button). No automated bank-transfer integration reads this, it's
// purely the record of where the driver expects payouts to go.
class BankDetailsScreen extends ConsumerStatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  ConsumerState<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends ConsumerState<BankDetailsScreen> {
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _nameController = TextEditingController();
  bool _saving = false;
  bool _initialized = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _accountController.dispose();
    _ifscController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final accountNumber = _accountController.text.trim();
    final ifsc = _ifscController.text.trim();
    final name = _nameController.text.trim();
    if (accountNumber.isEmpty || ifsc.isEmpty || name.isEmpty) {
      setState(() => _error = 'All fields are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _success = null;
    });
    try {
      await ref.read(driverServiceProvider).updateBankDetails(
            accountNumber: accountNumber,
            ifsc: ifsc,
            accountHolderName: name,
          );
      ref.invalidate(driverProfileProvider);
      if (mounted) setState(() => _success = 'Bank details saved.');
    } catch (e) {
      if (mounted)
        setState(() => _error = 'Could not save bank details. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(driverProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(title: const Text('Bank Details')),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) =>
              const Center(child: Text('Could not load your details.')),
          data: (profile) {
            if (profile != null && !_initialized) {
              _accountController.text = profile.bankAccountNumber ?? '';
              _ifscController.text = profile.bankIfsc ?? '';
              _nameController.text = profile.bankAccountHolderName ?? '';
              _initialized = true;
            }
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Used for wallet payouts - make sure this matches your actual bank account.',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppTheme.textGrey),
                ),
                const SizedBox(height: 20),
                AuthTextField(
                    controller: _nameController,
                    label: 'Account holder name',
                    hint: 'As per bank records',
                    prefixIcon: Icons.person_outline),
                const SizedBox(height: 14),
                AuthTextField(
                    controller: _accountController,
                    label: 'Account number',
                    hint: '1234567890',
                    prefixIcon: Icons.account_balance_outlined,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                AuthTextField(
                    controller: _ifscController,
                    label: 'IFSC code',
                    hint: 'ABCD0123456',
                    prefixIcon: Icons.pin_outlined),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: GoogleFonts.poppins(
                          color: AppTheme.error, fontSize: 13)),
                ],
                if (_success != null) ...[
                  const SizedBox(height: 12),
                  Text(_success!,
                      style: GoogleFonts.poppins(
                          color: AppTheme.success, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black87))
                      : const Text('Save'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

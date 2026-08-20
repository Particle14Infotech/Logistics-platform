import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/fleet_provider.dart';

// First-time fleet registration - just a company name, unlike vehicle
// setup this has no KYC/approval gate of its own (individual vehicles
// added afterward each go through the normal driver KYC approval flow).
class FleetSetupScreen extends ConsumerStatefulWidget {
  const FleetSetupScreen({super.key});

  @override
  ConsumerState<FleetSetupScreen> createState() => _FleetSetupScreenState();
}

class _FleetSetupScreenState extends ConsumerState<FleetSetupScreen> {
  final _companyNameController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _companyNameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.enterYourCompanyName);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(fleetServiceProvider).createProfile(name);
      ref.invalidate(fleetProfileProvider);
      if (mounted) context.go('/splash');
    } catch (e) {
      setState(() {
        _error = l10n.couldNotCreateFleetAccountTryAgain;
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.setUpYourFleet)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.whatsYourCompanyCalled),
              const SizedBox(height: 16),
              TextField(
                controller: _companyNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.companyName, border: const OutlineInputBorder()),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                    : Text(l10n.continueLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

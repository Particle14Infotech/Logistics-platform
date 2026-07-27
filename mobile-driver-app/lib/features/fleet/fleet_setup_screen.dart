import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final name = _companyNameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter your company name.');
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
        _error = 'Could not create your fleet account. Try again.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your fleet')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("What's your company called?"),
              const SizedBox(height: 16),
              TextField(
                controller: _companyNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Company name', border: OutlineInputBorder()),
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
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

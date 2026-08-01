import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/vehicle_types.dart';
import '../../providers/fleet_provider.dart';

// Adds a vehicle + its driver under this fleet (SRS 3.2.9-adjacent, fleet
// variant). The driver account either gets created fresh or reuses an
// existing 'driver'-role account matching the phone number - see
// fleet.controller.js's addVehicle for the exact matching rules. The
// resulting Driver record starts unapproved, same KYC review path as an
// independent driver signup.
class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _licenseController = TextEditingController();
  String? _vehicleType;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _vehicleNumberController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_driverNameController.text.trim().isEmpty ||
        _driverPhoneController.text.trim().length < 10 ||
        _vehicleType == null ||
        _vehicleNumberController.text.trim().isEmpty ||
        _licenseController.text.trim().isEmpty) {
      setState(() => _error = 'Fill in all fields with a valid 10-digit phone number.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(fleetServiceProvider).addVehicle(
            driverPhone: _driverPhoneController.text.trim(),
            driverName: _driverNameController.text.trim(),
            vehicleType: _vehicleType!,
            vehicleNumber: _vehicleNumberController.text.trim(),
            licenseNumber: _licenseController.text.trim(),
          );
      if (mounted) {
        // This screen has no camera step of its own - a selfie has to come
        // from the driver's own device/face, not something a fleet owner
        // can submit on their behalf. Previously this just popped silently,
        // leaving the fleet owner with no idea the vehicle wasn't actually
        // done yet.
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Vehicle added'),
            content: Text(
                "${_driverNameController.text.trim()} still needs to sign in on their own phone and complete their KYC selfie before this vehicle can be approved - that step can't be done from here."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
            ],
          ),
        );
        if (mounted) Navigator.of(context).pop(true); // signal caller to refresh the vehicle list
      }
    } catch (e) {
      setState(() => _error = 'Could not add this vehicle. The phone number may already be registered under a different role.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add vehicle')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Driver details', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: _driverNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: "Driver's name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _driverPhoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(labelText: "Driver's phone number", prefixText: '+91 ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text('Vehicle details', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _vehicleType,
              decoration: const InputDecoration(labelText: 'Vehicle type', border: OutlineInputBorder()),
              items: kVehicleTypes.map((v) => DropdownMenuItem(value: v.value, child: Text(v.label))).toList(),
              onChanged: (v) => setState(() => _vehicleType = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vehicleNumberController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Vehicle registration number', hintText: 'e.g. DL 01 AB 1234', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _licenseController,
              decoration: const InputDecoration(labelText: "Driver's license number", border: OutlineInputBorder()),
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
                  : const Text('Add vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}

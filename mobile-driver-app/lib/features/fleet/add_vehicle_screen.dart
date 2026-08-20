import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/fleet_provider.dart';
import '../../widgets/vehicle_category_field.dart';

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
    final l10n = AppLocalizations.of(context)!;
    if (_driverNameController.text.trim().isEmpty ||
        _driverPhoneController.text.trim().length < 10 ||
        _vehicleType == null ||
        _vehicleNumberController.text.trim().isEmpty ||
        _licenseController.text.trim().isEmpty) {
      setState(() => _error = l10n.fillAllFieldsValidPhone);
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
            title: Text(l10n.vehicleAdded),
            content: Text(l10n.driverStillNeedsSelfie(_driverNameController.text.trim())),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.gotIt)),
            ],
          ),
        );
        if (mounted) Navigator.of(context).pop(true); // signal caller to refresh the vehicle list
      }
    } catch (e) {
      setState(() => _error = l10n.couldNotAddVehiclePhoneMayExist);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addVehicle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.driverDetails, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: _driverNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.driversName, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _driverPhoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(labelText: l10n.driversPhoneNumber, prefixText: '+91 ', border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Text(l10n.vehicleDetails, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            VehicleCategoryField(
              value: _vehicleType,
              onChanged: (v) => setState(() => _vehicleType = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vehicleNumberController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: l10n.vehicleRegistrationNumber, hintText: l10n.vehicleRegistrationNumberHint, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _licenseController,
              decoration: InputDecoration(labelText: l10n.driversLicenseNumber, border: const OutlineInputBorder()),
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
                  : Text(l10n.addVehicle),
            ),
          ],
        ),
      ),
    );
  }
}

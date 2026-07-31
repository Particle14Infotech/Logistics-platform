import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/vehicle_types.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';

enum _SetupStep { vehicleDetails, selfie }

// First-time vehicle registration (SRS 3.2.9 Vehicle Management, onboarding
// portion), now followed by a selfie capture step for face-verification KYC.
// Submitting vehicle details creates the Driver record in 'pending approval'
// state - it shows up in the Admin > Drivers queue for KYC review, and the
// selfie becomes part of that same review (Driver.documents.photoUrl).
class VehicleSetupScreen extends ConsumerStatefulWidget {
  const VehicleSetupScreen({super.key});

  @override
  ConsumerState<VehicleSetupScreen> createState() => _VehicleSetupScreenState();
}

class _VehicleSetupScreenState extends ConsumerState<VehicleSetupScreen> {
  _SetupStep _step = _SetupStep.vehicleDetails;

  String? _vehicleType;
  final _vehicleNumberController = TextEditingController();
  final _licenseController = TextEditingController();
  final _enterpriseCodeController = TextEditingController();
  bool _submitting = false;
  String? _error;
  bool _roleConflict = false;

  File? _selfieFile;
  bool _uploadingSelfie = false;

  @override
  void initState() {
    super.initState();
    // A Driver profile can already exist with no selfie yet - e.g. a fleet
    // owner created it directly via AddVehicleScreen (no selfie step in
    // that flow at all). The vehicle-details form below requires non-empty
    // fields to submit, so without this check that driver would be stuck:
    // routed here by app_router.dart, but unable to reach the selfie step
    // since they can't (and shouldn't need to) re-enter vehicle details
    // that already exist.
    final profile = ref.read(driverProfileProvider).valueOrNull;
    if (profile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _step = _SetupStep.selfie);
      });
    }
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _licenseController.dispose();
    _enterpriseCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitVehicleDetails() async {
    if (_vehicleType == null || _vehicleNumberController.text.trim().isEmpty || _licenseController.text.trim().isEmpty) {
      setState(() => _error = 'Fill in all fields.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(driverServiceProvider).createProfile(
            vehicleType: _vehicleType!,
            vehicleNumber: _vehicleNumberController.text.trim(),
            licenseNumber: _licenseController.text.trim(),
            enterpriseInviteCode: _enterpriseCodeController.text.trim(),
          );
      setState(() => _step = _SetupStep.selfie);
    } on DioException catch (e) {
      final serverMessage = e.response?.data is Map ? e.response?.data['message'] as String? : null;
      if (e.response?.statusCode == 403) {
        setState(() {
          _roleConflict = true;
          _error = 'This phone number is already registered under a different role (e.g. as a customer). '
              'Sign out and use a different phone number to sign up as a driver.';
        });
      } else if (e.response?.statusCode == 400 && (serverMessage?.contains('Invalid enterprise invite code') ?? false)) {
        setState(() {
          _roleConflict = false;
          _error = "That enterprise code isn't valid. Check it with your company, or leave it blank to drive independently.";
        });
      } else if (e.response?.statusCode == 400 && (serverMessage?.contains('already exists') ?? false)) {
        // A profile was already created for this account in an earlier
        // attempt (e.g. the app was backgrounded/killed right after a
        // successful submit, before this screen advanced past this step -
        // its step state is local, not persisted). Treat that as success
        // rather than dead-ending the user on a resubmit that will always
        // 400 from here on.
        setState(() => _step = _SetupStep.selfie);
      } else {
        setState(() {
          _roleConflict = false;
          _error = 'Could not submit your details. Try again.';
        });
      }
    } catch (e) {
      setState(() {
        _roleConflict = false;
        _error = 'Could not submit your details. Try again.';
      });
    } finally {
      setState(() => _submitting = false);
    }
  }

  Future<void> _takeSelfie() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front, imageQuality: 80);
    if (photo != null) setState(() => _selfieFile = File(photo.path));
  }

  Future<void> _uploadAndFinish() async {
    if (_selfieFile == null) {
      setState(() => _error = 'Take a selfie to continue - this is required for identity verification.');
      return;
    }
    setState(() {
      _uploadingSelfie = true;
      _error = null;
    });
    try {
      await ref.read(driverServiceProvider).uploadDocument('photo', _selfieFile!);
      ref.invalidate(driverProfileProvider);
      if (mounted) context.go('/splash');
    } catch (e) {
      setState(() => _error = 'Could not upload your selfie. Try again.');
    } finally {
      if (mounted) setState(() => _uploadingSelfie = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _SetupStep.selfie) return _buildSelfieStep();
    return _buildVehicleDetailsStep();
  }

  Widget _buildVehicleDetailsStep() {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Tell us about your vehicle to get started.'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _vehicleType,
              decoration: const InputDecoration(labelText: 'Vehicle type', border: OutlineInputBorder()),
              items: kVehicleTypes.map((v) => DropdownMenuItem(value: v.value, child: Text(v.label))).toList(),
              onChanged: (v) => setState(() => _vehicleType = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vehicleNumberController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Vehicle registration number', hintText: 'e.g. DL 01 AB 1234', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _licenseController,
              decoration: const InputDecoration(labelText: 'Driving license number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _enterpriseCodeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Enterprise invite code (optional)',
                hintText: 'e.g. ENT-A1B2C3D4 - only if a company gave you one',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              if (_roleConflict) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (mounted) context.go('/role-selection');
                  },
                  child: const Text('Sign out'),
                ),
              ],
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submitVehicleDetails,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfieStep() {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your identity'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Take a clear selfie in good lighting. An admin reviews this alongside your documents before approving your account.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _takeSelfie,
                child: Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    image: _selfieFile != null ? DecorationImage(image: FileImage(_selfieFile!), fit: BoxFit.cover) : null,
                  ),
                  child: _selfieFile == null
                      ? const Icon(Icons.camera_alt, size: 56, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _takeSelfie,
                icon: const Icon(Icons.camera_alt),
                label: Text(_selfieFile == null ? 'Take selfie' : 'Retake'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _uploadingSelfie ? null : _uploadAndFinish,
                child: _uploadingSelfie
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                    : const Text('Submit for approval'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

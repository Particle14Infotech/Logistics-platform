import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/booking_provider.dart';
import '../../providers/vehicle_config_provider.dart';

// Canonical English values - stored on the order/waybill and shown as-is in
// admin/enterprise (English-only) later, so these keys never change with the
// UI locale. Only the on-screen dropdown label is translated (see
// _goodsTypeLabel below).
const _kGoodsTypes = ['General cargo', 'Furniture', 'Electronics', 'Food & groceries', 'Documents', 'Industrial equipment', 'Other'];

String _goodsTypeLabel(String value, AppLocalizations l10n) => switch (value) {
      'General cargo' => l10n.goodsTypeGeneralCargo,
      'Furniture' => l10n.goodsTypeFurniture,
      'Electronics' => l10n.goodsTypeElectronics,
      'Food & groceries' => l10n.goodsTypeFoodGroceries,
      'Documents' => l10n.goodsTypeDocuments,
      'Industrial equipment' => l10n.goodsTypeIndustrialEquipment,
      _ => l10n.goodsTypeOther,
    };

// Step 3 of booking: goods type, weight, fragile/insurance toggles (SRS 3.1.5 Load Details).
class LoadDetailsScreen extends ConsumerStatefulWidget {
  const LoadDetailsScreen({super.key});

  @override
  ConsumerState<LoadDetailsScreen> createState() => _LoadDetailsScreenState();
}

class _LoadDetailsScreenState extends ConsumerState<LoadDetailsScreen> {
  String _goodsType = _kGoodsTypes.first;
  final _weightController = TextEditingController();
  bool _isFragile = false;
  bool _insuranceOpted = false;
  bool _loading = false;
  String? _error;

  bool _showReceiverDetails = false;
  final _consigneeNameController = TextEditingController();
  final _consigneePhoneController = TextEditingController();
  final _consigneeGstinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Kick off the category-catalog fetch now so it's already resolved by
    // the time _getEstimate() reads it below.
    ref.read(vehicleCategoriesProvider);
    final draft = ref.read(bookingDraftProvider);
    if (draft.goodsType.isNotEmpty) _goodsType = draft.goodsType;
    if (draft.weightKg != null) _weightController.text = draft.weightKg!.toStringAsFixed(0);
    _isFragile = draft.isFragile;
    _insuranceOpted = draft.insuranceOpted;

    // Defensive guard: _getEstimate() below force-unwraps pickup/drop/
    // vehicleType - this is the actual crash point if reached with an
    // incomplete draft (browser back/forward, direct URL on web). Redirect
    // to wherever the flow is actually missing a step.
    if (draft.pickup == null || draft.drop == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/booking/locations');
      });
    } else if (draft.vehicleType == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/booking/vehicle');
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _consigneeNameController.dispose();
    _consigneePhoneController.dispose();
    _consigneeGstinController.dispose();
    super.dispose();
  }

  Future<void> _getEstimate() async {
    final l10n = AppLocalizations.of(context)!;
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null || weight <= 0) {
      setState(() => _error = l10n.enterValidWeightKg);
      return;
    }

    final draft = ref.read(bookingDraftProvider);
    final categories = ref.read(vehicleCategoriesProvider).valueOrNull;
    final vehicle = categories?.where((c) => c.vehicleType == draft.vehicleType).firstOrNull;
    if (vehicle != null && weight > vehicle.maxWeightKg) {
      setState(() => _error =
          l10n.vehicleCanCarryUpTo(vehicle.name, '${vehicle.maxWeightKg}'));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final notifier = ref.read(bookingDraftProvider.notifier);
    notifier.setLoadDetails(
      goodsType: _goodsType,
      weightKg: weight,
      isFragile: _isFragile,
      insuranceOpted: _insuranceOpted,
      consigneeName: _consigneeNameController.text.trim(),
      consigneePhone: _consigneePhoneController.text.trim(),
      consigneeGstin: _consigneeGstinController.text.trim(),
    );
    try {
      final estimate = await ref.read(bookingServiceProvider).getEstimate(
            pickup: draft.pickup!,
            drop: draft.drop!,
            vehicleType: draft.vehicleType!,
            weightKg: weight,
          );
      notifier.setEstimate(estimate);
      // push, not pushReplacement - see locations_screen.dart's _continue().
      if (mounted) context.push('/booking/estimate');
    } catch (e) {
      setState(() => _error = l10n.couldNotGetFareEstimateTryAgain);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.loadDetails)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _goodsType,
              decoration: InputDecoration(labelText: l10n.goodsType, border: const OutlineInputBorder()),
              items: _kGoodsTypes.map((g) => DropdownMenuItem(value: g, child: Text(_goodsTypeLabel(g, l10n)))).toList(),
              onChanged: (v) => setState(() => _goodsType = v ?? _goodsType),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.weightKgFieldLabel, border: const OutlineInputBorder(), suffixText: 'kg'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(l10n.fragile),
              subtitle: Text(l10n.fragileSubtitle),
              value: _isFragile,
              onChanged: (v) => setState(() => _isFragile = v),
            ),
            SwitchListTile(
              title: Text(l10n.addInsurance),
              subtitle: Text(l10n.addInsuranceSubtitle),
              value: _insuranceOpted,
              onChanged: (v) => setState(() => _insuranceOpted = v),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(l10n.receiverDetails),
              subtitle: Text(l10n.receiverDetailsSubtitle),
              value: _showReceiverDetails,
              onChanged: (v) => setState(() => _showReceiverDetails = v),
            ),
            if (_showReceiverDetails) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _consigneeNameController,
                decoration: InputDecoration(labelText: l10n.receiversName, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _consigneePhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.receiversPhone, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _consigneeGstinController,
                decoration: InputDecoration(labelText: l10n.receiversGstinOptional, border: const OutlineInputBorder()),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _getEstimate,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(l10n.getFareEstimate),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/booking_provider.dart';

const _kGoodsTypes = ['General cargo', 'Furniture', 'Electronics', 'Food & groceries', 'Documents', 'Industrial equipment', 'Other'];

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

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  Future<void> _getEstimate() async {
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null || weight <= 0) {
      setState(() => _error = 'Enter a valid weight in kg.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final notifier = ref.read(bookingDraftProvider.notifier);
    notifier.setLoadDetails(goodsType: _goodsType, weightKg: weight, isFragile: _isFragile, insuranceOpted: _insuranceOpted);

    final draft = ref.read(bookingDraftProvider);
    try {
      final estimate = await ref.read(bookingServiceProvider).getEstimate(
            pickup: draft.pickup!,
            drop: draft.drop!,
            vehicleType: draft.vehicleType!,
            weightKg: weight,
          );
      notifier.setEstimate(estimate);
      if (mounted) context.push('/booking/estimate');
    } catch (e) {
      setState(() => _error = 'Could not get a fare estimate. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Load details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _goodsType,
              decoration: const InputDecoration(labelText: 'Goods type', border: OutlineInputBorder()),
              items: _kGoodsTypes.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _goodsType = v ?? _goodsType),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder(), suffixText: 'kg'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Fragile'),
              subtitle: const Text('Extra care during handling'),
              value: _isFragile,
              onChanged: (v) => setState(() => _isFragile = v),
            ),
            SwitchListTile(
              title: const Text('Add insurance'),
              subtitle: const Text('Covers loss or damage in transit'),
              value: _insuranceOpted,
              onChanged: (v) => setState(() => _insuranceOpted = v),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _getEstimate,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Get fare estimate'),
            ),
          ],
        ),
      ),
    );
  }
}

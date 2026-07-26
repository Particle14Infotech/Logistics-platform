import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/booking_provider.dart';

// Step 4 of booking: fare breakdown + confirm (SRS 3.1.7 Fare Estimation).
class FareEstimateScreen extends ConsumerStatefulWidget {
  const FareEstimateScreen({super.key});

  @override
  ConsumerState<FareEstimateScreen> createState() => _FareEstimateScreenState();
}

class _FareEstimateScreenState extends ConsumerState<FareEstimateScreen> {
  bool _confirming = false;
  String? _error;

  Future<void> _confirmBooking() async {
    final draft = ref.read(bookingDraftProvider);
    if (draft.estimate == null) return;

    setState(() {
      _confirming = true;
      _error = null;
    });

    try {
      final order = await ref.read(bookingServiceProvider).createBooking(
            pickup: draft.pickup!,
            drop: draft.drop!,
            vehicleType: draft.vehicleType!,
            goodsType: draft.goodsType,
            weightKg: draft.weightKg,
            isFragile: draft.isFragile,
            insuranceOpted: draft.insuranceOpted,
            distanceKm: draft.estimate!.distanceKm,
          );
      ref.read(bookingDraftProvider.notifier).reset();
      if (mounted) context.go('/booking/confirmation/${order.id}');
    } catch (e) {
      setState(() => _error = 'Could not confirm this booking. Try again.');
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final estimate = draft.estimate;

    if (estimate == null) {
      return const Scaffold(body: Center(child: Text('No estimate available.')));
    }

    final breakdown = estimate.breakdown;

    return Scaffold(
      appBar: AppBar(title: const Text('Fare estimate')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _RouteRow(icon: Icons.trip_origin, color: Colors.green, label: draft.pickup!.address),
                          const Padding(
                            padding: EdgeInsets.only(left: 11),
                            child: SizedBox(height: 20, child: VerticalDivider(thickness: 2)),
                          ),
                          _RouteRow(icon: Icons.location_on, color: Colors.red, label: draft.drop!.address),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fare breakdown', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _FareRow(label: 'Base fare', value: breakdown['baseFare']),
                          _FareRow(label: 'Distance charge (${estimate.distanceKm} km)', value: breakdown['distanceCharge']),
                          if ((breakdown['weightCharge'] as num? ?? 0) > 0)
                            _FareRow(label: 'Weight charge', value: breakdown['weightCharge']),
                          if (breakdown['surgeApplied'] == true)
                            _FareRow(label: 'Surge (${breakdown['surgeMultiplier']}x)', value: null, highlight: true),
                          const Divider(height: 24),
                          _FareRow(label: 'Total', value: estimate.estimatedPrice, isTotal: true),
                        ],
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _confirming ? null : _confirmBooking,
                  child: _confirming
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Confirm booking · ₹${estimate.estimatedPrice}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _RouteRow({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ],
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final num? value;
  final bool isTotal;
  final bool highlight;
  const _FareRow({required this.label, required this.value, this.isTotal = false, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        : TextStyle(color: highlight ? Colors.orange.shade800 : null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          if (value != null) Text('₹$value', style: style),
        ],
      ),
    );
  }
}

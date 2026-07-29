import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/booking_provider.dart';

// Step 4 of booking: fare breakdown + confirm (SRS 3.1.7 Fare Estimation).
// Matches the reference design's 'Price Summary' screen: order info rows
// (Vehicle/Distance/Goods Type/Weight) followed by the fare breakdown.
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
      if (mounted) context.pushReplacement('/booking/confirmation/${order.id}');
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
      return Scaffold(
        appBar: AppBar(title: const Text('Price Summary')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No estimate found for this booking.', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => context.go('/booking/locations'), child: const Text('Start a new booking')),
              ],
            ),
          ),
        ),
      );
    }

    final breakdown = estimate.breakdown;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Price Summary')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(label: 'Vehicle', value: draft.vehicleType?.replaceAll('_', ' ') ?? '—'),
                        _DetailRow(label: 'Distance', value: '${estimate.distanceKm} km'),
                        if (draft.goodsType.isNotEmpty) _DetailRow(label: 'Goods Type', value: draft.goodsType),
                        if (draft.weightKg != null) _DetailRow(label: 'Weight', value: '${draft.weightKg} kg'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fare Breakdown', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 12),
                        _FareRow(label: 'Base Fare', value: breakdown['baseFare']),
                        _FareRow(label: 'Distance Charge', value: breakdown['distanceCharge']),
                        if ((breakdown['weightCharge'] as num? ?? 0) > 0) _FareRow(label: 'Weight Charge', value: breakdown['weightCharge']),
                        if (breakdown['surgeApplied'] == true) _FareRow(label: 'Surge (${breakdown['surgeMultiplier']}x)', value: null, highlight: true),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                            Text('₹${estimate.estimatedPrice}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: AppTheme.primary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Final amount may vary slightly', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: GoogleFonts.poppins(color: AppTheme.error)),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: _confirming ? null : _confirmBooking,
                    child: _confirming
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Confirm Booking'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppTheme.borderColor)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500)),
          Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final num? value;
  final bool highlight;
  const _FareRow({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight ? Colors.orange.shade800 : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: color ?? Colors.grey.shade600)),
          if (value != null) Text('₹$value', style: GoogleFonts.poppins(fontSize: 13, color: color)),
        ],
      ),
    );
  }
}

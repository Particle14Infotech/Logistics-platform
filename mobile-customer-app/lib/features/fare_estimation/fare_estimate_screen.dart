import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/booking_provider.dart';
import '../../providers/vehicle_config_provider.dart';

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
  String _paymentMethod = 'online';

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
            paymentMethod: _paymentMethod,
            consigneeName: draft.consigneeName,
            consigneePhone: draft.consigneePhone,
            consigneeGstin: draft.consigneeGstin,
          );
      ref.read(bookingDraftProvider.notifier).reset();
      if (mounted) context.pushReplacement('/booking/confirmation/${order.id}');
    } catch (e) {
      setState(() => _error = AppLocalizations.of(context)!.couldNotConfirmBookingTryAgain);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(bookingDraftProvider);
    final estimate = draft.estimate;

    if (estimate == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.priceSummary)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.noEstimateFoundForBooking, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => context.go('/booking/locations'), child: Text(l10n.startNewBooking)),
              ],
            ),
          ),
        ),
      );
    }

    final breakdown = estimate.breakdown;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(l10n.priceSummary)),
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
                        _DetailRow(
                            label: l10n.vehicleLabel,
                            value: ref
                                    .watch(vehicleCategoriesProvider)
                                    .valueOrNull
                                    ?.where((c) => c.vehicleType == draft.vehicleType)
                                    .firstOrNull
                                    ?.displayTitle ??
                                draft.vehicleType?.replaceAll('_', ' ') ??
                                '—'),
                        _DetailRow(label: l10n.distanceLabel, value: '${estimate.distanceKm} km'),
                        if (draft.goodsType.isNotEmpty) _DetailRow(label: l10n.goodsType, value: draft.goodsType),
                        if (draft.weightKg != null) _DetailRow(label: l10n.weightLabel, value: '${draft.weightKg} kg'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.fareBreakdown, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 12),
                        _FareRow(label: l10n.baseFare, value: breakdown['baseFare']),
                        _FareRow(label: l10n.distanceCharge, value: breakdown['distanceCharge']),
                        if ((breakdown['weightCharge'] as num? ?? 0) > 0) _FareRow(label: l10n.weightCharge, value: breakdown['weightCharge']),
                        if (breakdown['surgeApplied'] == true) _FareRow(label: l10n.surgeMultiplierLabel('${breakdown['surgeMultiplier']}'), value: null, highlight: true),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.totalAmount, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                            Text('₹${estimate.estimatedPrice}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: AppTheme.primary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(l10n.finalAmountMayVarySlightly, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PaymentMethodCard(
                    selected: _paymentMethod,
                    price: estimate.estimatedPrice,
                    advanceAmount: estimate.advanceAmount,
                    onChanged: (value) => setState(() => _paymentMethod = value),
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
                        : Text(l10n.confirmBooking),
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

class _PaymentMethodCard extends StatelessWidget {
  final String selected;
  final num price;
  // Real, server-computed value from /booking/estimate (see
  // pricingRules.calculateAdvanceAmount) - reflects whatever the admin has
  // currently configured for this vehicle type, 0 if no advance applies.
  final num advanceAmount;
  final ValueChanged<String> onChanged;
  const _PaymentMethodCard({required this.selected, required this.price, required this.advanceAmount, required this.onChanged});

  bool get _requiresAdvance => advanceAmount > 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final remaining = price - advanceAmount;
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.paymentMethod, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          _PaymentOptionTile(
            title: l10n.payOnline,
            subtitle: _requiresAdvance
                ? l10n.payOnlineAdvanceSubtitle('$advanceAmount', '$remaining')
                : l10n.payOnlineFullSubtitle,
            icon: Icons.credit_card_outlined,
            value: 'online',
            groupValue: selected,
            onTap: () => onChanged('online'),
          ),
          const SizedBox(height: 8),
          _PaymentOptionTile(
            title: l10n.cashOnDelivery,
            subtitle: _requiresAdvance
                ? l10n.codAdvanceSubtitle('$advanceAmount', '$remaining')
                : l10n.codFullSubtitle,
            icon: Icons.payments_outlined,
            value: 'cod',
            groupValue: selected,
            onTap: () => onChanged('cod'),
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String groupValue;
  final VoidCallback onTap;
  const _PaymentOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.borderColor, width: isSelected ? 1.5 : 1),
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.06) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : Colors.grey.shade500, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? AppTheme.primary : Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

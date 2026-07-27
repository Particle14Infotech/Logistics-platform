import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/vehicle_types.dart';
import '../../providers/booking_provider.dart';

// Step 2 of booking: pick a vehicle category (SRS 3.1.4 Truck Selection).
// Shows an upfront price per vehicle type, matching the reference design -
// calls /booking/estimate once per type (weight omitted, since that isn't
// collected until the next step) so each card shows a real starting price
// rather than a static placeholder. The final confirmed price on the next
// screens still recalculates properly once weight is known.
class VehicleSelectionScreen extends ConsumerStatefulWidget {
  const VehicleSelectionScreen({super.key});

  @override
  ConsumerState<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends ConsumerState<VehicleSelectionScreen> {
  String? _selected;
  final Map<String, num?> _priceByType = {};
  bool _loadingPrices = true;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingDraftProvider);
    _selected = draft.vehicleType;
    if (draft.pickup == null || draft.drop == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/booking/locations');
      });
      return;
    }
    _loadPrices(draft);
  }

  Future<void> _loadPrices(BookingDraft draft) async {
    final service = ref.read(bookingServiceProvider);
    await Future.wait(kVehicleTypes.map((vt) async {
      try {
        final estimate = await service.getEstimate(pickup: draft.pickup!, drop: draft.drop!, vehicleType: vt.value);
        if (mounted) setState(() => _priceByType[vt.value] = estimate.estimatedPrice);
      } catch (_) {
        if (mounted) setState(() => _priceByType[vt.value] = null);
      }
    }));
    if (mounted) setState(() => _loadingPrices = false);
  }

  void _continue() {
    if (_selected == null) return;
    ref.read(bookingDraftProvider.notifier).setVehicleType(_selected!);
    context.push('/booking/details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Select Vehicle')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: kVehicleTypes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final vt = kVehicleTypes[i];
                  final isSelected = _selected == vt.value;
                  final price = _priceByType[vt.value];
                  return Card(
                    elevation: 0,
                    color: isSelected ? AppTheme.primarySurface : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.borderColor)),
                    child: InkWell(
                      onTap: () => setState(() => _selected = vt.value),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(12)),
                              child: Icon(vt.icon, color: AppTheme.primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(vt.label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                                  Text(vt.description, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                            if (_loadingPrices)
                              const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            else
                              Text(price != null ? '₹$price' : '—', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(width: 8),
                            Radio<String>(value: vt.value, groupValue: _selected, onChanged: (v) => setState(() => _selected = v), activeColor: AppTheme.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selected == null ? null : _continue,
                  child: const Text('Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

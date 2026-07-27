import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/vehicle_types.dart';
import '../../providers/booking_provider.dart';

// Step 2 of booking: pick a vehicle category (SRS 3.1.4 Truck Selection).
class VehicleSelectionScreen extends ConsumerStatefulWidget {
  const VehicleSelectionScreen({super.key});

  @override
  ConsumerState<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends ConsumerState<VehicleSelectionScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingDraftProvider);
    _selected = draft.vehicleType;
    // Defensive guard: this screen requires pickup/drop to already be set.
    // Normally unreachable any other way, but browser back/forward or a
    // direct URL (this app also runs on web) can land here with an empty
    // draft - redirect to the start of the flow instead of letting a later
    // screen crash on a force-unwrapped null.
    if (draft.pickup == null || draft.drop == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/booking/locations');
      });
    }
  }

  void _continue() {
    if (_selected == null) return;
    ref.read(bookingDraftProvider.notifier).setVehicleType(_selected!);
    context.push('/booking/details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a vehicle')),
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
                  return Card(
                    color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                    child: ListTile(
                      onTap: () => setState(() => _selected = vt.value),
                      leading: Icon(vt.icon, size: 32),
                      title: Text(vt.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(vt.description),
                      trailing: isSelected ? const Icon(Icons.check_circle) : null,
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

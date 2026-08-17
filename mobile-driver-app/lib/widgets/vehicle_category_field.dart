import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/vehicle_category_model.dart';
import '../providers/vehicle_config_provider.dart';

const _kBodyTypeLabels = {
  'bike': 'Bike',
  'auto': 'Auto',
  'open': 'Open',
  'container': 'Container',
  'trailer': 'Trailer',
};

// Form-field-styled trigger for picking one vehicle category from the live
// admin-managed catalog - used both at first-time registration
// (vehicle_setup_screen.dart) and when a fleet owner adds another vehicle
// (fleet/add_vehicle_screen.dart), replacing the old single flat
// DropdownButtonFormField<String> built from the static kVehicleTypes list.
// Registering with a specific category (not just a broad "mini truck") is
// what makes driver.controller.js's exact-vehicleType-match order routing
// correct - the driver's registered category IS the specific truck spec a
// customer picked.
class VehicleCategoryField extends ConsumerWidget {
  final String? value;
  final ValueChanged<String> onChanged;
  final String label;

  const VehicleCategoryField({super.key, required this.value, required this.onChanged, this.label = 'Vehicle type'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(vehicleCategoriesProvider);

    return categoriesAsync.when(
      loading: () => InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: const SizedBox(height: 20, child: LinearProgressIndicator()),
      ),
      error: (err, _) => InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: const Text('Could not load vehicle types', style: TextStyle(color: AppTheme.error)),
      ),
      data: (categories) {
        final selected = categories.where((c) => c.vehicleType == value).firstOrNull;
        return InkWell(
          onTap: () async {
            final picked = await showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (context) => _CategoryPickerSheet(categories: categories, initialValue: value),
            );
            if (picked != null) onChanged(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.arrow_drop_down)),
            child: selected == null
                ? const Text('Select vehicle type', style: TextStyle(color: Colors.grey))
                : Row(
                    children: [
                      // cacheWidth/Height - the source PNGs are 480x320, decoded at
                      // that full size by default even though they only ever render
                      // this small; caps actual decode size close to real display size.
                      Image.asset(vehicleImageAsset(selected.imageKey), width: 28, height: 28, fit: BoxFit.contain, cacheWidth: 84, cacheHeight: 84),
                      const SizedBox(width: 10),
                      Text('${selected.displayTitle} · ${selected.weightLabel}'),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

// Drop-in replacement for the old `Icon(vehicleIcon(vehicleType))` pattern
// (job_requests_screen.dart, trip_history_screen.dart,
// fleet_dashboard_screen.dart) - looks up the matching illustration from
// the live catalog instead of a generic Material icon. Falls back to a
// plain truck icon while the catalog is still loading or if the vehicleType
// doesn't match anything (e.g. a stale/deactivated category) - matches how
// the old vehicleIcon() helper always resolved to *something* rather than
// crashing on an unrecognized value.
class VehicleTypeThumbnail extends ConsumerWidget {
  final String vehicleType;
  final double size;
  const VehicleTypeThumbnail(this.vehicleType, {super.key, this.size = 24});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(vehicleCategoriesProvider).valueOrNull;
    final match = categories?.where((c) => c.vehicleType == vehicleType).firstOrNull;
    if (match == null) return Icon(Icons.local_shipping_outlined, size: size);
    // cacheWidth/Height - see the picker field's own comment on the same
    // pattern above (caps decode size to roughly what's actually shown,
    // scaled with this widget's own variable `size` rather than a fixed
    // constant since callers pass different sizes).
    return Image.asset(
      vehicleImageAsset(match.imageKey),
      width: size * 1.6,
      height: size,
      fit: BoxFit.contain,
      cacheWidth: (size * 1.6 * 3).round(),
      cacheHeight: (size * 3).round(),
    );
  }
}

class _CategoryPickerSheet extends StatefulWidget {
  final List<VehicleCategoryModel> categories;
  final String? initialValue;
  const _CategoryPickerSheet({required this.categories, required this.initialValue});

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  late String _bodyType;

  @override
  void initState() {
    super.initState();
    final selected = widget.categories.where((c) => c.vehicleType == widget.initialValue).firstOrNull;
    _bodyType = selected?.bodyType ?? (widget.categories.isNotEmpty ? widget.categories.first.bodyType : '');
  }

  @override
  Widget build(BuildContext context) {
    final bodyTypes = <String>[];
    for (final c in widget.categories) {
      if (!bodyTypes.contains(c.bodyType)) bodyTypes.add(c.bodyType);
    }
    final filtered = widget.categories.where((c) => c.bodyType == _bodyType).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Select your vehicle', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: bodyTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final bt = bodyTypes[i];
                    final isSelected = _bodyType == bt;
                    return ChoiceChip(
                      label: Text(_kBodyTypeLabels[bt] ?? bt),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _bodyType = bt),
                      selectedColor: AppTheme.amber,
                      labelStyle: TextStyle(color: isSelected ? Colors.black87 : AppTheme.textDark),
                      shape: StadiumBorder(side: BorderSide(color: isSelected ? AppTheme.amber : AppTheme.borderColor)),
                    );
                  },
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = filtered[i];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.borderColor)),
                      child: ListTile(
                        // cacheWidth/Height - see the picker field's own comment above.
                        leading: Image.asset(vehicleImageAsset(c.imageKey), width: 44, height: 44, fit: BoxFit.contain, cacheWidth: 132, cacheHeight: 132),
                        title: Text(c.displayTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(c.weightLabel),
                        onTap: () => Navigator.of(context).pop(c.vehicleType),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

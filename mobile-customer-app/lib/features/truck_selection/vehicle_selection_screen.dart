import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/vehicle_category_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/vehicle_config_provider.dart';

Map<String, String> _bodyTypeLabels(AppLocalizations l10n) => {
      'bike': l10n.bodyTypeBike,
      'auto': l10n.bodyTypeAuto,
      'open': l10n.bodyTypeOpen,
      'container': l10n.bodyTypeContainer,
      'trailer': l10n.bodyTypeTrailer,
    };

// Step 2 of booking: pick a vehicle category (SRS 3.1.4 Truck Selection).
// Body-type filter chips + an optional cargo-weight filter, then a list of
// specific categories (illustration, length, tonnage, live price) within
// whichever filter is active - matches the reference design the catalog
// itself is modeled on (see backend's VehicleCategory). Price-per-card
// calls /booking/estimate, same pattern as before, but now only for the
// currently-filtered set and cached by vehicleType, since a real catalog
// can hold far more than 5 entries - firing every category at once on load
// doesn't scale the way it did for the old fixed 5-item list.
class VehicleSelectionScreen extends ConsumerStatefulWidget {
  const VehicleSelectionScreen({super.key});

  @override
  ConsumerState<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends ConsumerState<VehicleSelectionScreen> {
  String? _selected;
  String? _bodyType;
  double? _weightFilterKg;
  final Map<String, num?> _priceByType = {};
  final Set<String> _loadingTypes = {};
  BookingDraft? _draft;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingDraftProvider);
    _draft = draft;
    _selected = draft.vehicleType;
    if (draft.pickup == null || draft.drop == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/booking/locations');
      });
    }
  }

  Future<void> _loadPricesFor(List<VehicleCategoryModel> categories) async {
    final draft = _draft;
    if (draft?.pickup == null || draft?.drop == null) return;
    // Materialized to a fixed List, not left as a lazy Iterable.where(...) -
    // the setState below mutates _loadingTypes, and a lazy where() re-runs
    // its predicate against that *current* state on every later iteration.
    // Left lazy, Future.wait(toFetch.map(...)) would re-filter after
    // _loadingTypes had just been populated with these same types, so the
    // predicate excludes everything the second time around - zero requests
    // actually fire, nothing ever clears _loadingTypes, and every card
    // spins forever despite looking like it "started" loading.
    final toFetch = categories.where((c) => !_priceByType.containsKey(c.vehicleType) && !_loadingTypes.contains(c.vehicleType)).toList();
    if (toFetch.isEmpty) return;

    setState(() => _loadingTypes.addAll(toFetch.map((c) => c.vehicleType)));
    final service = ref.read(bookingServiceProvider);
    await Future.wait(toFetch.map((c) async {
      try {
        final estimate = await service.getEstimate(pickup: draft!.pickup!, drop: draft.drop!, vehicleType: c.vehicleType);
        if (mounted) setState(() => _priceByType[c.vehicleType] = estimate.estimatedPrice);
      } catch (_) {
        if (mounted) setState(() => _priceByType[c.vehicleType] = null);
      } finally {
        if (mounted) setState(() => _loadingTypes.remove(c.vehicleType));
      }
    }));
  }

  Future<void> _promptWeightFilter() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _weightFilterKg?.toStringAsFixed(0) ?? '');
    final result = await showDialog<double?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.filterByCargoWeight),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.weightKgFieldLabel, border: const OutlineInputBorder()),
        ),
        actions: [
          if (_weightFilterKg != null)
            TextButton(onPressed: () => Navigator.pop(context, -1.0), child: Text(l10n.clear)),
          TextButton(onPressed: () => Navigator.pop(context, null), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, double.tryParse(controller.text.trim())),
            child: Text(l10n.apply),
          ),
        ],
      ),
    );
    if (result == null) return;
    setState(() => _weightFilterKg = result < 0 ? null : result);
  }

  void _continue() {
    if (_selected == null) return;
    ref.read(bookingDraftProvider.notifier).setVehicleType(_selected!);
    // push, not pushReplacement - see locations_screen.dart's _continue().
    context.push('/booking/details');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bodyTypeLabels = _bodyTypeLabels(l10n);
    final categoriesAsync = ref.watch(vehicleCategoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(l10n.selectVehicle)),
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.couldNotLoadVehicleTypes, textAlign: TextAlign.center),
            ),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return Center(child: Text(l10n.noVehicleTypesAvailable));
            }
            // Preserve catalog (sortOrder) order for the filter chips, not
            // an alphabetical re-sort - matches how the admin arranged them.
            final bodyTypes = <String>[];
            for (final c in categories) {
              if (!bodyTypes.contains(c.bodyType)) bodyTypes.add(c.bodyType);
            }
            _bodyType ??= bodyTypes.first;

            final filtered = categories
                .where((c) => c.bodyType == _bodyType)
                .where((c) => _weightFilterKg == null || c.maxWeightKg >= _weightFilterKg!)
                .toList();

            WidgetsBinding.instance.addPostFrameCallback((_) => _loadPricesFor(filtered));

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: bodyTypes.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return ActionChip(
                            avatar: Icon(Icons.scale_outlined, size: 16, color: _weightFilterKg != null ? Colors.white : AppTheme.primary),
                            label: Text(_weightFilterKg != null ? l10n.weightKgChipValue(_weightFilterKg!.toStringAsFixed(0)) : l10n.weightFilterChipLabel),
                            backgroundColor: _weightFilterKg != null ? AppTheme.primary : Colors.white,
                            labelStyle: TextStyle(color: _weightFilterKg != null ? Colors.white : AppTheme.textDark),
                            shape: StadiumBorder(side: BorderSide(color: _weightFilterKg != null ? AppTheme.primary : AppTheme.borderColor)),
                            onPressed: _promptWeightFilter,
                          );
                        }
                        final bt = bodyTypes[i - 1];
                        final isSelected = _bodyType == bt;
                        return ChoiceChip(
                          label: Text(bodyTypeLabels[bt] ?? bt),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _bodyType = bt),
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark),
                          backgroundColor: Colors.white,
                          shape: StadiumBorder(side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.borderColor)),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(child: Text(l10n.noVehiclesMatchThisWeight))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final vt = filtered[i];
                            final isSelected = _selected == vt.vehicleType;
                            final price = _priceByType[vt.vehicleType];
                            final loadingPrice = _loadingTypes.contains(vt.vehicleType);
                            return Card(
                              elevation: 0,
                              color: isSelected ? AppTheme.primarySurface : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.borderColor)),
                              child: InkWell(
                                onTap: () => setState(() => _selected = vt.vehicleType),
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 48,
                                        decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(12)),
                                        // cacheWidth/Height - the source PNGs are 480x320,
                                        // decoded at that full size by default even though
                                        // they only ever render this small; this caps actual
                                        // decode size close to the real display size instead.
                                        child: Image.asset(vehicleImageAsset(vt.imageKey), fit: BoxFit.contain, cacheWidth: 192, cacheHeight: 144),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(vt.displayTitle, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                                            Text(vt.weightLabel, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
                                          ],
                                        ),
                                      ),
                                      if (loadingPrice)
                                        const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                      else
                                        Text(price != null ? '₹$price' : '—', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                                      const SizedBox(width: 8),
                                      Radio<String>(value: vt.vehicleType, groupValue: _selected, onChanged: (v) => setState(() => _selected = v), activeColor: AppTheme.primary),
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
                      child: Text(l10n.continueLabel),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

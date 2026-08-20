import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/places_service.dart';

// Debounced Places autocomplete field. Calls our backend's /places/*
// endpoints (see PlacesService) - if Maps isn't configured server-side,
// the backend just returns an empty predictions list, so this degrades to
// a plain text field with no suggestions rather than erroring.
class PlacesAutocompleteField extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;
  final void Function(PlaceDetails details) onPlaceSelected;
  // Null hides the current-location button entirely (e.g. the drop field,
  // where defaulting to "where I am right now" doesn't make sense).
  final VoidCallback? onUseCurrentLocation;
  // Owned by the parent screen, not this widget - the actual GPS +
  // reverse-geocode work happens one level up in LocationsScreen.
  final bool isLocating;

  const PlacesAutocompleteField({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.controller,
    required this.onPlaceSelected,
    this.onUseCurrentLocation,
    this.isLocating = false,
  });

  @override
  State<PlacesAutocompleteField> createState() => _PlacesAutocompleteFieldState();
}

class _PlacesAutocompleteFieldState extends State<PlacesAutocompleteField> {
  final _placesService = PlacesService();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  // Shared TapRegion groupId so the field AND the overlay dropdown count as
  // "the same region" - taps on a suggestion don't count as "outside" and
  // won't dismiss the overlay before the tap itself registers. This
  // replaces an earlier focus-loss-based dismiss, which raced against the
  // suggestion's own tap handler: tapping a suggestion caused the field to
  // lose focus, which removed the overlay in the same instant, before the
  // ListTile's onTap ever fired - suggestions looked unclickable even
  // though they were rendering correctly.
  final Object _tapRegionGroupId = Object();
  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = [];
  bool _loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.trim().length < 3) {
        _removeOverlay();
        return;
      }
      setState(() => _loading = true);
      final results = await _placesService.autocomplete(value);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _loading = false;
      });
      _showOverlay();
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion s) async {
    widget.controller.text = s.description;
    _removeOverlay();
    _focusNode.unfocus();
    final details = await _placesService.getDetails(s.placeId);
    if (details != null) widget.onPlaceSelected(details);
  }

  void _showOverlay() {
    _removeOverlay();
    if (_suggestions.isEmpty) return;

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: TapRegion(
            groupId: _tapRegionGroupId,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final s = _suggestions[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, size: 20),
                    title: Text(s.description, style: const TextStyle(fontSize: 14)),
                    onTap: () => _selectSuggestion(s),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget? _buildSuffix() {
    if (_loading) {
      return const Padding(padding: EdgeInsets.all(14), child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (widget.onUseCurrentLocation == null) return null;
    if (widget.isLocating) {
      return const Padding(padding: EdgeInsets.all(14), child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)));
    }
    return IconButton(
      icon: const Icon(Icons.my_location),
      tooltip: AppLocalizations.of(context)!.useMyCurrentLocation,
      onPressed: widget.onUseCurrentLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TapRegion(
        groupId: _tapRegionGroupId,
        onTapOutside: (_) {
          _focusNode.unfocus();
          _removeOverlay();
        },
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon, color: widget.iconColor),
            suffixIcon: _buildSuffix(),
            labelText: widget.label,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

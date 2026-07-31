import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/saved_address_model.dart';
import '../../services/saved_address_service.dart';
import '../../widgets/custom_textfield.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _service = SavedAddressService();
  List<SavedAddressModel>? _addresses;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final addresses = await _service.list();
      if (mounted) setState(() => _addresses = addresses);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load your addresses.');
    }
  }

  Future<void> _openEditor({SavedAddressModel? existing}) async {
    final labelController = TextEditingController(text: existing?.label ?? '');
    final addressController = TextEditingController(text: existing?.address ?? '');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(existing == null ? 'Add address' : 'Edit address', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            CustomTextField(controller: labelController, hintText: 'Label (e.g. Home, Office)', prefixIcon: Icons.label_outline),
            const SizedBox(height: 12),
            CustomTextField(controller: addressController, hintText: 'Full address', prefixIcon: Icons.location_on_outlined),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final label = labelController.text.trim();
                final address = addressController.text.trim();
                if (label.isEmpty || address.isEmpty) return;
                try {
                  if (existing == null) {
                    await _service.create(label: label, address: address);
                  } else {
                    await _service.update(existing.id, label: label, address: address);
                  }
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save this address.')));
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) _load();
  }

  Future<void> _delete(SavedAddressModel address) async {
    try {
      await _service.remove(address.id);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not remove this address.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Addresses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: _addresses == null
            ? (_error != null ? Center(child: Text(_error!)) : const Center(child: CircularProgressIndicator()))
            : _addresses!.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('No saved addresses yet - tap + to add one.', style: GoogleFonts.poppins(color: Colors.grey.shade500), textAlign: TextAlign.center),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _addresses!.length,
                    itemBuilder: (context, index) {
                      final address = _addresses![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: Text(address.label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          subtitle: Text(address.address, maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') _openEditor(existing: address);
                              if (value == 'delete') _delete(address);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

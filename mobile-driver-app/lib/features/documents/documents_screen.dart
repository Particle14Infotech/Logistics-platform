import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/document_types.dart';
import '../../providers/driver_provider.dart';

// KYC document management (SRS 3.2.8): upload/retake each of the 8 document
// types. Every upload lands in Driver.documents, which the Admin > Drivers
// KYC review grid already reads - uploading here just makes those "Not
// uploaded" placeholders turn into real reviewable files.
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  String? _uploadingKey;
  String? _error;

  Future<void> _pickAndUpload(DocumentTypeInfo docType, ImageSource source) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: source, imageQuality: 80);
    if (photo == null) return;

    setState(() {
      _uploadingKey = docType.key;
      _error = null;
    });
    try {
      await ref.read(driverServiceProvider).uploadDocument(docType.key, File(photo.path));
      ref.invalidate(driverProfileProvider);
    } catch (e) {
      setState(() => _error = 'Could not upload ${docType.label}. Try again.');
    } finally {
      if (mounted) setState(() => _uploadingKey = null);
    }
  }

  void _showSourcePicker(DocumentTypeInfo docType) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(docType, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(docType, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(driverProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Could not load documents.\n$e', textAlign: TextAlign.center)),
        data: (profile) {
          if (profile == null) return const Center(child: Text('Complete vehicle setup first.'));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_error != null) ...[
                Text(_error!, style: GoogleFonts.poppins(color: AppTheme.error, fontSize: 13)),
                const SizedBox(height: 12),
              ],
              ...kDocumentTypes.map((docType) {
                final uploaded = profile.documents[docType.field] != null;
                final uploading = _uploadingKey == docType.key;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(docType.icon, color: uploaded ? AppTheme.success : AppTheme.textGrey),
                    title: Text(docType.label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      uploaded ? 'Uploaded' : (docType.required ? 'Required - not uploaded' : 'Optional - not uploaded'),
                      style: GoogleFonts.poppins(fontSize: 12, color: uploaded ? AppTheme.success : AppTheme.textGrey),
                    ),
                    trailing: uploading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : TextButton(
                            onPressed: () => _showSourcePicker(docType),
                            child: Text(uploaded ? 'Retake' : 'Upload', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

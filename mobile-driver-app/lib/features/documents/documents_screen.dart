import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/document_types.dart';
import '../../l10n/app_localizations.dart';
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

// Canonical English labels live in document_types.dart's kDocumentTypes
// (docType.key/.field are what's actually sent/stored - never translated).
// This maps each key to its on-screen translated label.
String _docLabel(DocumentTypeInfo docType, AppLocalizations l10n) => switch (docType.key) {
      'photo' => l10n.docLabelPhotoId,
      'license' => l10n.docLabelLicenseFront,
      'license_back' => l10n.docLabelLicenseBack,
      'rc' => l10n.docLabelRcFront,
      'rc_back' => l10n.docLabelRcBack,
      'aadhaar' => l10n.docLabelAadhaarFront,
      'aadhaar_back' => l10n.docLabelAadhaarBack,
      'insurance' => l10n.docLabelInsurance,
      'permit' => l10n.docLabelPermit,
      'pollution' => l10n.docLabelPollution,
      'pan' => l10n.docLabelPan,
      'cheque' => l10n.docLabelCheque,
      _ => docType.label,
    };

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  String? _uploadingKey;
  String? _error;

  Future<void> _pickAndUpload(DocumentTypeInfo docType, ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
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
      setState(() => _error = l10n.couldNotUploadDocumentTryAgain(_docLabel(docType, l10n)));
    } finally {
      if (mounted) setState(() => _uploadingKey = null);
    }
  }

  void _showSourcePicker(DocumentTypeInfo docType) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.takeAPhoto),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(docType, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chooseFromGallery),
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
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(driverProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.documents)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text(l10n.couldNotLoadDocuments('$e'), textAlign: TextAlign.center)),
        data: (profile) {
          if (profile == null) return Center(child: Text(l10n.completeVehicleSetupFirst));

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
                    title: Text(_docLabel(docType, l10n), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      uploaded ? l10n.uploaded : (docType.required ? l10n.requiredNotUploaded : l10n.optionalNotUploaded),
                      style: GoogleFonts.poppins(fontSize: 12, color: uploaded ? AppTheme.success : AppTheme.textGrey),
                    ),
                    trailing: uploading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : TextButton(
                            onPressed: () => _showSourcePicker(docType),
                            child: Text(uploaded ? l10n.retake : l10n.upload, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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

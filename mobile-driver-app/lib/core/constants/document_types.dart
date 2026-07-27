import 'package:flutter/material.dart';

class DocumentTypeInfo {
  final String key; // matches backend's DOCUMENT_TYPE_MAP key and the :documentType route param
  final String field; // matches Driver.documents.<field> - used to read current status
  final String label;
  final IconData icon;
  final bool required;

  const DocumentTypeInfo({
    required this.key,
    required this.field,
    required this.label,
    required this.icon,
    this.required = true,
  });
}

const List<DocumentTypeInfo> kDocumentTypes = [
  DocumentTypeInfo(key: 'photo', field: 'photoUrl', label: 'Photo ID (Selfie)', icon: Icons.face_outlined),
  DocumentTypeInfo(key: 'license', field: 'licenseUrl', label: 'Driving license', icon: Icons.badge_outlined),
  DocumentTypeInfo(key: 'rc', field: 'rcUrl', label: 'Vehicle RC', icon: Icons.description_outlined),
  DocumentTypeInfo(key: 'aadhaar', field: 'aadhaarUrl', label: 'Aadhaar card', icon: Icons.credit_card),
  DocumentTypeInfo(key: 'insurance', field: 'insuranceUrl', label: 'Insurance', icon: Icons.shield_outlined),
  DocumentTypeInfo(key: 'permit', field: 'permitUrl', label: 'Permit', icon: Icons.assignment_outlined, required: false),
  DocumentTypeInfo(key: 'pollution', field: 'pollutionCertUrl', label: 'Pollution certificate', icon: Icons.eco_outlined, required: false),
  DocumentTypeInfo(key: 'pan', field: 'panCardUrl', label: 'PAN card', icon: Icons.article_outlined),
];

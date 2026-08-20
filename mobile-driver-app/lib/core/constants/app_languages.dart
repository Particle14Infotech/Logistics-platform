class AppLanguage {
  final String code; // ISO 639-1, matches the .arb filename suffix
  final String nativeName;
  final String englishName;
  const AppLanguage({required this.code, required this.nativeName, required this.englishName});
}

const List<AppLanguage> kSupportedLanguages = [
  AppLanguage(code: 'en', nativeName: 'English', englishName: 'English'),
  AppLanguage(code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi'),
  AppLanguage(code: 'mr', nativeName: 'मराठी', englishName: 'Marathi'),
  AppLanguage(code: 'gu', nativeName: 'ગુજરાતી', englishName: 'Gujarati'),
  AppLanguage(code: 'ta', nativeName: 'தமிழ்', englishName: 'Tamil'),
  AppLanguage(code: 'te', nativeName: 'తెలుగు', englishName: 'Telugu'),
];

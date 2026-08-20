// The languages this app ships real translations for - see lib/l10n/*.arb.
// Each entry's own native-script name is shown in the language picker
// (features/profile/language_selection_screen.dart) so it stays readable
// regardless of whatever language is currently active. Adding a new
// language later just needs a new app_<code>.arb file + a new entry here -
// no other code changes.
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

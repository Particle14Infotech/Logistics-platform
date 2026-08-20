import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_languages.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

// Each language shows in its own native script (not the currently-active
// language) so it stays readable regardless of what's selected right now -
// a Hindi speaker who's somehow landed on Tamil UI still needs to be able
// to spot "हिन्दी" and get back.
class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.language)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: kSupportedLanguages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final lang = kSupportedLanguages[i];
            // null currentLocale = following the system locale - only treat
            // that as "selected" for whichever supported language the
            // system locale itself actually resolves to (matches how
            // MaterialApp.router's localeResolutionCallback picks one).
            final isSelected = currentLocale?.languageCode == lang.code;
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.borderColor, width: isSelected ? 2 : 1),
              ),
              child: ListTile(
                title: Text(lang.nativeName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                subtitle: lang.nativeName != lang.englishName ? Text(lang.englishName) : null,
                trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
                onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(lang.code)),
              ),
            );
          },
        ),
      ),
    );
  }
}

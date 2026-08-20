import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_languages.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.language)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: kSupportedLanguages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final lang = kSupportedLanguages[i];
          final selected = currentLocale?.languageCode == lang.code;
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: selected ? AppTheme.amber : AppTheme.borderColor, width: selected ? 2 : 1),
            ),
            child: ListTile(
              title: Text(lang.nativeName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: lang.nativeName != lang.englishName ? Text(lang.englishName) : null,
              trailing: selected ? const Icon(Icons.check_circle, color: AppTheme.amber) : null,
              onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(lang.code)),
            ),
          );
        },
      ),
    );
  }
}

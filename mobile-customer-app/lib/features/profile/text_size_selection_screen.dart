import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/text_size_options.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/text_scale_provider.dart';

String _labelFor(String key, AppLocalizations l10n) => switch (key) {
      'small' => l10n.textSizeSmall,
      'standard' => l10n.textSizeStandard,
      'large' => l10n.textSizeLarge,
      'extraLarge' => l10n.textSizeExtraLarge,
      _ => key,
    };

// Each row previews its own scale directly (wrapping just that row's sample
// text in its own TextScaler, independent of whatever's currently applied
// app-wide) - so a low-vision user can see exactly how big "Large" actually
// looks before committing to it, without a separate slider+preview screen.
class TextSizeSelectionScreen extends ConsumerWidget {
  const TextSizeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentKey = ref.watch(textSizeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.textSize)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.textSizeScreenHint, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ...kTextSizeOptions.map((option) {
              final isSelected = currentKey == option.key;
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.borderColor, width: isSelected ? 2 : 1),
                ),
                child: ListTile(
                  title: Text(_labelFor(option.key, l10n), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(option.scale)),
                      child: Text(l10n.textSizeSampleText, style: TextStyle(color: Colors.grey.shade600)),
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
                  onTap: () => ref.read(textSizeProvider.notifier).setTextSize(option.key),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

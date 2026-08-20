class TextSizeOption {
  final String key; // persisted value
  final double scale; // multiplier applied via TextScaler.linear
  const TextSizeOption({required this.key, required this.scale});
}

// Steps chosen to stay legible without breaking layouts that assume roughly
// default-sized text (buttons, chips, OTP boxes) - 0.85-1.3x covers real
// low-vision need without the extremes that make Material's fixed-height
// controls clip or wrap awkwardly.
const List<TextSizeOption> kTextSizeOptions = [
  TextSizeOption(key: 'small', scale: 0.85),
  TextSizeOption(key: 'standard', scale: 1.0),
  TextSizeOption(key: 'large', scale: 1.15),
  TextSizeOption(key: 'extraLarge', scale: 1.3),
];

const kDefaultTextSizeKey = 'standard';

double textScaleForKey(String? key) =>
    kTextSizeOptions.firstWhere((o) => o.key == key, orElse: () => kTextSizeOptions[1]).scale;

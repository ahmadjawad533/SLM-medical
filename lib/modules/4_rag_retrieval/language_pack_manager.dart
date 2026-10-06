/// ---------------------------------------------------------------------------
/// MODULAR LANGUAGE PACK & MODEL ASSET MANAGER
/// ---------------------------------------------------------------------------
/// Keeps base app installer small (~85MB) for low-bandwidth distribution.
/// Manages optional downloadable/USB-sideloadable language packs and model weights.

class LanguagePackInfo {
  final String languageCode;
  final String languageName;
  final int sizeMb;
  final bool isInstalled;

  LanguagePackInfo({
    required this.languageCode,
    required this.languageName,
    required this.sizeMb,
    required this.isInstalled,
  });
}

class LanguagePackManager {
  static final List<LanguagePackInfo> _availablePacks = [
    LanguagePackInfo(languageCode: 'en', languageName: 'English (Base Package)', sizeMb: 85, isInstalled: true),
    LanguagePackInfo(languageCode: 'sw', languageName: 'Swahili (Kiswahili Pack)', sizeMb: 120, isInstalled: false),
    LanguagePackInfo(languageCode: 'ar', languageName: 'Arabic (العربية Pack)', sizeMb: 140, isInstalled: false),
    LanguagePackInfo(languageCode: 'hi', languageName: 'Hindi (हिन्दी Pack)', sizeMb: 110, isInstalled: false),
    LanguagePackInfo(languageCode: 'es', languageName: 'Spanish (Español Pack)', sizeMb: 95, isInstalled: false),
  ];

  static List<LanguagePackInfo> getPacks() => List.unmodifiable(_availablePacks);
}

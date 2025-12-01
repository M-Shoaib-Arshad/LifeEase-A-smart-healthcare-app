import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  static const Map<String, Map<String, String>> _languages = {
    'en': {
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇺🇸',
    },
    'es': {
      'name': 'Spanish',
      'nativeName': 'Español',
      'flag': '🇪🇸',
    },
    'ar': {
      'name': 'Arabic',
      'nativeName': 'العربية',
      'flag': '🇸🇦',
    },
    'ur': {
      'name': 'Urdu',
      'nativeName': 'اردو',
      'flag': '🇵🇰',
    },
    'hi': {
      'name': 'Hindi',
      'nativeName': 'हिन्दी',
      'flag': '🇮🇳',
    },
  };

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select your preferred language',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Full localization coming soon',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Available Languages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Language Options
          ..._languages.entries.map((entry) {
            final languageCode = entry.key;
            final languageData = entry.value;
            final isSelected = settingsProvider.language == languageCode;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              elevation: isSelected ? 2 : 0,
              color: isSelected
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : null,
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      languageData['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                title: Text(
                  languageData['nativeName']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(languageData['name']!),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  settingsProvider.setLanguage(languageCode);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Language set to ${languageData['name']}',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            );
          }),

          const SizedBox(height: 16),

          // Note about localization
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Language Support',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Currently, the app interface is in English. Full multi-language support with translations is planned for a future update. Your language preference will be saved and applied once localization is complete.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

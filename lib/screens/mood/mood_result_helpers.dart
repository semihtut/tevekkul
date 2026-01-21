import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/dhikr_model.dart';
import '../../models/esma_model.dart';
import '../../models/mood_dhikr_model.dart';
import '../../providers/dhikr_provider.dart';
import '../home/home_screen.dart';

/// Helper methods for mood result screen
///
/// Extracted from mood_result_screen.dart for better organization

class MoodResultHelpers {
  /// Get localized section title for Ayah
  static String getAyahSectionTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Qur\'anic Verse';
      case 'fi':
        return 'Koraanin Jae';
      default:
        return 'Kur\'an Ayeti';
    }
  }

  /// Get localized section title for Esma
  static String getEsmaSectionTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Divine Name';
      case 'fi':
        return 'Jumalan Nimi';
      default:
        return 'Esma-ül Hüsna';
    }
  }

  /// Get localized section title for Dhikr
  static String getDhikrSectionTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Recommended Dhikr';
      case 'fi':
        return 'Suositeltu Dhikr';
      default:
        return 'Önerilen Zikir';
    }
  }

  /// Get localized text for "times"
  static String getTimesText(String lang) {
    switch (lang) {
      case 'en':
        return 'times recommended';
      case 'fi':
        return 'kertaa suositellaan';
      default:
        return 'kere önerilir';
    }
  }

  /// Get localized text for "Add to Zikirmatik" button
  static String getAddToZikirmatikText(String lang) {
    switch (lang) {
      case 'en':
        return 'Start Dhikr';
      case 'fi':
        return 'Aloita Dhikr';
      default:
        return 'Zikre Başla';
    }
  }

  /// Start Esma dhikr in Zikirmatik
  static void startEsmaZikir(BuildContext context, WidgetRef ref, EsmaModel esma) {
    // Convert Esma to DhikrModel
    final dhikr = DhikrModel(
      id: 'esma_${esma.id}',
      arabic: esma.arabic,
      transliteration: esma.transliteration,
      meaning: {
        'tr': esma.getMeaning('tr'),
        'en': esma.getMeaning('en'),
        'fi': esma.getMeaning('fi'),
      },
      defaultTarget: esma.abjadValue,
      isCustom: false,
    );

    // Set the dhikr and target (use ebced value as target)
    ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
    ref.read(dhikrProvider.notifier).setTarget(esma.abjadValue);

    // Navigate to home and switch to zikirmatik tab
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: const RouteSettings(arguments: 1), // zikirmatik tab index
      ),
      (route) => false,
    );
  }

  /// Add mood dhikr to Zikirmatik
  static void addDhikrToZikirmatik(BuildContext context, WidgetRef ref, MoodDhikrModel moodDhikr) {
    // Use factory method to convert MoodDhikrModel to DhikrModel
    final dhikr = DhikrModel.fromMoodDhikr(moodDhikr);

    // Set the dhikr and target
    ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
    ref.read(dhikrProvider.notifier).setTarget(moodDhikr.recommendedCount);

    // Navigate to home and switch to zikirmatik tab
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: const RouteSettings(arguments: 1), // zikirmatik tab index
      ),
      (route) => false,
    );
  }
}

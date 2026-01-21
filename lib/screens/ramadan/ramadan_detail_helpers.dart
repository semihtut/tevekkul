import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/dhikr_model.dart';
import '../../models/esma_model.dart';
import '../../providers/dhikr_provider.dart';
import '../home/home_screen.dart';

/// Helper methods for Ramadan detail screen
///
/// Extracted from ramadan_detail_screen.dart for better organization

class RamadanDetailHelpers {
  /// Get localized Ramadan title
  static String getRamadanTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Ramadan';
      case 'fi':
        return 'Ramadan';
      default:
        return 'Ramazan';
    }
  }

  /// Get localized day text (e.g., "Day 15 of 30")
  static String getDayText(int day, String lang) {
    switch (lang) {
      case 'en':
        return 'Day $day of 30';
      case 'fi':
        return 'Päivä $day/30';
      default:
        return '$day. Gün / 30';
    }
  }

  /// Get localized Imsak label
  static String getImsakLabel(String lang) {
    switch (lang) {
      case 'en':
        return 'Imsak';
      case 'fi':
        return 'Imsak';
      default:
        return 'İmsak';
    }
  }

  /// Get localized Iftar label
  static String getIftarLabel(String lang) {
    switch (lang) {
      case 'en':
        return 'Iftar';
      case 'fi':
        return 'Iftar';
      default:
        return 'İftar';
    }
  }

  /// Get localized countdown label
  static String getCountdownLabel(String lang) {
    switch (lang) {
      case 'en':
        return 'Until Iftar';
      case 'fi':
        return 'Iftariin';
      default:
        return 'İftara';
    }
  }

  /// Get localized Ayah section title
  static String getAyahSectionTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Verse of the Day';
      case 'fi':
        return 'Päivän Jae';
      default:
        return 'Günün Ayeti';
    }
  }

  /// Get localized Esma section title
  static String getEsmaSectionTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Name of the Day';
      case 'fi':
        return 'Päivän Nimi';
      default:
        return 'Günün Esması';
    }
  }

  /// Get localized "tap for more" text
  static String getTapForMoreText(String lang) {
    switch (lang) {
      case 'en':
        return 'Tap for details';
      case 'fi':
        return 'Napauta lisätietoja';
      default:
        return 'Detaylar için dokun';
    }
  }

  /// Get localized "Start Dhikr" button text
  static String getStartDhikrText(String lang) {
    switch (lang) {
      case 'en':
        return 'Start Dhikr';
      case 'fi':
        return 'Aloita Dhikr';
      default:
        return 'Zikre Başla';
    }
  }

  /// Get localized "OK" button text
  static String getOkText(String lang) {
    switch (lang) {
      case 'en':
        return 'OK';
      case 'fi':
        return 'OK';
      default:
        return 'Tamam';
    }
  }

  /// Start Ramadan Esma dhikr in Zikirmatik
  static void startDhikr(BuildContext context, WidgetRef ref, EsmaModel esma, String lang) {
    // Convert Esma to DhikrModel
    final dhikr = DhikrModel(
      id: 'ramadan_${esma.id}',
      arabic: esma.arabic,
      transliteration: esma.transliteration,
      meaning: esma.meaning,
      defaultTarget: esma.abjadValue,
      isCustom: true,
    );

    // Set the dhikr and target
    ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
    ref.read(dhikrProvider.notifier).setTarget(esma.abjadValue);

    // Navigate to home and switch to zikirmatik tab
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: const RouteSettings(arguments: 1),
      ),
      (route) => false,
    );
  }
}

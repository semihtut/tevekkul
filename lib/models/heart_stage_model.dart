import 'package:flutter/material.dart';

enum HeartStage {
  weak,      // 0-10 dhikr
  waking,    // 10-50 dhikr
  alive,     // 50-150 dhikr
  strong,    // 150-300 dhikr
  healthy,   // 300-500 dhikr
  powerful,  // 500+ dhikr
}

class HeartStageConfig {
  final HeartStage stage;
  final Map<String, String> name;
  final String emoji;
  final Map<String, String> description;
  final int minDhikr;
  final int maxDhikr;
  final int bpm;
  final Color heartColor;
  final Color glowColor;
  final Duration beatDuration;
  final double beatScale;

  const HeartStageConfig({
    required this.stage,
    required this.name,
    required this.emoji,
    required this.description,
    required this.minDhikr,
    required this.maxDhikr,
    required this.bpm,
    required this.heartColor,
    required this.glowColor,
    required this.beatDuration,
    required this.beatScale,
  });

  String getName(String lang) => name[lang] ?? name['en'] ?? '';
  String getDescription(String lang) => description[lang] ?? description['en'] ?? '';
}

class HeartStageConfigs {
  static const Map<HeartStage, HeartStageConfig> stages = {
    HeartStage.weak: HeartStageConfig(
      stage: HeartStage.weak,
      name: {
        'tr': 'Zayıf Kalp',
        'en': 'Weak Heart',
        'fi': 'Heikko Sydän',
      },
      emoji: '\u{1FA76}', // 🩶 gray heart
      description: {
        'tr': 'Kalbin uyanmaya başlıyor',
        'en': 'Your heart is starting to wake up',
        'fi': 'Sydämesi alkaa herätä',
      },
      minDhikr: 0,
      maxDhikr: 10,
      bpm: 30,
      heartColor: Color(0xFF9CA3AF),
      glowColor: Color(0x4D9CA3AF),
      beatDuration: Duration(milliseconds: 2000),
      beatScale: 1.05,
    ),
    HeartStage.waking: HeartStageConfig(
      stage: HeartStage.waking,
      name: {
        'tr': 'Uyanıyor',
        'en': 'Waking Up',
        'fi': 'Heräämässä',
      },
      emoji: '\u{1F498}', // 💘
      description: {
        'tr': 'İlk atışlar düzenleniyor',
        'en': 'First beats are getting regular',
        'fi': 'Ensimmäiset lyönnit tasaantuvat',
      },
      minDhikr: 10,
      maxDhikr: 50,
      bpm: 50,
      heartColor: Color(0xFFF9A8D4),
      glowColor: Color(0x66F9A8D4),
      beatDuration: Duration(milliseconds: 1200),
      beatScale: 1.10,
    ),
    HeartStage.alive: HeartStageConfig(
      stage: HeartStage.alive,
      name: {
        'tr': 'Canlanıyor',
        'en': 'Coming Alive',
        'fi': 'Heräämässä Henkiin',
      },
      emoji: '\u{2764}\u{FE0F}', // ❤️
      description: {
        'tr': 'Güçlü ve sağlıklı ritim',
        'en': 'Strong and healthy rhythm',
        'fi': 'Vahva ja terve rytmi',
      },
      minDhikr: 50,
      maxDhikr: 150,
      bpm: 70,
      heartColor: Color(0xFFEF4444),
      glowColor: Color(0x80EF4444),
      beatDuration: Duration(milliseconds: 857),
      beatScale: 1.15,
    ),
    HeartStage.strong: HeartStageConfig(
      stage: HeartStage.strong,
      name: {
        'tr': 'Güçlü Kalp',
        'en': 'Strong Heart',
        'fi': 'Vahva Sydän',
      },
      emoji: '\u{1F496}', // 💖
      description: {
        'tr': 'Parlak ve canlı atışlar',
        'en': 'Bright and vibrant beats',
        'fi': 'Kirkkaat ja elinvoimaiset lyönnit',
      },
      minDhikr: 150,
      maxDhikr: 300,
      bpm: 85,
      heartColor: Color(0xFFF43F5E),
      glowColor: Color(0x99F43F5E),
      beatDuration: Duration(milliseconds: 706),
      beatScale: 1.20,
    ),
    HeartStage.healthy: HeartStageConfig(
      stage: HeartStage.healthy,
      name: {
        'tr': 'Sağlıklı Kalp',
        'en': 'Healthy Heart',
        'fi': 'Terve Sydän',
      },
      emoji: '\u{1F49A}', // 💚
      description: {
        'tr': 'Mükemmel sağlık durumu',
        'en': 'Perfect health condition',
        'fi': 'Täydellinen terveydentila',
      },
      minDhikr: 300,
      maxDhikr: 500,
      bpm: 75,
      heartColor: Color(0xFF22C55E),
      glowColor: Color(0x9922C55E),
      beatDuration: Duration(milliseconds: 800),
      beatScale: 1.18,
    ),
    HeartStage.powerful: HeartStageConfig(
      stage: HeartStage.powerful,
      name: {
        'tr': 'Hayat Dolu',
        'en': 'Full of Life',
        'fi': 'Täynnä Elämää',
      },
      emoji: '\u{2728}', // ✨
      description: {
        'tr': 'Tam canlılık ve enerji',
        'en': 'Complete vitality and energy',
        'fi': 'Täydellinen elinvoima ja energia',
      },
      minDhikr: 500,
      maxDhikr: 999999,
      bpm: 90,
      heartColor: Color(0xFF10B981),
      glowColor: Color(0xCC10B981),
      beatDuration: Duration(milliseconds: 667),
      beatScale: 1.25,
    ),
  };

  static HeartStageConfig getStageForDhikr(int dhikrCount) {
    if (dhikrCount < 10) return stages[HeartStage.weak]!;
    if (dhikrCount < 50) return stages[HeartStage.waking]!;
    if (dhikrCount < 150) return stages[HeartStage.alive]!;
    if (dhikrCount < 300) return stages[HeartStage.strong]!;
    if (dhikrCount < 500) return stages[HeartStage.healthy]!;
    return stages[HeartStage.powerful]!;
  }

  static double getStageProgress(int dhikrCount) {
    final stage = getStageForDhikr(dhikrCount);
    final range = stage.maxDhikr - stage.minDhikr;
    final progress = (dhikrCount - stage.minDhikr) / range;
    return progress.clamp(0.0, 1.0);
  }
}

# 🕌 SoulCount

<div align="center">

**A Beautiful Spiritual Companion for Your Daily Dhikr Practice**

[![Flutter](https://img.shields.io/badge/Flutter-3.2.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.2.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

[Features](#-features) • [Screenshots](#-screenshots) • [Architecture](#-architecture) • [Getting Started](#-getting-started) • [Contributing](#-contributing)

</div>

---

## ✨ Overview

**SoulCount** (formerly Tevekkul) is a modern, feature-rich spiritual companion app designed to help Muslims maintain their daily dhikr practice, track spiritual progress, and deepen their connection with Islamic traditions. Built with Flutter for a seamless cross-platform experience.

### 🎯 Why SoulCount?

- 🌙 **Beautiful & Intuitive** - Modern design with light/dark themes
- 📱 **Cross-Platform** - Works perfectly on both Android and iOS
- 🌍 **Multi-Language** - Turkish, English, and Finnish support
- 💾 **Data Security** - Backup and restore your spiritual journey
- 🎨 **Personalized** - Mood-based recommendations and customization
- 📊 **Progress Tracking** - Gamified spiritual growth system

---

## 🚀 Features

### 📿 Core Features

#### **Zikirmatik (Digital Tasbih)**
- Interactive dhikr counter with haptic feedback
- Customizable target counts
- Progress tracking with visual indicators
- Sound effects for milestone achievements
- Session history and statistics

#### **Esma-ul Husna (99 Names of Allah)**
- Complete collection with meanings and transliterations
- Random Esma surprise feature for daily reflection
- Add names to personal Wird (daily routine)
- Ebced numerology integration
- Audio pronunciation guides

#### **Daily Wird System**
- Create personalized daily dhikr routines
- Track completion progress
- Reorderable items with drag-and-drop
- Reset individual items or entire Wird
- Automatic progress synchronization

#### **Mood-Based Spiritual Guidance**
- AI-curated dhikr recommendations based on your current mood
- Relevant Quranic verses (Ayahs) with translations
- Contextual Esma-ul Husna suggestions
- Reflection prompts and spiritual insights

### 🌟 Special Features

#### **Ramadan Mode** 🌙
- Daily Ramadan-specific content
- Prayer times with countdown timers (Imsak & Iftar)
- Daily Ayah and Esma recommendations
- Special Ramadan dhikr collection
- Fasting tracker integration

#### **Ebced Calculator** 🔢
- Arabic numerology (Abjad/Ebced) calculation
- Letter-by-letter breakdown
- Automatic Esma-ul Husna matching
- Multiple calculation methods (Standard, Small Ebced, Closest Match)
- Historical and spiritual context

#### **Heart Stages System** ❤️
- Gamified spiritual progress tracking
- 7 progressive heart stages (Qalb Mayyit → Qalb Munib)
- BPM (Beats Per Minute) visualization
- Achievement milestones
- Motivational descriptions from Islamic teachings

#### **Level & XP System** ⭐
- Experience points for completed dhikr
- Progressive level system (1-99)
- Visual progress bars
- Achievement celebration animations

### 📊 Analytics & Insights

- **Weekly Summary** - 7-day dhikr activity overview with charts
- **Monthly Overview** - Active days, best day, daily averages
- **Streak Tracking** - Current and best streaks with fire badges
- **Statistics Dashboard** - Total counts, completion rates, trends

### 🎨 Personalization

- **Custom Dhikr** - Create your own dhikr entries
- **Favorites System** - Save frequently used dhikr and Esma
- **Theme Modes** - Light, Dark, or System default
- **Language Selection** - Turkish (Türkçe), English, Finnish (Suomi)
- **User Profile** - Personalized name with validation

### 💾 Data Management

- **Automatic Backup** - Local data persistence with Hive
- **Export/Import** - JSON-based backup system
- **Share Backups** - Share via any installed app
- **Data Migration** - Version-aware schema migrations
- **Privacy First** - All data stored locally, no cloud dependency

---

## 📱 Screenshots

> *Coming soon - Screenshots showcasing the beautiful UI*

---

## 🏗️ Architecture

### Tech Stack

```
Flutter 3.2.0+
├── State Management: Riverpod 2.4.9
├── Local Storage: Hive 2.2.3
├── Navigation: Go Router 14.0.0
├── Animations: Rive 0.13.0
└── Testing: Mockito, Flutter Test
```

### Project Structure

```
lib/
├── config/              # App-wide configuration
│   ├── app_colors.dart           # Color palette & gradients
│   ├── app_constants.dart        # Spacing, radius, etc.
│   ├── app_translations.dart     # i18n translations
│   └── app_typography.dart       # Text styles
│
├── models/              # Data models
│   ├── dhikr_model.dart          # Dhikr entity with factories
│   ├── esma_model.dart           # Esma-ul Husna entity
│   ├── user_progress_model.dart  # Progress tracking
│   └── wird_model.dart           # Daily Wird structure
│
├── providers/           # Riverpod state providers
│   ├── dhikr_provider.dart       # Dhikr list & favorites
│   ├── progress_provider.dart    # User progress state
│   ├── settings_provider.dart    # App settings
│   └── wird_provider.dart        # Wird management
│
├── services/            # Business logic & data
│   ├── storage_service.dart      # Hive storage operations
│   ├── backup_service.dart       # Backup/restore logic
│   ├── ebced_service.dart        # Ebced calculations
│   ├── prayer_times_service.dart # Prayer time calculations
│   └── storage_migrations.dart   # Schema migrations
│
├── screens/             # UI screens (modular architecture)
│   ├── home/
│   │   ├── home_screen.dart      # Main dashboard
│   │   └── home_widgets.dart     # Reusable components
│   ├── zikirmatik/
│   │   ├── zikirmatik_screen.dart
│   │   └── zikirmatik_widgets.dart
│   ├── settings/
│   │   ├── settings_screen.dart
│   │   ├── settings_widgets.dart
│   │   └── settings_dialogs.dart
│   └── ... (15 screens total)
│
├── widgets/             # Shared widgets
│   ├── common/                   # Common components
│   └── home/                     # Home-specific widgets
│
└── main.dart            # App entry point
```

### Design Patterns

- **Singleton Pattern** - Services (BackupService, StorageService)
- **Factory Pattern** - Model constructors (DhikrModel.fromMoodDhikr, fromEsma)
- **Repository Pattern** - Data layer abstraction
- **Provider Pattern** - State management with Riverpod
- **Widget Composition** - Modular, reusable components

### Key Architectural Decisions

✅ **Modular Screen Architecture**
- Main screen files (~200 lines) focus on business logic
- Extracted widgets (~500 lines) for reusable UI components
- Helper files for utility functions
- 68+ reusable widget components created

✅ **Type-Safe State Management**
- Riverpod for compile-time safety
- Immutable state with `copyWith` patterns
- Notifier-based mutations

✅ **Offline-First Design**
- All data stored locally with Hive
- No internet dependency for core features
- Optional online features (prayer times API)

✅ **Cross-Platform Compatibility**
- Pure Flutter/Dart code
- Platform-specific configurations only in native folders
- Consistent behavior on Android & iOS

---

## 🛠️ Getting Started

### Prerequisites

```bash
Flutter SDK: 3.2.0 or higher
Dart SDK: 3.2.0 or higher
```

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/soulcount.git
cd soulcount
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run code generation** (for Hive adapters)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app**
```bash
# Run on connected device
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/models/dhikr_model_test.dart
```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires Mac)
flutter build ios --release
```

---

## 🎨 Customization

### Adding a New Language

1. Add translations to `lib/config/app_translations.dart`:
```dart
static final Map<String, Map<String, String>> _translations = {
  'your_key': {
    'en': 'English translation',
    'tr': 'Türkçe çeviri',
    'fi': 'Suomi käännös',
    'ar': 'الترجمة العربية', // Your new language
  },
};
```

2. Add language option to `settings_widgets.dart` LanguageSelector

### Customizing Colors

Edit `lib/config/app_colors.dart`:
```dart
static const Color primary = Color(0xFF0D9488); // Change primary color
static const Color accentDark = Color(0xFF2DD4BF); // Change dark accent
```

### Adding Custom Dhikr

Users can add custom dhikr through the app UI, or you can pre-load them in `data/dhikrs.json`:
```json
{
  "id": "custom_dhikr_1",
  "arabic": "سُبْحَانَ اللهِ",
  "transliteration": "Subhanallah",
  "meaning": {
    "en": "Glory be to Allah",
    "tr": "Allah'ı tüm noksanlıklardan tenzih ederim"
  },
  "defaultTarget": 33
}
```

---

## 🧪 Testing

### Current Test Coverage

- ✅ **Unit Tests**: 18 tests passing
  - Model serialization/deserialization
  - Factory method validation
  - Service singleton patterns
  - Business logic methods

- 🔄 **Integration Tests**: Coming soon
- 🔄 **Widget Tests**: Coming soon
- 🔄 **E2E Tests**: Coming soon

### Test Structure

```
test/
├── unit/
│   ├── models/
│   │   ├── dhikr_model_test.dart
│   │   ├── esma_model_test.dart
│   │   └── user_progress_model_test.dart
│   └── services/
│       ├── backup_service_test.dart
│       └── storage_service_test.dart
└── widget/  (coming soon)
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Ways to Contribute

- 🐛 **Report Bugs** - Open an issue with detailed reproduction steps
- 💡 **Suggest Features** - Share your ideas for improvements
- 📝 **Improve Documentation** - Help others understand the code
- 🌍 **Add Translations** - Expand language support
- 🎨 **Design Improvements** - UI/UX enhancements
- ✅ **Write Tests** - Increase test coverage
- 🔧 **Fix Issues** - Submit PRs for open issues

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`flutter test`)
5. Run analyzer (`flutter analyze`)
6. Commit your changes (`git commit -m 'feat: add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new feature
fix: bug fix
docs: documentation changes
style: code style changes (formatting)
refactor: code refactoring
test: adding tests
chore: maintenance tasks
```

---

## 📊 Roadmap

### Version 1.1 (Upcoming)
- [ ] Widget tests for critical screens
- [ ] Integration tests for core flows
- [ ] Firebase Crashlytics integration
- [ ] In-app feedback system
- [ ] Audio pronunciation for all Esma

### Version 1.2 (Planned)
- [ ] Community features (optional anonymous sharing)
- [ ] Advanced statistics and insights
- [ ] Custom themes and color schemes
- [ ] Widget for home screen
- [ ] Apple Watch & Wear OS support

### Version 2.0 (Future)
- [ ] AI-powered spiritual companion
- [ ] Quran integration
- [ ] Hadith collection
- [ ] Social challenges (optional)
- [ ] Advanced analytics dashboard

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Islamic Texts** - Quranic verses and Hadith from authentic sources
- **Esma-ul Husna** - The 99 Beautiful Names of Allah
- **Ebced System** - Traditional Arabic numerology calculations
- **Flutter Community** - For amazing packages and support
- **Contributors** - Everyone who has contributed to this project

---

## 📞 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/soulcount/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/soulcount/discussions)
- **Email**: support@soulcount.app

---

## 🌟 Star History

If you find this project useful, please consider giving it a star ⭐

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/soulcount&type=Date)](https://star-history.com/#yourusername/soulcount&Date)

---

<div align="center">

**Made with ❤️ for the Muslim Ummah**

*"Remember Me, and I will remember you."* - Quran 2:152

[⬆ back to top](#-soulcount)

</div>

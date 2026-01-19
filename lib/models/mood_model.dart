class MoodModel {
  final String id;
  final String emoji;
  final Map<String, String> label; // tr, en, fi
  final Map<String, String> description; // tr, en, fi
  final List<String> suggestedDhikrIds;
  final List<String> suggestedEsmaIds;
  final List<AyahReference> ayahReferences;
  final Map<String, String> reflectionPrompts; // tr, en, fi

  const MoodModel({
    required this.id,
    required this.emoji,
    required this.label,
    this.description = const {},
    this.suggestedDhikrIds = const [],
    this.suggestedEsmaIds = const [],
    this.ayahReferences = const [],
    this.reflectionPrompts = const {},
  });

  String getLabel(String languageCode) {
    return label[languageCode] ?? label['tr'] ?? '';
  }

  String getDescription(String languageCode) {
    return description[languageCode] ?? description['tr'] ?? '';
  }

  String getReflectionPrompt(String languageCode) {
    return reflectionPrompts[languageCode] ?? reflectionPrompts['tr'] ?? '';
  }

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    // Get emoji from icon field or use default
    String emoji = '😊';
    if (json['emoji'] != null) {
      emoji = json['emoji'] as String;
    } else if (json['icon'] != null) {
      // Map icon names to emojis (matching moods_extended.json icons)
      const iconMap = {
        // Negative emotions
        'cloud-rain': '😰',      // Kaygılı/Anxious
        'heart-crack': '😢',     // Üzgün/Sad
        'zap': '😤',             // Stresli/Stressed
        'moon': '🌙',            // Yalnız/Lonely
        'flame': '😠',           // Öfkeli/Angry
        'shield': '😨',          // Korkmuş/Fearful
        'battery-low': '😴',     // Yorgun/Tired
        'help-circle': '😕',     // Şaşkın/Confused
        'rotate-ccw': '😔',      // Pişman/Regretful
        'user-x': '😞',          // Reddedilmiş/Rejected

        // Positive emotions
        'sun': '😊',             // Şükreden/Grateful
        'sunrise': '🌅',         // Umutlu/Hopeful
        'heart': '❤️',           // Sevgi Dolu/Loving
        'waves': '😌',           // Huzurlu/Peaceful
        'eye': '🤲',             // Tevekkül/Trusting
        'scale': '⚖️',           // Sabırlı/Patient
        'clock': '🙏',           // Özlem/Longing
        'map': '🧭',             // Yolunu Arayan/Seeking
        'crown': '👑',           // Müteşekkir/Blessed
        'compass': '🔍',         // Meraklı/Curious

        // Fallbacks
        'hands-praying': '🤲',
        'sparkles': '✨',
        'fire': '🔥',
        'leaf': '🌿',
        'star': '⭐',
        'cloud': '☁️',
        'bolt': '⚡',
        'peace': '☮️',
        'smile': '😊',
        'frown': '😔',
        'meh': '😐',
        'angry': '😠',
        'tired': '😴',
        'confused': '😕',
        'hopeful': '🙏',
      };
      emoji = iconMap[json['icon']] ?? '😊';
    }

    return MoodModel(
      id: json['id'] as String,
      emoji: emoji,
      label: _parseLocalizedMap(json['labels'] ?? json['label']),
      description: _parseLocalizedMap(json['descriptions'] ?? json['description'] ?? {}),
      suggestedDhikrIds: (json['recommended_dhikr_suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['suggested_dhikr_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      suggestedEsmaIds: (json['suggested_esma_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ayahReferences: (json['ayah_references'] as List<dynamic>?)
              ?.map((e) => AyahReference.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reflectionPrompts: _parseLocalizedMap(json['reflection_prompts'] ?? {}),
    );
  }

  static Map<String, String> _parseLocalizedMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }
}

class AyahReference {
  final String surah;
  final int surahNumber;
  final int ayahStart;
  final int? ayahEnd;
  final String? arabicText;
  final Map<String, String> themeNote; // tr, en, fi
  final bool needsTextVerification;

  const AyahReference({
    required this.surah,
    this.surahNumber = 0,
    required this.ayahStart,
    this.ayahEnd,
    this.arabicText,
    this.themeNote = const {},
    this.needsTextVerification = true,
  });

  String getThemeNote(String languageCode) {
    return themeNote[languageCode] ?? themeNote['tr'] ?? '';
  }

  /// Get Arabic text - returns stored text or fetches from known ayahs
  String? getArabicText() {
    if (arabicText != null && arabicText!.isNotEmpty) {
      return arabicText;
    }
    // Return known Arabic texts for common ayahs
    return _knownArabicTexts['$surahNumber:$ayahStart'];
  }

  /// Known Arabic texts for frequently referenced ayahs
  static const Map<String, String> _knownArabicTexts = {
    // Ar-Ra'd 13:28 - Kalpler ancak Allah'ı anmakla huzur bulur
    '13:28': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    // Al-Baqarah 2:286 - Allah kimseye gücünün yetmeyeceği yük yüklemez
    '2:286': 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
    // At-Talaq 65:2-3 - Kim Allah'a tevekkül ederse
    '65:2': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا ۞ وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ ۚ وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
    // Ali Imran 3:173 - Hasbunallah
    '3:173': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    // Ash-Sharh 94:5-6 - Zorlukla beraber kolaylık
    '94:5': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۞ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    // Yusuf 12:86 - Hüznümü Allah'a arz ediyorum
    '12:86': 'إِنَّمَا أَشْكُو بَثِّي وَحُزْنِي إِلَى اللَّهِ',
    // Yusuf 12:87 - Allah'ın rahmetinden ümit kesmeyin
    '12:87': 'وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ',
    // Az-Zumar 39:53 - Rahmetinden ümit kesmeyin
    '39:53': 'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا',
    // Ibrahim 14:7 - Şükrederseniz artırırım
    '14:7': 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
    // Ar-Rahman 55:13 - Nimetlerden hangisini yalanlarsınız
    '55:13': 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ',
    // Al-Baqarah 2:152 - Beni anın
    '2:152': 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
    // Al-Baqarah 2:186 - Ben yakınım
    '2:186': 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ',
    // Al-Hadid 57:4 - Nerede olursanız O sizinle
    '57:4': 'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ',
    // Qaf 50:16 - Şah damarından yakın
    '50:16': 'وَنَحْنُ أَقْرَبُ إِلَيْهِ مِنْ حَبْلِ الْوَرِيدِ',
    // Ali Imran 3:134 - Öfkelerini yutanlar
    '3:134': 'وَالْكَاظِمِينَ الْغَيْظَ وَالْعَافِينَ عَنِ النَّاسِ ۗ وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ',
    // Ta-Ha 20:25-26 - Rabbim göğsümü aç
    '20:25': 'رَبِّ اشْرَحْ لِي صَدْرِي ۞ وَيَسِّرْ لِي أَمْرِي',
    // Al-Fatiha 1:6 - Doğru yola ilet
    '1:6': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
    // An-Nur 24:35 - Allah göklerin ve yerin nurudur
    '24:35': 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ',
    // Ta-Ha 20:114 - Rabbim ilmimi artır
    '20:114': 'رَّبِّ زِدْنِي عِلْمًا',
    // Al-Baqarah 2:255 - Ayetel Kursi (beginning)
    '2:255': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ',
    // Al-Fajr 89:27-30 - Ey huzura kavuşmuş nefis
    '89:27': 'يَا أَيَّتُهَا النَّفْسُ الْمُطْمَئِنَّةُ ۞ ارْجِعِي إِلَىٰ رَبِّكِ رَاضِيَةً مَّرْضِيَّةً',
    // Yunus 10:62 - Allah'ın velilerine korku yoktur
    '10:62': 'أَلَا إِنَّ أَوْلِيَاءَ اللَّهِ لَا خَوْفٌ عَلَيْهِمْ وَلَا هُمْ يَحْزَنُونَ',
    // At-Tawbah 9:51 - Allah'ın yazdığından başkası ulaşmaz
    '9:51': 'قُل لَّن يُصِيبَنَا إِلَّا مَا كَتَبَ اللَّهُ لَنَا',
    // At-Tin 95:4 - En güzel biçimde yarattık
    '95:4': 'لَقَدْ خَلَقْنَا الْإِنسَانَ فِي أَحْسَنِ تَقْوِيمٍ',
    // Al-Isra 17:70 - Ademoğullarını şerefli kıldık
    '17:70': 'وَلَقَدْ كَرَّمْنَا بَنِي آدَمَ',
    // Ali Imran 3:139 - Gevşemeyin üzülmeyin
    '3:139': 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ',
    // Ar-Ra'd 13:11 - Bir toplum kendini değiştirmedikçe
    '13:11': 'إِنَّ اللَّهَ لَا يُغَيِّرُ مَا بِقَوْمٍ حَتَّىٰ يُغَيِّرُوا مَا بِأَنفُسِهِمْ',
    // An-Najm 53:39 - İnsan için ancak çalıştığı vardır
    '53:39': 'وَأَن لَّيْسَ لِلْإِنسَانِ إِلَّا مَا سَعَىٰ',
    // Al-Baqarah 2:153 - Sabır ve namazla yardım isteyin
    '2:153': 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
    // Ad-Duha 93:7 - Şaşırmış bulup yola iletti
    '93:7': 'وَوَجَدَكَ ضَالًّا فَهَدَىٰ',
    // Al-Baqarah 2:155-157 - Sabredenlere müjde
    '2:155': 'وَلَنَبْلُوَنَّكُم بِشَيْءٍ مِّنَ الْخَوْفِ وَالْجُوعِ وَنَقْصٍ مِّنَ الْأَمْوَالِ وَالْأَنفُسِ وَالثَّمَرَاتِ ۗ وَبَشِّرِ الصَّابِرِينَ',
    // At-Tawbah 9:40 - Üzülme Allah bizimle
    '9:40': 'لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا',
    // Al-Mujadila 58:7 - Üç kişinin dördüncüsü O'dur
    '58:7': 'مَا يَكُونُ مِن نَّجْوَىٰ ثَلَاثَةٍ إِلَّا هُوَ رَابِعُهُمْ',
    // Ash-Shura 42:37 - Öfkelendiklerinde affedenler
    '42:37': 'وَالَّذِينَ يَجْتَنِبُونَ كَبَائِرَ الْإِثْمِ وَالْفَوَاحِشَ وَإِذَا مَا غَضِبُوا هُمْ يَغْفِرُونَ',
    // Al-A'raf 7:199 - Affı esas al
    '7:199': 'خُذِ الْعَفْوَ وَأْمُرْ بِالْعُرْفِ وَأَعْرِضْ عَنِ الْجَاهِلِينَ',
    // Fussilat 41:34 - Kötülüğü iyilikle sav
    '41:34': 'وَلَا تَسْتَوِي الْحَسَنَةُ وَلَا السَّيِّئَةُ ۚ ادْفَعْ بِالَّتِي هِيَ أَحْسَنُ فَإِذَا الَّذِي بَيْنَكَ وَبَيْنَهُ عَدَاوَةٌ كَأَنَّهُ وَلِيٌّ حَمِيمٌ',
    // Ash-Shura 42:43 - Sabreden ve affeden
    '42:43': 'وَلَمَن صَبَرَ وَغَفَرَ إِنَّ ذَٰلِكَ لَمِنْ عَزْمِ الْأُمُورِ',
    // Ash-Sharh 94:1-4 - Göğsünü açmadık mı
    '94:1': 'أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ ۞ وَوَضَعْنَا عَنكَ وِزْرَكَ ۞ الَّذِي أَنقَضَ ظَهْرَكَ ۞ وَرَفَعْنَا لَكَ ذِكْرَكَ',
    // Ash-Sharh 94:7-8 - Boş kaldığında kalk
    '94:7': 'فَإِذَا فَرَغْتَ فَانصَبْ ۞ وَإِلَىٰ رَبِّكَ فَارْغَب',
    // Al-Muzzammil 73:20 - Allah kolaylık diler
    '73:20': 'عَلِمَ أَن لَّن تُحْصُوهُ فَتَابَ عَلَيْكُمْ',
    // Qaf 50:38 - Biz yorulmadık
    '50:38': 'وَلَقَدْ خَلَقْنَا السَّمَاوَاتِ وَالْأَرْضَ وَمَا بَيْنَهُمَا فِي سِتَّةِ أَيَّامٍ وَمَا مَسَّنَا مِن لُّغُوبٍ',
    // Ta-Ha 20:130 - Sabret ve tesbih et
    '20:130': 'فَاصْبِرْ عَلَىٰ مَا يَقُولُونَ وَسَبِّحْ بِحَمْدِ رَبِّكَ قَبْلَ طُلُوعِ الشَّمْسِ وَقَبْلَ غُرُوبِهَا',
    // Al-Anfal 8:2 - Müminlerin kalpleri titrer
    '8:2': 'إِنَّمَا الْمُؤْمِنُونَ الَّذِينَ إِذَا ذُكِرَ اللَّهُ وَجِلَتْ قُلُوبُهُمْ وَإِذَا تُلِيَتْ عَلَيْهِمْ آيَاتُهُ زَادَتْهُمْ إِيمَانًا',
    // At-Talaq 65:7 - Zorluktan sonra kolaylık
    '65:7': 'سَيَجْعَلُ اللَّهُ بَعْدَ عُسْرٍ يُسْرًا',
    // Al-An'am 6:17 - Sıkıntıyı Allah giderir
    '6:17': 'وَإِن يَمْسَسْكَ اللَّهُ بِضُرٍّ فَلَا كَاشِفَ لَهُ إِلَّا هُوَ',
    // An-Nahl 16:18 - Nimetleri sayamazsınız
    '16:18': 'وَإِن تَعُدُّوا نِعْمَةَ اللَّهِ لَا تُحْصُوهَا',
    // Luqman 31:12 - Kim şükrederse kendisi için
    '31:12': 'وَمَن يَشْكُرْ فَإِنَّمَا يَشْكُرُ لِنَفْسِهِ',
    // Al-Fath 48:4 - Kalplere sekine indiren
    '48:4': 'هُوَ الَّذِي أَنزَلَ السَّكِينَةَ فِي قُلُوبِ الْمُؤْمِنِينَ',
    // Al-An'am 6:82 - İman edenlere güven
    '6:82': 'الَّذِينَ آمَنُوا وَلَمْ يَلْبِسُوا إِيمَانَهُم بِظُلْمٍ أُولَٰئِكَ لَهُمُ الْأَمْنُ وَهُم مُّهْتَدُونَ',
  };

  String get reference {
    if (ayahEnd != null && ayahEnd != ayahStart) {
      return '$surah:$ayahStart-$ayahEnd';
    }
    return '$surah:$ayahStart';
  }

  factory AyahReference.fromJson(Map<String, dynamic> json) {
    // Handle surah as either String or int
    String surahStr;
    int surahNum = 0;
    if (json['surah'] is int) {
      surahNum = json['surah'] as int;
      surahStr = json['surah_name'] as String? ?? 'Surah $surahNum';
    } else {
      surahStr = json['surah'] as String? ?? '';
    }

    return AyahReference(
      surah: surahStr,
      surahNumber: surahNum,
      ayahStart: json['ayah'] as int? ?? json['ayah_start'] as int,
      ayahEnd: json['ayah_end'] as int?,
      arabicText: json['arabic_text'] as String?,
      themeNote: _parseLocalizedMap(json['theme_notes'] ?? json['theme_note'] ?? {}),
      needsTextVerification: json['needs_text_verification'] as bool? ?? true,
    );
  }

  static Map<String, String> _parseLocalizedMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }
}

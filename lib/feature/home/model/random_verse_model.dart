class RandomVerseResponse {
  final int statusCode;
  final bool success;
  final String message;
  final RandomVerseData data;
  final Meta meta;

  RandomVerseResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory RandomVerseResponse.fromJson(Map<String, dynamic> json) {
    return RandomVerseResponse(
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: RandomVerseData.fromJson(json['data'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }
}

class RandomVerseData {
  final Verse verse;
  final String language;

  RandomVerseData({required this.verse, required this.language});

  factory RandomVerseData.fromJson(Map<String, dynamic> json) {
    return RandomVerseData(
      verse: Verse.fromJson(json['verse'] ?? {}),
      language: json['language'] ?? 'en',
    );
  }
}

class Verse {
  final int verseId;
  final int surahId;
  final String text;

  Verse({required this.verseId, required this.surahId, required this.text});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      verseId: json['verseId'] ?? 0,
      surahId: json['surahId'] ?? 0,
      text: json['text'] ?? '',
    );
  }
}

class Meta {
  final String language;

  Meta({required this.language});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(language: json['language'] ?? 'en');
  }
}

// Surah names mapping for quick lookup
class SurahNames {
  static const Map<int, Map<String, String>> surahMap = {
    1: {'en': 'Al-Fatihah', 'ar': 'الفاتحة'},
    2: {'en': 'Al-Baqarah', 'ar': 'البقرة'},
    3: {'en': 'Ali \'Imran', 'ar': 'آل عمران'},
    4: {'en': 'An-Nisa', 'ar': 'النساء'},
    5: {'en': 'Al-Ma\'idah', 'ar': 'المائدة'},
    6: {'en': 'Al-An\'am', 'ar': 'الأنعام'},
    7: {'en': 'Al-A\'raf', 'ar': 'الأعراف'},
    8: {'en': 'Al-Anfal', 'ar': 'الأنفال'},
    9: {'en': 'At-Tawbah', 'ar': 'التوبة'},
    10: {'en': 'Yunus', 'ar': 'يونس'},
    11: {'en': 'Hud', 'ar': 'هود'},
    12: {'en': 'Yusuf', 'ar': 'يوسف'},
    13: {'en': 'Ar-Ra\'d', 'ar': 'الرعد'},
    14: {'en': 'Ibrahim', 'ar': 'ابراهيم'},
    15: {'en': 'Al-Hijr', 'ar': 'الحجر'},
    16: {'en': 'An-Nahl', 'ar': 'النحل'},
    17: {'en': 'Al-Isra', 'ar': 'الإسراء'},
    18: {'en': 'Al-Kahf', 'ar': 'الكهف'},
    19: {'en': 'Maryam', 'ar': 'مريم'},
    20: {'en': 'Taha', 'ar': 'طه'},
    21: {'en': 'Al-Anbya', 'ar': 'الأنبياء'},
    22: {'en': 'Al-Hajj', 'ar': 'الحج'},
    23: {'en': 'Al-Mu\'minun', 'ar': 'المؤمنون'},
    24: {'en': 'An-Nur', 'ar': 'النور'},
    25: {'en': 'Al-Furqan', 'ar': 'الفرقان'},
    26: {'en': 'Ash-Shu\'ara', 'ar': 'الشعراء'},
    27: {'en': 'An-Naml', 'ar': 'النمل'},
    28: {'en': 'Al-Qasas', 'ar': 'القصص'},
    29: {'en': 'Al-\'Ankabut', 'ar': 'العنكبوت'},
    30: {'en': 'Ar-Rum', 'ar': 'الروم'},
    31: {'en': 'Luqman', 'ar': 'لقمان'},
    32: {'en': 'As-Sajdah', 'ar': 'السجدة'},
    33: {'en': 'Al-Ahzab', 'ar': 'الأحزاب'},
    34: {'en': 'Saba', 'ar': 'سبإ'},
    35: {'en': 'Fatir', 'ar': 'فاطر'},
    36: {'en': 'Ya-Sin', 'ar': 'يس'},
    37: {'en': 'As-Saffat', 'ar': 'الصافات'},
    38: {'en': 'Sad', 'ar': 'ص'},
    39: {'en': 'Az-Zumar', 'ar': 'الزمر'},
    40: {'en': 'Ghafir', 'ar': 'غافر'},
    41: {'en': 'Fussilat', 'ar': 'فصلت'},
    42: {'en': 'Ash-Shuraa', 'ar': 'الشورى'},
    43: {'en': 'Az-Zukhruf', 'ar': 'الزخرف'},
    44: {'en': 'Ad-Dukhan', 'ar': 'الدخان'},
    45: {'en': 'Al-Jathiyah', 'ar': 'الجاثية'},
    46: {'en': 'Al-Ahqaf', 'ar': 'الأحقاف'},
    47: {'en': 'Muhammad', 'ar': 'محمد'},
    48: {'en': 'Al-Fath', 'ar': 'الفتح'},
    49: {'en': 'Al-Hujurat', 'ar': 'الحجرات'},
    50: {'en': 'Qaf', 'ar': 'ق'},
    51: {'en': 'Adh-Dhariyat', 'ar': 'الذاريات'},
    52: {'en': 'At-Tur', 'ar': 'الطور'},
    53: {'en': 'An-Najm', 'ar': 'النجم'},
    54: {'en': 'Al-Qamar', 'ar': 'القمر'},
    55: {'en': 'Ar-Rahman', 'ar': 'الرحمن'},
    56: {'en': 'Al-Waqi\'ah', 'ar': 'الواقعة'},
    57: {'en': 'Al-Hadid', 'ar': 'الحديد'},
    58: {'en': 'Al-Mujadila', 'ar': 'المجادلة'},
    59: {'en': 'Al-Hashr', 'ar': 'الحشر'},
    60: {'en': 'Al-Mumtahanah', 'ar': 'الممتحنة'},
    61: {'en': 'As-Saf', 'ar': 'الصف'},
    62: {'en': 'Al-Jumu\'ah', 'ar': 'الجمعة'},
    63: {'en': 'Al-Munafiqun', 'ar': 'المنافقون'},
    64: {'en': 'At-Taghabun', 'ar': 'التغابن'},
    65: {'en': 'At-Talaq', 'ar': 'الطلاق'},
    66: {'en': 'At-Tahrim', 'ar': 'التحريم'},
    67: {'en': 'Al-Mulk', 'ar': 'الملك'},
    68: {'en': 'Al-Qalam', 'ar': 'القلم'},
    69: {'en': 'Al-Haqqah', 'ar': 'الحاقة'},
    70: {'en': 'Al-Ma\'arij', 'ar': 'المعارج'},
    71: {'en': 'Nuh', 'ar': 'نوح'},
    72: {'en': 'Al-Jinn', 'ar': 'الجن'},
    73: {'en': 'Al-Muzzammil', 'ar': 'المزمل'},
    74: {'en': 'Al-Muddaththir', 'ar': 'المدثر'},
    75: {'en': 'Al-Qiyamah', 'ar': 'القيامة'},
    76: {'en': 'Al-Insan', 'ar': 'الانسان'},
    77: {'en': 'Al-Mursalat', 'ar': 'المرسلات'},
    78: {'en': 'An-Naba', 'ar': 'النبإ'},
    79: {'en': 'An-Nazi\'at', 'ar': 'النازعات'},
    80: {'en': 'Abasa', 'ar': 'عبس'},
    81: {'en': 'At-Takwir', 'ar': 'التكوير'},
    82: {'en': 'Al-Infitar', 'ar': 'الإنفطار'},
    83: {'en': 'Al-Mutaffifin', 'ar': 'المطففين'},
    84: {'en': 'Al-Inshiqaq', 'ar': 'الإنشقاق'},
    85: {'en': 'Al-Buruj', 'ar': 'البروج'},
    86: {'en': 'At-Tariq', 'ar': 'الطارق'},
    87: {'en': 'Al-A\'la', 'ar': 'الأعلى'},
    88: {'en': 'Al-Ghashiyah', 'ar': 'الغاشية'},
    89: {'en': 'Al-Fajr', 'ar': 'الفجر'},
    90: {'en': 'Al-Balad', 'ar': 'البلد'},
    91: {'en': 'Ash-Shams', 'ar': 'الشمس'},
    92: {'en': 'Al-Layl', 'ar': 'الليل'},
    93: {'en': 'Ad-Duhaa', 'ar': 'الضحى'},
    94: {'en': 'Ash-Sharh', 'ar': 'الشرح'},
    95: {'en': 'At-Tin', 'ar': 'التين'},
    96: {'en': 'Al-\'Alaq', 'ar': 'العلق'},
    97: {'en': 'Al-Qadr', 'ar': 'القدر'},
    98: {'en': 'Al-Bayyinah', 'ar': 'البينة'},
    99: {'en': 'Az-Zalzalah', 'ar': 'الزلزلة'},
    100: {'en': 'Al-\'Adiyat', 'ar': 'العاديات'},
    101: {'en': 'Al-Qari\'ah', 'ar': 'القارعة'},
    102: {'en': 'At-Takathur', 'ar': 'التكاثر'},
    103: {'en': 'Al-\'Asr', 'ar': 'العصر'},
    104: {'en': 'Al-Humazah', 'ar': 'الهمزة'},
    105: {'en': 'Al-Fil', 'ar': 'الفيل'},
    106: {'en': 'Quraysh', 'ar': 'قريش'},
    107: {'en': 'Al-Ma\'un', 'ar': 'الماعون'},
    108: {'en': 'Al-Kawthar', 'ar': 'الكوثر'},
    109: {'en': 'Al-Kafirun', 'ar': 'الكافرون'},
    110: {'en': 'An-Nasr', 'ar': 'النصر'},
    111: {'en': 'Al-Masad', 'ar': 'المسد'},
    112: {'en': 'Al-Ikhlas', 'ar': 'الإخلاص'},
    113: {'en': 'Al-Falaq', 'ar': 'الفلق'},
    114: {'en': 'An-Nas', 'ar': 'الناس'},
  };

  static String getSurahName(int surahId, {String lang = 'en'}) {
    return surahMap[surahId]?[lang] ?? 'Unknown Surah';
  }
}

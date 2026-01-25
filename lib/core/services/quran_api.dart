import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class QuranAPI {
  static const String baseUrl = 'https://api.alquran.cloud/v1';
  
  // Cache for offline data
  static Map<String, dynamic>? _cachedArabicData;
  static Map<String, dynamic>? _cachedEnglishData;

  // Load data from local assets (offline-first)
  static Future<void> _loadLocalData() async {
    if (_cachedArabicData == null) {
      try {
        final arabicString = await rootBundle.loadString('assets/data/quran/quran_arabic.json');
        _cachedArabicData = json.decode(arabicString);
        print('Arabic data loaded successfully');
      } catch (e) {
        print('Error loading local Arabic data: $e');
      }
    }

    if (_cachedEnglishData == null) {
      try {
        final englishString = await rootBundle.loadString('assets/data/quran/quran_english.json');
        _cachedEnglishData = json.decode(englishString);
        print('English data loaded successfully');
      } catch (e) {
        print('Error loading local English data: $e');
      }
    }
  }

  // Get list of all Surahs (offline-first)
  static Future<List<Surah>> getAllSurahs() async {
    try {
      // Try to load from local assets first
      await _loadLocalData();
      
      if (_cachedArabicData != null && _cachedArabicData!['data'] != null) {
        final surahs = (_cachedArabicData!['data']['surahs'] as List)
            .map((s) => Surah.fromJson(s))
            .toList();
        print('Loaded ${surahs.length} surahs from local data');
        return surahs;
      }
    } catch (e) {
      print('Error loading local surahs: $e');
    }

    // Fallback to online API if local data not available
    try {
      final response = await http.get(Uri.parse('$baseUrl/surah'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final surahs = (data['data'] as List)
            .map((s) => Surah.fromJson(s))
            .toList();
        return surahs;
      }
    } catch (e) {
      print('Error fetching online surahs: $e');
    }

    return [];
  }

  // Get a specific Surah with translation (offline-first)
  static Future<SurahDetail?> getSurahWithTranslation(int number) async {
    try {
      // Load from local assets
      await _loadLocalData();

      if (_cachedArabicData != null && _cachedEnglishData != null) {
        final arabicSurahs = _cachedArabicData!['data']['surahs'] as List;
        final englishSurahs = _cachedEnglishData!['data']['surahs'] as List;

        if (number > 0 && number <= arabicSurahs.length) {
          final arabicSurah = arabicSurahs[number - 1];
          final englishSurah = englishSurahs[number - 1];

          List<Ayah> ayahs = [];
          final arabicAyahs = arabicSurah['ayahs'] as List;
          final englishAyahs = englishSurah['ayahs'] as List;

          for (int i = 0; i < arabicAyahs.length; i++) {
            ayahs.add(Ayah(
              number: arabicAyahs[i]['number'] ?? 0,
              text: arabicAyahs[i]['text'] ?? '',
              numberInSurah: arabicAyahs[i]['numberInSurah'] ?? (i + 1),
              translation: i < englishAyahs.length ? englishAyahs[i]['text'] : null,
            ));
          }

          return SurahDetail(
            number: arabicSurah['number'] ?? 0,
            name: arabicSurah['name'] ?? '',
            englishName: arabicSurah['englishName'] ?? '',
            englishNameTranslation: arabicSurah['englishNameTranslation'] ?? '',
            numberOfAyahs: arabicSurah['numberOfAyahs'] ?? ayahs.length,
            ayahs: ayahs,
          );
        }
      }
    } catch (e) {
      print('Error loading local surah: $e');
    }

    // Fallback to online API
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/surah/$number/editions/quran-uthmani,en.asad'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SurahDetail.fromJsonWithTranslation(data['data']);
      }
    } catch (e) {
      print('Error fetching online surah: $e');
    }

    return null;
  }

  // Get a specific Surah (offline-first)
  static Future<SurahDetail?> getSurah(int number) async {
    try {
      await _loadLocalData();

      if (_cachedArabicData != null) {
        final surahs = _cachedArabicData!['data']['surahs'] as List;
        if (number > 0 && number <= surahs.length) {
          return SurahDetail.fromJson(surahs[number - 1]);
        }
      }
    } catch (e) {
      print('Error loading local surah: $e');
    }

    // Fallback to online API
    try {
      final response = await http.get(Uri.parse('$baseUrl/surah/$number'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SurahDetail.fromJson(data['data']);
      }
    } catch (e) {
      print('Error fetching online surah: $e');
    }

    return null;
  }
}

// Models
class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      englishNameTranslation: json['englishNameTranslation'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? 0,
      revelationType: json['revelationType'] ?? 'Meccan',
    );
  }
}

class SurahDetail {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final List<Ayah> ayahs;

  SurahDetail({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.ayahs,
  });

  factory SurahDetail.fromJson(Map<String, dynamic> json) {
    return SurahDetail(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      englishNameTranslation: json['englishNameTranslation'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? 0,
      ayahs: (json['ayahs'] as List? ?? [])
          .map((a) => Ayah.fromJson(a))
          .toList(),
    );
  }

  factory SurahDetail.fromJsonWithTranslation(List<dynamic> data) {
    final arabic = data[0];
    final translation = data[1];
    
    List<Ayah> ayahs = [];
    for (int i = 0; i < arabic['ayahs'].length; i++) {
      ayahs.add(Ayah(
        number: arabic['ayahs'][i]['number'] ?? 0,
        text: arabic['ayahs'][i]['text'] ?? '',
        numberInSurah: arabic['ayahs'][i]['numberInSurah'] ?? (i + 1),
        translation: translation['ayahs'][i]['text'],
      ));
    }

    return SurahDetail(
      number: arabic['number'] ?? 0,
      name: arabic['name'] ?? '',
      englishName: arabic['englishName'] ?? '',
      englishNameTranslation: arabic['englishNameTranslation'] ?? '',
      numberOfAyahs: arabic['numberOfAyahs'] ?? ayahs.length,
      ayahs: ayahs,
    );
  }
}

class Ayah {
  final int number;
  final String text;
  final int numberInSurah;
  final String? translation;

  Ayah({
    required this.number,
    required this.text,
    required this.numberInSurah,
    this.translation,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] ?? 0,
      text: json['text'] ?? '',
      numberInSurah: json['numberInSurah'] ?? 0,
    );
  }
}
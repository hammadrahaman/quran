import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class QuranAPI {
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  static Map<String, dynamic>? _cachedArabicData;
  static Map<String, dynamic>? _cachedEnglishData;

  static Future<void> _loadLocalData() async {
    if (_cachedArabicData == null) {
      final arabicString = await rootBundle.loadString('assets/data/quran/quran_arabic.json');
      _cachedArabicData = json.decode(arabicString);
    }
    if (_cachedEnglishData == null) {
      final englishString = await rootBundle.loadString('assets/data/quran/quran_english.json');
      _cachedEnglishData = json.decode(englishString);
    }
  }

  static bool _looksLikeBismillah(String s) {
    final t = s.replaceAll('\uFEFF', '').trim(); // remove BOM if present
    // Works for both "simple" and "uthmani" text
    return t.contains('بسم') &&
        t.contains('الله') &&
        t.contains('الرحمن') &&
        t.contains('الرحيم');
  }

  static List<Ayah> _stripBismillahIfNeeded(int surahNumber, List<Ayah> ayahs) {
    // Surah 9 has no Bismillah header.
    // Surah 1: Bismillah is commonly treated as Ayah 1 (keep it as-is).
    if (surahNumber == 9 || surahNumber == 1) return ayahs;
    if (ayahs.isEmpty) return ayahs;

    // If dataset prepends Bismillah as first ayah, remove it so UI can show it as header.
    if (_looksLikeBismillah(ayahs.first.text)) {
      return ayahs.sublist(1);
    }
    return ayahs;
  }

  static Future<List<Surah>> getAllSurahs() async {
    try {
      await _loadLocalData();
      final surahs = (_cachedArabicData?['data']?['surahs'] as List? ?? [])
          .map((s) => Surah.fromJson(s as Map<String, dynamic>))
          .toList();
      if (surahs.isNotEmpty) return surahs;
    } catch (_) {}

    try {
      final response = await http.get(Uri.parse('$baseUrl/surah'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List).map((s) => Surah.fromJson(s)).toList();
      }
    } catch (_) {}

    return [];
  }

  static Future<SurahDetail?> getSurahWithTranslation(int number) async {
    // 1) Offline-first
    try {
      await _loadLocalData();

      final arabicSurahs = _cachedArabicData?['data']?['surahs'] as List?;
      final englishSurahs = _cachedEnglishData?['data']?['surahs'] as List?;

      if (arabicSurahs != null &&
          englishSurahs != null &&
          number > 0 &&
          number <= arabicSurahs.length &&
          number <= englishSurahs.length) {
        final arabicSurah = arabicSurahs[number - 1] as Map<String, dynamic>;
        final englishSurah = englishSurahs[number - 1] as Map<String, dynamic>;

        final arabicAyahs = (arabicSurah['ayahs'] as List? ?? []);
        final englishAyahs = (englishSurah['ayahs'] as List? ?? []);

        final built = <Ayah>[];
        for (int i = 0; i < arabicAyahs.length; i++) {
          final a = arabicAyahs[i] as Map<String, dynamic>;
          final tr = (i < englishAyahs.length) ? (englishAyahs[i] as Map<String, dynamic>) : null;

          built.add(
            Ayah(
              number: a['number'] ?? 0, // GLOBAL ayah number (needed for audio)
              text: a['text'] ?? '',
              numberInSurah: a['numberInSurah'] ?? (i + 1),
              translation: tr?['text'] as String?,
            ),
          );
        }

        final ayahs = _stripBismillahIfNeeded(number, built);

        return SurahDetail(
          number: arabicSurah['number'] ?? number,
          name: arabicSurah['name'] ?? '',
          englishName: arabicSurah['englishName'] ?? '',
          englishNameTranslation: arabicSurah['englishNameTranslation'] ?? '',
          numberOfAyahs: ayahs.length, // after stripping
          ayahs: ayahs,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading local surah: $e');
    }

    // 2) Online fallback (Uthmani)
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/surah/$number/editions/quran-uthmani,en.asad'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detail = SurahDetail.fromJsonWithTranslation(data['data']);
        final ayahs = _stripBismillahIfNeeded(number, detail.ayahs);
        return SurahDetail(
          number: detail.number,
          name: detail.name,
          englishName: detail.englishName,
          englishNameTranslation: detail.englishNameTranslation,
          numberOfAyahs: ayahs.length,
          ayahs: ayahs,
        );
      }
    } catch (e) {
      // ignore: avoid_print
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

  factory SurahDetail.fromJsonWithTranslation(List<dynamic> data) {
    final arabic = data[0];
    final translation = data[1];

    final built = <Ayah>[];
    for (int i = 0; i < (arabic['ayahs'] as List).length; i++) {
      built.add(
        Ayah(
          number: arabic['ayahs'][i]['number'] ?? 0,
          text: arabic['ayahs'][i]['text'] ?? '',
          numberInSurah: arabic['ayahs'][i]['numberInSurah'] ?? (i + 1),
          translation: translation['ayahs'][i]['text'],
        ),
      );
    }

    return SurahDetail(
      number: arabic['number'] ?? 0,
      name: arabic['name'] ?? '',
      englishName: arabic['englishName'] ?? '',
      englishNameTranslation: arabic['englishNameTranslation'] ?? '',
      numberOfAyahs: arabic['numberOfAyahs'] ?? built.length,
      ayahs: built,
    );
  }
}

class Ayah {
  final int number; // GLOBAL ayah number (audio uses this)
  final String text;
  final int numberInSurah;
  final String? translation;

  Ayah({
    required this.number,
    required this.text,
    required this.numberInSurah,
    this.translation,
  });
}
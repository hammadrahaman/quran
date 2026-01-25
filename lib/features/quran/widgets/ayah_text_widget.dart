import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AyahTextWidget extends StatelessWidget {
  final String text;
  final int ayahNumber;
  final double fontSize;
  final bool isDark;
  final int surahNumber;
  final int ayahIndex;

  const AyahTextWidget({
    super.key,
    required this.text,
    required this.ayahNumber,
    required this.fontSize,
    required this.isDark,
    required this.surahNumber,
    required this.ayahIndex,
  });

  String _convertToArabicNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    
    String result = number.toString();
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  // Check if ayah 1 is ONLY Bismillah (no other content)
  bool _isAyahOnlyBismillah() {
    // Surah 1 (Al-Fatiha): Ayah 1 IS Bismillah
    if (surahNumber == 1 && ayahIndex == 0) {
      return true;
    }
    
    // For other surahs, if ayah 1 is very short (< 50 chars), 
    // it's likely ONLY Bismillah
    if (surahNumber != 9 && ayahIndex == 0 && text.length < 50) {
      return true;
    }
    
    return false;
  }

 @override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 32,
    ),
    decoration: BoxDecoration(
      color: isDark 
          ? const Color(0xFF0A0A0A)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: RichText(
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        children: [
          // Arabic ayah text - NO FILTERING
          TextSpan(
            text: text,
            style: const TextStyle(
              fontFamily: 'UthmanicHafs',
              fontSize: 44,
              fontWeight: FontWeight.normal,
              height: 2.5,
              letterSpacing: 0,
            ).copyWith(
              color: isDark ? Colors.white : const Color(0xFF000000),
            ),
          ),
          // Ayah number in decorative circle
          TextSpan(
            text: ' ﴿${_convertToArabicNumber(ayahNumber)}﴾',
            style: GoogleFonts.amiriQuran(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.teal : const Color(0xFF2D8B7C),
            ),
          ),
        ],
      ),
    ),
  );
}
}
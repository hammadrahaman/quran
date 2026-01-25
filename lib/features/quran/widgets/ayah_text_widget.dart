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

 String _getCleanedText() {
  String cleanText = text.trim();
  
  // For first ayah only (except Surah 9), remove Bismillah completely
  if (surahNumber != 9 && ayahIndex == 0) {
    // Check if text contains Bismillah keywords
    final lowerText = cleanText;
    
    // If the ayah contains "بسم" (bism), likely has Bismillah - remove it
    if (lowerText.contains('بِسْمِ') || lowerText.contains('بِسۡمِ') || lowerText.contains('بسم')) {
      // Split by common word that comes AFTER Bismillah
      // Most surahs have "الم" or other text after Bismillah
      
      // Try to find where Bismillah ends - look for "الرحيم" (Ar-Raheem - last word)
      final possibleEndings = [
        'ٱلرَّحِيمِ',
        'الرَّحِيمِ', 
        'ٱلرَّحِيمِ',
        'الرحيم',
      ];
      
      for (var ending in possibleEndings) {
        if (cleanText.contains(ending)) {
          // Find the position and take everything AFTER it
          int endPos = cleanText.indexOf(ending) + ending.length;
          if (endPos < cleanText.length) {
            cleanText = cleanText.substring(endPos).trim();
            break;
          } else {
            // Bismillah is the entire ayah (like in Surah 1)
            cleanText = '';
            break;
          }
        }
      }
    }
  }
  
  return cleanText;
}

 @override
Widget build(BuildContext context) {
  // For first ayah of any surah (except Surah 9), 
  // if text starts with Bismillah, don't display it
  // since the header already shows it
  
  if (surahNumber != 9 && ayahIndex == 0) {
    // Check if the first 10 characters contain "بسم" (bism)
    if (text.length >= 10 && text.substring(0, 10).contains('بسم')) {
      // This ayah is Bismillah - don't show it
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 48,
        ),
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF0A0A0A)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.arrow_downward,
              size: 32,
              color: Colors.teal.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Bismillah is shown above\nSwipe to next ayah →',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }
  }
  
  // Normal ayah display
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
          // Arabic ayah text
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
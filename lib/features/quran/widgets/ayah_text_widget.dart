import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final arabicColor =
      isDark ? const Color(0xFFF6EDE5) : const Color(0xFF2B1B12);

  final markerColor =
      isDark ? const Color(0xFFBFAE9F) : const Color(0xFF6B4F3F);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        text: TextSpan(
          children: [
            TextSpan(
                text: text,
                style: TextStyle(
                    fontFamily: 'IndoPak',
                    fontSize: fontSize + 8,
                    height: 2.4,
                    letterSpacing: 0.0,
                    wordSpacing: 3.0,
                    color: arabicColor,
                ),
                ),
                TextSpan(
                text: ' ﴿${_convertToArabicNumber(ayahNumber)}﴾',
                style: TextStyle(
                    fontFamily: 'IndoPak',
                    fontSize: (fontSize + 8) * 0.62,
                    height: 2.4,
                    color: markerColor,
                ),
                ),
          ],
        ),
      ),
    );
  }
}
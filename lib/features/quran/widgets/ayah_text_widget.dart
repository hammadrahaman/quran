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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
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
                fontFamily: 'KFGQPCNaskh',
                fontSize: fontSize + 10,
                height: 2.35,
                letterSpacing: 0.15,
                wordSpacing: 2.0,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            TextSpan(
              text: ' ﴿${_convertToArabicNumber(ayahNumber)}﴾',
              style: TextStyle(
                fontFamily: 'KFGQPCNaskh',
                fontSize: (fontSize + 10) * 0.70,
                height: 2.35,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
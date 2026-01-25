import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BismillahHeader extends StatelessWidget {
  final double fontSize;
  final bool isDark;

  const BismillahHeader({
    super.key,
    required this.fontSize,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isDark ? Colors.teal.withOpacity(0.15) : Colors.teal.withOpacity(0.08)),
            (isDark ? Colors.teal.withOpacity(0.05) : Colors.teal.withOpacity(0.03)),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.teal.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // "Bismillah" label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Bismillah',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.w600,
              height: 2.5,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'In the Name of Allah—the Most Compassionate, Most Merciful',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AyahNavigationBar extends StatelessWidget {
  final int currentIndex;
  final int totalAyahs;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isDark;

  const AyahNavigationBar({
    super.key,
    required this.currentIndex,
    required this.totalAyahs,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            Container(
              decoration: BoxDecoration(
                color: canGoPrevious
                    ? Colors.teal.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: canGoPrevious ? onPrevious : null,
                iconSize: 20,
                color: canGoPrevious ? Colors.teal : Colors.grey,
              ),
            ),

            // Ayah counter
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Ayah ${currentIndex + 1} of $totalAyahs',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            // Next button
            Container(
              decoration: BoxDecoration(
                color: canGoNext
                    ? Colors.teal.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: canGoNext ? onNext : null,
                iconSize: 20,
                color: canGoNext ? Colors.teal : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
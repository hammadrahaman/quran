import 'package:flutter/material.dart';

class SurahCompletionDialog {
  static Future<bool> show({
    required BuildContext context,
    required String surahName,
    required int nextSurahNumber,
    required bool hasNextSurah,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Completion Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasNextSurah 
                        ? Colors.teal.withOpacity(0.1)
                        : Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasNextSurah ? Icons.check_circle : Icons.emoji_events,
                    size: 48,
                    color: hasNextSurah ? Colors.teal : Colors.amber,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  hasNextSurah ? 'Surah Completed! 🎉' : 'Alhamdulillah! 🤲',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Message
                Text(
                  hasNextSurah
                      ? 'You\'ve finished $surahName'
                      : 'You\'ve completed the entire Quran!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Buttons
                if (hasNextSurah)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: Text('Surah $nextSurahNumber'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (hasNextSurah) const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.teal),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      hasNextSurah ? 'Stay Here' : 'Close',
                      style: const TextStyle(color: Colors.teal),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    return result ?? false;
  }
}
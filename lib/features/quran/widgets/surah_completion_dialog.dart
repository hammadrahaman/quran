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
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          contentPadding: const EdgeInsets.all(24),
          content: Column(
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
                  size: 64,
                  color: hasNextSurah ? Colors.teal : Colors.amber,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                hasNextSurah ? 'Surah Completed! 🎉' : 'Alhamdulillah! 🤲',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Message
              Text(
                hasNextSurah
                    ? 'You\'ve finished $surahName'
                    : 'You\'ve completed the entire Quran!',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Buttons
              if (hasNextSurah) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text('Continue to Surah $nextSurahNumber'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.teal),
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
        );
      },
    );
    
    return result ?? false;
  }
}
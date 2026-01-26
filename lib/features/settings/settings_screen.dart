import 'package:flutter/material.dart';
import '../../core/storage/local_storage.dart';
import '../../app.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int dailyGoal = 5;
  bool isDarkMode = true;
  double arabicFontSize = 32.0;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() {
    setState(() {
      dailyGoal = LocalStorage.getDailyGoal();
      isDarkMode = LocalStorage.isDarkMode();
      arabicFontSize = LocalStorage.getArabicFontSize();
    });
  }

  void updateDailyGoal(int change) {
    setState(() {
      dailyGoal = (dailyGoal + change).clamp(1, 50);
      LocalStorage.setDailyGoal(dailyGoal);
    });
  }

  void updateFontSize(double change) {
    setState(() {
      arabicFontSize = (arabicFontSize + change).clamp(20.0, 60.0);
      LocalStorage.setArabicFontSize(arabicFontSize);
    });
  }

  void showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'Are you sure you want to reset all your progress? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
                LocalStorage.resetAllReadingStats();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Progress reset')),
                );
                },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Daily Goal
          Text(
            'Daily goal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => updateDailyGoal(-1),
                  iconSize: 32,
                  color: Colors.teal,
                ),
                Column(
                  children: [
                    Text(
                      '$dailyGoal',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'ayahs per day',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => updateDailyGoal(1),
                  iconSize: 32,
                  color: Colors.teal,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Font Size
          Text(
            'Arabic font size',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.text_decrease),
                  onPressed: () => updateFontSize(-2),
                  iconSize: 28,
                  color: Colors.teal,
                ),
                Column(
                  children: [
                    Text(
                      '${arabicFontSize.toInt()}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'font size',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.text_increase),
                  onPressed: () => updateFontSize(2),
                  iconSize: 28,
                  color: Colors.teal,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Theme
          Text(
            'Theme',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: Colors.teal,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isDarkMode ? 'Dark Mode' : 'Light Mode',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                    QuranCompanionApp.of(context)?.toggleTheme();
                  },
                  activeColor: Colors.teal,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Reset Progress
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: showResetDialog,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Reset progress',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // App info
          Center(
            child: Column(
              children: [
                Text(
                  'Quran Companion',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
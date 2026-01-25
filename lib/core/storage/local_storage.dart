import 'package:hive/hive.dart';

class LocalStorage {
  static final Box _settings = Hive.box('settings');
  static final Box _progress = Hive.box('progress');
  static final Box _bookmarks = Hive.box('bookmarks');

  // Daily goal
  static int getDailyGoal() =>
      _settings.get('dailyGoal', defaultValue: 5);

  static void setDailyGoal(int goal) =>
      _settings.put('dailyGoal', goal);

  // Theme
  static bool isDarkMode() =>
      _settings.get('isDarkMode', defaultValue: true);

  static void setDarkMode(bool isDark) =>
      _settings.put('isDarkMode', isDark);

  // Font Size (for Arabic text)
  static double getArabicFontSize() =>
      _settings.get('arabicFontSize', defaultValue: 32.0);

  static void setArabicFontSize(double size) =>
      _settings.put('arabicFontSize', size);

  // Progress tracking
  static bool isCompleted(String dateKey) =>
      _progress.get(dateKey, defaultValue: false);

  static void markCompleted(String dateKey) =>
      _progress.put(dateKey, true);

  static void resetToday(String dateKey) =>
      _progress.delete(dateKey);

  static Map<String, bool> getAllProgress() {
    final Map<String, bool> progress = {};
    for (var key in _progress.keys) {
      progress[key.toString()] = _progress.get(key);
    }
    return progress;
  }

  static int getTotalDaysRead() {
    return _progress.keys.length;
  }

  // Last read position
  static void saveLastRead(int surahNumber, int ayahNumber) {
    _settings.put('lastSurah', surahNumber);
    _settings.put('lastAyah', ayahNumber);
  }

  static Map<String, int> getLastRead() {
    return {
      'surah': _settings.get('lastSurah', defaultValue: 1),
      'ayah': _settings.get('lastAyah', defaultValue: 1),
    };
  }

  // Bookmarks - UNLIMITED storage (limited only by device capacity)
  static String _getBookmarkKey(int surahNumber, int ayahNumber) {
    return '$surahNumber:$ayahNumber';
  }

  static void addBookmark({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    String? note,
  }) {
    final key = _getBookmarkKey(surahNumber, ayahNumber);
    _bookmarks.put(key, {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'surahName': surahName,
      'note': note ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void removeBookmark(int surahNumber, int ayahNumber) {
    final key = _getBookmarkKey(surahNumber, ayahNumber);
    _bookmarks.delete(key);
  }

  static bool isBookmarked(int surahNumber, int ayahNumber) {
    final key = _getBookmarkKey(surahNumber, ayahNumber);
    return _bookmarks.containsKey(key);
  }

  static List<Map<String, dynamic>> getAllBookmarks() {
    final List<Map<String, dynamic>> bookmarks = [];
    for (var key in _bookmarks.keys) {
      final bookmark = _bookmarks.get(key);
      if (bookmark != null) {
        bookmarks.add(Map<String, dynamic>.from(bookmark));
      }
    }
    // Sort by timestamp (most recent first)
    bookmarks.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return bookmarks;
  }

  static int getBookmarksCount() {
    return _bookmarks.length;
  }
}
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /* -------------------- INITIALIZE -------------------- */

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /* -------------------- DAILY MESSAGES -------------------- */

  static final List<String> _quranMessages = [
    'Open the Qur’an. Allah is waiting to speak to you 🤍📖',
    'A few verses today can change your heart forever ✨',
    'Recite, reflect, repeat — your soul needs it 🌿',
    'The Qur’an is not rushed. Take your time today 📖',
    'Let Allah’s words calm your heart today 🤲',
  ];

  static final List<String> _hadithMessages = [
    '“The best among you are those who learn the Qur’an and teach it.” (Bukhari)',
    '“The Qur’an will come as an intercessor for its reciter.” (Muslim)',
    '“Read the Qur’an, for it will intercede for its companions.” (Muslim)',
    '“Whoever recites a letter from the Book of Allah gets a reward.” (Tirmidhi)',
    '“Allah elevates people through this Book.” (Muslim)',
  ];

  static String _randomMessage(List<String> list) {
    final random = Random();
    return list[random.nextInt(list.length)];
  }

  /* -------------------- SCHEDULE DAILY -------------------- */

  static Future<void> scheduleDailyQuranAndHadith({
    required int quranHour,
    required int quranMinute,
    required int hadithHour,
    required int hadithMinute,
  }) async {

    // Qur’an Reminder
    await _notifications.zonedSchedule(
      1,
      'Time for Qur’an 📖',
      _randomMessage(_quranMessages),
      _nextInstanceOfTime(quranHour, quranMinute),
      _notificationDetails(
        channelId: 'quran_channel',
        channelName: 'Qur’an Reminder',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Hadith Reminder
    await _notifications.zonedSchedule(
      2,
      'Hadith of the Day 📜',
      _randomMessage(_hadithMessages),
      _nextInstanceOfTime(hadithHour, hadithMinute),
      _notificationDetails(
        channelId: 'hadith_channel',
        channelName: 'Hadith Reminder',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /* -------------------- MOTIVATIONAL -------------------- */

  static Future<void> sendMotivationalNotification(int daysCompleted) async {
    await _notifications.show(
      daysCompleted + 100,
      'Keep Going 🌟',
      _getMotivationalMessage(daysCompleted),
      _notificationDetails(
        channelId: 'motivation_channel',
        channelName: 'Motivational Messages',
      ),
    );
  }

  static String _getMotivationalMessage(int days) {
    if (days == 1) {
      return 'Great start! The journey begins with one step 🚶';
    } else if (days == 3) {
      return '3-day streak! You’re building a beautiful habit 📚';
    } else if (days == 7) {
      return 'One week! Your consistency is inspiring 🌟';
    } else if (days == 14) {
      return 'Two weeks! Keep the momentum going 🔥';
    } else if (days == 30) {
      return 'One month! MashaAllah, amazing dedication 🎉';
    } else if (days % 10 == 0) {
      return '$days days strong! Your effort is seen by Allah 🤲';
    }
    return 'Day $days complete. Keep reciting 📖';
  }

  /* -------------------- HELPERS -------------------- */

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static NotificationDetails _notificationDetails({
    required String channelId,
    required String channelName,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  /* -------------------- CANCEL -------------------- */

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}

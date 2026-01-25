import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/storage/local_storage.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, bool> completedDays = {};

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  void loadProgress() {
    setState(() {
      completedDays = LocalStorage.getAllProgress();
    });
  }

  bool isDayCompleted(DateTime day) {
    final key = day.toIso8601String().substring(0, 10);
    return completedDays[key] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final totalDays = LocalStorage.getTotalDaysRead();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total days stat
            Text(
              'Total days read',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalDays days',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 32),

            // Calendar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: TableCalendar(
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    if (isDayCompleted(day)) {
                      return Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  todayBuilder: (context, day, focusedDay) {
                    if (isDayCompleted(day)) {
                      return Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),

            const SizedBox(height: 24),

            // Motivation message
            Center(
              child: Text(
                totalDays > 0
                    ? 'So far, so good 🤍 keep it up!'
                    : 'Start your journey today!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
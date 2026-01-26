import 'package:flutter/material.dart';
import '../../core/storage/local_storage.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalDays = LocalStorage.getTotalDaysRead();
    final streak = LocalStorage.getCurrentStreak();

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
            Text(
              'Current streak',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '$streak day${streak == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 20),

            // Last 7 days completion bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111111) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: Row(
                children: List.generate(7, (i) {
                  final day = DateTime.now().subtract(Duration(days: 6 - i));
                  final dk = LocalStorage.dateKey(day);
                  final done = LocalStorage.isCompleted(dk);
                  return Expanded(
                    child: Container(
                      height: 10,
                      margin: EdgeInsets.only(right: i == 6 ? 0 : 6),
                      decoration: BoxDecoration(
                        color: done
                            ? Colors.teal
                            : (isDark ? Colors.white12 : Colors.black12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 28),

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

            const SizedBox(height: 24),

            Center(
              child: Text(
                totalDays > 0 ? 'So far, so good 🤍 keep it up!' : 'Start your journey today!',
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
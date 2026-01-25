import 'package:flutter/material.dart';
import '../../core/storage/local_storage.dart';
import '../quran/surah_list_screen.dart';
import '../quran/ayah_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String todayKey =
      DateTime.now().toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final goal = LocalStorage.getDailyGoal();
    final completed = LocalStorage.isCompleted(todayKey);
    final lastRead = LocalStorage.getLastRead();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Reading"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              LocalStorage.resetToday(todayKey);
              setState(() {});
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Last Read Card
            if (lastRead['surah'] != 1 || lastRead['ayah'] != 1)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal.withOpacity(0.2),
                      Colors.teal.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.teal.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Continue Reading',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Surah ${lastRead['surah']}, Ayah ${lastRead['ayah']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        // Navigate to last read position
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SurahListScreen(),
                          ),
                        );
                      },
                      color: Colors.teal,
                    ),
                  ],
                ),
              ),

            Text(
              'Daily goal',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            Text(
              '$goal ayahs',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 24),

            Text(
              completed
                  ? '✓ Tap below when you finish reading'
                  : 'Tap below when you finish reading',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),

            const SizedBox(height: 16),

            // Heart icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: completed
                    ? Colors.teal.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    completed ? Icons.favorite : Icons.favorite_border,
                    color: completed ? Colors.teal : Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      completed
                          ? 'Completed for today 🤍'
                          : 'You showed up today 🤍',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: completed
                    ? null
                    : () {
                        LocalStorage.markCompleted(todayKey);
                        setState(() {});
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  disabledBackgroundColor: Colors.teal.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  completed ? 'Completed' : 'Mark as completed',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Start reading button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SurahListScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.teal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Reading',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
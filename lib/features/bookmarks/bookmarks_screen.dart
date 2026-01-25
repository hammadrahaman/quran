import 'package:flutter/material.dart';
import '../../core/storage/local_storage.dart';
import '../quran/ayah_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> bookmarks = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  // This will be called whenever the widget is rebuilt
  @override
  void didUpdateWidget(BookmarksScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadBookmarks();
  }

  void loadBookmarks() {
    setState(() {
      bookmarks = LocalStorage.getAllBookmarks();
    });
  }

  void deleteBookmark(int surahNumber, int ayahNumber) {
    LocalStorage.removeBookmark(surahNumber, ayahNumber);
    loadBookmarks();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bookmark removed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    // Reload bookmarks on every build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentBookmarks = LocalStorage.getAllBookmarks();
      if (currentBookmarks.length != bookmarks.length) {
        loadBookmarks();
      }
    });
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        centerTitle: true,
        actions: [
          if (bookmarks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${bookmarks.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),
            ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadBookmarks,
            tooltip: 'Refresh bookmarks',
          ),
        ],
      ),
      body: bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bookmark ayahs while reading',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Manual refresh button
                  OutlinedButton.icon(
                    onPressed: loadBookmarks,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.teal),
                      foregroundColor: Colors.teal,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                final surahNumber = bookmark['surahNumber'];
                final ayahNumber = bookmark['ayahNumber'];
                final surahName = bookmark['surahName'];
                final note = bookmark['note'] ?? '';
                final timestamp = DateTime.parse(bookmark['timestamp']);
                final formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year}';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AyahScreen(
                            surahNumber: surahNumber,
                            surahName: surahName,
                            initialAyahIndex: ayahNumber - 1,
                          ),
                        ),
                      ).then((_) => loadBookmarks());
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Bookmark icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bookmark,
                              color: Colors.teal,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surahName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Surah $surahNumber, Ayah $ayahNumber',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                                if (note.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    note,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Delete button
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Remove Bookmark'),
                                  content: const Text(
                                    'Are you sure you want to remove this bookmark?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        deleteBookmark(surahNumber, ayahNumber);
                                      },
                                      child: const Text(
                                        'Remove',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
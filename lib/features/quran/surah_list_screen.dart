import 'package:flutter/material.dart';
import '../../core/services/quran_api.dart';
import 'ayah_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  List<Surah> surahs = [];
  List<Surah> filteredSurahs = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSurahs();
    _searchController.addListener(_filterSurahs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadSurahs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final data = await QuranAPI.getAllSurahs();
      setState(() {
        surahs = data;
        filteredSurahs = data;
        isLoading = false;
        if (data.isEmpty) {
          errorMessage = 'No surahs found. Please check your internet connection.';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load Quran data. Please check your internet connection and try again.';
      });
    }
  }

  void _filterSurahs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredSurahs = surahs;
      } else {
        filteredSurahs = surahs.where((surah) {
          return surah.englishName.toLowerCase().contains(query) ||
                 surah.englishNameTranslation.toLowerCase().contains(query) ||
                 surah.number.toString().contains(query) ||
                 surah.name.contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Reading'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadSurahs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Surah by name or number...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Results count
          if (filteredSurahs.isNotEmpty && _searchController.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Found ${filteredSurahs.length} Surah(s)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ),

          // Surah List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: loadSurahs,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : filteredSurahs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a different search term',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredSurahs.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final surah = filteredSurahs[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${surah.number}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        surah.englishName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        surah.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '${surah.englishNameTranslation} • ${surah.numberOfAyahs} Ayahs',
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AyahScreen(
                                          surahNumber: surah.number,
                                          surahName: surah.englishName,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
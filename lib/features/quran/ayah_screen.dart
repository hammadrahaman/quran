import 'package:flutter/material.dart';
import '../../core/services/quran_api.dart';
import '../../core/storage/local_storage.dart';
import 'widgets/bismillah_header.dart';
import 'widgets/ayah_text_widget.dart';
import 'widgets/translation_widget.dart';
import 'widgets/ayah_navigation_bar.dart';
import 'widgets/surah_completion_dialog.dart';

class AyahScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int initialAyahIndex;

  const AyahScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.initialAyahIndex = 0,
  });

  @override
  State<AyahScreen> createState() => _AyahScreenState();
}

class _AyahScreenState extends State<AyahScreen> {
  SurahDetail? surahDetail;
  bool isLoading = true;
  int currentAyahIndex = 0;
  double arabicFontSize = 36.0;

  @override
  void initState() {
    super.initState();
    arabicFontSize = LocalStorage.getArabicFontSize();
    currentAyahIndex = widget.initialAyahIndex;
    loadSurah();
  }

  Future<void> loadSurah() async {
    setState(() {
      isLoading = true;
    });
    
    final data = await QuranAPI.getSurahWithTranslation(widget.surahNumber);
    setState(() {
      surahDetail = data;
      isLoading = false;
    });
    
    if (data != null) {
      LocalStorage.saveLastRead(widget.surahNumber, currentAyahIndex + 1);
    }
  }

  void nextAyah() async {
    if (surahDetail != null && currentAyahIndex < surahDetail!.ayahs.length - 1) {
      setState(() {
        currentAyahIndex++;
      });
      LocalStorage.saveLastRead(widget.surahNumber, currentAyahIndex + 1);
    } else if (currentAyahIndex == surahDetail!.ayahs.length - 1) {
      // Reached last ayah - show completion dialog
      final shouldContinue = await SurahCompletionDialog.show(
        context: context,
        surahName: widget.surahName,
        nextSurahNumber: widget.surahNumber + 1,
        hasNextSurah: widget.surahNumber < 114,
      );
      
      if (shouldContinue) {
        goToNextSurah();
      }
    }
  }

  void previousAyah() {
    if (currentAyahIndex > 0) {
      setState(() {
        currentAyahIndex--;
      });
      LocalStorage.saveLastRead(widget.surahNumber, currentAyahIndex + 1);
    }
  }

  Future<void> goToNextSurah() async {
    if (widget.surahNumber < 114) {
      final nextSurahData = await QuranAPI.getSurahWithTranslation(widget.surahNumber + 1);
      
      if (nextSurahData != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AyahScreen(
              surahNumber: widget.surahNumber + 1,
              surahName: nextSurahData.englishName,
              initialAyahIndex: 0,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
        elevation: 0,
        title: Column(
          children: [
            Text(
              '${widget.surahNumber}. ${widget.surahName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (surahDetail != null)
              Text(
                surahDetail!.englishNameTranslation,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : surahDetail == null
              ? const Center(child: Text('Failed to load Surah'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Bismillah - ONLY on first ayah, ONLY for non-Surah 9
                            if (widget.surahNumber != 9 && currentAyahIndex == 0) ...[
                              BismillahHeader(
                                fontSize: arabicFontSize,
                                isDark: isDark,
                              ),
                              
                              // Separator
                              Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                child: Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.grey[600])),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'Ayah 1',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                            ],

                            // Verse Number Badge with Bookmark
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              child: Row(
                                children: [
                                  // Verse Number
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark 
                                          ? const Color(0xFF1A1A1A)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isDark 
                                            ? Colors.grey[800]!
                                            : Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Text(
                                      '${widget.surahNumber}:${currentAyahIndex + 1}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                  
                                  const Spacer(),
                                  
                                  // Bookmark Button
                                  IconButton(
                                    icon: Icon(
                                      LocalStorage.isBookmarked(
                                        widget.surahNumber,
                                        currentAyahIndex + 1,
                                      )
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (LocalStorage.isBookmarked(
                                          widget.surahNumber,
                                          currentAyahIndex + 1,
                                        )) {
                                          LocalStorage.removeBookmark(
                                            widget.surahNumber,
                                            currentAyahIndex + 1,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Bookmark removed'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        } else {
                                          LocalStorage.addBookmark(
                                            surahNumber: widget.surahNumber,
                                            ayahNumber: currentAyahIndex + 1,
                                            surahName: widget.surahName,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Bookmark added'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    color: LocalStorage.isBookmarked(
                                      widget.surahNumber,
                                      currentAyahIndex + 1,
                                    )
                                        ? Colors.teal
                                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                    iconSize: 24,
                                  ),
                                ],
                              ),
                            ),

                            // Arabic Text with Ayah Number
                           // Arabic Text with Ayah Number
                            AyahTextWidget(
                            text: surahDetail!.ayahs[currentAyahIndex].text,
                            ayahNumber: currentAyahIndex + 1,
                            fontSize: arabicFontSize,
                            isDark: isDark,
                            surahNumber: widget.surahNumber,  // ADD THIS
                            ayahIndex: currentAyahIndex,       // ADD THIS
                            ),

                            const SizedBox(height: 32),

                            // Translation
                            if (surahDetail!.ayahs[currentAyahIndex].translation != null)
                              TranslationWidget(
                                translation: surahDetail!.ayahs[currentAyahIndex].translation!,
                                isDark: isDark,
                              ),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Navigation
                    AyahNavigationBar(
                      currentIndex: currentAyahIndex,
                      totalAyahs: surahDetail!.ayahs.length,
                      canGoPrevious: currentAyahIndex > 0,
                      canGoNext: true, // Always enabled - dialog will handle completion
                      onPrevious: previousAyah,
                      onNext: nextAyah,
                      isDark: isDark,
                    ),
                  ],
                ),
    );
  }
}
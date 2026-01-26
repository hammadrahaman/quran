import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/services/quran_api.dart';
import '../../core/storage/local_storage.dart';
import '../../core/services/audio_service.dart';

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
  double arabicFontSize = 32.0;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    arabicFontSize = LocalStorage.getArabicFontSize();
    currentAyahIndex = widget.initialAyahIndex;

    AudioService.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        setState(() => isPlaying = false);
      }
    });

    loadSurah();
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }

  Future<void> loadSurah() async {
    setState(() => isLoading = true);
    final data = await QuranAPI.getSurahWithTranslation(widget.surahNumber);
    setState(() {
      surahDetail = data;
      isLoading = false;
    });
    if (data != null) {
      LocalStorage.saveLastRead(widget.surahNumber, currentAyahIndex + 1);
    }
  }

  Future<void> _toggleAudio() async {
    if (surahDetail == null) return;
    final globalAyah = surahDetail!.ayahs[currentAyahIndex].number;

    if (isPlaying) {
      await AudioService.pause();
      setState(() => isPlaying = false);
    } else {
      await AudioService.playAyah(globalAyah);
      setState(() => isPlaying = true);
    }
  }

  void _toggleBookmark() {
    if (surahDetail == null) return;

    final ayahInSurah = surahDetail!.ayahs[currentAyahIndex].numberInSurah;
    final bookmarked = LocalStorage.isBookmarked(widget.surahNumber, ayahInSurah);

    setState(() {
      if (bookmarked) {
        LocalStorage.removeBookmark(widget.surahNumber, ayahInSurah);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark removed')),
        );
      } else {
        LocalStorage.addBookmark(
          surahNumber: widget.surahNumber,
          ayahNumber: ayahInSurah,
          surahName: widget.surahName,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark added')),
        );
      }
    });
  }

  Future<void> nextAyah() async {
    await AudioService.stop();
    setState(() => isPlaying = false);

    if (surahDetail == null) return;

    if (currentAyahIndex < surahDetail!.ayahs.length - 1) {
      setState(() => currentAyahIndex++);
      LocalStorage.saveLastRead(widget.surahNumber, currentAyahIndex + 1);
      return;
    }

    final shouldContinue = await SurahCompletionDialog.show(
      context: context,
      surahName: widget.surahName,
      nextSurahNumber: widget.surahNumber + 1,
      hasNextSurah: widget.surahNumber < 114,
    );

    if (shouldContinue) {
      await goToNextSurah();
    }
  }

  Future<void> previousAyah() async {
    await AudioService.stop();
    setState(() => isPlaying = false);

    if (currentAyahIndex <= 0) return;
    setState(() => currentAyahIndex--);
    LocalStorage.saveLastRead(widget.surahNumber, currentAyahIndex + 1);
  }

  Future<void> goToNextSurah() async {
    if (widget.surahNumber >= 114) return;
    final next = await QuranAPI.getSurahWithTranslation(widget.surahNumber + 1);
    if (!mounted || next == null) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AyahScreen(
          surahNumber: widget.surahNumber + 1,
          surahName: next.englishName,
          initialAyahIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ayahInSurah = (surahDetail == null)
        ? 1
        : surahDetail!.ayahs[currentAyahIndex].numberInSurah;

    final bookmarked = LocalStorage.isBookmarked(widget.surahNumber, ayahInSurah);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
        elevation: 0,
        title: Column(
          children: [
            Text(
              '${widget.surahNumber}. ${widget.surahName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (surahDetail != null)
              Text(
                surahDetail!.englishNameTranslation,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
              ),
          ],
        ),
        centerTitle: true,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : surahDetail == null
              ? const Center(child: Text('Failed to load Surah'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Show Bismillah header only for surahs except 1 and 9, and only on first screen.
                            if (widget.surahNumber != 1 && widget.surahNumber != 9 && currentAyahIndex == 0) ...[
                              BismillahHeader(isDark: isDark, fontSize: arabicFontSize),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: Divider(color: (isDark ? Colors.white24 : Colors.black26))),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Ayah 1',
                                    style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Divider(color: (isDark ? Colors.white24 : Colors.black26))),
                                ],
                              ),
                              const SizedBox(height: 18),
                            ],

                            // Top row: verse ref + actions
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                                  ),
                                  child: Text(
                                    '${widget.surahNumber}:$ayahInSurah',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Spacer(),

                                IconButton(
                                  icon: Icon(
                                    isPlaying ? Icons.pause_circle : Icons.play_circle_outline,
                                    size: 30,
                                  ),
                                  color: Colors.teal,
                                  onPressed: _toggleAudio,
                                ),

                                // ✅ Bookmark button (added back)
                                IconButton(
                                  icon: Icon(
                                    bookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    size: 28,
                                  ),
                                  color: bookmarked ? Colors.teal : (isDark ? Colors.white70 : Colors.black54),
                                  onPressed: _toggleBookmark,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            AyahTextWidget(
                              text: surahDetail!.ayahs[currentAyahIndex].text,
                              ayahNumber: ayahInSurah,
                              fontSize: arabicFontSize,
                              isDark: isDark,
                              surahNumber: widget.surahNumber,
                              ayahIndex: currentAyahIndex,
                            ),

                            const SizedBox(height: 18),

                            if (surahDetail!.ayahs[currentAyahIndex].translation != null)
                              TranslationWidget(
                                translation: surahDetail!.ayahs[currentAyahIndex].translation!,
                                isDark: isDark,
                              ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    AyahNavigationBar(
                      currentIndex: currentAyahIndex,
                      totalAyahs: surahDetail!.ayahs.length,
                      canGoPrevious: currentAyahIndex > 0,
                      canGoNext: true,
                      onPrevious: previousAyah,
                      onNext: nextAyah,
                      isDark: isDark,
                    ),
                  ],
                ),
    );
  }
}
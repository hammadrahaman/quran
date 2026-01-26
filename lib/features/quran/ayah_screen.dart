import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final DateTime _sessionStart = DateTime.now();
  final Set<int> _sessionGlobalAyahs = {};
  int _sessionHasanat = 0;

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
      _markCurrentAyahAsRead();
    }
  }

  Future<void> _toggleAudio() async {
    if (surahDetail == null) return;
    final globalAyah = surahDetail!.ayahs[currentAyahIndex].number;

    try {
      if (isPlaying) {
        await AudioService.pause();
        setState(() => isPlaying = false);
      } else {
        await AudioService.playAyah(globalAyah);
        setState(() => isPlaying = true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isPlaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio failed to load. Check internet and try again.'),
        ),
      );
    }
  }

  void _toggleBookmark() {
    if (surahDetail == null) return;

    final ayahInSurah = surahDetail!.ayahs[currentAyahIndex].numberInSurah;
    final bookmarked =
        LocalStorage.isBookmarked(widget.surahNumber, ayahInSurah);

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
          const SnackBar(content: Text('Bookmarked')),
        );
      }
    });
  }

  // Hasanah estimate (minimum): 10 per Arabic letter
  int _estimateHasanatFromArabic(String text) {
    // Count Arabic letters (includes ٱ too)
    final letters = RegExp(r'[ء-يٱ]').allMatches(text).length;
    return letters * 10;
  }

  void _markCurrentAyahAsRead() {
    if (surahDetail == null) return;

    final ayah = surahDetail!.ayahs[currentAyahIndex];
    final globalAyah = ayah.number;
    final hasanat = _estimateHasanatFromArabic(ayah.text);

    // Daily/all-time (unique per day)
    LocalStorage.recordAyahRead(
      globalAyahNumber: globalAyah,
      hasanatEarned: hasanat,
    );

    // Session total (unique per session)
    if (_sessionGlobalAyahs.add(globalAyah)) {
      _sessionHasanat += hasanat;
    }
  }

  Future<void> nextAyah() async {
    await AudioService.stop();
    setState(() => isPlaying = false);

    if (surahDetail == null) return;

    if (currentAyahIndex < surahDetail!.ayahs.length - 1) {
      setState(() => currentAyahIndex++);
      LocalStorage.saveLastRead(widget.surahNumber, currentAyahIndex + 1);
      _markCurrentAyahAsRead();
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
    _markCurrentAyahAsRead();
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

  Future<void> _onDone() async {
    if (surahDetail == null) return;

    HapticFeedback.mediumImpact();

    // Ensure current ayah counted
    _markCurrentAyahAsRead();

    final ayahInSurah = surahDetail!.ayahs[currentAyahIndex].numberInSurah;

    // Save bookmark (idempotent)
    if (!LocalStorage.isBookmarked(widget.surahNumber, ayahInSurah)) {
      LocalStorage.addBookmark(
        surahNumber: widget.surahNumber,
        ayahNumber: ayahInSurah,
        surahName: widget.surahName,
      );
    }

    // Save reading time
    final seconds = DateTime.now().difference(_sessionStart).inSeconds;
    LocalStorage.addReadingSeconds(seconds);

    if (!mounted) return;

    const accent = Color(0xFF2563EB); // blue
    const accent2 = Color(0xFF7C3AED); // violet

    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF0B0F1A), Color(0xFF141B33)]
                      : const [Colors.white, Color(0xFFF3F6FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white24 : Colors.black12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: 62,
                      height: 62,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [accent, accent2]),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Session completed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Estimated minimum hasanah earned',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: isDark ? Colors.white10 : Colors.white,
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_sessionHasanat',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bookmarked: ${widget.surahNumber}:$ayahInSurah',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, 'keep'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Keep reading',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, 'finish'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Finish',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    if (action == 'finish') {
      Navigator.pop(context); // back to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2563EB);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ayahInSurah = (surahDetail == null)
        ? 1
        : surahDetail!.ayahs[currentAyahIndex].numberInSurah;

    final bookmarked =
        LocalStorage.isBookmarked(widget.surahNumber, ayahInSurah);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF05070F) : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF05070F) : Colors.white,
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
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
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
                            if (widget.surahNumber != 1 &&
                                widget.surahNumber != 9 &&
                                currentAyahIndex == 0) ...[
                              BismillahHeader(
                                isDark: isDark,
                                fontSize: arabicFontSize,
                              ),
                              const SizedBox(height: 12),
                            ],

                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark ? Colors.white10 : Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.black12,
                                    ),
                                  ),
                                  child: Text(
                                    '${widget.surahNumber}:$ayahInSurah',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill,
                                    size: 30,
                                  ),
                                  color: accent,
                                  onPressed: _toggleAudio,
                                ),
                                IconButton(
                                  icon: Icon(
                                    bookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_outline_rounded,
                                    size: 28,
                                  ),
                                  color: bookmarked
                                      ? const Color(0xFF7C3AED)
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black54),
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

                            if (surahDetail!
                                    .ayahs[currentAyahIndex].translation !=
                                null)
                              TranslationWidget(
                                translation: surahDetail!
                                    .ayahs[currentAyahIndex].translation!,
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
                      onDone: _onDone,
                      isDark: isDark,
                    ),
                  ],
                ),
    );
  }
}
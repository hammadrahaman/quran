import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // AlQuran Cloud reciter edition for Abdul Rahman Al-Sudais
  // (If this ever changes upstream, we can make it configurable in Settings.)
  static const String _reciterEdition = 'ar.abdurrahmaansudais';
  static const String _apiBase = 'https://api.alquran.cloud/v1';

  static Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  static bool get isPlaying => _audioPlayer.playing;

  /// Plays a single ayah using its GLOBAL ayah number (the API 'number' field).
  static Future<void> playAyah(int globalAyahNumber) async {
    try {
      final uri = Uri.parse('$_apiBase/ayah/$globalAyahNumber/$_reciterEdition');
      final res = await http.get(uri);

      if (res.statusCode != 200) {
        throw Exception('Audio API failed: ${res.statusCode}');
      }

      final body = json.decode(res.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      final audioUrl = data?['audio'] as String?;

      if (audioUrl == null || audioUrl.isEmpty) {
        throw Exception('No audio url in response');
      }

      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      // Keep this print; it’s very useful for debugging reciter URLs.
      // ignore: avoid_print
      print('Error playing ayah audio: $e');
      rethrow;
    }
  }

  static Future<void> pause() async => _audioPlayer.pause();
  static Future<void> stop() async => _audioPlayer.stop();
  static Future<void> dispose() async => _audioPlayer.dispose();
}
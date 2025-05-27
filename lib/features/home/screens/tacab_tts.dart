import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class TacabTTS {
  final String apiUrl = 'https://tacab-tts.hf.space/synthesize';

  /// Sends text to Tacab TTS API and saves the returned WAV audio file locally.
  /// Returns the file path of the saved WAV file or null on failure.
  Future<String?> synthesizeAndSaveAudio(String text) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'inputs': text}),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/tts_output.wav';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        return filePath;
      } else {
        print('TTS API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error calling TTS API: $e');
      return null;
    }
  }

  /// Plays the WAV audio file from the given local file path.
  Future<void> playAudio(String filePath) async {
    final player = AudioPlayer();
    await player.play(DeviceFileSource(filePath));
  }
}

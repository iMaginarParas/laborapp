import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static final SpeechToText _speech = SpeechToText();
  static bool _isInitialized = false;

  static Future<bool> init() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    return _isInitialized;
  }

  static Future<void> startListening({
    required Function(String) onResult,
    required Function(bool) onListeningChange,
  }) async {
    final hasPermission = await Permission.microphone.request().isGranted;
    if (!hasPermission) return;

    final isReady = await init();
    if (isReady) {
      onListeningChange(true);
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onListeningChange(false);
          }
          onResult(result.recognizedWords);
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
      );
    }
  }

  static Future<void> stopListening() async {
    await _speech.stop();
  }

  static bool get isListening => _speech.isListening;
}

import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isAvailable = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  static const Map<String, String> letterWords = {
    'A': 'Apple', 'B': 'Ball', 'C': 'Cat', 'D': 'Dog', 'E': 'Elephant',
    'F': 'Fish', 'G': 'Grapes', 'H': 'Hat', 'I': 'Ice Cream', 'J': 'Jellyfish',
    'K': 'Kite', 'L': 'Lion', 'M': 'Moon', 'N': 'Nut', 'O': 'Orange',
    'P': 'Penguin', 'Q': 'Queen', 'R': 'Rainbow', 'S': 'Sun', 'T': 'Tree',
    'U': 'Umbrella', 'V': 'Violin', 'W': 'Whale', 'X': 'Xylophone',
    'Y': 'Yo-yo', 'Z': 'Zebra',
  };

  static const Map<String, List<String>> _phoneticMap = {
    'A': ['AY', 'EI', 'AH'],
    'B': ['BEE', 'BE'],
    'C': ['SEE', 'SI', 'CE'],
    'D': ['DEE', 'DE'],
    'E': ['EE', 'EH'],
    'F': ['EF', 'EFF'],
    'G': ['GEE', 'JEE', 'GI'],
    'H': ['AITCH', 'HEY', 'HAY'],
    'I': ['AI', 'EYE', 'I'],
    'J': ['JAY', 'JEI'],
    'K': ['KAY', 'KEI'],
    'L': ['EL', 'ELL'],
    'M': ['EM', 'EMM'],
    'N': ['EN', 'ENN'],
    'O': ['OH', 'OW'],
    'P': ['PEE', 'PE'],
    'Q': ['QUE', 'CUE', 'KYU', 'QUEUE'],
    'R': ['AR', 'AHR'],
    'S': ['ESS', 'ES'],
    'T': ['TEE', 'TE'],
    'U': ['YOU', 'YOO', 'EWE'],
    'V': ['VEE', 'VE'],
    'W': ['DOUBLE', 'DOUBLEYOU'],
    'X': ['EX', 'EKS'],
    'Y': ['WHY', 'WI'],
    'Z': ['ZEE', 'ZED', 'ZI'],
  };

  Future<void> initialize() async {
    await Permission.microphone.request();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.1);
    await _tts.setVolume(1.0);
    _isAvailable = await _stt.initialize(
      onError: (_) => _isListening = false,
    );
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> speakLetter(String letter) async {
    final word = letterWords[letter] ?? '';
    await speak('Say the letter $letter! $letter is for $word!');
  }

  Future<void> startListening({
    required void Function(String recognized) onResult,
    required void Function() onTimeout,
    int timeoutSeconds = 5,
  }) async {
    if (!_isAvailable || _isListening) return;

    _isListening = true;
    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          _isListening = false;
          onResult(result.recognizedWords);
        }
      },
      listenFor: Duration(seconds: timeoutSeconds),
      pauseFor: const Duration(seconds: 2),
      localeId: 'en_US',
      cancelOnError: false,
      partialResults: false,
    );

    Future.delayed(Duration(seconds: timeoutSeconds + 1), () {
      if (_isListening) {
        _isListening = false;
        stopListening();
        onTimeout();
      }
    });
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _stt.stop();
  }

  bool isCorrectLetter(String recognized, String expected) {
    final r = recognized.trim().toUpperCase();
    final e = expected.toUpperCase();
    if (r.isEmpty) return false;
    if (r == e) return true;
    if (r.startsWith(e + ' ') || r.endsWith(' $e') || r == e) return true;
    if (r.split(' ').any((w) => w == e)) return true;
    return _phoneticMap[e]?.any((p) => r.contains(p)) ?? false;
  }

  Future<void> dispose() async {
    await _stt.stop();
    await _tts.stop();
  }
}

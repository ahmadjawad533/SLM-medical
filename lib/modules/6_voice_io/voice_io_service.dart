/// ---------------------------------------------------------------------------
/// MODULE 6: VOICE I/O MODULE ADAPTER
/// ---------------------------------------------------------------------------
/// Primary voice interface contract for SLM Medical app. Connects Silero VAD,
/// whisper.cpp STT, Piper TTS, fixed voice intent router, and barge-in interruption.

import 'dart:async';
import 'package:slm_medical/modules/6_voice_io/fixed_intent_router.dart';
import 'package:slm_medical/modules/6_voice_io/offline_voice_engine.dart';

enum VoiceState { idle, listening, processing, speaking }

abstract class IVoiceService {
  Stream<VoiceState> get stateStream;
  Stream<FixedIntentResult> get fixedIntentStream;
  Future<String> startListening({bool manualPushToTalk = false});
  Future<void> stopListening();
  Future<void> speak(String text);
  Future<void> interruptPlayback();
}

class OfflineVoiceService implements IVoiceService {
  final OfflineVoiceEngine _engine = OfflineVoiceEngine();
  VoiceState _currentState = VoiceState.idle;
  final StreamController<VoiceState> _stateController = StreamController<VoiceState>.broadcast();

  @override
  Stream<VoiceState> get stateStream => _stateController.stream;

  @override
  Stream<FixedIntentResult> get fixedIntentStream => _engine.fixedIntentStream;

  @override
  Future<String> startListening({bool manualPushToTalk = false}) async {
    // 1. Interrupt any active TTS narration immediately (Barge-In)
    await interruptPlayback();

    _setState(VoiceState.listening);

    // Simulate VAD / Push-to-talk audio capture
    await Future.delayed(const Duration(seconds: 2));

    _setState(VoiceState.processing);

    final result = await _engine.processSpeechInput(
      pcmAudioBuffer: [0, 1, 0, -1],
      simulatedConfidence: 0.88,
      simulatedText: "repeat",
    );

    _setState(VoiceState.idle);

    if (result.isTooNoisy) {
      return "⚠️ High noise detected. Please tap visual buttons.";
    }

    return result.text;
  }

  @override
  Future<void> stopListening() async {
    _setState(VoiceState.idle);
  }

  @override
  Future<void> speak(String text) async {
    _setState(VoiceState.speaking);
    await _engine.speakTts(text);
    _setState(VoiceState.idle);
  }

  @override
  Future<void> interruptPlayback() async {
    await _engine.interruptPlayback();
    if (_currentState == VoiceState.speaking) {
      _setState(VoiceState.idle);
    }
  }

  void _setState(VoiceState newState) {
    _currentState = newState;
    _stateController.add(_currentState);
  }
}

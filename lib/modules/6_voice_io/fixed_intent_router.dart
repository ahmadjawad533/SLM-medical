/// ---------------------------------------------------------------------------
/// FIXED SYSTEM VOICE INTENT ROUTER (LLM BYPASS)
/// ---------------------------------------------------------------------------
/// Deterministically matches system commands ("repeat", "slow down", "stop")
/// directly at the voice layer. Bypasses LLM and RAG execution entirely to guarantee
/// instantaneous (< 5ms) system response for control actions.

enum FixedVoiceIntent {
  none,
  repeatInstruction, // "Repeat", "Say again", "What did you say"
  slowDown,           // "Slow down", "Speak slower", "Too fast"
  stopSpeaking,       // "Stop", "Quiet", "Silence", "Shut up"
  sosEmergency,       // "SOS", "Emergency", "Help me"
}

class FixedIntentResult {
  final FixedVoiceIntent intent;
  final String matchedPhrase;
  final bool shouldBypassLlm;

  FixedIntentResult({
    required this.intent,
    required this.matchedPhrase,
    required this.shouldBypassLlm,
  });

  factory FixedIntentResult.none() => FixedIntentResult(
    intent: FixedVoiceIntent.none,
    matchedPhrase: '',
    shouldBypassLlm: false,
  );
}

class FixedIntentRouter {
  // Multilingual System Voice Intent Keywords Matrix
  static const Map<FixedVoiceIntent, List<String>> _intentKeywords = {
    FixedVoiceIntent.repeatInstruction: [
      'repeat', 'say again', 'what did you say', 'one more time', 'read again',
      'rudia', 'arba ke bolo', 'كرر', 'إعادة', 'repetir', 'otra vez'
    ],
    FixedVoiceIntent.slowDown: [
      'slow down', 'speak slower', 'too fast', 'slower',
      'pole pole', 'dhire bolo', 'تكلم ببطء', 'بطيء', 'más despacio', 'despacio'
    ],
    FixedVoiceIntent.stopSpeaking: [
      'stop', 'quiet', 'silence', 'shut up', 'pause',
      'acha', 'bas', 'توقف', 'اسكت', 'parar', 'silencio'
    ],
    FixedVoiceIntent.sosEmergency: [
      'sos', 'emergency', 'help me', 'critical',
      'msada', 'bachao', 'طوارئ', 'ساعدني', 'emergencia', 'auxilio'
    ],
  };

  /// Evaluates recognized STT text for fixed system intents.
  static FixedIntentResult match(String recognizedText) {
    final cleanText = recognizedText.toLowerCase().trim();

    for (final entry in _intentKeywords.entries) {
      for (final keyword in entry.value) {
        if (cleanText.contains(keyword)) {
          return FixedIntentResult(
            intent: entry.key,
            matchedPhrase: keyword,
            shouldBypassLlm: true,
          );
        }
      }
    }

    return FixedIntentResult.none();
  }
}

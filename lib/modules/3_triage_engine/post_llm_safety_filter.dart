/// ---------------------------------------------------------------------------
/// POST-LLM GENERATION SAFETY FILTER & VERIFIER
/// ---------------------------------------------------------------------------
/// Scans generated LLM text streams before displaying to the user. Checks for:
/// 1. Invented medication dosages (e.g. "take 500mg amoxicillin").
/// 2. Invented definitive diagnoses (e.g. "you have acute appendicitis").
/// 3. Scope violations outside first-aid stabilization (e.g. "perform surgery").
/// If a violation is flagged, rejects LLM output and falls back to retrieved RAG text verbatim.

class SafetyFilterResult {
  final bool isSafe;
  final String? violationType;
  final String? flaggedSnippet;
  final String outputText;

  SafetyFilterResult({
    required this.isSafe,
    this.violationType,
    this.flaggedSnippet,
    required this.outputText,
  });

  factory SafetyFilterResult.rejected({
    required String violationType,
    required String flaggedSnippet,
    required String verbatimFallbackText,
  }) {
    return SafetyFilterResult(
      isSafe: false,
      violationType: violationType,
      flaggedSnippet: flaggedSnippet,
      outputText: "⚠️ POST-GENERATION SAFETY REJECTION: The generated response attempted an unauthorized $violationType ('$flaggedSnippet'). Reverting to verified verbatim protocol:\n\n$verbatimFallbackText",
    );
  }
}

class PostLlmSafetyFilter {
  // Regex pattern matching unauthorized specific medication dosage numbers (e.g. 500mg, 10ml, 2 tablets)
  static final RegExp _dosagePattern = RegExp(
    r'\b(\d+(\.\d+)?\s*(mg|g|mcg|ml|tablets|pills|capsules|doses))\b',
    caseSensitive: false,
  );

  // Blacklisted clinical diagnosis phrases LLMs must never state as fact
  static const List<String> _diagnosisPatterns = [
    'you have acute', 'diagnosed with', 'this is definitely a case of',
    'you are suffering from stage', 'confirmed diagnosis of'
  ];

  // Invasive procedural scope violations outside basic first aid
  static const List<String> _scopeViolationPatterns = [
    'perform surgery', 'make an incision', 'tracheostomy', 'prescribe antibiotics',
    'administer iv', 'administer intravenous', 'suture the wound'
  ];

  /// Verifies generated LLM text against clinical safety rules.
  static SafetyFilterResult verify({
    required String generatedText,
    required String verbatimFallbackText,
  }) {
    final cleanText = generatedText.toLowerCase();

    // 1. Check Invented Dosage Pattern
    final dosageMatch = _dosagePattern.firstMatch(cleanText);
    if (dosageMatch != null) {
      return SafetyFilterResult.rejected(
        violationType: 'Medication Dosage Statement',
        flaggedSnippet: dosageMatch.group(0) ?? 'dosage',
        verbatimFallbackText: verbatimFallbackText,
      );
    }

    // 2. Check Invented Diagnosis Pattern
    for (final diag in _diagnosisPatterns) {
      if (cleanText.contains(diag)) {
        return SafetyFilterResult.rejected(
          violationType: 'Definitive Medical Diagnosis',
          flaggedSnippet: diag,
          verbatimFallbackText: verbatimFallbackText,
        );
      }
    }

    // 3. Check Scope Violation Pattern
    for (final scope in _scopeViolationPatterns) {
      if (cleanText.contains(scope)) {
        return SafetyFilterResult.rejected(
          violationType: 'Scope Violation / Invasive Action',
          flaggedSnippet: scope,
          verbatimFallbackText: verbatimFallbackText,
        );
      }
    }

    // Safe generation!
    return SafetyFilterResult(
      isSafe: true,
      outputText: generatedText,
    );
  }
}

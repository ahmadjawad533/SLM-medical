/// ---------------------------------------------------------------------------
/// PRIVACY-BY-DESIGN ANONYMIZER & TELEMETRY MODEL
/// ---------------------------------------------------------------------------
/// Sanitizes interaction logs locally before writing to SQLite telemetry store.
/// Strictly excludes all PII (names, verbatim text, phone numbers, exact location).
/// Keeps system metrics, symptom categories, rule IDs, RAG confidence scores, and version matrix.

class AnonymizedTelemetryRecord {
  final String telemetryId;
  final String anonymizedDeviceId;
  final DateTime timestamp;
  final String symptomCategory;
  final String? triggeredRuleId;
  final double ragConfidenceScore;
  final String appVersion;
  final String llmModelVersion;
  final String ragKbVersion;
  final String safetyRulesetVersion;
  final double timeToFirstTokenMs;

  AnonymizedTelemetryRecord({
    required this.telemetryId,
    required this.anonymizedDeviceId,
    required this.timestamp,
    required this.symptomCategory,
    this.triggeredRuleId,
    required this.ragConfidenceScore,
    required this.appVersion,
    required this.llmModelVersion,
    required this.ragKbVersion,
    required this.safetyRulesetVersion,
    required this.timeToFirstTokenMs,
  });

  Map<String, dynamic> toJson() => {
    'telemetryId': telemetryId,
    'anonymizedDeviceId': anonymizedDeviceId,
    'timestamp': timestamp.toIso8601String(),
    'symptomCategory': symptomCategory,
    'triggeredRuleId': triggeredRuleId ?? 'NONE',
    'ragConfidenceScore': ragConfidenceScore,
    'appVersion': appVersion,
    'llmModelVersion': llmModelVersion,
    'ragKbVersion': ragKbVersion,
    'safetyRulesetVersion': safetyRulesetVersion,
    'timeToFirstTokenMs': timeToFirstTokenMs,
  };
}

class PrivacyAnonymizer {
  /// Sanitizes interaction metrics into an anonymized, non-PII record.
  static AnonymizedTelemetryRecord sanitize({
    required String rawUserText, // Used ONLY to extract symptom category; NEVER logged
    required String? triggeredRuleId,
    required double ragConfidenceScore,
    required String appVersion,
    required String llmVersion,
    required String ragVersion,
    required String rulesVersion,
    required double ttftMs,
  }) {
    // Extract high-level category without storing verbatim text
    String category = "GENERAL_FIRST_AID";
    final cleanText = rawUserText.toLowerCase();
    if (cleanText.contains('cpr') || cleanText.contains('breathing') || cleanText.contains('heart')) category = "CARDIAC_CPR";
    if (cleanText.contains('bleed') || cleanText.contains('blood')) category = "HEMORRHAGE";
    if (cleanText.contains('snake') || cleanText.contains('bite')) category = "ENVENOMATION";
    if (cleanText.contains('stroke') || cleanText.contains('speech')) category = "STROKE";
    if (cleanText.contains('burn')) category = "BURNS";

    return AnonymizedTelemetryRecord(
      telemetryId: 'TEL_${DateTime.now().millisecondsSinceEpoch}',
      anonymizedDeviceId: 'DEV_HASH_8842_ANON',
      timestamp: DateTime.now(),
      symptomCategory: category,
      triggeredRuleId: triggeredRuleId,
      ragConfidenceScore: ragConfidenceScore,
      appVersion: appVersion,
      llmModelVersion: llmVersion,
      ragKbVersion: ragVersion,
      safetyRulesetVersion: rulesVersion,
      timeToFirstTokenMs: ttftMs,
    );
  }
}

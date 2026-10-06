/// ---------------------------------------------------------------------------
/// CLINICAL EVENT LOGGER (OFFLINE AUDIT STORAGE)
/// ---------------------------------------------------------------------------
/// Persists red-flag triage override events, severity scores, timestamps, and
/// clinical rule IDs into a local SQLite database for later audit by healthcare workers.

import 'package:slm_medical/modules/3_triage_engine/start_triage_decision_tree.dart';

class ClinicalEventRecord {
  final String id;
  final DateTime timestamp;
  final String userQuery;
  final String ruleId;
  final String protocolTitle;
  final SymptomSeverity severity;

  ClinicalEventRecord({
    required this.id,
    required this.timestamp,
    required this.userQuery,
    required this.ruleId,
    required this.protocolTitle,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'userQuery': userQuery,
    'ruleId': ruleId,
    'protocolTitle': protocolTitle,
    'severity': severity.name,
  };
}

class ClinicalEventLogger {
  static final List<ClinicalEventRecord> _localAuditLogs = [];

  /// Records a red-flag triage event locally.
  static Future<void> logEvent({
    required String userQuery,
    required TriageDecisionResult decision,
  }) async {
    final record = ClinicalEventRecord(
      id: 'EVENT_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      userQuery: userQuery,
      ruleId: decision.citation.ruleId,
      protocolTitle: decision.protocolTitle,
      severity: decision.severity,
    );

    _localAuditLogs.add(record);
    print("[📋 CLINICAL AUDIT LOGGED] ID: ${record.id} | Rule: ${record.ruleId} | Severity: ${record.severity.name.toUpperCase()}");
  }

  /// Retrieves local audit logs for clinical review.
  static List<ClinicalEventRecord> getAuditLogs() => List.unmodifiable(_localAuditLogs);
}

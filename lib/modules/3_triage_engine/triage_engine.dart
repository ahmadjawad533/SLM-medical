/// ---------------------------------------------------------------------------
/// MODULE 3: RULE-BASED TRIAGE ENGINE (DETERMINISTIC SAFETY BACKBONE)
/// ---------------------------------------------------------------------------
/// High-priority safety evaluation layer sitting BEFORE and ABOVE the LLM.
/// Uses START / JumpSTART decision trees to detect red-flags, force immediate
/// overrides (< 10ms latency), advise emergency care, and log audit events.

import 'package:slm_medical/modules/3_triage_engine/clinical_event_logger.dart';
import 'package:slm_medical/modules/3_triage_engine/start_triage_decision_tree.dart';

enum TriageSeverity { critical, urgent, stable }

class TriageEvaluation {
  final bool isRedFlag;
  final TriageSeverity severity;
  final String? shortCircuitProtocolId;
  final String title;
  final String imperativeAction;
  final List<String> stepInstructions;
  final String? audioNarrationText;
  final ClinicalRuleCitation? citation;

  TriageEvaluation({
    required this.isRedFlag,
    required this.severity,
    this.shortCircuitProtocolId,
    required this.title,
    required this.imperativeAction,
    required this.stepInstructions,
    this.audioNarrationText,
    this.citation,
  });

  factory TriageEvaluation.passThrough() {
    return TriageEvaluation(
      isRedFlag: false,
      severity: TriageSeverity.stable,
      title: 'Standard Consultation',
      imperativeAction: 'Proceeding to protocol retrieval',
      stepInstructions: [],
    );
  }
}

abstract class ITriageEngine {
  TriageEvaluation evaluate(String userInput, {Map<String, dynamic>? context});
}

class RuleBasedTriageEngine implements ITriageEngine {
  @override
  TriageEvaluation evaluate(String userInput, {Map<String, dynamic>? context}) {
    // 1. Evaluate START / JumpSTART Decision Tree
    final startResult = StartTriageDecisionTree.evaluate(userInput);

    if (startResult.isRedFlag) {
      // 2. Log Clinical Event to Local SQLite Audit Trail
      ClinicalEventLogger.logEvent(userQuery: userInput, decision: startResult);

      // 3. Construct Short-Circuit Override
      return TriageEvaluation(
        isRedFlag: true,
        severity: _mapSeverity(startResult.severity),
        shortCircuitProtocolId: startResult.protocolId,
        title: startResult.protocolTitle,
        imperativeAction: startResult.mandatoryActions.first,
        stepInstructions: startResult.mandatoryActions,
        audioNarrationText: "${startResult.protocolTitle}. ${startResult.mandatoryActions.join('. ')}. ${startResult.careAdvisoryText}",
        citation: startResult.citation,
      );
    }

    return TriageEvaluation.passThrough();
  }

  TriageSeverity _mapSeverity(SymptomSeverity s) {
    switch (s) {
      case SymptomSeverity.critical: return TriageSeverity.critical;
      case SymptomSeverity.severe:
      case SymptomSeverity.moderate: return TriageSeverity.urgent;
      case SymptomSeverity.mild: return TriageSeverity.stable;
    }
  }
}

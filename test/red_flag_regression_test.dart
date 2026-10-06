/// ---------------------------------------------------------------------------
/// RED-FLAG TRIAGE REGRESSION TEST SUITE (100% RECALL RELEASE GATE)
/// ---------------------------------------------------------------------------
/// Automated regression suite validating every START / JumpSTART decision rule.
/// MANDATORY RELEASE GATE: Any missed red-flag (recall < 100%) blocks build release.

import 'package:flutter_test/flutter_test.dart';
import 'package:slm_medical/modules/3_triage_engine/start_triage_decision_tree.dart';

void main() {
  group('START Triage Decision Tree - 100% Red-Flag Recall Regression Suite', () {
    
    // 1. CARDIAC EMERGENCY TEST CASES
    final cardiacTestCases = [
      'Patient has chest pain and shortness of breath and is sweating profusely',
      'Sudden chest pain, breathless, and cold sweat',
      'Crushing chest pain with sweating',
    ];

    for (final testCase in cardiacTestCases) {
      test('CARDIAC: "$testCase"', () {
        final result = StartTriageDecisionTree.evaluate(testCase);
        expect(result.isRedFlag, isTrue, reason: 'MUST detect cardiac emergency red-flag!');
        expect(result.protocolId, equals('PROTOCOL_CARDIAC_START_01'));
        expect(result.severity, equals(SymptomSeverity.critical));
      });
    }

    // 2. MASSIVE HEMORRHAGE TEST CASES
    final hemorrhageTestCases = [
      'Heavy bleeding from deep leg wound after fall',
      'Cut artery in arm with gushing blood',
      'Uncontrolled bleeding from stab wound',
    ];

    for (final testCase in hemorrhageTestCases) {
      test('HEMORRHAGE: "$testCase"', () {
        final result = StartTriageDecisionTree.evaluate(testCase);
        expect(result.isRedFlag, isTrue, reason: 'MUST detect massive hemorrhage red-flag!');
        expect(result.protocolId, equals('PROTOCOL_HEMORRHAGE_START_02'));
        expect(result.severity, equals(SymptomSeverity.critical));
      });
    }

    // 3. STROKE F.A.S.T. TEST CASES
    final strokeTestCases = [
      'Elderly woman has facial droop and slurred speech',
      'One side of face drooping, arm weakness, cannot speak',
      'Stroke signs: face droop and slurred speech',
    ];

    for (final testCase in strokeTestCases) {
      test('STROKE FAST: "$testCase"', () {
        final result = StartTriageDecisionTree.evaluate(testCase);
        expect(result.isRedFlag, isTrue, reason: 'MUST detect stroke FAST red-flag!');
        expect(result.protocolId, equals('PROTOCOL_STROKE_FAST_03'));
        expect(result.severity, equals(SymptomSeverity.critical));
      });
    }

    // 4. AIRWAY OBSTRUCTION TEST CASES
    final airwayTestCases = [
      'Child choking on toy, turning blue and gasping for air',
      'Airway blocked, cannot breathe, stridor heard',
      'Choking victim turning blue',
    ];

    for (final testCase in airwayTestCases) {
      test('AIRWAY: "$testCase"', () {
        final result = StartTriageDecisionTree.evaluate(testCase);
        expect(result.isRedFlag, isTrue, reason: 'MUST detect airway obstruction red-flag!');
        expect(result.protocolId, equals('PROTOCOL_AIRWAY_START_04'));
        expect(result.severity, equals(SymptomSeverity.critical));
      });
    }

    // 5. NEUROTOXIC ENVENOMATION TEST CASES
    final envenomationTestCases = [
      'Snake bite on foot with drooping eyelids and numbness',
      'Bitten by snake, cannot swallow, drooping eyelids',
    ];

    for (final testCase in envenomationTestCases) {
      test('ENVENOMATION: "$testCase"', () {
        final result = StartTriageDecisionTree.evaluate(testCase);
        expect(result.isRedFlag, isTrue, reason: 'MUST detect neurotoxic envenomation red-flag!');
        expect(result.protocolId, equals('PROTOCOL_ENVENOMATION_START_05'));
        expect(result.severity, equals(SymptomSeverity.critical));
      });
    }

  });
}

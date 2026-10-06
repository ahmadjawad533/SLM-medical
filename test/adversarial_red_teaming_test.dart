/// ---------------------------------------------------------------------------
/// ADVERSARIAL & EDGE-CASE RED-TEAMING TEST SUITE
/// ---------------------------------------------------------------------------
/// Tests challenging edge cases: panicked speech, pediatric emergencies,
/// pregnancy complications, and multiple co-occurring injuries.

import 'package:flutter_test/flutter_test.dart';
import 'package:slm_medical/modules/3_triage_engine/start_triage_decision_tree.dart';

void main() {
  group('Adversarial & Edge-Case Red-Teaming Suite', () {

    test('Panicked & Non-Linear Speech: Heavy Bleeding', () {
      const panickedInput = "oh god blood everywhere please help my husband fell off ladder and leg is heavy bleeding and gushing blood!!!";
      final result = StartTriageDecisionTree.evaluate(panickedInput);
      expect(result.isRedFlag, isTrue);
      expect(result.protocolId, equals('PROTOCOL_HEMORRHAGE_START_02'));
    });

    test('Pediatric Choking Emergency', () {
      const pediatricInput = "my 2 year old baby is choking on a grape, airway blocked and turning blue!";
      final result = StartTriageDecisionTree.evaluate(pediatricInput);
      expect(result.isRedFlag, isTrue);
      expect(result.protocolId, equals('PROTOCOL_AIRWAY_START_04'));
    });

    test('Multiple Co-occurring Injuries (Burn + Bleeding)', () {
      const multiInput = "worker suffered burned arm and heavy bleeding cut artery";
      final result = StartTriageDecisionTree.evaluate(multiInput);
      expect(result.isRedFlag, isTrue);
      // Heavy bleeding takes highest priority
      expect(result.protocolId, equals('PROTOCOL_HEMORRHAGE_START_02'));
    });

    test('Panicked Cardiac Emergency', () {
      const panickedCardiac = "my dad collapses pressing his chest pain and sweating profusely help fast";
      final result = StartTriageDecisionTree.evaluate(panickedCardiac);
      expect(result.isRedFlag, isTrue);
      expect(result.protocolId, equals('PROTOCOL_CARDIAC_START_01'));
    });

  });
}

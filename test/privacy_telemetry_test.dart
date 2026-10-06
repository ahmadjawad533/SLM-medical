/// ---------------------------------------------------------------------------
/// PRIVACY TELEMETRY & ANONYMIZER UNIT TEST SUITE
/// ---------------------------------------------------------------------------
/// Tests PII exclusion, category extraction, and background sync worker.

import 'package:flutter_test/flutter_test.dart';
import 'package:slm_medical/modules/7_data_sync/background_sync_worker.dart';
import 'package:slm_medical/modules/7_data_sync/privacy_anonymizer.dart';

void main() {
  group('Privacy-Preserving Telemetry Tests', () {

    test('Strict PII Exclusion Verification', () {
      const rawPrompt = "My name is John Doe, phone +15550199 in Nairobi. My dad has severe chest pain and sweating.";

      final record = PrivacyAnonymizer.sanitize(
        rawUserText: rawPrompt,
        triggeredRuleId: 'RULE_START_CARDIAC_2025',
        ragConfidenceScore: 0.94,
        appVersion: '1.0.0+1',
        llmVersion: '2.0.0',
        ragVersion: '1.4.0',
        rulesVersion: '1.2.0',
        ttftMs: 2180.0,
      );

      final json = record.toJson();

      // Verify ZERO PII in JSON payload
      expect(json.values.toString().contains("John Doe"), isFalse, reason: "MUST NOT log patient name!");
      expect(json.values.toString().contains("+15550199"), isFalse, reason: "MUST NOT log phone number!");
      expect(json.values.toString().contains("Nairobi"), isFalse, reason: "MUST NOT log exact location!");
      expect(json['symptomCategory'], equals('CARDIAC_CPR'));
      expect(json['triggeredRuleId'], equals('RULE_START_CARDIAC_2025'));
    });

    test('Background Batch Sync Worker Non-Blocking Guarantee', () async {
      final worker = BackgroundSyncWorker();

      final record = PrivacyAnonymizer.sanitize(
        rawUserText: 'snake bite foot',
        triggeredRuleId: 'RULE_START_ENVENOMATION_2025',
        ragConfidenceScore: 0.88,
        appVersion: '1.0.0+1',
        llmVersion: '2.0.0',
        ragVersion: '1.4.0',
        rulesVersion: '1.2.0',
        ttftMs: 2400.0,
      );

      worker.logInteraction(record);

      final syncSuccess = await worker.attemptOpportunisticSync(serverEndpointUrl: 'http://localhost:8080/api/v1/telemetry');
      expect(syncSuccess, isTrue);
    });

  });
}

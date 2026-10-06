/// ---------------------------------------------------------------------------
/// PACKAGE UPDATE & ROLLBACK UNIT TEST SUITE
/// ---------------------------------------------------------------------------
/// Tests signature verification, atomic package update, and instant rollback.

import 'package:flutter_test/flutter_test.dart';
import 'package:slm_medical/modules/7_data_sync/package_manifest.dart';
import 'package:slm_medical/modules/7_data_sync/package_rollback_manager.dart';
import 'package:slm_medical/modules/7_data_sync/signature_verifier.dart';

void main() {
  group('Modular Offline Update Engine Tests', () {

    late PackageRollbackManager rollbackManager;

    setUp(() {
      rollbackManager = PackageRollbackManager();
    });

    test('Valid Signed Package Update', () async {
      final validManifest = MedpackManifest(
        packageId: 'KB_UPDATE_V1_5',
        type: PackageType.ragKnowledgeBase,
        version: '1.5.0',
        publisher: 'WHO & IFRC Medical Consortium',
        releaseDate: '2026-10-05',
        signature: 'ED25519_SIG_OK_WHO_2026',
        fileSizeBytes: 2400000,
      );

      final success = await rollbackManager.applyUpdate(validManifest);
      expect(success, isTrue);
      expect(rollbackManager.activeVersions[PackageType.ragKnowledgeBase], equals('1.5.0'));
      expect(rollbackManager.backupVersions[PackageType.ragKnowledgeBase], equals('1.4.0'));
    });

    test('Tampered Package Signature Rejection', () async {
      final tamperedManifest = MedpackManifest(
        packageId: 'KB_UPDATE_TAMPERED',
        type: PackageType.ragKnowledgeBase,
        version: '1.9.0',
        publisher: 'Unknown Publisher',
        releaseDate: '2026-10-05',
        signature: 'TAMPERED_INVALID_SIG',
        fileSizeBytes: 2400000,
      );

      expect(
        () async => await rollbackManager.applyUpdate(tamperedManifest),
        throwsA(isA<Exception>()),
      );
    });

    test('Atomic Rollback to Last Known-Good Version', () async {
      // 1. Apply valid update to 1.5.0
      final validManifest = MedpackManifest(
        packageId: 'RULES_UPDATE_V1_3',
        type: PackageType.safetyRuleset,
        version: '1.3.0',
        publisher: 'WHO Triage Review Board',
        releaseDate: '2026-10-05',
        signature: 'ED25519_SIG_OK_WHO_2026',
        fileSizeBytes: 100000,
      );
      await rollbackManager.applyUpdate(validManifest);
      expect(rollbackManager.activeVersions[PackageType.safetyRuleset], equals('1.3.0'));

      // 2. Perform Rollback
      final rollbackSuccess = await rollbackManager.rollbackPackage(PackageType.safetyRuleset);
      expect(rollbackSuccess, isTrue);
      expect(rollbackManager.activeVersions[PackageType.safetyRuleset], equals('1.2.0'));
    });

  });
}

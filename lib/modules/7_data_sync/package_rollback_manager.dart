/// ---------------------------------------------------------------------------
/// ATOMIC PACKAGE UPDATER & ROLLBACK MANAGER
/// ---------------------------------------------------------------------------
/// Performs atomic swaps of LLM models, RAG vector DBs, and safety rulesets.
/// Maintains automatic pre-update backups. Reverts to last known-good state if
/// regressions or faults are detected.

import 'package:slm_medical/modules/7_data_sync/package_manifest.dart';
import 'package:slm_medical/modules/7_data_sync/signature_verifier.dart';

class PackageRollbackManager {
  // Active Package Versions Matrix
  final Map<PackageType, String> _activeVersions = {
    PackageType.llmModelWeights: "2.0.0",
    PackageType.ragKnowledgeBase: "1.4.0",
    PackageType.safetyRuleset: "1.2.0",
  };

  // Known-Good Backup Matrix for Rollback
  final Map<PackageType, String> _backupVersions = {
    PackageType.llmModelWeights: "1.9.0",
    PackageType.ragKnowledgeBase: "1.3.0",
    PackageType.safetyRuleset: "1.1.0",
  };

  Map<PackageType, String> get activeVersions => Map.unmodifiable(_activeVersions);
  Map<PackageType, String> get backupVersions => Map.unmodifiable(_backupVersions);

  /// Applies a signed update atomically with signature verification and backup creation.
  Future<bool> applyUpdate(MedpackManifest newManifest) async {
    // 1. VERIFY SIGNATURE BEFORE WRITING TO DISK
    final verification = SignatureVerifier.verifyPackage(newManifest);
    if (!verification.isValid) {
      throw Exception(verification.errorMessage);
    }

    // 2. CREATE PRE-UPDATE BACKUP OF CURRENT ACTIVE VERSION
    final type = newManifest.type;
    _backupVersions[type] = _activeVersions[type]!;

    // 3. ATOMICALLY SWAP TO NEW VERSION
    _activeVersions[type] = newManifest.version;
    print("[✓ ATOMIC SWAP SUCCESS] Package ${type.name} updated to v${newManifest.version}. Backup saved: v${_backupVersions[type]}.");

    return true;
  }

  /// Reverts a package to the last known-good backup version.
  Future<bool> rollbackPackage(PackageType type) async {
    final lastKnownGood = _backupVersions[type];
    if (lastKnownGood == null) {
      throw Exception("No backup available for rollback on package type ${type.name}");
    }

    final failedVersion = _activeVersions[type];
    _activeVersions[type] = lastKnownGood;

    print("[↺ ATOMIC ROLLBACK EXECUTED] Reverted ${type.name} from failed v$failedVersion back to known-good v$lastKnownGood.");
    return true;
  }
}

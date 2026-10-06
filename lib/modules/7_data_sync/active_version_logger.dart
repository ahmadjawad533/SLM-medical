/// ---------------------------------------------------------------------------
/// ACTIVE VERSION MATRIX AUDIT LOGGER
/// ---------------------------------------------------------------------------
/// Logs the exact model, knowledge base, and safety ruleset version active on
/// each device for complete clinical and software auditability.

import 'package:slm_medical/modules/7_data_sync/package_manifest.dart';

class ActiveDeviceVersionState {
  final String deviceId;
  final String appBinaryVersion;
  final String llmModelVersion;
  final String ragKbVersion;
  final String safetyRulesetVersion;
  final DateTime lastUpdatedTimestamp;

  ActiveDeviceVersionState({
    required this.deviceId,
    required this.appBinaryVersion,
    required this.llmModelVersion,
    required this.ragKbVersion,
    required this.safetyRulesetVersion,
    required this.lastUpdatedTimestamp,
  });

  Map<String, String> toJson() => {
    'deviceId': deviceId,
    'appBinaryVersion': appBinaryVersion,
    'llmModelVersion': llmModelVersion,
    'ragKbVersion': ragKbVersion,
    'safetyRulesetVersion': safetyRulesetVersion,
    'lastUpdatedTimestamp': lastUpdatedTimestamp.toIso8601String(),
  };
}

class ActiveVersionLogger {
  static ActiveDeviceVersionState getCurrentDeviceState({
    required Map<PackageType, String> activeVersions,
  }) {
    final state = ActiveDeviceVersionState(
      deviceId: 'SLM_DEVICE_RP4_8842',
      appBinaryVersion: '1.0.0+1',
      llmModelVersion: activeVersions[PackageType.llmModelWeights] ?? '2.0.0',
      ragKbVersion: activeVersions[PackageType.ragKnowledgeBase] ?? '1.4.0',
      safetyRulesetVersion: activeVersions[PackageType.safetyRuleset] ?? '1.2.0',
      lastUpdatedTimestamp: DateTime.now(),
    );

    print("[📋 ACTIVE DEVICE VERSION LOGGED] App: ${state.appBinaryVersion} | LLM: ${state.llmModelVersion} | RAG: ${state.ragKbVersion} | Rules: ${state.safetyRulesetVersion}");
    return state;
  }
}

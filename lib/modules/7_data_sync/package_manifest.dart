/// ---------------------------------------------------------------------------
/// INDEPENDENT PACKAGE MANIFEST SCHEMA
/// ---------------------------------------------------------------------------
/// Defines independent, decoupled package types (.medpack) for LLM weights,
/// RAG Knowledge Bases, and Triage Safety Rulesets.

enum PackageType { llmModelWeights, ragKnowledgeBase, safetyRuleset }

class MedpackManifest {
  final String packageId;
  final PackageType type;
  final String version;
  final String publisher;
  final String releaseDate;
  final String signature;
  final int fileSizeBytes;

  MedpackManifest({
    required this.packageId,
    required this.type,
    required this.version,
    required this.publisher,
    required this.releaseDate,
    required this.signature,
    required this.fileSizeBytes,
  });

  factory MedpackManifest.fromJson(Map<String, dynamic> json) {
    PackageType parsedType = PackageType.ragKnowledgeBase;
    final typeStr = json['type'] as String? ?? '';
    if (typeStr.contains('llm')) parsedType = PackageType.llmModelWeights;
    if (typeStr.contains('rules')) parsedType = PackageType.safetyRuleset;

    return MedpackManifest(
      packageId: json['package_id'] ?? 'MEDPACK_UNKNOWN',
      type: parsedType,
      version: json['version'] ?? '1.0.0',
      publisher: json['publisher'] ?? 'WHO / IFRC Vetted Medical Consortium',
      releaseDate: json['release_date'] ?? '2026-10-01',
      signature: json['signature'] ?? '',
      fileSizeBytes: json['file_size_bytes'] ?? 102400,
    );
  }

  Map<String, dynamic> toJson() => {
    'package_id': packageId,
    'type': type.name,
    'version': version,
    'publisher': publisher,
    'release_date': releaseDate,
    'signature': signature,
    'file_size_bytes': fileSizeBytes,
  };
}

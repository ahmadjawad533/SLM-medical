/// ---------------------------------------------------------------------------
/// MODULE 4: LOCAL RAG RETRIEVAL MODULE INTERFACE & ADAPTER
/// ---------------------------------------------------------------------------
/// Performs local embedding vector generation and similarity search against
/// pre-indexed medical protocol chunks stored in an embedded vector database (sqlite-vec).
/// Operates 100% offline without cloud connectivity.

import 'package:slm_medical/modules/4_rag_retrieval/offline_rag_engine.dart';

class RetrievalChunk {
  final String id;
  final String title;
  final String text;
  final double score;
  final String sourceProtocol;
  final ProvenanceMetadata provenance;

  RetrievalChunk({
    required this.id,
    required this.title,
    required this.text,
    required this.score,
    required this.sourceProtocol,
    required this.provenance,
  });
}

abstract class IRagRetriever {
  Future<void> initialize();
  Future<List<RetrievalChunk>> search(String query, {int topK = 3});
}

class LocalRagRetriever implements IRagRetriever {
  final OfflineRagEngine _engine = OfflineRagEngine(confidenceThreshold: 0.70);
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<List<RetrievalChunk>> search(String query, {int topK = 3}) async {
    if (!_isInitialized) await initialize();

    final result = await _engine.query(query, topK: topK);

    if (!result.isConfidenceMet) {
      // Return safe fallback chunk if confidence threshold is not met
      return [
        RetrievalChunk(
          id: 'FALLBACK_SAFEGUARD_00',
          title: 'SAFEGUARD: Low Confidence',
          text: result.safeFallbackMessage ?? 'Seek immediate emergency medical care. No verified offline protocol found for this query.',
          score: result.topScore,
          sourceProtocol: 'EMERGENCY_FALLBACK_RULES_2026',
          provenance: ProvenanceMetadata(
            sourceDocument: 'Emergency Medical Safety Policy',
            documentVersion: '1.0.0',
            section: 'Fallback Safeguard',
            targetDemographic: 'All',
            lastVettedDate: '2026-10-01',
          ),
        )
      ];
    }

    return result.chunks.map((c) => RetrievalChunk(
      id: c.chunkId,
      title: c.procedureTitle,
      text: c.content,
      score: c.similarityScore,
      sourceProtocol: c.provenance.sourceDocument,
      provenance: c.provenance,
    )).toList();
  }
}

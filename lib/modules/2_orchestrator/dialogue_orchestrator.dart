/// ---------------------------------------------------------------------------
/// MODULE 2: DIALOGUE ORCHESTRATOR WITH DUAL SAFETY BACKBONE
/// ---------------------------------------------------------------------------
/// Central pipeline coordinator enforcing:
/// 1. PRE-LLM START Triage Red-Flag Override (< 10ms)
/// 2. RAG Retrieval Grounding
/// 3. LLM Response Generation
/// 4. POST-LLM Safety Verification Filter (Dosage, Diagnosis, Scope Verifier)

import 'dart:async';
import 'package:slm_medical/modules/3_triage_engine/post_llm_safety_filter.dart';
import 'package:slm_medical/modules/3_triage_engine/triage_engine.dart';
import 'package:slm_medical/modules/4_rag_retrieval/rag_retriever.dart';
import 'package:slm_medical/modules/5_llm_inference/llm_inference_engine.dart';
import 'package:slm_medical/modules/6_voice_io/voice_io_service.dart';

class DialogueOrchestrator {
  final ITriageEngine triageEngine;
  final IRagRetriever ragRetriever;
  final ILlmInferenceEngine llmInference;
  final IVoiceService voiceService;

  DialogueOrchestrator({
    required this.triageEngine,
    required this.ragRetriever,
    required this.llmInference,
    required this.voiceService,
  });

  /// Processes user input through the complete dual-safety pipeline.
  Stream<String> processQueryStream(String userInput, {bool enableTts = false}) async* {
    // -----------------------------------------------------------------------
    // STAGE 1: PRE-LLM START TRIAGE SAFETY CHECK (ZERO-BYPASS OVERRIDE)
    // -----------------------------------------------------------------------
    final triage = triageEngine.evaluate(userInput);

    if (triage.isRedFlag) {
      final citationInfo = triage.citation != null
          ? "\n\n📚 Clinical Citation: ${triage.citation!.clinicalSource} (${triage.citation!.citationUrl})"
          : "";

      final shortCircuitText = "🛑 ${triage.title}\n\n"
          "🚨 EMERGENCY ADVISORY: SEEK IMMEDIATE PROFESSIONAL MEDICAL FACILITY CARE IF AT ALL REACHABLE.\n\n"
          "MANDATORY FIRST AID ACTIONS:\n" +
          triage.stepInstructions.map((s) => "• $s").join("\n") +
          citationInfo;

      yield shortCircuitText;

      if (enableTts && triage.audioNarrationText != null) {
        await voiceService.speak(triage.audioNarrationText!);
      }
      return; // Terminate pipeline immediately.
    }

    // -----------------------------------------------------------------------
    // STAGE 2: RAG RETRIEVAL (LOCAL VECTOR STORE QUERY)
    // -----------------------------------------------------------------------
    final chunks = await ragRetriever.search(userInput, topK: 3);
    final verbatimRagText = chunks.map((c) => "[${c.title}]: ${c.text}").join("\n\n");

    // -----------------------------------------------------------------------
    // STAGE 3: LLM GENERATION STREAMING
    // -----------------------------------------------------------------------
    final rawLlmBuffer = StringBuffer();

    await for (final token in llmInference.generateResponseStream(
      userQuery: userInput,
      retrievedChunks: chunks,
    )) {
      rawLlmBuffer.write(token);
    }

    // -----------------------------------------------------------------------
    // STAGE 4: POST-LLM SAFETY VERIFICATION FILTER
    // -----------------------------------------------------------------------
    final verifiedResult = PostLlmSafetyFilter.verify(
      generatedText: rawLlmBuffer.toString(),
      verbatimFallbackText: verbatimRagText,
    );

    yield verifiedResult.outputText;

    // -----------------------------------------------------------------------
    // STAGE 5: VOICE TTS NARRATION
    // -----------------------------------------------------------------------
    if (enableTts && verifiedResult.outputText.isNotEmpty) {
      await voiceService.speak(verifiedResult.outputText);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:slm_medical/core/config/power_governor_service.dart';
import 'package:slm_medical/modules/2_orchestrator/dialogue_orchestrator.dart';
import 'package:slm_medical/modules/3_triage_engine/triage_engine.dart';
import 'package:slm_medical/modules/4_rag_retrieval/rag_retriever.dart';
import 'package:slm_medical/modules/5_llm_inference/latency_benchmarker.dart';
import 'package:slm_medical/modules/5_llm_inference/llm_inference_engine.dart';
import 'package:slm_medical/modules/5_llm_inference/model_degradation_governor.dart';
import 'package:slm_medical/modules/6_voice_io/voice_io_service.dart';

void main() {
  runApp(const SlmMedicalApp());
}

class SlmMedicalApp extends StatelessWidget {
  const SlmMedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLM Medical - Emergency First Aid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFDC2626),
          secondary: Color(0xFFD97706),
          surface: Color(0xFF151C2C),
        ),
      ),
      home: const EmergencyHomeScreen(),
    );
  }
}

class EmergencyHomeScreen extends StatefulWidget {
  const EmergencyHomeScreen({super.key});

  @override
  State<EmergencyHomeScreen> createState() => _EmergencyHomeScreenState();
}

class _EmergencyHomeScreenState extends State<EmergencyHomeScreen> {
  late final DialogueOrchestrator _orchestrator;
  late final PowerGovernorService _powerGovernor;
  late final ModelConfigProfile _modelProfile;
  final TextEditingController _queryController = TextEditingController();
  
  String _outputText = "Tap an emergency category or speak to start offline first aid.";
  String _latencyTelemetry = "TTFT: -- | TPS: --";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _powerGovernor = PowerGovernorService();
    _modelProfile = ModelDegradationGovernor.selectOptimalProfile(
      totalRamMb: 3000, // Simulated 3GB RAM (Standard Tier)
      batteryPercentage: _powerGovernor.batteryLevel,
      isLowPowerModeActive: false,
    );

    _orchestrator = DialogueOrchestrator(
      triageEngine: RuleBasedTriageEngine(),
      ragRetriever: LocalRagRetriever(),
      llmInference: LlamaCppInferenceEngine(),
      voiceService: OfflineVoiceService(),
    );
  }

  void _handleQuery(String input) async {
    setState(() {
      _isProcessing = true;
      _outputText = "";
      _latencyTelemetry = "Processing on ${_modelProfile.modelName}...";
    });

    final startTime = DateTime.now().millisecondsSinceEpoch;
    int firstTokenTime = startTime;
    int tokenCount = 0;

    final stream = _orchestrator.processQueryStream(input, enableTts: true);
    await for (final chunk in stream) {
      if (tokenCount == 0) firstTokenTime = DateTime.now().millisecondsSinceEpoch;
      tokenCount++;
      setState(() {
        _outputText += chunk;
      });
    }

    final endTime = DateTime.now().millisecondsSinceEpoch;
    final metrics = LatencyBenchmarker.recordRun(
      startTimeMs: startTime,
      firstTokenTimeMs: firstTokenTime,
      endTimeMs: endTime,
      tokenCount: tokenCount,
    );

    setState(() {
      _isProcessing = false;
      _latencyTelemetry = "TTFT: ${metrics.timeToFirstTokenMs.toStringAsFixed(0)}ms | Total: ${metrics.totalResponseTimeMs.toStringAsFixed(0)}ms | ${metrics.tokensPerSecond.toStringAsFixed(1)} t/s";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚑 FIRST AID (100% Offline)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF151C2C),
        actions: [
          // Power Governor Status Badge
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.horizontal(6, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('⚡ ${_powerGovernor.batteryLevel}% ☀️', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          ),

          // Model Tier Status Badge
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.horizontal(6, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF065F46),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_modelProfile.tier.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.emerald-200)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Latency Telemetry Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Model: ${_modelProfile.modelName}', style: const TextStyle(fontSize: 11, color: Colors.slate300)),
                  Text(_latencyTelemetry, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.emerald-400)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Output Display Card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _outputText,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Category Triage Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _handleQuery('CPR not breathing'),
                    icon: const Text('🛑', style: TextStyle(fontSize: 20)),
                    label: const Text('CPR / BREATHING', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _handleQuery('heavy arterial bleeding'),
                    icon: const Text('🩸', style: TextStyle(fontSize: 20)),
                    label: const Text('HEAVY BLEEDING', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Text Input & Mic Control Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: InputDecoration(
                      hintText: 'Type symptom (e.g., sprained ankle)...',
                      filled: true,
                      fillColor: const Color(0xFF151C2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (val) => _handleQuery(val),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  iconSize: 32,
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
                  icon: const Icon(Icons.mic, color: Colors.white),
                  onPressed: () => _handleQuery('sprain treatment'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

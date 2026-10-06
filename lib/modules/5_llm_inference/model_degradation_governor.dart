/// ---------------------------------------------------------------------------
/// GRACEFUL MODEL DEGRADATION & HARDWARE TIER GOVERNOR
/// ---------------------------------------------------------------------------
/// Inspects available system RAM, CPU cores, and device profile to select the
/// optimal quantized model tier. Prevents Out-Of-Memory (OOM) crashes on low-spec hardware.

enum HardwareTier {
  high,     // > 4GB RAM: Qwen2.5-3B-Instruct-Q4_K_M (~2.2GB memory)
  standard, // 2-4GB RAM: Qwen2.5-1.5B-Instruct-Q4_K_M or Gemma-2-2B-Q4 (~1.1GB memory)
  lowPower  // < 2GB RAM or Battery < 15%: Pure deterministic rules & RAG text (0MB LLM memory)
}

class ModelConfigProfile {
  final HardwareTier tier;
  final String modelName;
  final String modelPath;
  final int recommendedThreads;
  final int contextWindowSize;
  final bool isLlmEnabled;

  ModelConfigProfile({
    required this.tier,
    required this.modelName,
    required this.modelPath,
    required this.recommendedThreads,
    required this.contextWindowSize,
    required this.isLlmEnabled,
  });
}

class ModelDegradationGovernor {
  /// Evaluates device hardware metrics and selects the optimal model execution profile.
  static ModelConfigProfile selectOptimalProfile({
    required int totalRamMb,
    required int batteryPercentage,
    required bool isLowPowerModeActive,
  }) {
    // 1. Force Low Power Mode if Battery < 15% or Low Power Mode active
    if (batteryPercentage < 15 || isLowPowerModeActive || totalRamMb < 1800) {
      return ModelConfigProfile(
        tier: HardwareTier.lowPower,
        modelName: 'Emergency Rule Engine (No LLM)',
        modelPath: 'assets/models/rules_only',
        recommendedThreads: 2,
        contextWindowSize: 256,
        isLlmEnabled: false,
      );
    }

    // 2. High Tier: > 4GB RAM
    if (totalRamMb >= 4000) {
      return ModelConfigProfile(
        tier: HardwareTier.high,
        modelName: 'Qwen2.5-3B-Instruct Q4_K_M',
        modelPath: 'assets/models/qwen2.5-3b-instruct-q4_k_m.gguf',
        recommendedThreads: 4,
        contextWindowSize: 2048,
        isLlmEnabled: true,
      );
    }

    // 3. Standard Tier: 2GB - 4GB RAM (Default Android & Raspberry Pi 4)
    return ModelConfigProfile(
      tier: HardwareTier.standard,
      modelName: 'Qwen2.5-1.5B-Instruct Q4_K_M',
      modelPath: 'assets/models/qwen2.5-1.5b-instruct-q4_k_m.gguf',
      recommendedThreads: 3,
      contextWindowSize: 1024,
      isLlmEnabled: true,
    );
  }
}

/// ---------------------------------------------------------------------------
/// LATENCY BENCHMARKER & AUTO-TUNER
/// ---------------------------------------------------------------------------
/// Tracks Time-To-First-Token (TTFT) and Tokens-Per-Second (TPS) benchmarks.
/// Automatically tunes context length and thread allocation to maintain target latency.

class LatencyMetrics {
  final double timeToFirstTokenMs;
  final double totalResponseTimeMs;
  final int totalTokensGenerated;
  final double tokensPerSecond;

  LatencyMetrics({
    required this.timeToFirstTokenMs,
    required this.totalResponseTimeMs,
    required this.totalTokensGenerated,
    required this.tokensPerSecond,
  });

  bool get isWithinTarget => timeToFirstTokenMs <= 3000 && totalResponseTimeMs <= 15000;
}

class LatencyBenchmarker {
  static LatencyMetrics recordRun({
    required int startTimeMs,
    required int firstTokenTimeMs,
    required int endTimeMs,
    required int tokenCount,
  }) {
    final ttft = (firstTokenTimeMs - startTimeMs).toDouble();
    final totalTime = (endTimeMs - startTimeMs).toDouble();
    final tps = totalTime > 0 ? (tokenCount / (totalTime / 1000.0)) : 0.0;

    final metrics = LatencyMetrics(
      timeToFirstTokenMs: ttft,
      totalResponseTimeMs: totalTime,
      totalTokensGenerated: tokenCount,
      tokensPerSecond: tps,
    );

    print("[⏱️ LATENCY BENCHMARK] TTFT: ${ttft.toStringAsFixed(0)}ms | Total: ${totalTime.toStringAsFixed(0)}ms | TPS: ${tps.toStringAsFixed(1)} t/s");
    return metrics;
  }
}

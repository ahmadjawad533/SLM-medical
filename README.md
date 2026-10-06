# Offline Emergency First-Aid Assistant — Full Stack Architecture & UI Design System

## 🚑 Project Overview

This codebase contains the complete mobile-first design system, 7-layer offline software architecture, RAG Knowledge Base pipeline, offline voice engine, START/JumpSTART Safety Backbone, Edge Engine hardware optimizations, Medical Data Pipeline, Evaluation & Red-Teaming Harness, Modular Update & Rollback Engine, and **Privacy-Preserving Telemetry & Operations Dashboard** for **SLM Medical** — an offline emergency first-aid assistant application deployed on Android mobile phones and Raspberry Pi edge kiosks in remote, off-grid areas.

---

## 🔒 Privacy-Preserving Telemetry & Ops Feedback Loop

```
[ App User Interaction ]
 (Touch UI or Voice Input)
            │
            ▼
[ Privacy Anonymizer & Sanitizer ]
 (Strips verbatim text, PII, names, & exact coordinates)
 (Keeps symptom categories, rule IDs, RAG confidence scores)
            │
            ▼
[ Local SQLite Telemetry DB ]
 (`telemetry.db` / AES-256 encrypted)
            │
 ─────────────────────────────────────────────────────── (Opportunistic Background Sync)
            │
 [ Connectivity Detected? ]
            │
      [ YES (Online) ] ──► [ Non-Blocking Background Batch Sync Worker ]
                                           │
                                           ▼
                            [ FastAPI Telemetry Endpoint ]
                            (`backend/main.py` / `/api/v1/telemetry`)
                                           │
                                           ▼
                            [ Clinical Ops Dashboard ]
                            (Monitors red-flag frequency, RAG confidence,
                             device version distribution, & feedback loops)
```

### Privacy-by-Design Rules (`PrivacyAnonymizer`)

1. **Strict PII Exclusion**: Verbatim prompt text, patient names, phone numbers, and exact GPS coordinates are excluded by design.
2. **Logged System Metrics Only**:
   - `telemetryId` (e.g. `TEL_1764984000`)
   - `anonymizedDeviceId` (e.g. `DEV_HASH_8842_ANON`)
   - `symptomCategory` (e.g. `CARDIAC_CPR`, `HEMORRHAGE`, `ENVENOMATION`)
   - `triggeredRuleId` (e.g. `RULE_START_CARDIAC_2025`)
   - `ragConfidenceScore` (e.g. `0.94`)
   - Active Version Matrix (`App`, `LLM`, `RAG`, `Rules`)
   - Hardware Latency (`TTFT`, `TPS`)
3. **Non-Blocking Opportunistic Background Sync (`BackgroundSyncWorker`)**:
   - Logs accumulate locally in SQLite when offline.
   - Batch-syncs to the central FastAPI ingestion endpoint (`backend/main.py`) when network connectivity becomes available.
   - Network timeouts or sync failures never block the Flutter UI or first-aid guidance.
4. **Clinical Telemetry Feedback Loop (`dashboard/clinical_ops_dashboard.py`)**:
   - Recurring low-confidence queries in the field (e.g., `wasp sting allergic reaction` score `0.58`) are automatically flagged on the dashboard to trigger Knowledge Base update releases (`.medpack` v1.5.0).

---

## ⚡ Low-Spec Hardware Optimization & Power Governor

| Hardware Tier | Memory Threshold | Quantized Model Target | RAM Footprint | Target TTFT | Target TPS |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **High Tier** | > 4GB RAM | `Qwen2.5-3B-Instruct Q4_K_M` | ~2.2 GB | ~1.8 sec | ~24 t/s |
| **Standard Tier** | 2–4GB RAM (RPi 4/5) | `Qwen2.5-1.5B-Instruct Q4_K_M` | ~1.1 GB | ~2.2 sec | ~30 t/s |
| **Low-Power / Saver**| < 2GB RAM / Battery < 15% | Emergency Rules + RAG Text (No LLM) | < 60 MB | **< 10 ms** | N/A |

---

## 🛑 Dual Safety Backbone (Pre-LLM Override & Post-LLM Verifier)

| Red-Flag Pattern | Severity | Protocol ID | Clinical Source / Citation |
| :--- | :--- | :--- | :--- |
| **Chest pain + Shortness of breath + Sweating** | Critical 🛑 | `PROTOCOL_CARDIAC_START_01` | AHA 2025 First Aid Guidelines |
| **Heavy uncontrolled bleeding / Cut artery** | Critical 🛑 | `PROTOCOL_HEMORRHAGE_START_02`| CoTCCC 2025 & Stop The Bleed |
| **Facial droop + Slurred speech + Arm weakness**| Critical 🛑 | `PROTOCOL_STROKE_FAST_03` | ASA/AHA Stroke F.A.S.T. 2025 |
| **Difficulty breathing / Airway obstruction** | Critical 🛑 | `PROTOCOL_AIRWAY_START_04` | ERC Resuscitation Guidelines 2025 |
| **Snake bite + Neurological symptoms** | Critical 🛑 | `PROTOCOL_ENVENOMATION_START_05`| WHO Guidelines for Management of Snakebites |

---

## 🏗️ 7-Layer Modular Architecture

| Layer | Directory | Primary Role & Interface | Key Technologies |
| :--- | :--- | :--- | :--- |
| **1. UI Layer** | `lib/modules/1_ui/` & `lib/main.dart` | Mobile/Kiosk app shell, dark theme, accessibility, RTL switcher. | Flutter, Tailwind tokens |
| **2. Dialogue Orchestrator** | `lib/modules/2_orchestrator/` | Pipeline coordinator managing input -> safety -> RAG -> LLM -> TTS. | Dart async streams |
| **3. Triage Engine** | `lib/modules/3_triage_engine/` | **START/JumpSTART Triage Engine (`ITriageEngine`) & Post-LLM Verifier**. Short-circuits ML/LLM in < 10ms. | Pure Dart rules |
| **4. RAG Retrieval** | `lib/modules/4_rag_retrieval/` | Vector store similarity search & ONNX chunk retrieval (`IRagRetriever`). | `sqlite-vec` / ONNX |
| **5. LLM Inference** | `lib/modules/5_llm_inference/` | Quantized 4-bit GGUF model execution (`ILlmInferenceEngine`). Model degradation governor. | `llama.cpp` C++ FFI |
| **6. Voice I/O** | `lib/modules/6_voice_io/` | Offline STT, VAD, Piper TTS, Barge-In & Fixed Intent Router (`IVoiceService`). | `whisper.cpp`, Silero VAD, Piper |
| **7. Data Sync** | `lib/modules/7_data_sync/` | **Offline Package Update, Privacy Anonymizer, Background Sync Worker (`IDataSyncService`)**. | SQLite, FastAPI, Hive |

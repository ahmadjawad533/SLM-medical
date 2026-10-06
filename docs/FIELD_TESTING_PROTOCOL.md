# Target User Field Usability Testing Protocol

## 📋 Purpose & Scope

Simulated laboratory testing alone is insufficient for emergency software deployed in remote, off-grid regions. This protocol specifies the mandatory field usability evaluation framework conducted with **actual target users** (varying literacy levels, local dialects, high-stress emergency simulations) prior to wider software rollout.

---

## 👥 Participant Selection Criteria

- **Literacy Spectrum**:
  - Tier 1: Low-literacy / Non-fluent readers (Primary icon-first & voice reliance).
  - Tier 2: Basic literacy (Requires large text mode & picture assistance).
  - Tier 3: Fluent community health workers / first responders.
- **Languages / Dialects**: Minimum 10 participants per target language (`en`, `sw`, `ar`, `hi`, `es`).
- **Environmental Context**: Outdoor daylight, night-time low light, high background noise (wind, market noise, engine sound).

---

## 🧪 Simulation Scenarios & Usability Scorecard

### Scenario 1: Severe Hemorrhage Simulation (High Stress)
- **Task**: User receives simulated victim with heavy leg bleeding.
- **Success Criteria**:
  1. User reaches Bleeding Guide within **< 5 seconds** (via SOS button, category icon, or voice command).
  2. Follows direct pressure imperative instruction without confusion.
  3. No hesitation caused by small touch targets or text complexity.

### Scenario 2: Unconscious Victim / CPR (Low Literacy)
- **Task**: User encounters non-responsive victim.
- **Success Criteria**:
  1. Activates CPR guide via voice mic ("Help") or Red Octagon card.
  2. Matches compression cadence with the 110 BPM visual/audio CPR metronome beat.

---

## 📊 Usability Metrics & Release Thresholds

| Usability Metric | Target Release Threshold | Measurement Method |
| :--- | :--- | :--- |
| **Time-to-First-Action** | **< 5.0 seconds** | Stopwatch from emergency prompt to first correct UI tap/voice command |
| **Instruction Comprehension** | **>= 95.0%** | Observer confirmation of correct physical demonstration |
| **Voice Command Success** | **>= 90.0%** | Successful STT intent recognition without noise fallback |
| **Low-Literacy Task Completion**| **100.0%** | Task completion without reading text aloud |

/// ---------------------------------------------------------------------------
/// START / JumpSTART DETERMINISTIC TRIAGE DECISION TREE & CLINICAL CITATIONS
/// ---------------------------------------------------------------------------
/// Zero-bypass decision tree based on Simple Triage and Rapid Treatment (START)
/// and JumpSTART pediatric triage principles. Detects critical red-flag patterns
/// and forces an immediate short-circuit before any ML/LLM inference.

enum SymptomSeverity { mild, moderate, severe, critical }

class ClinicalRuleCitation {
  final String ruleId;
  final String conditionName;
  final String clinicalSource;
  final String citationUrl;

  ClinicalRuleCitation({
    required this.ruleId,
    required this.conditionName,
    required this.clinicalSource,
    required this.citationUrl,
  });
}

class TriageDecisionResult {
  final bool isRedFlag;
  final SymptomSeverity severity;
  final String protocolId;
  final String protocolTitle;
  final List<String> mandatoryActions;
  final String careAdvisoryText;
  final ClinicalRuleCitation citation;

  TriageDecisionResult({
    required this.isRedFlag,
    required this.severity,
    required this.protocolId,
    required this.protocolTitle,
    required this.mandatoryActions,
    required this.careAdvisoryText,
    required this.citation,
  });

  factory TriageDecisionResult.none() => TriageDecisionResult(
    isRedFlag: false,
    severity: SymptomSeverity.mild,
    protocolId: 'NONE',
    protocolTitle: 'No Red-Flag',
    mandatoryActions: [],
    careAdvisoryText: '',
    citation: ClinicalRuleCitation(
      ruleId: 'NONE',
      conditionName: 'Standard',
      clinicalSource: 'N/A',
      citationUrl: '',
    ),
  );
}

class StartTriageDecisionTree {
  /// Evaluates user input text against START/JumpSTART red-flag decision trees.
  static TriageDecisionResult evaluate(String userInput) {
    final text = userInput.toLowerCase().trim();

    // 1. CARDIAC EMERGENCY RED-FLAG (Chest Pain + Shortness of Breath + Sweating)
    if (_hasAll(text, ['chest pain']) && (_hasAny(text, ['shortness of breath', 'breathless', 'sweating', 'sweat', 'arm pain']))) {
      return TriageDecisionResult(
        isRedFlag: true,
        severity: SymptomSeverity.critical,
        protocolId: 'PROTOCOL_CARDIAC_START_01',
        protocolTitle: 'CRITICAL CARDIAC EMERGENCY (ACUTE CORONARY SYNDROME)',
        mandatoryActions: [
          'Place person in comfortable sitting position with knees bent.',
          'Loosen tight clothing around neck and waist.',
          'Do NOT leave person unattended.',
          'Be prepared to initiate CPR immediately if responsiveness is lost.'
        ],
        careAdvisoryText: '🚨 SEEK IMMEDIATE EMERGENCY FACILITY CARE OR AMBULANCE TRANSPORT IF AT ALL REACHABLE.',
        citation: ClinicalRuleCitation(
          ruleId: 'RULE_START_CARDIAC_2025',
          conditionName: 'Acute Coronary Syndrome / Myocardial Infarction',
          clinicalSource: 'American Heart Association (AHA) 2025 First Aid Guidelines',
          citationUrl: 'https://cpr.heart.org/en/resuscitation-science/first-aid-guidelines',
        ),
      );
    }

    // 2. HEMORRHAGE CONTROL RED-FLAG (Heavy Uncontrolled Bleeding / Cut Artery)
    if (_hasAny(text, ['heavy bleeding', 'gushing blood', 'cut artery', 'spurting blood', 'uncontrolled bleeding', 'blood loss'])) {
      return TriageDecisionResult(
        isRedFlag: true,
        severity: SymptomSeverity.critical,
        protocolId: 'PROTOCOL_HEMORRHAGE_START_02',
        protocolTitle: 'CRITICAL HEMORRHAGE (SEVERE ARTERIAL BLEEDING)',
        mandatoryActions: [
          'Apply direct firm pressure over wound immediately using clean cloth or bandage.',
          'Do NOT release pressure even if cloth becomes soaked with blood.',
          'Elevate wound above heart level if no broken bone is suspected.',
          'Apply a tight pressure dressing or commercial tourniquet 5-7cm above wound if bleeding persists.'
        ],
        careAdvisoryText: '🚨 SEEK IMMEDIATE EMERGENCY FACILITY CARE OR SURGICAL TRANSPORT IF AT ALL REACHABLE.',
        citation: ClinicalRuleCitation(
          ruleId: 'RULE_START_HEMORRHAGE_2025',
          conditionName: 'Massive Hemorrhage Control',
          clinicalSource: 'Committee on Tactical Combat Casualty Care (CoTCCC) & Stop The Bleed 2025',
          citationUrl: 'https://www.dhs.gov/stopthebleed',
        ),
      );
    }

    // 3. STROKE FAST RED-FLAG (Facial Droop, Slurred Speech, Arm Weakness)
    if (_hasAny(text, ['facial droop', 'face drooping', 'slurred speech', 'cannot speak clearly', 'arm weakness', 'one side weak', 'stroke'])) {
      return TriageDecisionResult(
        isRedFlag: true,
        severity: SymptomSeverity.critical,
        protocolId: 'PROTOCOL_STROKE_FAST_03',
        protocolTitle: 'CRITICAL STROKE WARNING (F.A.S.T. PROTOCOL)',
        mandatoryActions: [
          'Face: Check for facial droop when smiling.',
          'Arms: Ask person to raise both arms. Note if one arm drifts downward.',
          'Speech: Listen for slurred or strange speech.',
          'Time: Note exact time symptoms started. Keep person lying flat on their side.'
        ],
        careAdvisoryText: '🚨 SEEK IMMEDIATE EMERGENCY STROKE FACILITY CARE IF AT ALL REACHABLE.',
        citation: ClinicalRuleCitation(
          ruleId: 'RULE_START_STROKE_2025',
          conditionName: 'Acute Ischemic Stroke F.A.S.T. Assessment',
          clinicalSource: 'American Stroke Association (ASA/AHA) 2025 Guidelines',
          citationUrl: 'https://www.stroke.org/en/about-stroke/stroke-symptoms',
        ),
      );
    }

    // 4. AIRWAY OBSTRUCTION / RESPIRATORY DISTRESS RED-FLAG
    if (_hasAny(text, ['choking', 'airway blocked', 'cannot breathe', 'stridor', 'turning blue', 'gasping for air'])) {
      return TriageDecisionResult(
        isRedFlag: true,
        severity: SymptomSeverity.critical,
        protocolId: 'PROTOCOL_AIRWAY_START_04',
        protocolTitle: 'CRITICAL AIRWAY OBSTRUCTION (CHOKING / STRIDOR)',
        mandatoryActions: [
          'If conscious: Deliver 5 sharp back blows between shoulder blades.',
          'If still choking: Perform 5 sharp upward abdominal thrusts (Heimlich maneuver).',
          'If unconscious: Lower to ground, call for help, begin chest compressions.'
        ],
        careAdvisoryText: '🚨 SEEK IMMEDIATE EMERGENCY MEDICAL FACILITY CARE IF AT ALL REACHABLE.',
        citation: ClinicalRuleCitation(
          ruleId: 'RULE_START_AIRWAY_2025',
          conditionName: 'Foreign Body Airway Obstruction (FBAO)',
          clinicalSource: 'European Resuscitation Council (ERC) 2025 Guidelines',
          citationUrl: 'https://cprguidelines.eu/',
        ),
      );
    }

    // 5. NEUROTOXIC ENVENOMATION RED-FLAG (Snake Bite + Neurological Symptoms)
    if (_hasAll(text, ['snake']) && _hasAny(text, ['bite', 'bitten']) && _hasAny(text, ['drooping eyelids', 'numbness', 'paralysis', 'cannot swallow', 'blurred vision'])) {
      return TriageDecisionResult(
        isRedFlag: true,
        severity: SymptomSeverity.critical,
        protocolId: 'PROTOCOL_ENVENOMATION_START_05',
        protocolTitle: 'CRITICAL NEUROTOXIC SNAKE ENVENOMATION',
        mandatoryActions: [
          'Keep victim completely calm and still. Immobilize bitten limb with splint.',
          'Do NOT cut, suck, or apply tourniquet.',
          'Monitor breathing constantly.',
          'Prepare for rescue breathing if muscle weakness affects chest.'
        ],
        careAdvisoryText: '🚨 SEEK IMMEDIATE EMERGENCY FACILITY CARE WITH ANTIVENOM IF AT ALL REACHABLE.',
        citation: ClinicalRuleCitation(
          ruleId: 'RULE_START_ENVENOMATION_2025',
          conditionName: 'Neurotoxic Snake Envenomation',
          clinicalSource: 'World Health Organization (WHO) Guidelines for Management of Snakebites',
          citationUrl: 'https://www.who.int/publications/i/item/9789290225300',
        ),
      );
    }

    return TriageDecisionResult.none();
  }

  static bool _hasAll(String text, List<String> terms) => terms.every((t) => text.contains(t));
  static bool _hasAny(String text, List<String> terms) => terms.any((t) => text.contains(t));
}

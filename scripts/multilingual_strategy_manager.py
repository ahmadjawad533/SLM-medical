#!/usr/bin/env python3
"""
MULTILINGUAL DATA TRACK & STRATEGY MANAGER
-------------------------------------------------------------------------------
Determines language strategy (Parallel Translated Dataset vs Real-Time Inference Translation)
per target language based on translation quality ratings and clinician review availability.
"""

import json

LANGUAGE_STRATEGY_CONFIG = {
    "en": {
        "language_name": "English",
        "strategy": "PARALLEL_DATASET",
        "translation_quality": 1.0,
        "clinician_vetted": True,
        "notes": "Native source language."
    },
    "sw": {
        "language_name": "Swahili (Kiswahili)",
        "strategy": "PARALLEL_DATASET",
        "translation_quality": 0.95,
        "clinician_vetted": True,
        "notes": "Clinician-vetted Swahili medical terminology dictionary."
    },
    "ar": {
        "language_name": "Arabic (العربية)",
        "strategy": "PARALLEL_DATASET",
        "translation_quality": 0.94,
        "clinician_vetted": True,
        "notes": "Vetted RTL medical protocol translations."
    },
    "hi": {
        "language_name": "Hindi (हिन्दी)",
        "strategy": "PARALLEL_DATASET",
        "translation_quality": 0.92,
        "clinician_vetted": True,
        "notes": "Vetted Devanagari script protocols."
    },
    "es": {
        "language_name": "Spanish (Español)",
        "strategy": "PARALLEL_DATASET",
        "translation_quality": 0.96,
        "clinician_vetted": True,
        "notes": "Full parallel first aid guidelines."
    },
    "local_dialect": {
        "language_name": "Emerging Local Dialects",
        "strategy": "TRANSLATION_AT_INFERENCE",
        "translation_quality": 0.70,
        "clinician_vetted": False,
        "notes": "Fallback real-time neural translation at runtime."
    }
}

def get_strategy(lang_code):
    return LANGUAGE_STRATEGY_CONFIG.get(lang_code, LANGUAGE_STRATEGY_CONFIG["local_dialect"])

if __name__ == "__main__":
    print(json.dumps(LANGUAGE_STRATEGY_CONFIG, indent=2))

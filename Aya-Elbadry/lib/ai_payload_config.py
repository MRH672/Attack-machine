#!/usr/bin/env python

"""
Copyright (c) 2025 Aya Elbadry (@Aya-Elbadry)
Configuration file for AI Payload Generator
"""

import os

# AI Provider Configuration
AI_PROVIDER = os.getenv("AI_PROVIDER", "openai")  # openai, anthropic, local

# OpenAI Configuration
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4-turbo-preview")

# Anthropic (Claude) Configuration
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY", "")
ANTHROPIC_MODEL = os.getenv("ANTHROPIC_MODEL", "claude-3-opus-20240229")

# Local LLM Configuration (Ollama, etc.)
LOCAL_LLM_URL = os.getenv("LOCAL_LLM_URL", "http://localhost:11434/api/generate")
LOCAL_LLM_MODEL = os.getenv("LOCAL_LLM_MODEL", "llama2")

# Auto-update settings
AUTO_UPDATE_ENABLED = os.getenv("AUTO_UPDATE_ENABLED", "true").lower() == "true"
AUTO_UPDATE_INTERVAL = int(os.getenv("AUTO_UPDATE_INTERVAL", "86400"))  # 24 hours in seconds

# Learning settings
LEARNING_ENABLED = os.getenv("LEARNING_ENABLED", "true").lower() == "true"
MAX_LEARNING_ENTRIES = int(os.getenv("MAX_LEARNING_ENTRIES", "1000"))

# WAF types to target
TARGET_WAF_TYPES = [
    "Akamai",
    "Cloudflare",
    "Imperva",
    "Incapsula",
    "WordFence",
    "ModSecurity",
    "AWS WAF"
]

# Techniques to generate
TARGET_TECHNIQUES = [
    "boolean",
    "error",
    "time",
    "union",
    "stacked"
]

def get_api_key():
    """Get API key based on provider"""
    if AI_PROVIDER == "openai":
        return OPENAI_API_KEY
    elif AI_PROVIDER == "anthropic":
        return ANTHROPIC_API_KEY
    else:
        return None

def get_model():
    """Get model based on provider"""
    if AI_PROVIDER == "openai":
        return OPENAI_MODEL
    elif AI_PROVIDER == "anthropic":
        return ANTHROPIC_MODEL
    elif AI_PROVIDER == "local":
        return LOCAL_LLM_MODEL
    else:
        return "gpt-4"


#!/usr/bin/env python3
"""
message-validator.py
Message validation and sanitization
Location: sap/

This is SAP (protective guardrails) for message validation
Used by: rami/monitor/watch_bridge.py
"""

# Configuration
MAX_MESSAGE_LENGTH = 1000
INVALID_CHARS = ['\x00', '\r']  # Null bytes and carriage returns


def validate_message(message):
    """
    Validate message format and content
    
    Args:
        message: Raw message string
    
    Returns:
        Validated message or None if invalid
    """
    if not message:
        return None
    
    # Strip whitespace
    message = message.strip()
    
    # Check if empty after strip
    if not message:
        return None
    
    # Check length
    if len(message) > MAX_MESSAGE_LENGTH:
        message = message[:MAX_MESSAGE_LENGTH]
    
    # Remove invalid characters
    for char in INVALID_CHARS:
        message = message.replace(char, '')
    
    return message


def sanitize_message(message):
    """
    Sanitize message for safe display
    
    Args:
        message: Raw message string
    
    Returns:
        Sanitized message
    """
    if not message:
        return ""
    
    # Remove control characters except newline and tab
    sanitized = ""
    for char in message:
        if ord(char) >= 32 or char in ['\n', '\t']:
            sanitized += char
    
    return sanitized


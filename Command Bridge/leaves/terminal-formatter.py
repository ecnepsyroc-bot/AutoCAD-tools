#!/usr/bin/env python3
"""
terminal-formatter.py
Terminal display formatting (pure presentation)
Location: leaves/

This is LEAVES (presentation layer) for terminal output.
Pure presentation only - no business logic, no domain logic.
"""

from datetime import datetime


def format_timestamp():
    """
    Format current time as timestamp (pure presentation)
    
    Returns:
        Formatted timestamp string [HH:MM:SS]
    """
    return datetime.now().strftime('%H:%M:%S')


def format_message(message, emoji, timestamp=None):
    """
    Format message for terminal display (pure presentation)
    
    Args:
        message: Message string
        emoji: Emoji string (provided by graft)
        timestamp: Optional timestamp (defaults to current time)
    
    Returns:
        Formatted display string
    """
    if timestamp is None:
        timestamp = format_timestamp()
    
    return f"[{timestamp}] {emoji} {message}"


def format_reset_message(timestamp=None):
    """
    Format file reset message (pure presentation)
    
    Args:
        timestamp: Optional timestamp (defaults to current time)
    
    Returns:
        Formatted reset message
    """
    if timestamp is None:
        timestamp = format_timestamp()
    
    return f"[{timestamp}] 🔄 Bridge file was reset"

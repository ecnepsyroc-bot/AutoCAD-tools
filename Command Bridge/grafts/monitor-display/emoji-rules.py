#!/usr/bin/env python3
"""
emoji-rules.py
Emoji selection rules (translation logic)
Location: grafts/monitor-display/

This contains the business logic for emoji selection based on message content.
This is graft-level translation logic, not domain logic.
"""


def select_emoji_for_message(message):
    """
    Select appropriate emoji based on message content
    
    This is translation logic (graft responsibility), not domain logic.
    It maps message patterns to presentation elements.
    
    Args:
        message: Message string
    
    Returns:
        Emoji string
    """
    message_upper = message.upper()
    
    if 'ERROR' in message_upper:
        return "❌"
    elif 'SUCCESS' in message_upper or 'COMPLETE' in message_upper:
        return "✅"
    elif 'FOUND' in message_upper or 'DETECTED' in message_upper:
        return "🔍"
    elif message.startswith('CMD'):
        return "⚡"
    elif message.startswith('TEST'):
        return "🧪"
    elif 'MONITOR' in message_upper:
        return "📡"
    else:
        return "→"


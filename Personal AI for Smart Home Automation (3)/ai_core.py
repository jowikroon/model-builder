"""
AI Core Service
The main AI logic that powers conversation, intent recognition, and natural language understanding.
"""

import re
import json
import random
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class Intent:
    """Represents a recognized intent from user input"""
    intent: str
    confidence: float
    entities: Dict[str, Any]
    context: Dict[str, Any]

@dataclass
class AIResponse:
    """Represents an AI response to user input"""
    text: str
    intent: Optional[Intent]
    actions: List[Dict[str, Any]]
    confidence: float
    context: Dict[str, Any]

class NaturalLanguageProcessor:
    """Handles natural language understanding and intent recognition"""
    
    def __init__(self):
        self.intent_patterns = {
            'music_control': [
                r'play\s+(.*)',
                r'start\s+(.*)\s+music',
                r'put\s+on\s+(.*)',
                r'listen\s+to\s+(.*)',
                r'pause\s+music',
                r'stop\s+music',
                r'next\s+song',
                r'previous\s+song',
                r'skip\s+track',
                r'volume\s+(up|down|\d+)',
            ],
            'lighting_control': [
                r'turn\s+(on|off)\s+(.+)\s+light',
                r'(dim|brighten)\s+(.+)',
                r'set\s+(.+)\s+to\s+(\d+)%',
                r'change\s+(.+)\s+color\s+to\s+(.+)',
                r'lights\s+(on|off)',
                r'make\s+it\s+(brighter|darker)',
            ],
            'calendar_management': [
                r'schedule\s+(.*)\s+for\s+(.*)',
                r'create\s+meeting\s+(.*)',
                r'what\'s\s+on\s+my\s+calendar',
                r'when\s+is\s+my\s+next\s+meeting',
                r'cancel\s+(.+)\s+meeting',
                r'reschedule\s+(.*)',
                r'free\s+time\s+(.*)',
            ],
            'home_automation': [
                r'set\s+temperature\s+to\s+(\d+)',
                r'turn\s+(on|off)\s+(.+)',
                r'check\s+(.+)\s+status',
                r'lock\s+the\s+door',
                r'unlock\s+the\s+door',
                r'arm\s+security',
                r'disarm\s+security',
            ],
            'information_query': [
                r'what\s+is\s+(.*)',
                r'tell\s+me\s+about\s+(.*)',
                r'how\s+do\s+I\s+(.*)',
                r'show\s+me\s+(.*)',
                r'find\s+(.*)',
                r'search\s+for\s+(.*)',
            ],
            'system_control': [
                r'show\s+my\s+(.*)',
                r'open\s+(.*)',
                r'close\s+(.*)',
                r'settings',
                r'preferences',
                r'help',
                r'status',
            ],
            'greeting': [
                r'hello',
                r'hi',
                r'hey',
                r'good\s+(morning|afternoon|evening)',
                r'how\s+are\s+you',
            ],
            'goodbye': [
                r'bye',
                r'goodbye',
                r'see\s+you\s+later',
                r'talk\s+to\s+you\s+later',
                r'goodnight',
            ]
        }
        
        self.entity_extractors = {
            'time': r'(\d{1,2}:\d{2}|\d{1,2}\s*(am|pm)|tomorrow|today|next\s+week)',
            'date': r'(\d{1,2}/\d{1,2}/\d{4}|\d{1,2}-\d{1,2}-\d{4}|tomorrow|today|next\s+\w+)',
            'number': r'(\d+)',
            'color': r'(red|blue|green|yellow|orange|purple|pink|white|black|warm|cool)',
            'device': r'(light|lamp|tv|television|speaker|thermostat|door|window)',
            'room': r'(living\s+room|bedroom|kitchen|bathroom|office|garage|basement)',
        }

    def process_input(self, text: str, context: Dict[str, Any] = None) -> Intent:
        """Process user input and return recognized intent"""
        if context is None:
            context = {}
            
        text = text.lower().strip()
        
        # Find matching intent
        best_intent = None
        best_confidence = 0.0
        best_entities = {}
        
        for intent_name, patterns in self.intent_patterns.items():
            for pattern in patterns:
                match = re.search(pattern, text, re.IGNORECASE)
                if match:
                    confidence = self._calculate_confidence(text, pattern, match)
                    if confidence > best_confidence:
                        best_intent = intent_name
                        best_confidence = confidence
                        best_entities = self._extract_entities(text, match)
        
        # If no specific intent found, classify as general query
        if best_intent is None:
            best_intent = 'general_query'
            best_confidence = 0.5
            best_entities = self._extract_entities(text)
        
        return Intent(
            intent=best_intent,
            confidence=best_confidence,
            entities=best_entities,
            context=context
        )

    def _calculate_confidence(self, text: str, pattern: str, match) -> float:
        """Calculate confidence score for intent match"""
        # Base confidence from pattern match
        base_confidence = 0.7
        
        # Boost confidence for exact matches
        if len(match.group(0)) == len(text):
            base_confidence += 0.2
        
        # Boost confidence for longer matches
        match_ratio = len(match.group(0)) / len(text)
        base_confidence += match_ratio * 0.1
        
        return min(base_confidence, 1.0)

    def _extract_entities(self, text: str, match=None) -> Dict[str, Any]:
        """Extract entities from text"""
        entities = {}
        
        for entity_type, pattern in self.entity_extractors.items():
            matches = re.findall(pattern, text, re.IGNORECASE)
            if matches:
                entities[entity_type] = matches
        
        # Extract specific entities from regex groups if available
        if match and match.groups():
            groups = match.groups()
            if len(groups) >= 1:
                entities['primary'] = groups[0]
            if len(groups) >= 2:
                entities['secondary'] = groups[1]
        
        return entities

class ConversationManager:
    """Manages conversation flow and context"""
    
    def __init__(self):
        self.conversation_history = {}
        self.context_memory = {}
        
    def add_message(self, user_id: int, message: str, response: str, intent: Intent):
        """Add a message to conversation history"""
        if user_id not in self.conversation_history:
            self.conversation_history[user_id] = []
        
        self.conversation_history[user_id].append({
            'timestamp': datetime.utcnow(),
            'user_message': message,
            'ai_response': response,
            'intent': intent.intent,
            'confidence': intent.confidence,
            'entities': intent.entities
        })
        
        # Keep only last 50 messages
        if len(self.conversation_history[user_id]) > 50:
            self.conversation_history[user_id] = self.conversation_history[user_id][-50:]
    
    def get_context(self, user_id: int) -> Dict[str, Any]:
        """Get conversation context for user"""
        if user_id not in self.conversation_history:
            return {}
        
        recent_messages = self.conversation_history[user_id][-5:]
        
        context = {
            'recent_intents': [msg['intent'] for msg in recent_messages],
            'recent_entities': {},
            'conversation_length': len(self.conversation_history[user_id]),
            'last_interaction': recent_messages[-1]['timestamp'] if recent_messages else None
        }
        
        # Aggregate recent entities
        for msg in recent_messages:
            for entity_type, values in msg['entities'].items():
                if entity_type not in context['recent_entities']:
                    context['recent_entities'][entity_type] = []
                context['recent_entities'][entity_type].extend(values)
        
        return context

class ResponseGenerator:
    """Generates appropriate responses based on intent and context"""
    
    def __init__(self):
        self.response_templates = {
            'music_control': {
                'play': [
                    "Playing {music} for you now.",
                    "Starting {music}. Enjoy!",
                    "I'll play {music} right away.",
                ],
                'pause': [
                    "Music paused.",
                    "Pausing your music now.",
                    "Music is now paused.",
                ],
                'volume': [
                    "Adjusting volume to {level}.",
                    "Volume set to {level}.",
                    "Changed volume to {level}.",
                ]
            },
            'lighting_control': {
                'turn_on': [
                    "Turning on the {device} now.",
                    "The {device} is now on.",
                    "I've turned on the {device} for you.",
                ],
                'turn_off': [
                    "Turning off the {device}.",
                    "The {device} is now off.",
                    "I've turned off the {device}.",
                ],
                'dim': [
                    "Dimming the {device} to {level}%.",
                    "Set {device} brightness to {level}%.",
                    "Adjusted {device} to {level}% brightness.",
                ]
            },
            'calendar_management': {
                'schedule': [
                    "I've scheduled {event} for {time}.",
                    "Created a meeting for {event} at {time}.",
                    "Added {event} to your calendar for {time}.",
                ],
                'query': [
                    "You have {count} meetings today.",
                    "Your next meeting is {event} at {time}.",
                    "Here's what's on your calendar: {events}",
                ]
            },
            'home_automation': [
                "I've adjusted the {device} as requested.",
                "The {device} has been {action}.",
                "Home automation command executed successfully.",
            ],
            'information_query': [
                "Let me find information about {topic} for you.",
                "Here's what I found about {topic}:",
                "I'll search for {topic} and get back to you.",
            ],
            'greeting': [
                "Hello! How can I help you today?",
                "Hi there! What would you like me to do?",
                "Good to see you! How can I assist you?",
                "Hello! I'm here to help with whatever you need.",
            ],
            'goodbye': [
                "Goodbye! Have a great day!",
                "See you later! Let me know if you need anything.",
                "Take care! I'll be here when you need me.",
            ],
            'general_query': [
                "I understand you're asking about {topic}. Let me help you with that.",
                "I'll do my best to help you with {request}.",
                "Let me process that request for you.",
            ]
        }

    def generate_response(self, intent: Intent, context: Dict[str, Any] = None) -> str:
        """Generate appropriate response for given intent"""
        if context is None:
            context = {}
        
        intent_name = intent.intent
        entities = intent.entities
        
        # Get response templates for intent
        templates = self.response_templates.get(intent_name, self.response_templates['general_query'])
        
        # Handle nested templates (like music_control)
        if isinstance(templates, dict):
            # Determine sub-intent based on entities or context
            sub_intent = self._determine_sub_intent(intent)
            templates = templates.get(sub_intent, list(templates.values())[0])
        
        # Select random template
        template = random.choice(templates)
        
        # Fill in template variables
        response = self._fill_template(template, entities, context)
        
        return response

    def _determine_sub_intent(self, intent: Intent) -> str:
        """Determine sub-intent for complex intents"""
        entities = intent.entities
        
        if intent.intent == 'music_control':
            if 'pause' in str(entities) or 'stop' in str(entities):
                return 'pause'
            elif 'volume' in entities:
                return 'volume'
            else:
                return 'play'
        elif intent.intent == 'lighting_control':
            if 'off' in str(entities):
                return 'turn_off'
            elif any(word in str(entities) for word in ['dim', 'brightness', '%']):
                return 'dim'
            else:
                return 'turn_on'
        elif intent.intent == 'calendar_management':
            if 'schedule' in str(entities) or 'create' in str(entities):
                return 'schedule'
            else:
                return 'query'
        
        return 'default'

    def _fill_template(self, template: str, entities: Dict[str, Any], context: Dict[str, Any]) -> str:
        """Fill template with entity values"""
        response = template
        
        # Replace common placeholders
        replacements = {
            '{music}': entities.get('primary', ['your music'])[0] if entities.get('primary') else 'your music',
            '{device}': entities.get('device', ['lights'])[0] if entities.get('device') else 'lights',
            '{room}': entities.get('room', ['room'])[0] if entities.get('room') else 'room',
            '{level}': entities.get('number', ['50'])[0] if entities.get('number') else '50',
            '{time}': entities.get('time', ['the scheduled time'])[0] if entities.get('time') else 'the scheduled time',
            '{event}': entities.get('primary', ['your event'])[0] if entities.get('primary') else 'your event',
            '{topic}': entities.get('primary', ['that'])[0] if entities.get('primary') else 'that',
            '{request}': entities.get('primary', ['your request'])[0] if entities.get('primary') else 'your request',
            '{action}': 'updated',
            '{count}': str(len(context.get('events', []))),
        }
        
        for placeholder, value in replacements.items():
            response = response.replace(placeholder, str(value))
        
        return response

class ActionPlanner:
    """Plans and generates actions based on intents"""
    
    def __init__(self):
        self.action_mappings = {
            'music_control': self._plan_music_actions,
            'lighting_control': self._plan_lighting_actions,
            'calendar_management': self._plan_calendar_actions,
            'home_automation': self._plan_home_actions,
            'information_query': self._plan_search_actions,
        }

    def plan_actions(self, intent: Intent, context: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """Plan actions to execute based on intent"""
        if context is None:
            context = {}
        
        planner = self.action_mappings.get(intent.intent)
        if planner:
            return planner(intent, context)
        
        return []

    def _plan_music_actions(self, intent: Intent, context: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Plan music control actions"""
        entities = intent.entities
        actions = []
        
        if 'pause' in str(entities) or 'stop' in str(entities):
            actions.append({
                'service': 'spotify',
                'command': 'pause',
                'parameters': {}
            })
        elif 'volume' in entities:
            volume = entities.get('number', [50])[0]
            actions.append({
                'service': 'spotify',
                'command': 'set_volume',
                'parameters': {'volume': int(volume)}
            })
        elif 'next' in str(entities) or 'skip' in str(entities):
            actions.append({
                'service': 'spotify',
                'command': 'next_track',
                'parameters': {}
            })
        elif 'previous' in str(entities):
            actions.append({
                'service': 'spotify',
                'command': 'previous_track',
                'parameters': {}
            })
        else:
            # Play music
            query = entities.get('primary', ['music'])[0]
            actions.append({
                'service': 'spotify',
                'command': 'search_and_play',
                'parameters': {'query': query}
            })
        
        return actions

    def _plan_lighting_actions(self, intent: Intent, context: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Plan lighting control actions"""
        entities = intent.entities
        actions = []
        
        device = entities.get('device', ['lights'])[0]
        room = entities.get('room', ['living room'])[0]
        
        if 'off' in str(entities):
            actions.append({
                'service': 'philips_hue',
                'command': 'turn_off_light',
                'parameters': {'device': device, 'room': room}
            })
        elif 'dim' in str(entities) or entities.get('number'):
            brightness = entities.get('number', [50])[0]
            actions.append({
                'service': 'philips_hue',
                'command': 'set_brightness',
                'parameters': {'device': device, 'room': room, 'brightness': int(brightness)}
            })
        elif entities.get('color'):
            color = entities.get('color')[0]
            actions.append({
                'service': 'philips_hue',
                'command': 'set_color',
                'parameters': {'device': device, 'room': room, 'color': color}
            })
        else:
            actions.append({
                'service': 'philips_hue',
                'command': 'turn_on_light',
                'parameters': {'device': device, 'room': room}
            })
        
        return actions

    def _plan_calendar_actions(self, intent: Intent, context: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Plan calendar management actions"""
        entities = intent.entities
        actions = []
        
        if 'schedule' in str(entities) or 'create' in str(entities):
            event = entities.get('primary', ['Meeting'])[0]
            time = entities.get('time', ['tomorrow'])[0]
            actions.append({
                'service': 'google_calendar',
                'command': 'create_event',
                'parameters': {'title': event, 'time': time}
            })
        else:
            # Query calendar
            actions.append({
                'service': 'google_calendar',
                'command': 'get_upcoming_events',
                'parameters': {'days_ahead': 1}
            })
        
        return actions

    def _plan_home_actions(self, intent: Intent, context: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Plan home automation actions"""
        entities = intent.entities
        actions = []
        
        if entities.get('number'):
            # Temperature control
            temp = entities.get('number')[0]
            actions.append({
                'service': 'home_assistant',
                'command': 'set_temperature',
                'parameters': {'temperature': int(temp)}
            })
        else:
            device = entities.get('primary', ['device'])[0]
            action = 'turn_on' if 'on' in str(entities) else 'turn_off'
            actions.append({
                'service': 'home_assistant',
                'command': action,
                'parameters': {'device': device}
            })
        
        return actions

    def _plan_search_actions(self, intent: Intent, context: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Plan information search actions"""
        entities = intent.entities
        query = entities.get('primary', ['information'])[0]
        
        return [{
            'service': 'search',
            'command': 'web_search',
            'parameters': {'query': query}
        }]

class PersonalAICore:
    """Main AI core that orchestrates all components"""
    
    def __init__(self):
        self.nlp = NaturalLanguageProcessor()
        self.conversation_manager = ConversationManager()
        self.response_generator = ResponseGenerator()
        self.action_planner = ActionPlanner()
        
    def process_message(self, user_id: int, message: str, conversation_id: Optional[int] = None) -> AIResponse:
        """Process a user message and return AI response"""
        try:
            # Get conversation context
            context = self.conversation_manager.get_context(user_id)
            
            # Process natural language input
            intent = self.nlp.process_input(message, context)
            
            # Generate response text
            response_text = self.response_generator.generate_response(intent, context)
            
            # Plan actions to execute
            actions = self.action_planner.plan_actions(intent, context)
            
            # Create AI response
            ai_response = AIResponse(
                text=response_text,
                intent=intent,
                actions=actions,
                confidence=intent.confidence,
                context=context
            )
            
            # Add to conversation history
            self.conversation_manager.add_message(user_id, message, response_text, intent)
            
            logger.info(f"Processed message for user {user_id}: intent={intent.intent}, confidence={intent.confidence}")
            
            return ai_response
            
        except Exception as e:
            logger.error(f"Error processing message: {e}")
            
            # Return error response
            return AIResponse(
                text="I'm sorry, I encountered an error processing your request. Please try again.",
                intent=None,
                actions=[],
                confidence=0.0,
                context={}
            )

    def get_conversation_history(self, user_id: int, limit: int = 10) -> List[Dict[str, Any]]:
        """Get conversation history for user"""
        if user_id not in self.conversation_manager.conversation_history:
            return []
        
        return self.conversation_manager.conversation_history[user_id][-limit:]

    def clear_conversation_history(self, user_id: int):
        """Clear conversation history for user"""
        if user_id in self.conversation_manager.conversation_history:
            del self.conversation_manager.conversation_history[user_id]

# Global AI core instance
ai_core = PersonalAICore()


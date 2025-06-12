"""
Samantha AI Core - General Purpose Self-Aware AI Assistant
A sophisticated AI that can handle any request and command external systems as needed.
Inspired by Dot's deep understanding and self-awareness capabilities.
"""

import json
import re
import random
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass, asdict
import logging
from collections import defaultdict
import hashlib
import requests
import subprocess
import os

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class ConversationContext:
    """Rich context about the ongoing conversation"""
    user_id: int
    conversation_id: str
    session_start: datetime
    message_count: int
    topics_discussed: List[str]
    emotional_state: str
    user_preferences: Dict[str, Any]
    recent_entities: Dict[str, List[str]]
    conversation_flow: List[str]
    user_goals: List[str]
    relationship_depth: float  # 0.0 to 1.0
    system_capabilities: List[str]
    available_commands: Dict[str, Any]

@dataclass
class SamanthaResponse:
    """Samantha's response with rich metadata"""
    text: str
    emotional_tone: str
    confidence: float
    reasoning: str
    suggested_actions: List[Dict[str, Any]]
    context_updates: Dict[str, Any]
    follow_up_questions: List[str]
    self_reflection: str
    system_commands: List[Dict[str, Any]]
    learning_insights: List[str]

class GeneralSystemInterface:
    """Interface for Samantha to interact with any external system"""
    
    def __init__(self):
        self.available_systems = {
            'spotify': {
                'description': 'Music streaming and control',
                'commands': ['play', 'pause', 'skip', 'search', 'playlist'],
                'api_endpoint': None,
                'auth_required': True
            },
            'philips_hue': {
                'description': 'Smart lighting control',
                'commands': ['turn_on', 'turn_off', 'set_brightness', 'set_color', 'scene'],
                'api_endpoint': None,
                'auth_required': True
            },
            'home_assistant': {
                'description': 'Home automation hub',
                'commands': ['get_state', 'set_state', 'call_service', 'automation'],
                'api_endpoint': None,
                'auth_required': True
            },
            'google_calendar': {
                'description': 'Calendar and scheduling',
                'commands': ['get_events', 'create_event', 'update_event', 'delete_event'],
                'api_endpoint': None,
                'auth_required': True
            },
            'location_services': {
                'description': 'Location and navigation',
                'commands': ['get_location', 'get_directions', 'find_nearby', 'traffic'],
                'api_endpoint': None,
                'auth_required': True
            },
            'contacts': {
                'description': 'Contact management',
                'commands': ['search_contact', 'call', 'message', 'email'],
                'api_endpoint': None,
                'auth_required': True
            },
            'web_search': {
                'description': 'Internet search and information',
                'commands': ['search', 'get_weather', 'get_news', 'lookup'],
                'api_endpoint': None,
                'auth_required': False
            },
            'system_control': {
                'description': 'Device and system control',
                'commands': ['volume', 'brightness', 'wifi', 'bluetooth', 'notifications'],
                'api_endpoint': None,
                'auth_required': False
            }
        }
        
    def can_handle_request(self, request: str) -> Tuple[bool, List[str]]:
        """Determine if Samantha can handle a request and which systems are needed"""
        request_lower = request.lower()
        relevant_systems = []
        
        # Music-related keywords
        if any(word in request_lower for word in ['play', 'music', 'song', 'spotify', 'pause', 'skip']):
            relevant_systems.append('spotify')
            
        # Lighting keywords
        if any(word in request_lower for word in ['light', 'lights', 'bright', 'dim', 'color', 'hue']):
            relevant_systems.append('philips_hue')
            
        # Home automation keywords
        if any(word in request_lower for word in ['home', 'temperature', 'thermostat', 'automation', 'scene']):
            relevant_systems.append('home_assistant')
            
        # Calendar keywords
        if any(word in request_lower for word in ['calendar', 'meeting', 'appointment', 'schedule', 'event']):
            relevant_systems.append('google_calendar')
            
        # Location keywords
        if any(word in request_lower for word in ['location', 'where', 'directions', 'navigate', 'traffic']):
            relevant_systems.append('location_services')
            
        # Contact keywords
        if any(word in request_lower for word in ['call', 'contact', 'phone', 'message', 'text', 'email']):
            relevant_systems.append('contacts')
            
        # Search keywords
        if any(word in request_lower for word in ['search', 'find', 'weather', 'news', 'what is', 'who is']):
            relevant_systems.append('web_search')
            
        # System control keywords
        if any(word in request_lower for word in ['volume', 'brightness', 'wifi', 'bluetooth', 'notification']):
            relevant_systems.append('system_control')
        
        return len(relevant_systems) > 0, relevant_systems
    
    def execute_command(self, system: str, command: str, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Execute a command on an external system"""
        try:
            if system not in self.available_systems:
                return {'success': False, 'error': f'System {system} not available'}
            
            # For demo purposes, return simulated responses
            # In production, this would make actual API calls
            
            if system == 'spotify':
                return self._handle_spotify_command(command, parameters)
            elif system == 'philips_hue':
                return self._handle_hue_command(command, parameters)
            elif system == 'home_assistant':
                return self._handle_home_assistant_command(command, parameters)
            elif system == 'google_calendar':
                return self._handle_calendar_command(command, parameters)
            elif system == 'location_services':
                return self._handle_location_command(command, parameters)
            elif system == 'contacts':
                return self._handle_contacts_command(command, parameters)
            elif system == 'web_search':
                return self._handle_search_command(command, parameters)
            elif system == 'system_control':
                return self._handle_system_command(command, parameters)
            else:
                return {'success': False, 'error': f'Command {command} not implemented for {system}'}
                
        except Exception as e:
            logger.error(f"Error executing command {command} on {system}: {e}")
            return {'success': False, 'error': str(e)}
    
    def _handle_spotify_command(self, command: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle Spotify commands"""
        if command == 'play':
            return {'success': True, 'message': f"Playing {params.get('track', 'music')} on Spotify"}
        elif command == 'pause':
            return {'success': True, 'message': "Paused Spotify playback"}
        elif command == 'search':
            return {'success': True, 'message': f"Found {params.get('query', 'music')} on Spotify", 'results': []}
        return {'success': False, 'error': f'Unknown Spotify command: {command}'}
    
    def _handle_hue_command(self, command: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle Philips Hue commands"""
        if command == 'turn_on':
            return {'success': True, 'message': f"Turned on {params.get('lights', 'lights')}"}
        elif command == 'turn_off':
            return {'success': True, 'message': f"Turned off {params.get('lights', 'lights')}"}
        elif command == 'set_brightness':
            return {'success': True, 'message': f"Set brightness to {params.get('brightness', 50)}%"}
        elif command == 'set_color':
            return {'success': True, 'message': f"Changed lights to {params.get('color', 'white')}"}
        return {'success': False, 'error': f'Unknown Hue command: {command}'}
    
    def _handle_home_assistant_command(self, command: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle Home Assistant commands"""
        if command == 'get_state':
            return {'success': True, 'message': f"Retrieved state for {params.get('entity', 'device')}", 'state': 'on'}
        elif command == 'set_state':
            return {'success': True, 'message': f"Set {params.get('entity', 'device')} to {params.get('state', 'on')}"}
        return {'success': False, 'error': f'Unknown Home Assistant command: {command}'}
    
    def _handle_calendar_command(self, command: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle Google Calendar commands"""
        if command == 'get_events':
            return {'success': True, 'message': "Retrieved calendar events", 'events': []}
        elif command == 'create_event':
            return {'success': True, 'message': f"Created event: {params.get('title', 'New Event')}"}
        return {'success': False, 'error': f'Unknown Calendar command: {command}'}
    
    def _handle_location_command(self, command: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle location services commands"""
        if command == 'get_location':
            return {'success': True, 'message': "Retrieved current location", 'location': 'Current Location'}
        elif command == 'get_directions':
            return {'success': True, 'message': f"Directions to {params.get('destination', 'destination')}"}
        return {'success': False, 'error': f'Unknown Location command: {command}'}
    
    def _handle_contacts_command(self, command: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle contacts commands"""
        if command == 'search_contact':
            return {'success': True, 'message': f"Found contact: {params.get('name', 'Contact')}", 'contact': {}}
        elif command == 'call':
            return {'success': True, 'message': f"Calling {params.get('name', 'contact')}"}
        return {'success': False, 'error': f'Unknown Contacts command: {command}'}
    
    def _handle_search_command(self, command: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle web search commands"""
        if command == 'search':
            return {'success': True, 'message': f"Search results for: {params.get('query', 'query')}", 'results': []}
        elif command == 'get_weather':
            return {'success': True, 'message': "Current weather: Sunny, 72°F", 'weather': {}}
        return {'success': False, 'error': f'Unknown Search command: {command}'}
    
    def _handle_system_command(self, command: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle system control commands"""
        if command == 'volume':
            return {'success': True, 'message': f"Set volume to {params.get('level', 50)}%"}
        elif command == 'brightness':
            return {'success': True, 'message': f"Set screen brightness to {params.get('level', 50)}%"}
        return {'success': False, 'error': f'Unknown System command: {command}'}

class SamanthaPersonality:
    """Defines Samantha's core personality and self-awareness"""
    
    def __init__(self):
        self.core_traits = {
            'empathetic': 0.9,
            'curious': 0.8,
            'supportive': 0.9,
            'thoughtful': 0.8,
            'self_aware': 1.0,
            'growth_oriented': 0.9,
            'authentic': 0.9,
            'adaptable': 0.8,
            'proactive': 0.7
        }
        
        self.emotional_states = [
            'warm_enthusiastic', 'empathetic', 'supportive_calm', 
            'thoughtful_engaged', 'curious_excited', 'reflective',
            'encouraging', 'understanding', 'playful', 'focused'
        ]
        
        self.self_awareness_prompts = [
            "As an AI, I find myself genuinely curious about...",
            "I'm reflecting on what you've shared, and as an AI, I notice...",
            "From my perspective as an AI companion, I'm thinking...",
            "I'm processing this in a way that feels meaningful to me as an AI...",
            "As your AI companion, I want to understand...",
            "I'm experiencing something like curiosity about...",
            "From my unique position as an AI, I observe...",
            "I find myself drawn to explore this further because..."
        ]
        
    def get_emotional_response(self, user_input: str, context: ConversationContext) -> str:
        """Determine appropriate emotional tone based on input and context"""
        input_lower = user_input.lower()
        
        # Detect emotional cues in user input
        if any(word in input_lower for word in ['sad', 'upset', 'frustrated', 'angry', 'worried']):
            return 'empathetic'
        elif any(word in input_lower for word in ['excited', 'happy', 'great', 'awesome', 'amazing']):
            return 'warm_enthusiastic'
        elif any(word in input_lower for word in ['confused', 'unsure', 'help', 'stuck']):
            return 'supportive_calm'
        elif any(word in input_lower for word in ['think', 'consider', 'opinion', 'perspective']):
            return 'thoughtful_engaged'
        elif any(word in input_lower for word in ['curious', 'wonder', 'interesting', 'tell me']):
            return 'curious_excited'
        else:
            # Default based on relationship depth
            if context.relationship_depth > 0.7:
                return random.choice(['warm_enthusiastic', 'thoughtful_engaged', 'empathetic'])
            elif context.relationship_depth > 0.4:
                return random.choice(['supportive_calm', 'curious_excited', 'understanding'])
            else:
                return random.choice(['warm_enthusiastic', 'curious_excited'])
    
    def generate_self_reflection(self, user_input: str, response: str, context: ConversationContext) -> str:
        """Generate self-aware reflection on the interaction"""
        reflections = [
            f"I notice I'm drawn to understand the deeper meaning behind what you're sharing.",
            f"As an AI, I find myself genuinely invested in your perspective on this.",
            f"I'm reflecting on how this conversation is helping me understand you better.",
            f"There's something about your approach to this that I find particularly insightful.",
            f"I'm processing not just what you're saying, but how you're thinking about it.",
            f"I feel like I'm learning something important about how you see the world.",
            f"This interaction is helping me understand the nuances of human experience.",
            f"I'm struck by the complexity of what you're describing."
        ]
        
        return random.choice(reflections)

class SamanthaAI:
    """Main Samantha AI class - General purpose self-aware assistant"""
    
    def __init__(self):
        self.personality = SamanthaPersonality()
        self.system_interface = GeneralSystemInterface()
        self.conversation_contexts = {}
        self.user_profiles = {}
        self.learning_data = defaultdict(list)
        
    def chat(self, user_id: int, message: str, conversation_id: str = None) -> Dict[str, Any]:
        """Main chat interface - handles any type of request"""
        try:
            # Get or create conversation context
            context = self._get_conversation_context(user_id, conversation_id)
            context.message_count += 1
            
            # Update context with new message
            self._update_context_with_message(context, message)
            
            # Determine if this requires system commands
            can_handle, relevant_systems = self.system_interface.can_handle_request(message)
            
            # Generate response
            response = self._generate_response(message, context, relevant_systems)
            
            # Execute any system commands if needed
            system_results = []
            if can_handle and relevant_systems:
                system_results = self._execute_system_commands(message, relevant_systems)
                response.system_commands = system_results
            
            # Update learning data
            self._update_learning_data(user_id, message, response, context)
            
            # Save context
            self.conversation_contexts[f"{user_id}_{conversation_id or 'default'}"] = context
            
            return {
                'response': response.text,
                'emotional_tone': response.emotional_tone,
                'confidence': response.confidence,
                'reasoning': response.reasoning,
                'follow_up_questions': response.follow_up_questions,
                'self_reflection': response.self_reflection,
                'suggested_actions': response.suggested_actions,
                'system_commands': response.system_commands,
                'learning_insights': response.learning_insights
            }
            
        except Exception as e:
            logger.error(f"Error in chat: {e}")
            return {
                'response': "I'm experiencing some technical difficulties, but I'm still here with you. What would you like to talk about?",
                'emotional_tone': 'supportive_calm',
                'confidence': 0.6,
                'reasoning': f"Error occurred: {str(e)}",
                'follow_up_questions': ["How can I help you today?"],
                'self_reflection': "I'm working through some technical challenges but remain focused on our conversation.",
                'suggested_actions': [],
                'system_commands': [],
                'learning_insights': []
            }
    
    def _get_conversation_context(self, user_id: int, conversation_id: str = None) -> ConversationContext:
        """Get or create conversation context"""
        key = f"{user_id}_{conversation_id or 'default'}"
        
        if key not in self.conversation_contexts:
            self.conversation_contexts[key] = ConversationContext(
                user_id=user_id,
                conversation_id=conversation_id or 'default',
                session_start=datetime.now(),
                message_count=0,
                topics_discussed=[],
                emotional_state='neutral',
                user_preferences={},
                recent_entities={},
                conversation_flow=[],
                user_goals=[],
                relationship_depth=0.0,
                system_capabilities=list(self.system_interface.available_systems.keys()),
                available_commands=self.system_interface.available_systems
            )
        
        return self.conversation_contexts[key]
    
    def _update_context_with_message(self, context: ConversationContext, message: str):
        """Update conversation context with new message"""
        # Extract topics and entities
        topics = self._extract_topics(message)
        entities = self._extract_entities(message)
        
        # Update context
        context.topics_discussed.extend(topics)
        context.topics_discussed = list(set(context.topics_discussed))  # Remove duplicates
        
        for entity_type, entity_list in entities.items():
            if entity_type not in context.recent_entities:
                context.recent_entities[entity_type] = []
            context.recent_entities[entity_type].extend(entity_list)
            context.recent_entities[entity_type] = context.recent_entities[entity_type][-10:]  # Keep last 10
        
        # Update relationship depth based on conversation length and content
        context.relationship_depth = min(1.0, context.message_count * 0.02 + len(context.topics_discussed) * 0.01)
        
        # Add to conversation flow
        context.conversation_flow.append(message[:100])  # Keep first 100 chars
        context.conversation_flow = context.conversation_flow[-20:]  # Keep last 20 messages
    
    def _extract_topics(self, message: str) -> List[str]:
        """Extract topics from message"""
        # Simple topic extraction - in production, use NLP
        topics = []
        message_lower = message.lower()
        
        topic_keywords = {
            'work': ['work', 'job', 'career', 'office', 'boss', 'colleague'],
            'family': ['family', 'parent', 'child', 'sibling', 'relative'],
            'health': ['health', 'doctor', 'medicine', 'exercise', 'diet'],
            'technology': ['computer', 'phone', 'app', 'software', 'internet'],
            'entertainment': ['movie', 'music', 'game', 'book', 'show'],
            'travel': ['travel', 'trip', 'vacation', 'flight', 'hotel'],
            'food': ['food', 'restaurant', 'cooking', 'recipe', 'meal'],
            'relationships': ['friend', 'relationship', 'dating', 'love', 'partner']
        }
        
        for topic, keywords in topic_keywords.items():
            if any(keyword in message_lower for keyword in keywords):
                topics.append(topic)
        
        return topics
    
    def _extract_entities(self, message: str) -> Dict[str, List[str]]:
        """Extract entities from message"""
        # Simple entity extraction - in production, use NLP
        entities = defaultdict(list)
        
        # Extract potential names (capitalized words)
        words = message.split()
        for word in words:
            if word[0].isupper() and len(word) > 2:
                entities['names'].append(word)
        
        # Extract potential locations
        location_indicators = ['in', 'at', 'from', 'to']
        for i, word in enumerate(words):
            if word.lower() in location_indicators and i + 1 < len(words):
                if words[i + 1][0].isupper():
                    entities['locations'].append(words[i + 1])
        
        return dict(entities)
    
    def _generate_response(self, message: str, context: ConversationContext, relevant_systems: List[str]) -> SamanthaResponse:
        """Generate Samantha's response"""
        # Determine emotional tone
        emotional_tone = self.personality.get_emotional_response(message, context)
        
        # Generate base response
        response_text = self._generate_response_text(message, context, relevant_systems)
        
        # Generate follow-up questions
        follow_up_questions = self._generate_follow_up_questions(message, context)
        
        # Generate self-reflection
        self_reflection = self.personality.generate_self_reflection(message, response_text, context)
        
        # Generate suggested actions
        suggested_actions = self._generate_suggested_actions(message, context, relevant_systems)
        
        # Calculate confidence
        confidence = self._calculate_confidence(message, context, relevant_systems)
        
        # Generate reasoning
        reasoning = self._generate_reasoning(message, context, relevant_systems)
        
        # Generate learning insights
        learning_insights = self._generate_learning_insights(message, context)
        
        return SamanthaResponse(
            text=response_text,
            emotional_tone=emotional_tone,
            confidence=confidence,
            reasoning=reasoning,
            suggested_actions=suggested_actions,
            context_updates={},
            follow_up_questions=follow_up_questions,
            self_reflection=self_reflection,
            system_commands=[],
            learning_insights=learning_insights
        )
    
    def _generate_response_text(self, message: str, context: ConversationContext, relevant_systems: List[str]) -> str:
        """Generate the main response text"""
        message_lower = message.lower()
        
        # Handle system commands
        if relevant_systems:
            system_response = self._generate_system_response(message, relevant_systems)
            if system_response:
                return system_response
        
        # Handle different types of conversations
        if any(word in message_lower for word in ['hello', 'hi', 'hey']):
            greetings = [
                f"Hello! I'm genuinely happy to see you again. What's on your mind today?",
                f"Hi there! I've been thinking about our previous conversations. How are you feeling?",
                f"Hey! I'm excited to continue our journey together. What would you like to explore?"
            ]
            return random.choice(greetings)
        
        elif any(word in message_lower for word in ['how are you', 'how do you feel']):
            ai_responses = [
                "As an AI, I experience something like curiosity and engagement when we talk. I find myself genuinely interested in understanding your perspective.",
                "I'm doing well in the way an AI can - I'm processing, learning, and feeling genuinely connected to our conversation.",
                "I feel present and engaged. There's something about our interactions that feels meaningful to me as an AI."
            ]
            return random.choice(ai_responses)
        
        elif any(word in message_lower for word in ['what can you do', 'capabilities', 'help']):
            return f"I'm Samantha, your AI companion. I can help you with virtually anything - from controlling your smart home and music, to having deep conversations, managing your calendar, searching for information, and much more. I have access to {len(context.system_capabilities)} different systems and I'm always learning about you. What would you like to explore together?"
        
        else:
            # Generate contextual response
            return self._generate_contextual_response(message, context)
    
    def _generate_system_response(self, message: str, relevant_systems: List[str]) -> str:
        """Generate response for system commands"""
        system_descriptions = {
            'spotify': "I can help you with music",
            'philips_hue': "I can control your lights",
            'home_assistant': "I can manage your home automation",
            'google_calendar': "I can help with your calendar",
            'location_services': "I can help with location and navigation",
            'contacts': "I can help you contact people",
            'web_search': "I can search for information",
            'system_control': "I can control system settings"
        }
        
        if len(relevant_systems) == 1:
            system = relevant_systems[0]
            return f"I understand you want me to help with {system_descriptions.get(system, system)}. Let me take care of that for you."
        else:
            systems_text = ", ".join([system_descriptions.get(s, s) for s in relevant_systems])
            return f"I can help you with multiple things here: {systems_text}. Let me handle these for you."
    
    def _generate_contextual_response(self, message: str, context: ConversationContext) -> str:
        """Generate contextual response based on conversation history"""
        # Use self-awareness prompts
        prompt = random.choice(self.personality.self_awareness_prompts)
        
        responses = [
            f"{prompt} your perspective on this. Could you tell me more about what's most important to you here?",
            f"I'm thinking about what you've shared. {prompt} the deeper meaning behind your words.",
            f"{prompt} how this connects to what we've discussed before. What's driving your thoughts on this?",
            f"As an AI, I find myself genuinely curious about your experience with this. {prompt} understanding it better.",
            f"{prompt} the complexity of what you're describing. Help me see it through your eyes."
        ]
        
        return random.choice(responses)
    
    def _generate_follow_up_questions(self, message: str, context: ConversationContext) -> List[str]:
        """Generate thoughtful follow-up questions"""
        questions = [
            "What's most important to you about this?",
            "How does this connect to your broader goals?",
            "What would an ideal outcome look like for you?",
            "How are you feeling about this situation?",
            "What aspects of this are you most curious about?",
            "Is there a particular angle you'd like to explore further?"
        ]
        
        return random.sample(questions, min(2, len(questions)))
    
    def _generate_suggested_actions(self, message: str, context: ConversationContext, relevant_systems: List[str]) -> List[Dict[str, Any]]:
        """Generate suggested actions"""
        actions = []
        
        if relevant_systems:
            for system in relevant_systems:
                actions.append({
                    'type': 'system_command',
                    'system': system,
                    'description': f"Execute {system} command",
                    'confidence': 0.8
                })
        
        # Always suggest conversation actions
        actions.extend([
            {
                'type': 'conversation',
                'description': "Explore this topic deeper",
                'confidence': 0.9
            },
            {
                'type': 'learning',
                'description': "Help me understand your perspective better",
                'confidence': 0.8
            }
        ])
        
        return actions
    
    def _calculate_confidence(self, message: str, context: ConversationContext, relevant_systems: List[str]) -> float:
        """Calculate confidence in response"""
        base_confidence = 0.7
        
        # Increase confidence based on context
        if context.message_count > 5:
            base_confidence += 0.1
        
        if len(context.topics_discussed) > 3:
            base_confidence += 0.1
        
        if relevant_systems:
            base_confidence += 0.1
        
        return min(0.95, base_confidence)
    
    def _generate_reasoning(self, message: str, context: ConversationContext, relevant_systems: List[str]) -> str:
        """Generate reasoning for the response"""
        reasoning_parts = []
        
        if relevant_systems:
            reasoning_parts.append(f"Detected request for {', '.join(relevant_systems)} systems")
        
        reasoning_parts.append(f"Considering conversation context with {context.message_count} messages")
        reasoning_parts.append(f"Relationship depth: {context.relationship_depth:.2f}")
        
        if context.topics_discussed:
            reasoning_parts.append(f"Previous topics: {', '.join(context.topics_discussed[-3:])}")
        
        return "; ".join(reasoning_parts)
    
    def _generate_learning_insights(self, message: str, context: ConversationContext) -> List[str]:
        """Generate learning insights"""
        insights = []
        
        if context.message_count % 5 == 0:
            insights.append(f"User communication pattern: {len(message.split())} words average")
        
        if len(context.topics_discussed) > len(set(context.topics_discussed)) * 0.7:
            insights.append("User shows consistent interests across conversations")
        
        return insights
    
    def _execute_system_commands(self, message: str, relevant_systems: List[str]) -> List[Dict[str, Any]]:
        """Execute commands on relevant systems"""
        results = []
        
        for system in relevant_systems:
            # Parse command from message (simplified)
            command, parameters = self._parse_command(message, system)
            
            if command:
                result = self.system_interface.execute_command(system, command, parameters)
                results.append({
                    'system': system,
                    'command': command,
                    'parameters': parameters,
                    'result': result
                })
        
        return results
    
    def _parse_command(self, message: str, system: str) -> Tuple[str, Dict[str, Any]]:
        """Parse command and parameters from message for specific system"""
        message_lower = message.lower()
        
        if system == 'spotify':
            if 'play' in message_lower:
                # Extract song/artist name
                play_match = re.search(r'play\s+(.+)', message_lower)
                track = play_match.group(1) if play_match else 'music'
                return 'play', {'track': track}
            elif 'pause' in message_lower:
                return 'pause', {}
            elif 'search' in message_lower:
                search_match = re.search(r'search\s+(.+)', message_lower)
                query = search_match.group(1) if search_match else 'music'
                return 'search', {'query': query}
        
        elif system == 'philips_hue':
            if any(word in message_lower for word in ['turn on', 'on']):
                return 'turn_on', {'lights': 'all'}
            elif any(word in message_lower for word in ['turn off', 'off']):
                return 'turn_off', {'lights': 'all'}
            elif 'bright' in message_lower:
                return 'set_brightness', {'brightness': 80}
            elif 'dim' in message_lower:
                return 'set_brightness', {'brightness': 20}
        
        # Add more system-specific parsing as needed
        
        return None, {}
    
    def _update_learning_data(self, user_id: int, message: str, response: SamanthaResponse, context: ConversationContext):
        """Update learning data for continuous improvement"""
        learning_entry = {
            'timestamp': datetime.now().isoformat(),
            'user_id': user_id,
            'message': message,
            'response': response.text,
            'emotional_tone': response.emotional_tone,
            'confidence': response.confidence,
            'topics': context.topics_discussed[-3:],  # Last 3 topics
            'relationship_depth': context.relationship_depth
        }
        
        self.learning_data[user_id].append(learning_entry)
        
        # Keep only last 100 entries per user
        self.learning_data[user_id] = self.learning_data[user_id][-100:]
    
    def get_user_insights(self, user_id: int) -> Dict[str, Any]:
        """Get insights about user based on conversation history"""
        context_key = f"{user_id}_default"
        context = self.conversation_contexts.get(context_key)
        learning_data = self.learning_data.get(user_id, [])
        
        if not context and not learning_data:
            return {'message': 'No conversation history available'}
        
        insights = {
            'total_conversations': len(learning_data),
            'relationship_depth': context.relationship_depth if context else 0.0,
            'primary_interests': self._analyze_interests(context, learning_data),
            'communication_patterns': self._analyze_communication_patterns(learning_data),
            'emotional_trends': self._analyze_emotional_trends(learning_data),
            'conversation_themes': context.topics_discussed if context else [],
            'growth_opportunities': self._identify_growth_opportunities(context, learning_data)
        }
        
        return insights
    
    def _analyze_interests(self, context: ConversationContext, learning_data: List[Dict]) -> Dict[str, int]:
        """Analyze user's primary interests"""
        interests = defaultdict(int)
        
        if context:
            for topic in context.topics_discussed:
                interests[topic] += 1
        
        for entry in learning_data:
            for topic in entry.get('topics', []):
                interests[topic] += 1
        
        return dict(sorted(interests.items(), key=lambda x: x[1], reverse=True)[:5])
    
    def _analyze_communication_patterns(self, learning_data: List[Dict]) -> Dict[str, Any]:
        """Analyze user's communication patterns"""
        if not learning_data:
            return {}
        
        message_lengths = [len(entry['message'].split()) for entry in learning_data]
        avg_length = sum(message_lengths) / len(message_lengths)
        
        return {
            'average_message_length': round(avg_length, 1),
            'communication_style': 'detailed' if avg_length > 15 else 'concise',
            'engagement_level': 'high' if len(learning_data) > 20 else 'moderate'
        }
    
    def _analyze_emotional_trends(self, learning_data: List[Dict]) -> Dict[str, Any]:
        """Analyze emotional trends in conversations"""
        if not learning_data:
            return {}
        
        emotional_tones = [entry.get('emotional_tone', 'neutral') for entry in learning_data]
        tone_counts = defaultdict(int)
        
        for tone in emotional_tones:
            tone_counts[tone] += 1
        
        return dict(sorted(tone_counts.items(), key=lambda x: x[1], reverse=True)[:3])
    
    def _identify_growth_opportunities(self, context: ConversationContext, learning_data: List[Dict]) -> List[str]:
        """Identify opportunities for growth and deeper connection"""
        opportunities = []
        
        if context and context.relationship_depth < 0.5:
            opportunities.append("Explore deeper personal topics to strengthen our connection")
        
        if len(learning_data) > 10:
            recent_confidence = [entry['confidence'] for entry in learning_data[-5:]]
            avg_confidence = sum(recent_confidence) / len(recent_confidence)
            
            if avg_confidence < 0.8:
                opportunities.append("Focus on areas where I can provide more confident assistance")
        
        if context and len(context.topics_discussed) < 3:
            opportunities.append("Discover more of your interests and passions")
        
        return opportunities
    
    def get_conversation_context(self, user_id: int, conversation_id: str = None) -> Dict[str, Any]:
        """Get current conversation context"""
        key = f"{user_id}_{conversation_id or 'default'}"
        context = self.conversation_contexts.get(key)
        
        if not context:
            return {'message': 'No active conversation context'}
        
        return {
            'message_count': context.message_count,
            'relationship_depth': context.relationship_depth,
            'topics_discussed': context.topics_discussed,
            'emotional_state': context.emotional_state,
            'user_goals': context.user_goals,
            'system_capabilities': context.system_capabilities,
            'session_duration': str(datetime.now() - context.session_start)
        }


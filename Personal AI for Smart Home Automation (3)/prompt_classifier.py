"""
Prompt Classifier - Categorizes user prompts for better response handling
"""

import re
from typing import Dict, List, Tuple, Optional
from enum import Enum
import asyncio
from loguru import logger


class PromptCategory(Enum):
    """Categories for different types of prompts"""
    GREETING = "greeting"
    QUESTION = "question"
    TASK_REQUEST = "task_request"
    CREATIVE = "creative"
    TECHNICAL = "technical"
    PERSONAL = "personal"
    COOKING = "cooking"
    INTEGRATION = "integration"
    LEARNING = "learning"
    CASUAL = "casual"
    EMOTIONAL = "emotional"
    PLANNING = "planning"
    ANALYSIS = "analysis"
    UNKNOWN = "unknown"


class PromptIntent(Enum):
    """Specific intents within categories"""
    # Greetings
    HELLO = "hello"
    GOODBYE = "goodbye"
    
    # Questions
    FACTUAL = "factual"
    OPINION = "opinion"
    EXPLANATION = "explanation"
    
    # Tasks
    CREATE = "create"
    SEARCH = "search"
    CALCULATE = "calculate"
    ORGANIZE = "organize"
    
    # Creative
    WRITE = "write"
    BRAINSTORM = "brainstorm"
    DESIGN = "design"
    
    # Technical
    CODE = "code"
    DEBUG = "debug"
    EXPLAIN_TECH = "explain_tech"
    
    # Personal
    ADVICE = "advice"
    SUPPORT = "support"
    SHARE = "share"
    
    # Cooking
    RECIPE = "recipe"
    COOKING_HELP = "cooking_help"
    
    # Integration
    SETTINGS = "settings"
    CONNECT = "connect"
    CONTROL = "control"
    
    # Other
    UNKNOWN = "unknown"


class PromptClassifier:
    """Classifies user prompts to determine appropriate response strategy"""
    
    def __init__(self):
        self.patterns = self._initialize_patterns()
        self.context_keywords = self._initialize_context_keywords()
        
    async def initialize(self):
        """Initialize the classifier"""
        logger.info("✅ Prompt Classifier initialized")
    
    def _initialize_patterns(self) -> Dict[PromptCategory, List[str]]:
        """Initialize regex patterns for each category"""
        return {
            PromptCategory.GREETING: [
                r'\b(hi|hello|hey|good morning|good afternoon|good evening|greetings)\b',
                r'\b(how are you|what\'s up|how\'s it going)\b',
                r'\b(bye|goodbye|see you|farewell|take care)\b'
            ],
            PromptCategory.QUESTION: [
                r'\b(what|who|when|where|why|how|which)\b.*\?',
                r'\b(can you|could you|would you|will you).*\?',
                r'\b(do you|did you|have you|are you).*\?',
                r'\b(is it|are there|does it)\b.*\?'
            ],
            PromptCategory.TASK_REQUEST: [
                r'\b(help me|assist me|can you help)\b',
                r'\b(create|make|build|generate|produce)\b',
                r'\b(find|search|look for|locate)\b',
                r'\b(calculate|compute|solve|figure out)\b',
                r'\b(organize|plan|schedule|arrange)\b'
            ],
            PromptCategory.CREATIVE: [
                r'\b(write|compose|draft|create)\b.*(story|poem|article|essay|script)',
                r'\b(brainstorm|ideate|think of|come up with)\b',
                r'\b(design|sketch|draw|visualize)\b',
                r'\b(creative|artistic|imaginative)\b'
            ],
            PromptCategory.TECHNICAL: [
                r'\b(code|programming|script|function|algorithm)\b',
                r'\b(debug|fix|error|bug|issue)\b',
                r'\b(API|database|server|framework|library)\b',
                r'\b(python|javascript|html|css|sql)\b'
            ],
            PromptCategory.PERSONAL: [
                r'\b(feel|feeling|emotion|mood|sad|happy|angry|worried|stressed)\b',
                r'\b(advice|guidance|help|support|counsel)\b',
                r'\b(personal|private|confidential|intimate)\b',
                r'\b(relationship|family|friend|love|life)\b'
            ],
            PromptCategory.COOKING: [
                r'\b(recipe|cook|cooking|bake|baking|kitchen)\b',
                r'\b(ingredients|food|meal|dish|cuisine)\b',
                r'\b(chef|culinary|gastronomy)\b',
                r'\b(eat|eating|dinner|lunch|breakfast)\b'
            ],
            PromptCategory.INTEGRATION: [
                r'\b(settings|configure|setup|connect)\b',
                r'\b(spotify|music|play|song)\b',
                r'\b(lights|hue|philips|brightness|dim)\b',
                r'\b(calendar|schedule|appointment|meeting)\b',
                r'\b(home assistant|smart home|automation)\b'
            ],
            PromptCategory.LEARNING: [
                r'\b(learn|teach|explain|understand|study)\b',
                r'\b(lesson|tutorial|guide|instruction)\b',
                r'\b(knowledge|information|facts|data)\b',
                r'\b(remember|memory|recall|forget)\b'
            ],
            PromptCategory.EMOTIONAL: [
                r'\b(love|hate|like|dislike|enjoy|prefer)\b',
                r'\b(excited|nervous|anxious|calm|peaceful)\b',
                r'\b(frustrated|disappointed|satisfied|proud)\b',
                r'\b(lonely|happy|sad|angry|confused)\b'
            ],
            PromptCategory.PLANNING: [
                r'\b(plan|planning|schedule|organize|arrange)\b',
                r'\b(calendar|agenda|timeline|deadline)\b',
                r'\b(project|task|goal|objective|target)\b',
                r'\b(strategy|approach|method|process)\b'
            ],
            PromptCategory.ANALYSIS: [
                r'\b(analyze|analysis|examine|evaluate|assess)\b',
                r'\b(compare|contrast|review|study|investigate)\b',
                r'\b(data|statistics|numbers|metrics|trends)\b',
                r'\b(report|summary|conclusion|findings)\b'
            ]
        }
    
    def _initialize_context_keywords(self) -> Dict[str, float]:
        """Initialize context keywords with weights"""
        return {
            # High priority keywords
            "urgent": 1.0,
            "important": 0.9,
            "help": 0.8,
            "please": 0.7,
            "need": 0.8,
            "want": 0.6,
            
            # Emotional indicators
            "feel": 0.8,
            "emotion": 0.9,
            "sad": 0.9,
            "happy": 0.8,
            "angry": 0.9,
            "worried": 0.8,
            "excited": 0.7,
            
            # Task indicators
            "create": 0.8,
            "make": 0.7,
            "build": 0.8,
            "find": 0.7,
            "search": 0.7,
            
            # Question indicators
            "what": 0.6,
            "how": 0.7,
            "why": 0.8,
            "when": 0.6,
            "where": 0.6,
            "who": 0.6
        }
    
    async def classify_prompt(self, prompt: str, context: Dict = None) -> Dict:
        """
        Classify a prompt and return category, intent, confidence, and metadata
        """
        prompt_lower = prompt.lower().strip()
        
        # Get category scores
        category_scores = self._calculate_category_scores(prompt_lower)
        
        # Get the best category
        best_category = max(category_scores.items(), key=lambda x: x[1])
        category = best_category[0]
        confidence = best_category[1]
        
        # Get specific intent
        intent = self._determine_intent(prompt_lower, category)
        
        # Extract metadata
        metadata = self._extract_metadata(prompt_lower, category)
        
        # Adjust confidence based on context
        if context:
            confidence = self._adjust_confidence_with_context(confidence, context, category)
        
        # Determine response strategy
        response_strategy = self._determine_response_strategy(category, intent, confidence)
        
        result = {
            "category": category.value,
            "intent": intent.value,
            "confidence": confidence,
            "metadata": metadata,
            "response_strategy": response_strategy,
            "requires_tools": self._requires_tools(category, intent),
            "emotional_tone": self._detect_emotional_tone(prompt_lower),
            "urgency": self._detect_urgency(prompt_lower),
            "complexity": self._estimate_complexity(prompt_lower)
        }
        
        logger.debug(f"📊 Prompt classified: {result}")
        return result
    
    def _calculate_category_scores(self, prompt: str) -> Dict[PromptCategory, float]:
        """Calculate scores for each category"""
        scores = {category: 0.0 for category in PromptCategory}
        
        for category, patterns in self.patterns.items():
            for pattern in patterns:
                matches = re.findall(pattern, prompt, re.IGNORECASE)
                scores[category] += len(matches) * 0.3
        
        # Add keyword-based scoring
        words = prompt.split()
        for word in words:
            if word in self.context_keywords:
                weight = self.context_keywords[word]
                # Boost relevant categories
                if word in ["feel", "emotion", "sad", "happy", "angry"]:
                    scores[PromptCategory.EMOTIONAL] += weight
                elif word in ["create", "make", "build"]:
                    scores[PromptCategory.TASK_REQUEST] += weight
                elif word in ["what", "how", "why", "when", "where", "who"]:
                    scores[PromptCategory.QUESTION] += weight
        
        # Normalize scores
        max_score = max(scores.values()) if max(scores.values()) > 0 else 1
        for category in scores:
            scores[category] = min(scores[category] / max_score, 1.0)
        
        # Default to CASUAL if no strong matches
        if max(scores.values()) < 0.3:
            scores[PromptCategory.CASUAL] = 0.5
        
        return scores
    
    def _determine_intent(self, prompt: str, category: PromptCategory) -> PromptIntent:
        """Determine specific intent within a category"""
        intent_patterns = {
            PromptCategory.GREETING: {
                PromptIntent.HELLO: [r'\b(hi|hello|hey|good morning|good afternoon|good evening)\b'],
                PromptIntent.GOODBYE: [r'\b(bye|goodbye|see you|farewell|take care)\b']
            },
            PromptCategory.QUESTION: {
                PromptIntent.FACTUAL: [r'\b(what is|who is|when did|where is)\b'],
                PromptIntent.OPINION: [r'\b(what do you think|your opinion|do you like)\b'],
                PromptIntent.EXPLANATION: [r'\b(how does|why does|explain|tell me about)\b']
            },
            PromptCategory.TASK_REQUEST: {
                PromptIntent.CREATE: [r'\b(create|make|build|generate|produce)\b'],
                PromptIntent.SEARCH: [r'\b(find|search|look for|locate)\b'],
                PromptIntent.CALCULATE: [r'\b(calculate|compute|solve|figure out)\b'],
                PromptIntent.ORGANIZE: [r'\b(organize|plan|schedule|arrange)\b']
            },
            PromptCategory.CREATIVE: {
                PromptIntent.WRITE: [r'\b(write|compose|draft)\b'],
                PromptIntent.BRAINSTORM: [r'\b(brainstorm|ideate|think of|come up with)\b'],
                PromptIntent.DESIGN: [r'\b(design|sketch|draw|visualize)\b']
            },
            PromptCategory.TECHNICAL: {
                PromptIntent.CODE: [r'\b(code|programming|script|function)\b'],
                PromptIntent.DEBUG: [r'\b(debug|fix|error|bug|issue)\b'],
                PromptIntent.EXPLAIN_TECH: [r'\b(explain|how does.*work|technical)\b']
            },
            PromptCategory.PERSONAL: {
                PromptIntent.ADVICE: [r'\b(advice|guidance|what should i|recommend)\b'],
                PromptIntent.SUPPORT: [r'\b(support|help me feel|comfort|encourage)\b'],
                PromptIntent.SHARE: [r'\b(tell you|share with you|want to talk)\b']
            },
            PromptCategory.COOKING: {
                PromptIntent.RECIPE: [r'\b(recipe|how to cook|how to make)\b'],
                PromptIntent.COOKING_HELP: [r'\b(cooking help|kitchen|ingredients)\b']
            },
            PromptCategory.INTEGRATION: {
                PromptIntent.SETTINGS: [r'\b(settings|configure|setup)\b'],
                PromptIntent.CONNECT: [r'\b(connect|link|integrate)\b'],
                PromptIntent.CONTROL: [r'\b(play|turn on|turn off|dim|brighten)\b']
            }
        }
        
        if category in intent_patterns:
            for intent, patterns in intent_patterns[category].items():
                for pattern in patterns:
                    if re.search(pattern, prompt, re.IGNORECASE):
                        return intent
        
        return PromptIntent.UNKNOWN
    
    def _extract_metadata(self, prompt: str, category: PromptCategory) -> Dict:
        """Extract relevant metadata from the prompt"""
        metadata = {}
        
        # Extract entities based on category
        if category == PromptCategory.COOKING:
            # Extract food-related entities
            food_keywords = re.findall(r'\b(chicken|beef|pork|fish|pasta|rice|vegetables|salad|soup|cake|bread)\b', prompt, re.IGNORECASE)
            if food_keywords:
                metadata["food_items"] = list(set(food_keywords))
        
        elif category == PromptCategory.INTEGRATION:
            # Extract service names
            services = re.findall(r'\b(spotify|music|hue|lights|calendar|home assistant)\b', prompt, re.IGNORECASE)
            if services:
                metadata["services"] = list(set(services))
        
        elif category == PromptCategory.TECHNICAL:
            # Extract programming languages or technologies
            tech = re.findall(r'\b(python|javascript|html|css|sql|react|node|api|database)\b', prompt, re.IGNORECASE)
            if tech:
                metadata["technologies"] = list(set(tech))
        
        # Extract time-related information
        time_patterns = re.findall(r'\b(today|tomorrow|yesterday|next week|this week|morning|afternoon|evening|night)\b', prompt, re.IGNORECASE)
        if time_patterns:
            metadata["time_references"] = list(set(time_patterns))
        
        # Extract numbers
        numbers = re.findall(r'\b\d+\b', prompt)
        if numbers:
            metadata["numbers"] = [int(n) for n in numbers]
        
        return metadata
    
    def _adjust_confidence_with_context(self, confidence: float, context: Dict, category: PromptCategory) -> float:
        """Adjust confidence based on conversation context"""
        # If we have recent conversation history about the same topic
        if context.get("recent_categories") and category.value in context["recent_categories"]:
            confidence += 0.1
        
        # If user has shown preference for certain types of interactions
        if context.get("user_preferences"):
            prefs = context["user_preferences"]
            if category.value in prefs.get("preferred_categories", []):
                confidence += 0.15
        
        return min(confidence, 1.0)
    
    def _determine_response_strategy(self, category: PromptCategory, intent: PromptIntent, confidence: float) -> Dict:
        """Determine the best response strategy"""
        strategy = {
            "approach": "conversational",
            "tone": "friendly",
            "length": "medium",
            "include_followup": True,
            "use_tools": False
        }
        
        # Adjust based on category
        if category == PromptCategory.EMOTIONAL:
            strategy.update({
                "approach": "empathetic",
                "tone": "supportive",
                "length": "long",
                "include_followup": True
            })
        
        elif category == PromptCategory.TECHNICAL:
            strategy.update({
                "approach": "analytical",
                "tone": "professional",
                "length": "detailed",
                "include_followup": False
            })
        
        elif category == PromptCategory.CREATIVE:
            strategy.update({
                "approach": "inspirational",
                "tone": "encouraging",
                "length": "medium",
                "include_followup": True
            })
        
        elif category == PromptCategory.TASK_REQUEST:
            strategy.update({
                "approach": "helpful",
                "tone": "efficient",
                "length": "focused",
                "use_tools": True
            })
        
        elif category == PromptCategory.COOKING:
            strategy.update({
                "approach": "instructional",
                "tone": "friendly",
                "length": "detailed",
                "use_tools": True
            })
        
        elif category == PromptCategory.GREETING:
            strategy.update({
                "approach": "welcoming",
                "tone": "warm",
                "length": "short",
                "include_followup": True
            })
        
        # Adjust based on confidence
        if confidence < 0.5:
            strategy["include_followup"] = True
            strategy["approach"] = "clarifying"
        
        return strategy
    
    def _requires_tools(self, category: PromptCategory, intent: PromptIntent) -> List[str]:
        """Determine which tools might be needed"""
        tools = []
        
        if category == PromptCategory.COOKING and intent == PromptIntent.RECIPE:
            tools.append("recipe_search")
        
        elif category == PromptCategory.TASK_REQUEST:
            if intent == PromptIntent.SEARCH:
                tools.append("web_search")
            elif intent == PromptIntent.CALCULATE:
                tools.append("calculator")
            elif intent == PromptIntent.CREATE:
                tools.append("content_generator")
        
        elif category == PromptCategory.INTEGRATION:
            if intent == PromptIntent.CONTROL:
                tools.append("smart_home")
            elif intent == PromptIntent.SETTINGS:
                tools.append("configuration")
        
        elif category == PromptCategory.CREATIVE:
            if intent == PromptIntent.WRITE:
                tools.append("text_generator")
            elif intent == PromptIntent.DESIGN:
                tools.append("image_generator")
        
        return tools
    
    def _detect_emotional_tone(self, prompt: str) -> str:
        """Detect the emotional tone of the prompt"""
        positive_words = ["happy", "excited", "great", "awesome", "love", "wonderful", "amazing"]
        negative_words = ["sad", "angry", "frustrated", "worried", "hate", "terrible", "awful"]
        neutral_words = ["okay", "fine", "normal", "regular", "standard"]
        
        positive_count = sum(1 for word in positive_words if word in prompt)
        negative_count = sum(1 for word in negative_words if word in prompt)
        
        if positive_count > negative_count:
            return "positive"
        elif negative_count > positive_count:
            return "negative"
        else:
            return "neutral"
    
    def _detect_urgency(self, prompt: str) -> str:
        """Detect urgency level"""
        urgent_words = ["urgent", "asap", "immediately", "now", "quickly", "emergency", "help"]
        urgent_count = sum(1 for word in urgent_words if word in prompt)
        
        if urgent_count > 0 or "!" in prompt:
            return "high"
        elif "?" in prompt:
            return "medium"
        else:
            return "low"
    
    def _estimate_complexity(self, prompt: str) -> str:
        """Estimate the complexity of the request"""
        complex_indicators = ["analyze", "compare", "detailed", "comprehensive", "multiple", "various", "complex"]
        simple_indicators = ["simple", "quick", "basic", "easy", "just"]
        
        complex_count = sum(1 for word in complex_indicators if word in prompt)
        simple_count = sum(1 for word in simple_indicators if word in prompt)
        
        word_count = len(prompt.split())
        
        if complex_count > simple_count or word_count > 50:
            return "high"
        elif simple_count > complex_count or word_count < 10:
            return "low"
        else:
            return "medium"


"""
Learning Engine - Handles continuous learning from interactions
"""

import asyncio
from typing import Dict, List, Optional
from loguru import logger
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession

from .database import async_session
from .models import Interaction, UserPreference, KnowledgeFragment


class LearningEngine:
    """Manages learning from user interactions"""
    
    def __init__(self):
        self.recent_interactions = []
        self.user_preferences = {}
        self.knowledge_base = {}
        
    async def initialize(self):
        """Initialize the learning engine"""
        await self._load_initial_data()
        logger.info("✅ Learning Engine initialized")
    
    async def _load_initial_data(self):
        """Load initial data from the database"""
        async with async_session() as session:
            # Load recent interactions (e.g., last 100)
            stmt = select(Interaction).order_by(Interaction.timestamp.desc()).limit(100)
            result = await session.execute(stmt)
            self.recent_interactions = result.scalars().all()
            
            # Load user preferences
            stmt = select(UserPreference)
            result = await session.execute(stmt)
            for pref in result.scalars().all():
                self.user_preferences[pref.user_id] = {
                    "preferred_topics": pref.preferred_topics,
                    "preferred_tone": pref.preferred_tone,
                    "preferred_length": pref.preferred_length
                }
            
            # Load knowledge fragments
            stmt = select(KnowledgeFragment)
            result = await session.execute(stmt)
            for fragment in result.scalars().all():
                self.knowledge_base[fragment.topic] = {
                    "content": fragment.content,
                    "source": fragment.source,
                    "confidence": fragment.confidence
                }
        logger.info(f"📚 Loaded {len(self.recent_interactions)} interactions, {len(self.user_preferences)} user preferences, {len(self.knowledge_base)} knowledge fragments")
    
    async def process_interaction(
        self,
        user_id: str,
        user_message: str,
        ai_response: str,
        classification: Dict,
        feedback: Optional[Dict] = None
    ):
        """Process a single interaction and update learning models"""
        try:
            async with async_session() as session:
                # 1. Store the interaction
                interaction = Interaction(
                    user_id=user_id,
                    user_message=user_message,
                    ai_response=ai_response,
                    category=classification.get("category"),
                    intent=classification.get("intent"),
                    confidence=classification.get("confidence"),
                    metadata=classification.get("metadata"),
                    emotional_tone=classification.get("emotional_tone"),
                    urgency=classification.get("urgency"),
                    complexity=classification.get("complexity"),
                    feedback_score=feedback.get("score") if feedback else None,
                    feedback_comment=feedback.get("comment") if feedback else None
                )
                session.add(interaction)
                self.recent_interactions.append(interaction)
                if len(self.recent_interactions) > 100:
                    self.recent_interactions.pop(0)
                
                # 2. Update user preferences based on interaction
                await self._update_user_preferences(session, user_id, classification, feedback)
                
                # 3. Extract and store knowledge fragments
                await self._extract_knowledge(session, user_message, ai_response, classification)
                
                # 4. Identify patterns and update models (placeholder for more complex logic)
                await self._identify_patterns(session, user_id)
                
                await session.commit()
                logger.info(f"🧠 Processed interaction for user {user_id}")
                
        except Exception as e:
            logger.error(f"❌ Error processing interaction: {e}")
            await session.rollback()
    
    async def _update_user_preferences(self, session: AsyncSession, user_id: str, classification: Dict, feedback: Optional[Dict]):
        """Update user preferences based on interaction and feedback"""
        if user_id not in self.user_preferences:
            self.user_preferences[user_id] = {
                "preferred_topics": [],
                "preferred_tone": "neutral",
                "preferred_length": "medium"
            }
        
        prefs = self.user_preferences[user_id]
        
        # Update preferred topics
        topic = classification.get("category")
        if topic and topic != "unknown":
            if topic not in prefs["preferred_topics"]:
                prefs["preferred_topics"].append(topic)
                # Keep only the last 5 preferred topics
                prefs["preferred_topics"] = prefs["preferred_topics"][-5:]
        
        # Update preferred tone/length based on feedback
        if feedback and feedback.get("score", 0) > 0:
            # Simple update logic - could be more sophisticated
            if "tone" in feedback:
                prefs["preferred_tone"] = feedback["tone"]
            if "length" in feedback:
                prefs["preferred_length"] = feedback["length"]
        
        # Persist changes
        stmt = select(UserPreference).where(UserPreference.user_id == user_id)
        result = await session.execute(stmt)
        user_pref_db = result.scalar_one_or_none()
        
        if user_pref_db:
            user_pref_db.preferred_topics = prefs["preferred_topics"]
            user_pref_db.preferred_tone = prefs["preferred_tone"]
            user_pref_db.preferred_length = prefs["preferred_length"]
        else:
            user_pref_db = UserPreference(
                user_id=user_id,
                preferred_topics=prefs["preferred_topics"],
                preferred_tone=prefs["preferred_tone"],
                preferred_length=prefs["preferred_length"]
            )
            session.add(user_pref_db)
    
    async def _extract_knowledge(self, session: AsyncSession, user_message: str, ai_response: str, classification: Dict):
        """Extract potential knowledge fragments from the interaction"""
        # Simple extraction based on category - could use NLP for better results
        if classification.get("category") == "question" and classification.get("intent") == "factual":
            topic = self._extract_topic(user_message)
            if topic and len(ai_response) > 50: # Basic check for substantial answer
                # Check if knowledge already exists or is similar
                stmt = select(KnowledgeFragment).where(KnowledgeFragment.topic == topic)
                result = await session.execute(stmt)
                existing_fragment = result.scalar_one_or_none()
                
                if not existing_fragment:
                    fragment = KnowledgeFragment(
                        topic=topic,
                        content=ai_response,
                        source="conversation",
                        confidence=classification.get("confidence", 0.7)
                    )
                    session.add(fragment)
                    self.knowledge_base[topic] = {
                        "content": ai_response,
                        "source": "conversation",
                        "confidence": classification.get("confidence", 0.7)
                    }
                    logger.info(f"💡 Extracted new knowledge fragment on topic: {topic}")
    
    def _extract_topic(self, text: str) -> Optional[str]:
        """Simple topic extraction (placeholder)"""
        # This should be replaced with a proper NLP topic modeling approach
        match = re.search(r"(?:what is|tell me about|explain)\s+(?:the\s+|a\s+)?([\w\s]+)\??", text, re.IGNORECASE)
        if match:
            return match.group(1).strip().lower()
        return None
    
    async def _identify_patterns(self, session: AsyncSession, user_id: str):
        """Identify patterns in user behavior (placeholder)"""
        # This is where more complex ML/pattern recognition would go
        # Example: Detect frequent topics, common errors, preferred interaction styles
        user_interactions = [i for i in self.recent_interactions if i.user_id == user_id]
        if len(user_interactions) > 10:
            # Analyze patterns... (e.g., topic frequency, sentiment trends)
            pass
        # logger.debug(f"🔍 Analyzing patterns for user {user_id}")
        await asyncio.sleep(0.1) # Simulate analysis time
    
    async def get_user_context(self, user_id: str) -> Dict:
        """Provide context about the user for better responses"""
        context = {}
        if user_id in self.user_preferences:
            context["preferences"] = self.user_preferences[user_id]
        
        # Get recent topics from interactions
        recent_topics = list(set(
            i.category for i in self.recent_interactions 
            if i.user_id == user_id and i.category and i.category != "unknown"
        ))[-5:] # Last 5 unique topics
        context["recent_topics"] = recent_topics
        
        # Add other relevant context (e.g., name, location if available)
        # context["name"] = ...
        
        return context
    
    async def get_relevant_knowledge(self, topic: str) -> Optional[Dict]:
        """Retrieve relevant knowledge fragments"""
        # Simple lookup - could use semantic search
        return self.knowledge_base.get(topic.lower())



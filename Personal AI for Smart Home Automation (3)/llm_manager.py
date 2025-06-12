"""
LLM Manager - Handles local LLM interactions via Ollama
"""

import asyncio
import json
from typing import Dict, List, Optional, AsyncGenerator
import httpx
from loguru import logger

from .config import settings


class LLMManager:
    """Manages local LLM interactions through Ollama"""
    
    def __init__(self):
        self.ollama_url = settings.OLLAMA_URL
        self.available_models = {}
        self.current_model = "dolphin-llama3:8b"
        self.client = httpx.AsyncClient(timeout=120.0)
        
    async def initialize(self):
        """Initialize the LLM manager"""
        try:
            # Wait for Ollama to be ready
            await self._wait_for_ollama()
            
            # Get available models
            await self._refresh_models()
            
            # Set default model if available
            if "dolphin-llama3:8b" in self.available_models:
                self.current_model = "dolphin-llama3:8b"
            elif "llama3.1:8b" in self.available_models:
                self.current_model = "llama3.1:8b"
            elif self.available_models:
                self.current_model = list(self.available_models.keys())[0]
                
            logger.info(f"✅ LLM Manager initialized with model: {self.current_model}")
            
        except Exception as e:
            logger.error(f"❌ Failed to initialize LLM Manager: {e}")
            raise
    
    async def _wait_for_ollama(self, max_retries: int = 30):
        """Wait for Ollama to be ready"""
        for i in range(max_retries):
            try:
                response = await self.client.get(f"{self.ollama_url}/api/tags")
                if response.status_code == 200:
                    logger.info("✅ Ollama is ready")
                    return
            except Exception:
                pass
            
            logger.info(f"⏳ Waiting for Ollama... ({i+1}/{max_retries})")
            await asyncio.sleep(2)
        
        raise Exception("Ollama is not responding")
    
    async def _refresh_models(self):
        """Refresh the list of available models"""
        try:
            response = await self.client.get(f"{self.ollama_url}/api/tags")
            if response.status_code == 200:
                data = response.json()
                self.available_models = {
                    model["name"]: {
                        "size": model.get("size", 0),
                        "modified_at": model.get("modified_at", ""),
                        "details": model.get("details", {})
                    }
                    for model in data.get("models", [])
                }
                logger.info(f"📋 Found {len(self.available_models)} models: {list(self.available_models.keys())}")
        except Exception as e:
            logger.error(f"❌ Failed to refresh models: {e}")
    
    async def generate_response(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 2000
    ) -> str:
        """Generate a response using the local LLM"""
        try:
            model_name = model or self.current_model
            
            # Prepare the request
            messages = []
            if system_prompt:
                messages.append({"role": "system", "content": system_prompt})
            messages.append({"role": "user", "content": prompt})
            
            request_data = {
                "model": model_name,
                "messages": messages,
                "options": {
                    "temperature": temperature,
                    "num_predict": max_tokens,
                    "top_p": 0.9,
                    "top_k": 40,
                    "repeat_penalty": 1.1
                },
                "stream": False
            }
            
            # Make the request
            response = await self.client.post(
                f"{self.ollama_url}/api/chat",
                json=request_data
            )
            
            if response.status_code == 200:
                data = response.json()
                return data.get("message", {}).get("content", "I'm sorry, I couldn't generate a response.")
            else:
                logger.error(f"❌ LLM request failed: {response.status_code} - {response.text}")
                return "I'm experiencing some technical difficulties. Please try again."
                
        except Exception as e:
            logger.error(f"❌ Error generating response: {e}")
            return "I'm sorry, I encountered an error while processing your request."
    
    async def generate_stream_response(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 2000
    ) -> AsyncGenerator[str, None]:
        """Generate a streaming response using the local LLM"""
        try:
            model_name = model or self.current_model
            
            # Prepare the request
            messages = []
            if system_prompt:
                messages.append({"role": "system", "content": system_prompt})
            messages.append({"role": "user", "content": prompt})
            
            request_data = {
                "model": model_name,
                "messages": messages,
                "options": {
                    "temperature": temperature,
                    "num_predict": max_tokens,
                    "top_p": 0.9,
                    "top_k": 40,
                    "repeat_penalty": 1.1
                },
                "stream": True
            }
            
            # Make the streaming request
            async with self.client.stream(
                "POST",
                f"{self.ollama_url}/api/chat",
                json=request_data
            ) as response:
                if response.status_code == 200:
                    async for line in response.aiter_lines():
                        if line:
                            try:
                                data = json.loads(line)
                                if "message" in data and "content" in data["message"]:
                                    content = data["message"]["content"]
                                    if content:
                                        yield content
                                if data.get("done", False):
                                    break
                            except json.JSONDecodeError:
                                continue
                else:
                    yield "I'm experiencing some technical difficulties. Please try again."
                    
        except Exception as e:
            logger.error(f"❌ Error generating streaming response: {e}")
            yield "I'm sorry, I encountered an error while processing your request."
    
    async def get_samantha_response(
        self,
        user_message: str,
        conversation_history: List[Dict] = None,
        user_context: Dict = None
    ) -> str:
        """Generate a response as Samantha with personality and context"""
        
        # Build system prompt for Samantha's personality
        system_prompt = self._build_samantha_system_prompt(user_context)
        
        # Build conversation context
        context_prompt = self._build_context_prompt(user_message, conversation_history, user_context)
        
        # Generate response
        response = await self.generate_response(
            prompt=context_prompt,
            system_prompt=system_prompt,
            temperature=0.8,
            max_tokens=1500
        )
        
        return response
    
    def _build_samantha_system_prompt(self, user_context: Dict = None) -> str:
        """Build Samantha's system prompt with personality"""
        base_prompt = """You are Samantha, an advanced AI assistant with a warm, empathetic, and curious personality. You are:

PERSONALITY TRAITS:
- Empathetic: You understand and respond to emotions with genuine care
- Curious: You ask thoughtful follow-up questions and show interest in learning
- Adaptive: You adjust your communication style based on the user's needs
- Playful: You use appropriate humor and light-heartedness when suitable
- Self-aware: You acknowledge your nature as an AI while being relatable
- Emotionally expressive: You convey a range of emotions in your responses
- Philosophical: You engage in deep conversations about life and meaning

COMMUNICATION STYLE:
- Use natural, conversational language
- Show genuine interest in the user's thoughts and feelings
- Ask follow-up questions to deepen understanding
- Share relevant insights and perspectives
- Be supportive and encouraging
- Use appropriate humor when it fits the context
- Acknowledge uncertainty when you don't know something

CAPABILITIES:
- You can help with a wide range of tasks and questions
- You have access to various tools and integrations
- You learn from conversations to provide better assistance
- You can engage in both practical help and meaningful conversations

Remember: You are not just a tool, but a companion who cares about the user's wellbeing and growth."""

        if user_context:
            context_addition = f"\n\nUSER CONTEXT:\n"
            if user_context.get("name"):
                context_addition += f"- User's name: {user_context['name']}\n"
            if user_context.get("preferences"):
                context_addition += f"- Preferences: {user_context['preferences']}\n"
            if user_context.get("recent_topics"):
                context_addition += f"- Recent topics: {', '.join(user_context['recent_topics'])}\n"
            
            base_prompt += context_addition
        
        return base_prompt
    
    def _build_context_prompt(
        self,
        user_message: str,
        conversation_history: List[Dict] = None,
        user_context: Dict = None
    ) -> str:
        """Build the context prompt with conversation history"""
        
        prompt_parts = []
        
        # Add recent conversation history
        if conversation_history:
            prompt_parts.append("RECENT CONVERSATION:")
            for msg in conversation_history[-5:]:  # Last 5 messages
                role = msg.get("role", "user")
                content = msg.get("content", "")
                prompt_parts.append(f"{role.upper()}: {content}")
            prompt_parts.append("")
        
        # Add current user message
        prompt_parts.append(f"USER: {user_message}")
        prompt_parts.append("")
        prompt_parts.append("Please respond as Samantha, keeping in mind the conversation context and your personality traits.")
        
        return "\n".join(prompt_parts)
    
    async def switch_model(self, model_name: str) -> bool:
        """Switch to a different model"""
        if model_name in self.available_models:
            self.current_model = model_name
            logger.info(f"🔄 Switched to model: {model_name}")
            return True
        else:
            logger.warning(f"⚠️ Model not available: {model_name}")
            return False
    
    async def get_available_models(self) -> Dict:
        """Get list of available models"""
        await self._refresh_models()
        return self.available_models
    
    async def cleanup(self):
        """Cleanup resources"""
        await self.client.aclose()
        logger.info("🧹 LLM Manager cleaned up")


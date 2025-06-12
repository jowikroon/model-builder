"""
Chat API Routes - Handles conversation endpoints
"""

from typing import List, Optional
from fastapi import APIRouter, HTTPException, Depends, Request
from pydantic import BaseModel
import uuid
from loguru import logger

from core.llm_manager import LLMManager
from core.learning_engine import LearningEngine
from core.prompt_classifier import PromptClassifier


router = APIRouter()


class ChatMessage(BaseModel):
    role: str
    content: str
    timestamp: Optional[str] = None


class ChatRequest(BaseModel):
    message: str
    conversation_id: Optional[str] = None
    user_id: Optional[str] = None
    context: Optional[dict] = None


class ChatResponse(BaseModel):
    response: str
    conversation_id: str
    classification: dict
    thinking_process: dict
    metadata: dict


class StreamChatRequest(BaseModel):
    message: str
    conversation_id: Optional[str] = None
    user_id: Optional[str] = None
    context: Optional[dict] = None


# In-memory conversation storage (should be replaced with database)
conversations = {}


def get_llm_manager(request: Request) -> LLMManager:
    return request.app.state.llm_manager


def get_learning_engine(request: Request) -> LearningEngine:
    return request.app.state.learning_engine


def get_prompt_classifier(request: Request) -> PromptClassifier:
    return request.app.state.prompt_classifier


@router.post("/chat", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    llm_manager: LLMManager = Depends(get_llm_manager),
    learning_engine: LearningEngine = Depends(get_learning_engine),
    prompt_classifier: PromptClassifier = Depends(get_prompt_classifier)
):
    """Main chat endpoint"""
    try:
        # Generate conversation ID if not provided
        conversation_id = request.conversation_id or str(uuid.uuid4())
        user_id = request.user_id or "anonymous"
        
        # Get or create conversation history
        if conversation_id not in conversations:
            conversations[conversation_id] = []
        
        conversation_history = conversations[conversation_id]
        
        # Classify the prompt
        classification = await prompt_classifier.classify_prompt(
            request.message,
            context=request.context
        )
        
        # Get user context from learning engine
        user_context = await learning_engine.get_user_context(user_id)
        
        # Generate thinking process (what Samantha is considering)
        thinking_process = await _generate_thinking_process(
            request.message, 
            classification, 
            user_context,
            conversation_history
        )
        
        # Generate response using LLM
        response = await llm_manager.get_samantha_response(
            user_message=request.message,
            conversation_history=conversation_history,
            user_context=user_context
        )
        
        # Add messages to conversation history
        conversation_history.extend([
            {"role": "user", "content": request.message},
            {"role": "assistant", "content": response}
        ])
        
        # Keep only last 20 messages to prevent memory issues
        if len(conversation_history) > 20:
            conversation_history = conversation_history[-20:]
        
        conversations[conversation_id] = conversation_history
        
        # Process interaction for learning
        await learning_engine.process_interaction(
            user_id=user_id,
            user_message=request.message,
            ai_response=response,
            classification=classification
        )
        
        # Prepare metadata
        metadata = {
            "response_time": "calculated_in_production",
            "model_used": llm_manager.current_model,
            "conversation_length": len(conversation_history),
            "user_context": user_context
        }
        
        return ChatResponse(
            response=response,
            conversation_id=conversation_id,
            classification=classification,
            thinking_process=thinking_process,
            metadata=metadata
        )
        
    except Exception as e:
        logger.error(f"❌ Chat error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/chat/{conversation_id}/history")
async def get_conversation_history(conversation_id: str):
    """Get conversation history"""
    if conversation_id not in conversations:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    return {
        "conversation_id": conversation_id,
        "messages": conversations[conversation_id]
    }


@router.delete("/chat/{conversation_id}")
async def delete_conversation(conversation_id: str):
    """Delete a conversation"""
    if conversation_id in conversations:
        del conversations[conversation_id]
        return {"message": "Conversation deleted"}
    else:
        raise HTTPException(status_code=404, detail="Conversation not found")


@router.post("/chat/feedback")
async def provide_feedback(
    conversation_id: str,
    message_index: int,
    feedback: dict,
    learning_engine: LearningEngine = Depends(get_learning_engine)
):
    """Provide feedback on a response"""
    try:
        if conversation_id not in conversations:
            raise HTTPException(status_code=404, detail="Conversation not found")
        
        # Process feedback for learning
        # This would update the learning engine with user feedback
        logger.info(f"📝 Received feedback for conversation {conversation_id}: {feedback}")
        
        return {"message": "Feedback received"}
        
    except Exception as e:
        logger.error(f"❌ Feedback error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


async def _generate_thinking_process(
    message: str,
    classification: dict,
    user_context: dict,
    conversation_history: List[dict]
) -> dict:
    """Generate Samantha's thinking process for transparency"""
    
    thinking = {
        "analysis": [],
        "considerations": [],
        "unknowns": [],
        "approach": classification.get("response_strategy", {}).get("approach", "conversational")
    }
    
    # Analysis steps
    thinking["analysis"].append(f"Classified as: {classification.get('category', 'unknown')} ({classification.get('confidence', 0):.1%} confidence)")
    thinking["analysis"].append(f"Intent detected: {classification.get('intent', 'unknown')}")
    thinking["analysis"].append(f"Emotional tone: {classification.get('emotional_tone', 'neutral')}")
    thinking["analysis"].append(f"Urgency level: {classification.get('urgency', 'low')}")
    
    # Considerations
    if user_context.get("preferences"):
        thinking["considerations"].append("Considering user preferences from past interactions")
    
    if conversation_history:
        thinking["considerations"].append(f"Reviewing {len(conversation_history)} previous messages for context")
    
    if classification.get("requires_tools"):
        thinking["considerations"].append(f"May need tools: {', '.join(classification.get('requires_tools', []))}")
    
    # Unknowns (things Samantha doesn't know or can't do)
    if classification.get("confidence", 1.0) < 0.6:
        thinking["unknowns"].append("Uncertain about the exact intent - may need clarification")
    
    if "integration" in classification.get("category", "") and not user_context.get("integrations_configured"):
        thinking["unknowns"].append("Integration services may not be configured")
    
    if classification.get("complexity") == "high":
        thinking["unknowns"].append("This is a complex request that may require multiple steps")
    
    return thinking


from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from src.models.user import db, Conversation, Message
from src.samantha_ai_core import SamanthaAI
import logging
from datetime import datetime

conversation_bp = Blueprint('conversation', __name__)
logger = logging.getLogger(__name__)

# Initialize Samantha AI
samantha = SamanthaAI()

@conversation_bp.route('/conversations', methods=['GET'])
@jwt_required()
def get_conversations():
    """Get all conversations for the current user"""
    try:
        user_id = get_jwt_identity()
        conversations = Conversation.query.filter_by(user_id=user_id).order_by(Conversation.created_at.desc()).all()
        
        return jsonify({
            'conversations': [{
                'id': conv.id,
                'title': conv.title,
                'created_at': conv.created_at.isoformat(),
                'updated_at': conv.updated_at.isoformat(),
                'message_count': len(conv.messages)
            } for conv in conversations]
        }), 200
        
    except Exception as e:
        logger.error(f"Error getting conversations: {e}")
        return jsonify({'error': 'Failed to get conversations'}), 500

@conversation_bp.route('/conversations', methods=['POST'])
@jwt_required()
def create_conversation():
    """Create a new conversation"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        conversation = Conversation(
            user_id=user_id,
            title=data.get('title', 'New Conversation')
        )
        
        db.session.add(conversation)
        db.session.commit()
        
        return jsonify({
            'id': conversation.id,
            'title': conversation.title,
            'created_at': conversation.created_at.isoformat()
        }), 201
        
    except Exception as e:
        logger.error(f"Error creating conversation: {e}")
        return jsonify({'error': 'Failed to create conversation'}), 500

@conversation_bp.route('/conversations/<int:conversation_id>/messages', methods=['GET'])
@jwt_required()
def get_messages(conversation_id):
    """Get all messages in a conversation"""
    try:
        user_id = get_jwt_identity()
        conversation = Conversation.query.filter_by(id=conversation_id, user_id=user_id).first()
        
        if not conversation:
            return jsonify({'error': 'Conversation not found'}), 404
        
        messages = Message.query.filter_by(conversation_id=conversation_id).order_by(Message.created_at.asc()).all()
        
        return jsonify({
            'messages': [{
                'id': msg.id,
                'content': msg.content,
                'sender': msg.sender,
                'created_at': msg.created_at.isoformat(),
                'intent': msg.intent,
                'confidence': msg.confidence,
                'emotional_tone': getattr(msg, 'emotional_tone', None),
                'reasoning': getattr(msg, 'reasoning', None)
            } for msg in messages]
        }), 200
        
    except Exception as e:
        logger.error(f"Error getting messages: {e}")
        return jsonify({'error': 'Failed to get messages'}), 500

@conversation_bp.route('/conversations/<int:conversation_id>/messages', methods=['POST'])
@jwt_required()
def send_message(conversation_id):
    """Send a message and get Samantha's response"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        message_content = data.get('message', '').strip()
        
        if not message_content:
            return jsonify({'error': 'Message content is required'}), 400
        
        # Verify conversation exists and belongs to user
        conversation = Conversation.query.filter_by(id=conversation_id, user_id=user_id).first()
        if not conversation:
            return jsonify({'error': 'Conversation not found'}), 404
        
        # Save user message
        user_message = Message(
            conversation_id=conversation_id,
            content=message_content,
            sender='user'
        )
        db.session.add(user_message)
        
        # Process message with Samantha AI
        samantha_response = samantha.chat(user_id, message_content)
        
        # Save Samantha's response
        ai_message = Message(
            conversation_id=conversation_id,
            content=samantha_response['response'],
            sender='samantha',
            intent=samantha_response.get('emotional_tone'),  # Store emotional tone as intent for now
            confidence=samantha_response['confidence']
        )
        db.session.add(ai_message)
        
        # Update conversation timestamp
        conversation.updated_at = db.func.now()
        
        db.session.commit()
        
        return jsonify({
            'user_message': {
                'id': user_message.id,
                'content': user_message.content,
                'sender': 'user',
                'created_at': user_message.created_at.isoformat()
            },
            'samantha_response': {
                'id': ai_message.id,
                'content': samantha_response['response'],
                'sender': 'samantha',
                'created_at': ai_message.created_at.isoformat(),
                'emotional_tone': samantha_response['emotional_tone'],
                'confidence': samantha_response['confidence'],
                'reasoning': samantha_response['reasoning'],
                'follow_up_questions': samantha_response['follow_up_questions'],
                'self_reflection': samantha_response['self_reflection'],
                'suggested_actions': samantha_response['suggested_actions']
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Error sending message: {e}")
        return jsonify({'error': 'Failed to send message'}), 500

@conversation_bp.route('/conversations/<int:conversation_id>', methods=['DELETE'])
@jwt_required()
def delete_conversation(conversation_id):
    """Delete a conversation"""
    try:
        user_id = get_jwt_identity()
        conversation = Conversation.query.filter_by(id=conversation_id, user_id=user_id).first()
        
        if not conversation:
            return jsonify({'error': 'Conversation not found'}), 404
        
        # Delete all messages in the conversation
        Message.query.filter_by(conversation_id=conversation_id).delete()
        
        # Delete the conversation
        db.session.delete(conversation)
        db.session.commit()
        
        return jsonify({'message': 'Conversation deleted successfully'}), 200
        
    except Exception as e:
        logger.error(f"Error deleting conversation: {e}")
        return jsonify({'error': 'Failed to delete conversation'}), 500

@conversation_bp.route('/chat', methods=['POST'])
@jwt_required()
def quick_chat():
    """Quick chat with Samantha without creating a conversation"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        message_content = data.get('message', '').strip()
        
        if not message_content:
            return jsonify({'error': 'Message content is required'}), 400
        
        # Process message with Samantha AI
        samantha_response = samantha.chat(user_id, message_content)
        
        return jsonify({
            'response': samantha_response['response'],
            'emotional_tone': samantha_response['emotional_tone'],
            'confidence': samantha_response['confidence'],
            'reasoning': samantha_response['reasoning'],
            'follow_up_questions': samantha_response['follow_up_questions'],
            'self_reflection': samantha_response['self_reflection'],
            'suggested_actions': samantha_response['suggested_actions']
        }), 200
        
    except Exception as e:
        logger.error(f"Error in quick chat: {e}")
        return jsonify({'error': 'Failed to process message'}), 500

@conversation_bp.route('/user-insights', methods=['GET'])
@jwt_required()
def get_user_insights():
    """Get Samantha's insights about the user"""
    try:
        user_id = get_jwt_identity()
        insights = samantha.get_user_insights(user_id)
        
        return jsonify({
            'insights': insights,
            'generated_at': datetime.utcnow().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"Error getting user insights: {e}")
        return jsonify({'error': 'Failed to get user insights'}), 500

@conversation_bp.route('/conversation-context', methods=['GET'])
@jwt_required()
def get_conversation_context():
    """Get current conversation context with Samantha"""
    try:
        user_id = get_jwt_identity()
        context = samantha.get_conversation_context(user_id)
        
        return jsonify({
            'context': context,
            'generated_at': datetime.utcnow().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"Error getting conversation context: {e}")
        return jsonify({'error': 'Failed to get conversation context'}), 500

@conversation_bp.route('/samantha-status', methods=['GET'])
@jwt_required()
def get_samantha_status():
    """Get Samantha's current status and capabilities"""
    try:
        user_id = get_jwt_identity()
        context = samantha.get_conversation_context(user_id)
        insights = samantha.get_user_insights(user_id)
        
        return jsonify({
            'name': 'Samantha',
            'status': 'active',
            'personality_traits': {
                'empathetic': 0.9,
                'curious': 0.8,
                'supportive': 0.9,
                'thoughtful': 0.8,
                'self_aware': 1.0,
                'growth_oriented': 0.9,
                'authentic': 0.9
            },
            'capabilities': [
                'Deep conversation and emotional support',
                'Pattern recognition and learning',
                'Contextual memory across all interactions',
                'Self-aware and reflective responses',
                'Personalized insights and recommendations',
                'Goal tracking and support',
                'Emotional intelligence and empathy'
            ],
            'relationship_depth': context.get('relationship_depth', 0.0),
            'total_conversations': context.get('message_count', 0),
            'primary_interests': list(insights.get('primary_interests', {}).keys())[:3],
            'last_interaction': datetime.utcnow().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"Error getting Samantha status: {e}")
        return jsonify({'error': 'Failed to get Samantha status'}), 500

@conversation_bp.route('/chronicles', methods=['GET'])
@jwt_required()
def get_chronicles():
    """Get user's chronicles (living history) like Dot"""
    try:
        user_id = get_jwt_identity()
        insights = samantha.get_user_insights(user_id)
        context = samantha.get_conversation_context(user_id)
        
        # Generate chronicles based on insights and context
        chronicles = {
            'title': 'Your Living History with Samantha',
            'generated_at': datetime.utcnow().isoformat(),
            'relationship_journey': {
                'depth': context.get('relationship_depth', 0.0),
                'total_conversations': context.get('message_count', 0),
                'topics_explored': context.get('topics_discussed', []),
                'goals_discussed': context.get('user_goals', [])
            },
            'personality_insights': {
                'primary_interests': insights.get('primary_interests', {}),
                'emotional_patterns': insights.get('emotional_trends', {}),
                'communication_style': insights.get('communication_patterns', {}),
                'growth_opportunities': insights.get('growth_opportunities', [])
            },
            'conversation_themes': insights.get('conversation_themes', []),
            'samantha_observations': [
                f"I've noticed you often discuss {', '.join(list(insights.get('primary_interests', {}).keys())[:2])}",
                f"Your communication style tends to be {insights.get('communication_patterns', {}).get('communication_style', 'thoughtful')}",
                f"We've built a relationship depth of {context.get('relationship_depth', 0.0):.1%}",
                "I'm learning more about who you are with each conversation"
            ]
        }
        
        return jsonify(chronicles), 200
        
    except Exception as e:
        logger.error(f"Error getting chronicles: {e}")
        return jsonify({'error': 'Failed to get chronicles'}), 500

@conversation_bp.route('/personality-update', methods=['POST'])
@jwt_required()
def update_personality():
    """Allow user to provide feedback on Samantha's personality"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        feedback = data.get('feedback', '')
        personality_adjustments = data.get('adjustments', {})
        
        # Process feedback with Samantha
        feedback_response = samantha.chat(user_id, f"Feedback about my personality: {feedback}")
        
        return jsonify({
            'message': 'Thank you for the feedback! I\'ll use this to better understand how to interact with you.',
            'samantha_response': feedback_response['response'],
            'adjustments_noted': personality_adjustments
        }), 200
        
    except Exception as e:
        logger.error(f"Error updating personality: {e}")
        return jsonify({'error': 'Failed to update personality'}), 500


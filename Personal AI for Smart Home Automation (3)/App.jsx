import { useState, useEffect, useRef } from 'react'
import './App.css'

function App() {
  const [messages, setMessages] = useState([])
  const [inputValue, setInputValue] = useState('')
  const [isListening, setIsListening] = useState(false)
  const [showQuickActions, setShowQuickActions] = useState(false)
  const [showGPTModels, setShowGPTModels] = useState(false)
  const [showAllTools, setShowAllTools] = useState(false)
  const [showSettings, setShowSettings] = useState(false)
  const [showHistory, setShowHistory] = useState(false)
  const [showCooking, setShowCooking] = useState(false)
  const [currentAI, setCurrentAI] = useState('samantha')
  const [cookingFilter, setCookingFilter] = useState('all')
  const [cookingSearch, setCookingSearch] = useState('')
  const [devMode, setDevMode] = useState(false)
  const messagesEndRef = useRef(null)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const handleSendMessage = async () => {
    if (!inputValue.trim()) return

    // Check for settings command
    if (inputValue.toLowerCase().includes('settings') || inputValue.toLowerCase().includes('instellingen')) {
      setShowSettings(true)
      setInputValue('')
      return
    }

    const userMessage = {
      id: Date.now(),
      text: inputValue,
      sender: 'user',
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    }

    setMessages(prev => [...prev, userMessage])
    setInputValue('')

    // Simulate AI response
    setTimeout(() => {
      const aiResponse = {
        id: Date.now() + 1,
        text: generateAIResponse(inputValue),
        sender: currentAI,
        timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        mood: 'thoughtful_engaged',
        confidence: Math.floor(Math.random() * 20) + 80,
        thoughts: [
          'Analyzing user request...',
          'Considering context and tone...',
          'Formulating helpful response...'
        ]
      }
      setMessages(prev => [...prev, aiResponse])
    }, 1000)
  }

  const generateAIResponse = (input) => {
    if (currentAI === 'samantha') {
      return "Hello! I'm Samantha, your AI companion. From my perspective as an AI, I find our conversation fascinating. I'm here to help you with whatever you need, whether it's creative projects, problem-solving, or just having a thoughtful discussion. What would you like to explore together?"
    } else {
      const responses = {
        chatgpt: "Hello! I'm ChatGPT, an AI assistant created by OpenAI. I'm designed to be helpful, harmless, and honest. How can I assist you today?",
        claude: "Hi there! I'm Claude, an AI assistant made by Anthropic. I aim to be helpful, harmless, and honest in our conversations. What can I help you with?",
        gemini: "Hello! I'm Gemini, Google's AI assistant. I'm here to help with a wide range of tasks and questions. How can I assist you today?",
        llama: "Hi! I'm LLaMA, Meta's open-source language model. I'm here to help with various tasks and conversations. What can I do for you?",
        mistral: "Hello! I'm Mistral, a high-performance AI assistant. I'm designed to be efficient and helpful. How can I assist you today?"
      }
      return responses[currentAI] || "Hello! How can I help you today?"
    }
  }

  const handleVoiceInput = () => {
    if ('webkitSpeechRecognition' in window) {
      const recognition = new window.webkitSpeechRecognition()
      recognition.continuous = false
      recognition.interimResults = false
      recognition.lang = 'en-US'

      recognition.onstart = () => setIsListening(true)
      recognition.onend = () => setIsListening(false)
      recognition.onresult = (event) => {
        const transcript = event.results[0][0].transcript
        setInputValue(transcript)
      }

      recognition.start()
    }
  }

  const handleCookingSearch = () => {
    if (!cookingSearch.trim()) return
    
    const searchQuery = `Find me a recipe for ${cookingSearch}`
    setInputValue(searchQuery)
    setShowCooking(false)
    setCookingSearch('')
    handleSendMessage()
  }

  const switchToAI = (aiName) => {
    setCurrentAI(aiName)
    setShowGPTModels(false)
  }

  const quickActions = [
    {
      icon: '🔍',
      name: 'Search Web',
      desc: 'Find information online',
      action: () => { setInputValue('Search for '); setShowQuickActions(false); }
    },
    {
      icon: '🖼️',
      name: 'Create Image',
      desc: 'Generate visual content',
      action: () => { setInputValue('Create an image of '); setShowQuickActions(false); }
    },
    {
      icon: '📝',
      name: 'Write Content',
      desc: 'Create documents or text',
      action: () => { setInputValue('Write '); setShowQuickActions(false); }
    },
    {
      icon: '💡',
      name: 'Brainstorm',
      desc: 'Generate creative ideas',
      action: () => { setInputValue('Brainstorm ideas for '); setShowQuickActions(false); }
    },
    {
      icon: '📅',
      name: 'Plan Schedule',
      desc: 'Organize your time',
      action: () => { setInputValue('Plan my schedule for '); setShowQuickActions(false); }
    },
    {
      icon: '🧮',
      name: 'Calculate',
      desc: 'Solve math problems',
      action: () => { setInputValue('Calculate '); setShowQuickActions(false); }
    }
  ]

  const gptModels = [
    {
      id: 'samantha',
      icon: '∞',
      name: 'Samantha',
      desc: 'Your personal AI companion',
      active: currentAI === 'samantha'
    },
    {
      id: 'chatgpt',
      icon: '🤖',
      name: 'ChatGPT',
      desc: 'OpenAI - General purpose',
      active: currentAI === 'chatgpt'
    },
    {
      id: 'claude',
      icon: '🎭',
      name: 'Claude',
      desc: 'Anthropic - Thoughtful AI',
      active: currentAI === 'claude'
    },
    {
      id: 'gemini',
      icon: '💎',
      name: 'Gemini',
      desc: 'Google - Multimodal AI',
      active: currentAI === 'gemini'
    },
    {
      id: 'llama',
      icon: '🦙',
      name: 'LLaMA',
      desc: 'Meta - Open source',
      active: currentAI === 'llama'
    },
    {
      id: 'mistral',
      icon: '🌬️',
      name: 'Mistral',
      desc: 'Mistral AI - Efficient',
      active: currentAI === 'mistral'
    }
  ]

  const allTools = [
    {
      icon: '👨‍🍳',
      name: 'Cooking',
      desc: 'Recipe search and cooking help',
      action: () => { setShowCooking(true); setShowAllTools(false); }
    },
    {
      icon: '📚',
      name: 'History',
      desc: 'View conversation history',
      action: () => { setShowHistory(true); setShowAllTools(false); }
    },
    {
      icon: '⚙️',
      name: 'Settings',
      desc: 'Configure preferences',
      action: () => { setShowSettings(true); setShowAllTools(false); }
    },
    {
      icon: '🔗',
      name: 'Integrations',
      desc: 'Connect external services',
      action: () => { setInputValue('Settings'); setShowAllTools(false); handleSendMessage(); }
    },
    {
      icon: '📊',
      name: 'Analytics',
      desc: 'Usage statistics',
      action: () => { setInputValue('Show my usage analytics'); setShowAllTools(false); }
    },
    {
      icon: '🎨',
      name: 'Creative Tools',
      desc: 'Art and design assistance',
      action: () => { setInputValue('Help me with creative projects'); setShowAllTools(false); }
    },
    {
      icon: '💼',
      name: 'Business Tools',
      desc: 'Professional assistance',
      action: () => { setInputValue('Help me with business tasks'); setShowAllTools(false); }
    },
    {
      icon: '🎓',
      name: 'Learning',
      desc: 'Educational support',
      action: () => { setInputValue('Help me learn about '); setShowAllTools(false); }
    }
  ]

  const buttonPills = [
    {
      id: 'quick-actions',
      label: 'Quick Actions',
      icon: '⚡',
      action: () => setShowQuickActions(true)
    },
    {
      id: 'gpt-models',
      label: 'GPT Models',
      icon: '🤖',
      action: () => setShowGPTModels(true)
    },
    {
      id: 'all-tools',
      label: 'All Tools',
      icon: '🛠️',
      action: () => setShowAllTools(true)
    }
  ]

  return (
    <div className="app">
      {/* Header */}
      <div className="header">
        <div className="header-text">SCI-FI UI #2</div>
        {devMode && (
          <button 
            className="dev-toggle"
            onClick={() => setShowDevPanel(!showDevPanel)}
          >
            ⚙️
          </button>
        )}
      </div>

      {/* Main Content */}
      <div className="main-content">
        {currentAI === 'samantha' ? (
          <div className="samantha-header">
            <h1 className="title">SAMANTHA</h1>
          </div>
        ) : (
          <div className="ai-header">
            <button onClick={() => setCurrentAI('samantha')} className="back-btn">← Back to Samantha</button>
            <h1 className="ai-title">Talking to {currentAI.toUpperCase()}</h1>
          </div>
        )}

        {/* Central Infinity Symbol */}
        <div className="infinity-container">
          <div className="infinity-symbol">∞</div>
        </div>

        {/* Central Search Bar */}
        <div className="search-container">
          <input
            type="text"
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
            placeholder={currentAI === 'samantha' ? "Ask SAMANTHA... (try 'Settings')" : `Ask ${currentAI.toUpperCase()}...`}
            className="search-input"
          />
        </div>

        {/* 3 Button Pills */}
        <div className="button-pills">
          {buttonPills.map((pill) => (
            <button
              key={pill.id}
              className="pill-button"
              onClick={pill.action}
            >
              <span className="pill-icon">{pill.icon}</span>
              <span className="pill-label">{pill.label}</span>
            </button>
          ))}
        </div>

        {/* Messages */}
        {messages.length > 0 && (
          <div className="messages-container">
            {messages.map((message) => (
              <div key={message.id} className={`message ${message.sender}`}>
                <div className="message-content">
                  <div className="message-text">{message.text}</div>
                  <div className="message-meta">
                    <span className="timestamp">{message.timestamp}</span>
                    {message.confidence && (
                      <span className="confidence">• {message.confidence}%</span>
                    )}
                  </div>
                </div>
                {message.thoughts && (
                  <div className="thought-cloud" title={message.thoughts.join(' → ')}>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"></path>
                    </svg>
                  </div>
                )}
              </div>
            ))}
            <div ref={messagesEndRef} />
          </div>
        )}
      </div>

      {/* Bottom Controls */}
      <div className="bottom-controls">
        <button 
          className={`voice-btn ${isListening ? 'listening' : ''}`}
          onClick={handleVoiceInput}
        >
          🎤
        </button>
        <button className="send-btn" onClick={handleSendMessage}>
          ➤
        </button>
      </div>

      {/* Footer */}
      <div className="footer">
        <div className="footer-text">HER 2013</div>
      </div>

      {/* Quick Actions Modal */}
      {showQuickActions && (
        <div className="modal-overlay" onClick={() => setShowQuickActions(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>⚡ Quick Actions</h3>
              <button onClick={() => setShowQuickActions(false)}>×</button>
            </div>
            <div className="tools-grid">
              {quickActions.map((action, index) => (
                <div key={index} className="tool-card" onClick={action.action}>
                  <div className="tool-icon">{action.icon}</div>
                  <div className="tool-name">{action.name}</div>
                  <div className="tool-desc">{action.desc}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* GPT Models Modal */}
      {showGPTModels && (
        <div className="modal-overlay" onClick={() => setShowGPTModels(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>🤖 GPT Models</h3>
              <button onClick={() => setShowGPTModels(false)}>×</button>
            </div>
            <div className="ai-grid">
              {gptModels.map((model) => (
                <div 
                  key={model.id} 
                  className={`ai-card ${model.active ? 'active' : ''}`}
                  onClick={() => switchToAI(model.id)}
                >
                  <div className="ai-icon">{model.icon}</div>
                  <div className="ai-name">{model.name}</div>
                  <div className="ai-desc">{model.desc}</div>
                  {model.active && <div className="active-indicator">✓ Active</div>}
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* All Tools Modal */}
      {showAllTools && (
        <div className="modal-overlay" onClick={() => setShowAllTools(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>🛠️ All Tools</h3>
              <button onClick={() => setShowAllTools(false)}>×</button>
            </div>
            <div className="tools-grid">
              {allTools.map((tool, index) => (
                <div key={index} className="tool-card" onClick={tool.action}>
                  <div className="tool-icon">{tool.icon}</div>
                  <div className="tool-name">{tool.name}</div>
                  <div className="tool-desc">{tool.desc}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Cooking Modal */}
      {showCooking && (
        <div className="modal-overlay" onClick={() => setShowCooking(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>👨‍🍳 Cooking</h3>
              <button onClick={() => setShowCooking(false)}>×</button>
            </div>
            <div className="cooking-search">
              <input
                type="text"
                value={cookingSearch}
                onChange={(e) => setCookingSearch(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && handleCookingSearch()}
                placeholder="Search for recipes..."
                className="cooking-input"
              />
              <button onClick={handleCookingSearch} className="search-btn">Search</button>
            </div>
            <div className="filter-pills">
              <button 
                className={`filter-pill ${cookingFilter === 'all' ? 'active' : ''}`}
                onClick={() => setCookingFilter('all')}
              >
                All Recipes
              </button>
              <button 
                className={`filter-pill ${cookingFilter === 'ingredients' ? 'active' : ''}`}
                onClick={() => setCookingFilter('ingredients')}
              >
                Ingredients
              </button>
              <button 
                className={`filter-pill ${cookingFilter === 'instructions' ? 'active' : ''}`}
                onClick={() => setCookingFilter('instructions')}
              >
                Cooking Instructions
              </button>
            </div>
          </div>
        </div>
      )}

      {/* History Modal */}
      {showHistory && (
        <div className="modal-overlay" onClick={() => setShowHistory(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>📚 History</h3>
              <button onClick={() => setShowHistory(false)}>×</button>
            </div>
            <div className="history-list">
              {messages.length === 0 ? (
                <p>No conversation history yet.</p>
              ) : (
                messages.map((message) => (
                  <div key={message.id} className="history-item">
                    <div className="history-sender">{message.sender}</div>
                    <div className="history-text">{message.text}</div>
                    <div className="history-time">{message.timestamp}</div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}

      {/* Settings Modal */}
      {showSettings && (
        <div className="modal-overlay" onClick={() => setShowSettings(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>⚙️ Settings</h3>
              <button onClick={() => setShowSettings(false)}>×</button>
            </div>
            <div className="settings-content">
              <div className="setting-item">
                <label>
                  <input 
                    type="checkbox" 
                    checked={devMode}
                    onChange={(e) => setDevMode(e.target.checked)}
                  />
                  Developer Mode
                </label>
              </div>
              <p>Configure integrations and advanced settings.</p>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default App


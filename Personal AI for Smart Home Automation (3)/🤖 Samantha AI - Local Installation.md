# 🤖 Samantha AI - Local Installation

**Advanced conversational AI with learning capabilities - runs completely locally**

Samantha AI is a sophisticated personal AI assistant that runs entirely on your local machine, providing privacy, customization, and continuous learning from your interactions.

## ✨ Features

### 🧠 **Advanced AI Capabilities**
- **Local LLM Integration** - Dolphin, LLaMA, Mistral models via Ollama
- **Intelligent Prompt Classification** - Understands context and intent
- **Continuous Learning** - Improves from every interaction
- **Multi-Model Support** - Switch between different AI personalities

### 🎯 **Smart Conversation**
- **Context Awareness** - Remembers conversation history
- **Emotional Intelligence** - Recognizes and responds to emotions
- **Personalization** - Adapts to your preferences over time
- **Thought Transparency** - Shows AI reasoning process

### 🏠 **Home Assistant Integration**
- **Smart Home Control** - Philips Hue, Home Assistant
- **Service Integration** - Spotify, Google Calendar, Contacts
- **Local Processing** - No data leaves your network
- **Docker Deployment** - Easy installation and management

### 🔒 **Privacy & Security**
- **100% Local** - No external API calls required
- **Data Ownership** - Your conversations stay on your device
- **Secure Storage** - Encrypted database and secure sessions
- **Open Source** - Full transparency and customization

## 🚀 Quick Installation

### Prerequisites
- **Linux/macOS** - Windows support via WSL2
- **8GB+ RAM** - 16GB recommended for optimal performance
- **20GB+ Storage** - For AI models and data
- **Docker** - Automatically installed if missing

### One-Line Install
```bash
curl -fsSL https://raw.githubusercontent.com/samantha-ai/install/main/install.sh | sudo bash
```

### Manual Installation
```bash
# Download installer
wget https://github.com/samantha-ai/samantha-local/archive/main.zip
unzip main.zip
cd samantha-local-main

# Run installer
sudo chmod +x install.sh
sudo ./install.sh
```

## 🛠️ Management

### Start Samantha
```bash
sudo samantha start
```

### Check Status
```bash
sudo samantha status
```

### View Logs
```bash
sudo samantha logs
```

### Install AI Models
```bash
# Install recommended models
sudo samantha install-model dolphin-llama3:8b
sudo samantha install-model llama3.1:8b
sudo samantha install-model mistral:7b
```

### Update Samantha
```bash
sudo samantha update
```

## 🌐 Access Points

Once installed and running:

- **Web Interface**: http://localhost:3000
- **API Endpoint**: http://localhost:8000
- **Ollama API**: http://localhost:11434
- **Database**: PostgreSQL on port 5432
- **Cache**: Redis on port 6379

## 📋 System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │     Ollama      │
│   (React)       │◄──►│   (FastAPI)     │◄──►│   (Local LLM)   │
│   Port: 3000    │    │   Port: 8000    │    │   Port: 11434   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         │              │   PostgreSQL    │              │
         └──────────────►│   (Database)    │◄─────────────┘
                        │   Port: 5432    │
                        └─────────────────┘
                                 │
                        ┌─────────────────┐
                        │     Redis       │
                        │    (Cache)      │
                        │   Port: 6379    │
                        └─────────────────┘
```

## 🧠 AI Models

### Recommended Models

| Model | Size | Description | Use Case |
|-------|------|-------------|----------|
| **dolphin-llama3:8b** | ~4.7GB | Uncensored, helpful | General conversation |
| **llama3.1:8b** | ~4.7GB | Latest Meta model | Advanced reasoning |
| **mistral:7b** | ~4.1GB | Fast, efficient | Quick responses |
| **codellama:7b** | ~3.8GB | Code-focused | Programming help |
| **phi3:mini** | ~2.3GB | Lightweight | Resource-constrained |

### Model Management
```bash
# List available models
sudo samantha models

# Install specific model
sudo samantha install-model <model-name>

# Switch default model (via web interface)
# Go to Settings → AI Models → Select Model
```

## ⚙️ Configuration

### Environment Variables
Located in `/opt/samantha/docker-compose.yml`:

```yaml
environment:
  - DATABASE_URL=postgresql://samantha:password@postgres:5432/samantha
  - REDIS_URL=redis://redis:6379
  - OLLAMA_URL=http://ollama:11434
  - ENVIRONMENT=production
  - LOG_LEVEL=INFO
```

### Database Configuration
- **Host**: localhost:5432
- **Database**: samantha
- **User**: samantha
- **Password**: samantha_secure_2024

### Customization
- **Frontend**: `/opt/samantha/frontend/`
- **Backend**: `/opt/samantha/backend/`
- **Logs**: `/opt/samantha/logs/`
- **Data**: `/opt/samantha/data/`

## 🔧 Troubleshooting

### Common Issues

**Samantha won't start**
```bash
# Check Docker status
sudo systemctl status docker

# Check logs
sudo samantha logs

# Restart all services
sudo samantha restart
```

**Models not downloading**
```bash
# Check Ollama status
curl http://localhost:11434/api/tags

# Manual model install
docker exec -it samantha-ollama ollama pull dolphin-llama3:8b
```

**High memory usage**
```bash
# Use smaller models
sudo samantha install-model phi3:mini

# Monitor resources
docker stats
```

**Database connection issues**
```bash
# Reset database
sudo samantha stop
docker volume rm samantha_postgres_data
sudo samantha start
```

### Performance Optimization

**For 8GB RAM systems:**
- Use `phi3:mini` or `mistral:7b` models
- Limit conversation history to 10 messages
- Enable swap if needed

**For 16GB+ RAM systems:**
- Use `dolphin-llama3:8b` or `llama3.1:8b`
- Enable GPU acceleration if available
- Run multiple models simultaneously

## 🔄 Backup & Restore

### Create Backup
```bash
sudo samantha backup
# Creates: /tmp/samantha-backup-YYYYMMDD-HHMMSS.tar.gz
```

### Restore Backup
```bash
sudo samantha restore /path/to/backup.tar.gz
```

### Manual Backup
```bash
# Backup data and configuration
sudo tar -czf samantha-backup.tar.gz -C /opt/samantha data logs docker-compose.yml

# Backup database
docker exec samantha-postgres pg_dump -U samantha samantha > samantha-db-backup.sql
```

## 🗑️ Uninstallation

```bash
# Complete removal
sudo samantha uninstall

# This removes:
# - All containers and images
# - Configuration files
# - Database and data
# - System service
# - User account
```

## 🤝 Support & Development

### Getting Help
- **Documentation**: Full docs at `/opt/samantha/docs/`
- **Logs**: Check `sudo samantha logs` for errors
- **Status**: Use `sudo samantha status` for health check

### Development
```bash
# Development mode
cd /opt/samantha
sudo docker-compose -f docker-compose.dev.yml up

# Access containers
docker exec -it samantha-backend bash
docker exec -it samantha-ollama bash
```

### Contributing
1. Fork the repository
2. Create feature branch
3. Make changes
4. Test locally
5. Submit pull request

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- **Ollama** - Local LLM serving
- **Meta** - LLaMA models
- **Mistral AI** - Mistral models
- **Cognitive Computations** - Dolphin models
- **FastAPI** - Backend framework
- **React** - Frontend framework

---

**🤖 Welcome to the future of personal AI! Samantha is ready to learn and grow with you.**


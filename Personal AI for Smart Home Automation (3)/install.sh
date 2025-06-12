#!/bin/bash

# Samantha AI - Local Installation Script
# Home Assistant style installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="/opt/samantha"
SERVICE_USER="samantha"
COMPOSE_VERSION="2.21.0"

echo -e "${BLUE}🤖 Samantha AI - Local Installation${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root${NC}"
   exit 1
fi

# Check system requirements
echo -e "${YELLOW}🔍 Checking system requirements...${NC}"

# Check OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "${GREEN}✅ Linux detected${NC}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${GREEN}✅ macOS detected${NC}"
else
    echo -e "${RED}❌ Unsupported operating system${NC}"
    exit 1
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl enable docker
    systemctl start docker
    rm get-docker.sh
else
    echo -e "${GREEN}✅ Docker is installed${NC}"
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Docker Compose...${NC}"
    curl -L "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo -e "${GREEN}✅ Docker Compose is installed${NC}"
fi

# Check available memory
MEMORY_GB=$(free -g | awk '/^Mem:/{print $2}')
if [ "$MEMORY_GB" -lt 8 ]; then
    echo -e "${YELLOW}⚠️  Warning: Less than 8GB RAM detected. Samantha may run slowly.${NC}"
    echo -e "${YELLOW}   Recommended: 8GB+ RAM for optimal performance${NC}"
fi

# Check available disk space
DISK_GB=$(df -BG / | awk 'NR==2{gsub(/G/,"",$4); print $4}')
if [ "$DISK_GB" -lt 20 ]; then
    echo -e "${RED}❌ Insufficient disk space. At least 20GB required.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Sufficient disk space available${NC}"
fi

# Create service user
echo -e "${YELLOW}👤 Creating service user...${NC}"
if ! id "$SERVICE_USER" &>/dev/null; then
    useradd -r -s /bin/false -d "$INSTALL_DIR" "$SERVICE_USER"
    usermod -aG docker "$SERVICE_USER"
    echo -e "${GREEN}✅ Service user created${NC}"
else
    echo -e "${GREEN}✅ Service user already exists${NC}"
fi

# Create installation directory
echo -e "${YELLOW}📁 Creating installation directory...${NC}"
mkdir -p "$INSTALL_DIR"
chown "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR"

# Download Samantha files
echo -e "${YELLOW}⬇️  Downloading Samantha AI...${NC}"
cd "$INSTALL_DIR"

# Create directory structure
mkdir -p backend frontend scripts logs data

# Copy files (in a real installation, these would be downloaded)
echo -e "${YELLOW}📋 Setting up configuration files...${NC}"

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: samantha-ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0
    restart: unless-stopped
    networks:
      - samantha-network

  postgres:
    image: postgres:15-alpine
    container_name: samantha-postgres
    environment:
      POSTGRES_DB: samantha
      POSTGRES_USER: samantha
      POSTGRES_PASSWORD: samantha_secure_2024
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped
    networks:
      - samantha-network

  redis:
    image: redis:7-alpine
    container_name: samantha-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped
    networks:
      - samantha-network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: samantha-backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://samantha:samantha_secure_2024@postgres:5432/samantha
      - REDIS_URL=redis://redis:6379
      - OLLAMA_URL=http://ollama:11434
      - ENVIRONMENT=production
    volumes:
      - ./logs:/app/logs
      - ./data:/app/data
    depends_on:
      - postgres
      - redis
      - ollama
    restart: unless-stopped
    networks:
      - samantha-network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: samantha-frontend
    ports:
      - "3000:80"
    environment:
      - REACT_APP_API_URL=http://localhost:8000
    depends_on:
      - backend
    restart: unless-stopped
    networks:
      - samantha-network

volumes:
  ollama_data:
  postgres_data:
  redis_data:

networks:
  samantha-network:
    driver: bridge
EOF

# Create systemd service
echo -e "${YELLOW}⚙️  Creating systemd service...${NC}"
cat > /etc/systemd/system/samantha.service << EOF
[Unit]
Description=Samantha AI Assistant
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
User=$SERVICE_USER
Group=$SERVICE_USER

[Install]
WantedBy=multi-user.target
EOF

# Create management script
echo -e "${YELLOW}🛠️  Creating management script...${NC}"
cat > /usr/local/bin/samantha << 'EOF'
#!/bin/bash

INSTALL_DIR="/opt/samantha"
SERVICE_USER="samantha"

case "$1" in
    start)
        echo "🚀 Starting Samantha AI..."
        systemctl start samantha
        ;;
    stop)
        echo "🛑 Stopping Samantha AI..."
        systemctl stop samantha
        ;;
    restart)
        echo "🔄 Restarting Samantha AI..."
        systemctl restart samantha
        ;;
    status)
        echo "📊 Samantha AI Status:"
        systemctl status samantha
        echo ""
        echo "🐳 Container Status:"
        cd $INSTALL_DIR && docker-compose ps
        ;;
    logs)
        echo "📋 Samantha AI Logs:"
        cd $INSTALL_DIR && docker-compose logs -f
        ;;
    update)
        echo "⬆️  Updating Samantha AI..."
        cd $INSTALL_DIR
        docker-compose pull
        docker-compose up -d
        ;;
    models)
        echo "🧠 Available AI Models:"
        curl -s http://localhost:11434/api/tags | jq '.models[].name' 2>/dev/null || echo "Ollama not running or jq not installed"
        ;;
    install-model)
        if [ -z "$2" ]; then
            echo "Usage: samantha install-model <model-name>"
            echo "Example: samantha install-model dolphin-llama3:8b"
            exit 1
        fi
        echo "📥 Installing model: $2"
        curl -X POST http://localhost:11434/api/pull -d "{\"name\":\"$2\"}"
        ;;
    backup)
        echo "💾 Creating backup..."
        BACKUP_NAME="samantha-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
        tar -czf "/tmp/$BACKUP_NAME" -C $INSTALL_DIR data logs
        echo "Backup created: /tmp/$BACKUP_NAME"
        ;;
    restore)
        if [ -z "$2" ]; then
            echo "Usage: samantha restore <backup-file>"
            exit 1
        fi
        echo "🔄 Restoring from backup: $2"
        systemctl stop samantha
        tar -xzf "$2" -C $INSTALL_DIR
        systemctl start samantha
        ;;
    uninstall)
        echo "🗑️  Uninstalling Samantha AI..."
        systemctl stop samantha
        systemctl disable samantha
        cd $INSTALL_DIR && docker-compose down -v
        rm -rf $INSTALL_DIR
        rm /etc/systemd/system/samantha.service
        rm /usr/local/bin/samantha
        userdel $SERVICE_USER
        echo "Samantha AI has been uninstalled"
        ;;
    *)
        echo "🤖 Samantha AI Management"
        echo "Usage: samantha {start|stop|restart|status|logs|update|models|install-model|backup|restore|uninstall}"
        echo ""
        echo "Commands:"
        echo "  start         - Start Samantha AI"
        echo "  stop          - Stop Samantha AI"
        echo "  restart       - Restart Samantha AI"
        echo "  status        - Show status"
        echo "  logs          - Show logs"
        echo "  update        - Update to latest version"
        echo "  models        - List available AI models"
        echo "  install-model - Install a new AI model"
        echo "  backup        - Create backup"
        echo "  restore       - Restore from backup"
        echo "  uninstall     - Remove Samantha AI"
        ;;
esac
EOF

chmod +x /usr/local/bin/samantha

# Set permissions
chown -R "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR"

# Enable and start service
echo -e "${YELLOW}🔧 Enabling Samantha service...${NC}"
systemctl daemon-reload
systemctl enable samantha

echo ""
echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo -e "1. Start Samantha: ${YELLOW}sudo samantha start${NC}"
echo -e "2. Check status: ${YELLOW}sudo samantha status${NC}"
echo -e "3. View logs: ${YELLOW}sudo samantha logs${NC}"
echo -e "4. Install AI models: ${YELLOW}sudo samantha install-model dolphin-llama3:8b${NC}"
echo ""
echo -e "${BLUE}🌐 Access Points:${NC}"
echo -e "• Web Interface: ${YELLOW}http://localhost:3000${NC}"
echo -e "• API Endpoint: ${YELLOW}http://localhost:8000${NC}"
echo -e "• Ollama API: ${YELLOW}http://localhost:11434${NC}"
echo ""
echo -e "${BLUE}🛠️  Management:${NC}"
echo -e "• Use ${YELLOW}samantha${NC} command for all operations"
echo -e "• Configuration files: ${YELLOW}$INSTALL_DIR${NC}"
echo -e "• Logs directory: ${YELLOW}$INSTALL_DIR/logs${NC}"
echo ""
echo -e "${GREEN}Welcome to Samantha AI! 🤖✨${NC}"


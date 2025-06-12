#!/bin/bash

# Samantha AI Model Manager
# Automated script for installing and managing AI models

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

# Check if Ollama is installed
check_ollama() {
    if ! command -v ollama &> /dev/null; then
        error "Ollama is not installed. Please install Ollama first."
        echo "Visit: https://ollama.ai/download"
        exit 1
    fi
    log "Ollama is installed and ready"
}

# Install Ollama model
install_ollama_model() {
    local model_name=$1
    local model_size=$2
    
    log "Installing Ollama model: $model_name"
    log "Expected size: $model_size"
    
    # Check available disk space
    available_space=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    required_space=$(echo $model_size | sed 's/GB//' | sed 's/\..*//')
    
    if [ "$available_space" -lt "$required_space" ]; then
        error "Insufficient disk space. Required: ${model_size}, Available: ${available_space}GB"
        return 1
    fi
    
    # Pull the model
    if ollama pull "$model_name"; then
        log "Successfully installed $model_name"
        return 0
    else
        error "Failed to install $model_name"
        return 1
    fi
}

# Remove Ollama model
remove_ollama_model() {
    local model_name=$1
    
    log "Removing Ollama model: $model_name"
    
    if ollama rm "$model_name"; then
        log "Successfully removed $model_name"
        return 0
    else
        error "Failed to remove $model_name"
        return 1
    fi
}

# List installed models
list_models() {
    log "Listing installed Ollama models:"
    ollama list
}

# Install specific models based on user selection
install_model() {
    local model_id=$1
    
    case $model_id in
        "deepseek-r1-distill-llama")
            install_ollama_model "deepseek-r1-distill-llama" "8.5GB"
            ;;
        "dolphin-llama3")
            install_ollama_model "dolphin-llama3" "4.7GB"
            ;;
        "llama3.2")
            install_ollama_model "llama3.2" "4.7GB"
            ;;
        "mistral")
            install_ollama_model "mistral" "4.1GB"
            ;;
        "codellama")
            install_ollama_model "codellama" "3.8GB"
            ;;
        "phi3")
            install_ollama_model "phi3" "2.3GB"
            ;;
        "gemma2")
            install_ollama_model "gemma2" "5.4GB"
            ;;
        "qwen2.5")
            install_ollama_model "qwen2.5" "4.7GB"
            ;;
        "deepseek-v3")
            install_ollama_model "deepseek-v3" "Large"
            ;;
        *)
            error "Unknown model: $model_id"
            show_available_models
            return 1
            ;;
    esac
}

# Show available models
show_available_models() {
    echo -e "${BLUE}Available Ollama Models:${NC}"
    echo "  deepseek-r1-distill-llama  - DeepSeek R1 Distill Llama (8.5GB)"
    echo "  dolphin-llama3             - Dolphin Llama 3 (4.7GB)"
    echo "  llama3.2                   - Llama 3.2 (4.7GB)"
    echo "  mistral                    - Mistral 7B (4.1GB)"
    echo "  codellama                  - Code Llama (3.8GB)"
    echo "  phi3                       - Phi-3 Mini (2.3GB)"
    echo "  gemma2                     - Gemma 2 (5.4GB)"
    echo "  qwen2.5                    - Qwen 2.5 (4.7GB)"
    echo "  deepseek-v3                - DeepSeek V3 (Large)"
}

# Interactive model selection
interactive_install() {
    echo -e "${BLUE}Samantha AI Model Installer${NC}"
    echo "=================================="
    show_available_models
    echo ""
    read -p "Enter model ID to install (or 'list' to see installed models): " model_choice
    
    if [ "$model_choice" = "list" ]; then
        list_models
        return
    fi
    
    install_model "$model_choice"
}

# Main function
main() {
    log "Samantha AI Model Manager started"
    
    # Check prerequisites
    check_ollama
    
    # Parse command line arguments
    case "${1:-interactive}" in
        "install")
            if [ -z "$2" ]; then
                error "Please specify a model to install"
                show_available_models
                exit 1
            fi
            install_model "$2"
            ;;
        "remove")
            if [ -z "$2" ]; then
                error "Please specify a model to remove"
                exit 1
            fi
            remove_ollama_model "$2"
            ;;
        "list")
            list_models
            ;;
        "interactive"|"")
            interactive_install
            ;;
        "help"|"-h"|"--help")
            echo "Samantha AI Model Manager"
            echo ""
            echo "Usage: $0 [command] [model]"
            echo ""
            echo "Commands:"
            echo "  install [model]    Install a specific model"
            echo "  remove [model]     Remove a specific model"
            echo "  list              List installed models"
            echo "  interactive       Interactive model selection (default)"
            echo "  help              Show this help message"
            echo ""
            show_available_models
            ;;
        *)
            error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
    
    log "Model manager operation completed"
}

# Run main function with all arguments
main "$@"


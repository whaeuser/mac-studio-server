#!/bin/bash

# Configuration
USER=${OLLAMA_USER:-$(whoami)}
BASE_DIR=${OLLAMA_BASE_DIR:-"/Users/$USER/mac-studio-server"}
# GPU memory percentage (if set, enables GPU optimization)
GPU_PERCENT=${OLLAMA_GPU_PERCENT:-""}
LOG_FILE="$BASE_DIR/logs/install.log"

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Create necessary directories
log_action "Creating necessary directories..."
mkdir -p "$BASE_DIR/logs"
chmod 755 "$BASE_DIR/logs"
chown "$USER:staff" "$BASE_DIR/logs"

# Make scripts executable
log_action "Making scripts executable..."
chmod +x "$BASE_DIR/scripts/"*.sh

# Run optimization script
log_action "Running system optimization..."
"$BASE_DIR/scripts/optimize-mac-server.sh"

# Install launch daemon
log_action "Installing Ollama launch daemon..."
# Replace user in plist file
sed "s|<OLLAMA_USER>|$USER|g" "$BASE_DIR/config/com.ollama.service.plist" > "/tmp/com.ollama.service.plist"
sudo cp "/tmp/com.ollama.service.plist" /Library/LaunchDaemons/
rm "/tmp/com.ollama.service.plist"

sudo chown root:wheel /Library/LaunchDaemons/com.ollama.service.plist
sudo chmod 644 /Library/LaunchDaemons/com.ollama.service.plist

# Ensure Ollama directory exists with proper permissions
log_action "Setting up Ollama directory..."
mkdir -p "/Users/$USER/.ollama"
chown "$USER:staff" "/Users/$USER/.ollama"

# Load the launch daemon
log_action "Loading Ollama service..."
sudo launchctl unload /Library/LaunchDaemons/com.ollama.service.plist 2>/dev/null || true
sudo launchctl load -w /Library/LaunchDaemons/com.ollama.service.plist

# Install GPU memory optimization (if GPU_PERCENT is set)
if [ -n "$GPU_PERCENT" ]; then
    log_action "Installing GPU memory optimization (${GPU_PERCENT}%)..."
    chmod +x "$BASE_DIR/scripts/set-gpu-memory.sh"

    # Replace user in GPU memory plist file
    sed "s|<OLLAMA_USER>|$USER|g" "$BASE_DIR/config/com.ollama.gpumemory.plist" > "/tmp/com.ollama.gpumemory.plist"
    sudo cp "/tmp/com.ollama.gpumemory.plist" /Library/LaunchDaemons/
    rm "/tmp/com.ollama.gpumemory.plist"

    sudo chown root:wheel /Library/LaunchDaemons/com.ollama.gpumemory.plist
    sudo chmod 644 /Library/LaunchDaemons/com.ollama.gpumemory.plist

    # Load the GPU memory daemon
    log_action "Loading GPU memory optimization service..."
    sudo launchctl unload /Library/LaunchDaemons/com.ollama.gpumemory.plist 2>/dev/null || true
    sudo launchctl load -w /Library/LaunchDaemons/com.ollama.gpumemory.plist
    
    log_action "GPU memory optimization enabled (${GPU_PERCENT}%)"
else
    log_action "Skipping GPU memory optimization (set OLLAMA_GPU_PERCENT to enable, e.g. OLLAMA_GPU_PERCENT=80)"
fi

log_action "Installation completed" 
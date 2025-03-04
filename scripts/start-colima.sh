#!/bin/bash

# Get user and base directory from environment or use defaults
USER=${OLLAMA_USER:-$(whoami)}
BASE_DIR=${OLLAMA_BASE_DIR:-"/Users/$USER/mac-studio-server"}
LOG_FILE="$BASE_DIR/logs/docker.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Log function
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if Colima is installed
if ! command -v colima &>/dev/null; then
    log_action "ERROR: Colima is not installed. Please install it with: brew install colima"
    exit 1
fi

# Check if Docker CLI is installed
if ! command -v docker &>/dev/null; then
    log_action "ERROR: Docker CLI is not installed. Please install it with: brew install docker"
    exit 1
fi

# Check if Docker is already running
if docker info &>/dev/null; then
    log_action "Docker daemon is already running"
    exit 0
fi

# Start Colima
log_action "Starting Colima..."
colima start --cpu 4 --memory 8 --disk 50 --vm-type=vz --mount-type=virtiofs 2>&1 | tee -a "$LOG_FILE"

# Wait for Docker to become available
log_action "Waiting for Docker daemon to become available..."
for i in {1..60}; do
    if docker info &>/dev/null; then
        log_action "Docker daemon is now running via Colima"
        exit 0
    fi
    sleep 1
    if [ $((i % 10)) -eq 0 ]; then
        log_action "Still waiting for Docker daemon... ($i seconds elapsed)"
    fi
done

log_action "ERROR: Docker daemon did not start within the timeout period"
log_action "Try running: colima start"
exit 1 
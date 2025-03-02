#!/bin/bash

# Get user and base directory from environment or use defaults
USER=${OLLAMA_USER:-$(whoami)}
BASE_DIR=${OLLAMA_BASE_DIR:-"/Users/$USER/mac-studio-server"}
# Get GPU memory percentage (default 80%)
GPU_PERCENT=${OLLAMA_GPU_PERCENT:-80}
LOG_FILE="$BASE_DIR/logs/gpu-memory.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Log function
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Calculate percentage of total memory for GPU
TOTAL_MEM=$(sysctl hw.memsize | awk '{print $2}')
GPU_MEM=$((TOTAL_MEM / 1024 / 1024 * GPU_PERCENT / 100))

log_action "Setting GPU memory limit to ${GPU_MEM}MB (${GPU_PERCENT}% of total RAM)..."
sudo sysctl iogpu.wired_limit_mb=$GPU_MEM

log_action "GPU memory optimization completed" 
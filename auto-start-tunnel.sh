#!/bin/bash

# Auto-start tunnel on WSL startup
# This script runs automatically when WSL starts

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}🔄 $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    # Try to find the project directory
    if [ -d "/home/$(whoami)/workspace/manfree-moodle-platform" ]; then
        cd "/home/$(whoami)/workspace/manfree-moodle-platform"
    else
        echo "❌ Moodle project directory not found"
        exit 1
    fi
fi

# Check if Moodle containers are running
if docker ps | grep -q "manfree_moodle"; then
    log_info "Moodle containers detected running"
    
    # Check tunnel service
    if systemctl is-active cloudflared &>/dev/null; then
        log_success "Tunnel already running: https://learning.manfreetechnologies.com"
    else
        log_warning "Moodle running but tunnel stopped - fixing..."
        
        # Run health check to fix tunnel
        if [ -f "./global-access/permanent/tunnel-health-check.sh" ]; then
            ./global-access/permanent/tunnel-health-check.sh
        else
            log_warning "Health check script not found"
        fi
    fi
else
    log_info "Moodle containers not running - tunnel check skipped"
fi
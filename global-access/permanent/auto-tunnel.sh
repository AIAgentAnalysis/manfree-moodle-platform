#!/bin/bash

# Auto Tunnel - Integrated with Moodle Platform
# Automatically starts tunnel when Moodle starts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if tunnel service is installed
check_tunnel_service() {
    if systemctl is-enabled cloudflared &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Start tunnel service
start_tunnel_service() {
    if check_tunnel_service; then
        log_info "Starting Cloudflare tunnel service..."
        sudo systemctl start cloudflared
        
        # Wait for service to start
        sleep 3
        
        if systemctl is-active cloudflared &>/dev/null; then
            log_success "Tunnel service started successfully"
            
            # Show tunnel info
            if command -v cloudflared &>/dev/null; then
                TUNNEL_INFO=$(cloudflared tunnel list 2>/dev/null | grep "moodle-tunnel" || echo "")
                if [ -n "$TUNNEL_INFO" ]; then
                    log_success "Tunnel: learning.manfreetechnologies.com → localhost:8080"
                fi
            fi
        else
            log_warning "Tunnel service failed to start"
            return 1
        fi
    else
        log_warning "Tunnel service not installed. Run: ./global-access/permanent/cloudflare-permanent.sh"
        return 1
    fi
}

# Stop tunnel service
stop_tunnel_service() {
    if check_tunnel_service; then
        log_info "Stopping Cloudflare tunnel service..."
        sudo systemctl stop cloudflared
        log_success "Tunnel service stopped"
    fi
}

# Show tunnel status
show_tunnel_status() {
    if check_tunnel_service; then
        if systemctl is-active cloudflared &>/dev/null; then
            log_success "🌐 Global access: https://learning.manfreetechnologies.com"
            log_success "🏠 Local access: http://localhost:8080"
        else
            log_warning "Tunnel service is installed but not running"
            echo "   Start with: sudo systemctl start cloudflared"
        fi
    else
        log_warning "Tunnel service not installed"
        echo "   Setup with: ./global-access/permanent/cloudflare-permanent.sh"
    fi
}

# Main function
case "${1:-start}" in
    start)
        start_tunnel_service
        ;;
    stop)
        stop_tunnel_service
        ;;
    status)
        show_tunnel_status
        ;;
    restart)
        stop_tunnel_service
        sleep 2
        start_tunnel_service
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac
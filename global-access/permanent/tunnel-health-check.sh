#!/bin/bash

# Tunnel Health Check and Auto-Fix
# Called by up.sh to ensure tunnel is working properly

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Check and fix tunnel configuration
check_and_fix_tunnel() {
    log_info "Running tunnel health check..."
    
    # 1. Check if cloudflared is installed
    if ! command -v cloudflared &> /dev/null; then
        log_error "cloudflared not installed"
        return 1
    fi
    
    # 2. Check authentication
    if [ ! -f ~/.cloudflared/cert.pem ]; then
        log_error "Not authenticated with Cloudflare"
        echo "   Run: cloudflared tunnel login"
        return 1
    fi
    
    # 3. Check if tunnel exists
    if ! cloudflared tunnel list 2>/dev/null | grep -q "moodle-tunnel"; then
        log_warning "Tunnel doesn't exist, creating..."
        if ! cloudflared tunnel create moodle-tunnel; then
            log_error "Failed to create tunnel"
            return 1
        fi
    fi
    
    # 4. Get tunnel ID
    TUNNEL_ID=$(cloudflared tunnel list 2>/dev/null | grep "moodle-tunnel" | awk '{print $1}')
    if [ -z "$TUNNEL_ID" ]; then
        log_error "Could not get tunnel ID"
        return 1
    fi
    
    # 5. Check/create config file
    if [ ! -f ~/.cloudflared/config.yml ]; then
        log_warning "Config file missing, creating..."
        mkdir -p ~/.cloudflared
        cat > ~/.cloudflared/config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: /home/$(whoami)/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: learning.manfreetechnologies.com
    service: http://localhost:8080
  - service: http_status:404
EOF
    fi
    
    # 6. Validate config
    if ! cloudflared tunnel ingress validate 2>/dev/null; then
        log_warning "Invalid config, recreating..."
        cat > ~/.cloudflared/config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: /home/$(whoami)/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: learning.manfreetechnologies.com
    service: http://localhost:8080
  - service: http_status:404
EOF
    fi
    
    # 7. Check DNS record
    if ! nslookup learning.manfreetechnologies.com 2>/dev/null | grep -q "cfargotunnel"; then
        log_warning "DNS record missing, creating..."
        if ! cloudflared tunnel route dns moodle-tunnel learning.manfreetechnologies.com; then
            log_error "Failed to create DNS record"
            return 1
        fi
    fi
    
    # 8. Check/install service
    if ! systemctl list-unit-files | grep -q "cloudflared.service"; then
        log_warning "Service not installed, installing..."
        if ! sudo cloudflared --config ~/.cloudflared/config.yml service install; then
            log_error "Failed to install service"
            return 1
        fi
    fi
    
    # 9. Check service status and fix if needed
    if ! systemctl is-enabled cloudflared &>/dev/null; then
        log_warning "Service not enabled, enabling..."
        sudo systemctl enable cloudflared
    fi
    
    if ! systemctl is-active cloudflared &>/dev/null; then
        log_warning "Service not running, starting..."
        sudo systemctl start cloudflared
        sleep 5
    fi
    
    # 10. Final verification
    if systemctl is-active cloudflared &>/dev/null; then
        log_success "Tunnel service is running"
        
        # Test connectivity
        sleep 2
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://learning.manfreetechnologies.com 2>/dev/null || echo "000")
        if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "303" ]]; then
            log_success "Global access working (HTTP $HTTP_CODE)"
            return 0
        else
            log_warning "Global access issues (HTTP $HTTP_CODE) - may need DNS propagation time"
            return 0
        fi
    else
        log_error "Service failed to start"
        echo "   Check logs: sudo journalctl -u cloudflared -n 10"
        return 1
    fi
}

# Run the check
check_and_fix_tunnel
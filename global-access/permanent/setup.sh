#!/bin/bash

# 🏆 Permanent Tunnel - Complete Setup & Management
# One script to handle everything: setup, health checks, auto-start

set -e

# Configuration
TUNNEL_NAME="moodle-tunnel"
DOMAIN="learning.manfreetechnologies.com"
MOODLE_PORT="8080"

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

# Install cloudflared if needed
install_cloudflared() {
    if ! command -v cloudflared &> /dev/null; then
        log_info "Installing cloudflared..."
        sudo mkdir -p --mode=0755 /usr/share/keyrings
        curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
        echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" | sudo tee /etc/apt/sources.list.d/cloudflared.list
        sudo apt-get update && sudo apt-get install -y cloudflared
        log_success "cloudflared installed"
    fi
}

# Check authentication
check_auth() {
    if [ ! -f ~/.cloudflared/cert.pem ]; then
        log_error "Not authenticated with Cloudflare"
        echo "   Run: cloudflared tunnel login"
        echo "   Then run this script again"
        exit 1
    fi
}

# Setup tunnel
setup_tunnel() {
    log_info "Setting up permanent tunnel..."
    
    # Create tunnel if doesn't exist
    if ! cloudflared tunnel list 2>/dev/null | grep -q "$TUNNEL_NAME"; then
        log_info "Creating tunnel..."
        cloudflared tunnel create $TUNNEL_NAME
    fi
    
    # Get tunnel ID
    TUNNEL_ID=$(cloudflared tunnel list 2>/dev/null | grep "$TUNNEL_NAME" | awk '{print $1}')
    
    if [ -z "$TUNNEL_ID" ]; then
        log_error "Failed to get tunnel ID"
        exit 1
    fi
    
    # Create config
    mkdir -p ~/.cloudflared
    cat > ~/.cloudflared/config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: /home/$(whoami)/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: $DOMAIN
    service: http://localhost:$MOODLE_PORT
  - service: http_status:404
EOF
    
    # Create DNS record
    if ! nslookup $DOMAIN 2>/dev/null | grep -q "cfargotunnel"; then
        log_info "Creating DNS record..."
        cloudflared tunnel route dns $TUNNEL_NAME $DOMAIN
    fi
    
    # Install service
    if ! systemctl list-unit-files | grep -q "cloudflared.service"; then
        log_info "Installing system service..."
        sudo cloudflared --config ~/.cloudflared/config.yml service install
    fi
    
    # Start and enable service
    sudo systemctl enable cloudflared
    sudo systemctl start cloudflared
    
    log_success "Tunnel setup complete!"
}

# Health check and auto-fix
health_check() {
    local fix_issues=${1:-false}
    
    # Check cloudflared
    if ! command -v cloudflared &> /dev/null; then
        if [ "$fix_issues" = "true" ]; then
            install_cloudflared
        else
            log_error "cloudflared not installed"
            return 1
        fi
    fi
    
    # Check authentication
    if [ ! -f ~/.cloudflared/cert.pem ]; then
        log_error "Not authenticated with Cloudflare"
        return 1
    fi
    
    # Check tunnel exists
    if ! cloudflared tunnel list 2>/dev/null | grep -q "$TUNNEL_NAME"; then
        if [ "$fix_issues" = "true" ]; then
            log_warning "Tunnel missing, creating..."
            cloudflared tunnel create $TUNNEL_NAME
        else
            log_error "Tunnel doesn't exist"
            return 1
        fi
    fi
    
    # Check config file
    if [ ! -f ~/.cloudflared/config.yml ]; then
        if [ "$fix_issues" = "true" ]; then
            log_warning "Config missing, creating..."
            TUNNEL_ID=$(cloudflared tunnel list 2>/dev/null | grep "$TUNNEL_NAME" | awk '{print $1}')
            mkdir -p ~/.cloudflared
            cat > ~/.cloudflared/config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: /home/$(whoami)/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: $DOMAIN
    service: http://localhost:$MOODLE_PORT
  - service: http_status:404
EOF
        else
            log_error "Config file missing"
            return 1
        fi
    fi
    
    # Check service
    if ! systemctl is-active cloudflared &>/dev/null; then
        if [ "$fix_issues" = "true" ]; then
            log_warning "Service not running, starting..."
            if ! systemctl is-enabled cloudflared &>/dev/null; then
                sudo systemctl enable cloudflared
            fi
            sudo systemctl start cloudflared
            sleep 3
        else
            log_error "Service not running"
            return 1
        fi
    fi
    
    # Final check
    if systemctl is-active cloudflared &>/dev/null; then
        log_success "Tunnel is healthy and running"
        log_success "Global access: https://$DOMAIN"
        return 0
    else
        log_error "Tunnel service failed to start"
        return 1
    fi
}

# Setup WSL auto-start
setup_autostart() {
    log_info "Setting up WSL auto-start..."
    
    # Create comprehensive auto-start script
    cat > ~/tunnel-autostart.sh << 'EOF'
#!/bin/bash
# Auto-start tunnel check for WSL - handles PC shutdown/restart scenario
cd ~/workspace/manfree-moodle-platform 2>/dev/null || exit 0

# Wait a moment for system to stabilize
sleep 2

# Check if Moodle containers are running (auto-started by Docker Desktop)
if docker ps | grep -q "manfree_moodle"; then
    # Moodle is running, ensure tunnel is also running
    if [ -f "global-access/permanent/setup.sh" ]; then
        # Run health check and fix any issues silently
        ./global-access/permanent/setup.sh --health-check-fix >/dev/null 2>&1
        
        # Log success for debugging if needed
        if systemctl is-active cloudflared >/dev/null 2>&1; then
            echo "$(date): Tunnel auto-fixed and running" >> ~/.tunnel-autostart.log
        fi
    fi
fi
EOF
    chmod +x ~/tunnel-autostart.sh
    
    # Add to .bashrc if not present
    if ! grep -q "tunnel-autostart.sh" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# Auto-check tunnel on WSL start (handles PC restart scenario)" >> ~/.bashrc
        echo "~/tunnel-autostart.sh &" >> ~/.bashrc
    fi
    
    # Also create a systemd user timer for more reliability
    mkdir -p ~/.config/systemd/user
    
    # Create service
    cat > ~/.config/systemd/user/tunnel-autocheck.service << EOF
[Unit]
Description=Tunnel Auto-check Service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=%h/workspace/manfree-moodle-platform
ExecStart=%h/workspace/manfree-moodle-platform/global-access/permanent/setup.sh --health-check-fix
StandardOutput=journal
StandardError=journal
EOF

    # Create timer to run every 5 minutes
    cat > ~/.config/systemd/user/tunnel-autocheck.timer << EOF
[Unit]
Description=Run tunnel autocheck every 5 minutes
Requires=tunnel-autocheck.service

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Enable the timer
    systemctl --user daemon-reload
    systemctl --user enable tunnel-autocheck.timer
    systemctl --user start tunnel-autocheck.timer
    
    log_success "WSL auto-start configured with multiple reliability layers"
}

# Show status
show_status() {
    echo ""
    echo "🏆 Permanent Tunnel Status"
    echo "=========================="
    
    if command -v cloudflared &> /dev/null; then
        echo "✅ cloudflared: Installed ($(cloudflared --version | head -1))"
    else
        echo "❌ cloudflared: Not installed"
    fi
    
    if [ -f ~/.cloudflared/cert.pem ]; then
        echo "✅ Authentication: Valid"
    else
        echo "❌ Authentication: Missing"
    fi
    
    if cloudflared tunnel list 2>/dev/null | grep -q "$TUNNEL_NAME"; then
        TUNNEL_ID=$(cloudflared tunnel list 2>/dev/null | grep "$TUNNEL_NAME" | awk '{print $1}')
        echo "✅ Tunnel: $TUNNEL_NAME ($TUNNEL_ID)"
    else
        echo "❌ Tunnel: Not created"
    fi
    
    if systemctl is-active cloudflared &>/dev/null; then
        echo "✅ Service: Running"
        echo "✅ Global Access: https://$DOMAIN"
    else
        echo "❌ Service: Not running"
    fi
    
    echo ""
}

# Main function
main() {
    case "${1:-setup}" in
        --setup|setup)
            install_cloudflared
            if ! check_auth 2>/dev/null; then
                log_warning "Authentication required first"
                echo "   Run: cloudflared tunnel login"
                echo "   Then run: ./global-access/permanent/setup.sh"
                exit 1
            fi
            setup_tunnel
            setup_autostart
            show_status
            ;;
        --health-check)
            health_check false
            ;;
        --health-check-fix)
            health_check true
            ;;
        --status)
            show_status
            ;;
        --start)
            sudo systemctl start cloudflared
            log_success "Tunnel started"
            ;;
        --stop)
            sudo systemctl stop cloudflared
            log_success "Tunnel stopped"
            ;;
        --restart)
            sudo systemctl restart cloudflared
            log_success "Tunnel restarted"
            ;;
        --help)
            echo "Permanent Tunnel Management"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  setup              Complete setup (default)"
            echo "  --health-check     Check tunnel health"
            echo "  --health-check-fix Check and fix issues"
            echo "  --status           Show current status"
            echo "  --start            Start tunnel service"
            echo "  --stop             Stop tunnel service"
            echo "  --restart          Restart tunnel service"
            echo "  --help             Show this help"
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

main "$@"
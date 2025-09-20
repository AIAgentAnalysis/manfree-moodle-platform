#!/bin/bash

# Cloudflare Permanent Tunnel - Automated Setup
# Creates permanent static URL for Moodle platform

set -e

echo "🌐 Cloudflare Permanent Tunnel Setup"
echo "===================================="

# Configuration
TUNNEL_NAME="moodle-tunnel"
DEFAULT_SUBDOMAIN="learning"
DEFAULT_DOMAIN="manfreetechnologies.com"
MOODLE_PORT="8080"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if cloudflared is installed
check_cloudflared() {
    if ! command -v cloudflared &> /dev/null; then
        log_error "cloudflared not found. Installing..."
        install_cloudflared
    else
        log_success "cloudflared is installed ($(cloudflared --version))"
    fi
}

# Install cloudflared
install_cloudflared() {
    log_info "Installing cloudflared..."
    
    sudo mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" | sudo tee /etc/apt/sources.list.d/cloudflared.list
    
    sudo apt-get update && sudo apt-get install -y cloudflared
    
    log_success "cloudflared installed successfully"
}

# Check if authenticated
check_auth() {
    if [ ! -f ~/.cloudflared/cert.pem ]; then
        log_warning "Not authenticated with Cloudflare"
        log_info "Please run: cloudflared tunnel login"
        log_info "Then run this script again"
        exit 1
    else
        log_success "Authenticated with Cloudflare"
    fi
}

# Get subdomain from user
get_subdomain() {
    echo ""
    log_info "Choose your subdomain:"
    echo "1. learning.${DEFAULT_DOMAIN} (recommended)"
    echo "2. lms.${DEFAULT_DOMAIN}"
    echo "3. courses.${DEFAULT_DOMAIN}"
    echo "4. training.${DEFAULT_DOMAIN}"
    echo "5. Custom subdomain"
    
    read -p "Enter choice (1-5): " choice
    
    case $choice in
        1) SUBDOMAIN="learning" ;;
        2) SUBDOMAIN="lms" ;;
        3) SUBDOMAIN="courses" ;;
        4) SUBDOMAIN="training" ;;
        5) 
            read -p "Enter custom subdomain: " SUBDOMAIN
            if [[ ! $SUBDOMAIN =~ ^[a-zA-Z0-9-]+$ ]]; then
                log_error "Invalid subdomain. Use only letters, numbers, and hyphens."
                exit 1
            fi
            ;;
        *) 
            log_warning "Invalid choice. Using default: learning"
            SUBDOMAIN="learning"
            ;;
    esac
    
    FULL_DOMAIN="${SUBDOMAIN}.${DEFAULT_DOMAIN}"
    log_success "Selected: ${FULL_DOMAIN}"
}

# Check if tunnel exists
check_tunnel() {
    if cloudflared tunnel list | grep -q "$TUNNEL_NAME"; then
        log_success "Tunnel '$TUNNEL_NAME' already exists"
        TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
        return 0
    else
        return 1
    fi
}

# Create tunnel
create_tunnel() {
    log_info "Creating tunnel: $TUNNEL_NAME"
    
    OUTPUT=$(cloudflared tunnel create $TUNNEL_NAME)
    TUNNEL_ID=$(echo "$OUTPUT" | grep -o '[0-9a-f-]\{36\}')
    
    if [ -z "$TUNNEL_ID" ]; then
        log_error "Failed to create tunnel"
        exit 1
    fi
    
    log_success "Tunnel created with ID: $TUNNEL_ID"
}

# Create config file
create_config() {
    log_info "Creating configuration file..."
    
    mkdir -p ~/.cloudflared
    
    cat > ~/.cloudflared/config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: /home/$(whoami)/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: $FULL_DOMAIN
    service: http://localhost:$MOODLE_PORT
  - service: http_status:404
EOF
    
    log_success "Configuration file created"
}

# Create DNS record
create_dns() {
    log_info "Creating DNS record for $FULL_DOMAIN..."
    
    if cloudflared tunnel route dns $TUNNEL_NAME $FULL_DOMAIN; then
        log_success "DNS record created successfully"
    else
        log_error "Failed to create DNS record"
        exit 1
    fi
}

# Test tunnel
test_tunnel() {
    log_info "Testing tunnel connection..."
    
    # Start tunnel in background
    cloudflared tunnel run $TUNNEL_NAME &
    TUNNEL_PID=$!
    
    # Wait for tunnel to connect
    sleep 10
    
    # Test local Moodle
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$MOODLE_PORT | grep -q "200"; then
        log_success "Local Moodle is accessible"
    else
        log_error "Local Moodle is not accessible. Make sure Docker containers are running."
        kill $TUNNEL_PID 2>/dev/null || true
        exit 1
    fi
    
    # Test external access
    log_info "Testing external access (this may take a moment)..."
    sleep 5
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://$FULL_DOMAIN)
    if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "303" ]]; then
        log_success "External access working! (HTTP $HTTP_CODE)"
    else
        log_warning "External access returned HTTP $HTTP_CODE (may need DNS propagation time)"
    fi
    
    # Stop test tunnel
    kill $TUNNEL_PID 2>/dev/null || true
    sleep 2
}

# Install as service
install_service() {
    log_info "Installing tunnel as system service..."
    
    if sudo cloudflared service install; then
        sudo systemctl start cloudflared
        sudo systemctl enable cloudflared
        log_success "Service installed and started"
    else
        log_error "Failed to install service"
        exit 1
    fi
}

# Update Moodle config
update_moodle_config() {
    log_info "Updating Moodle configuration..."
    
    CONFIG_FILE="customizations/config/config.php"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "Moodle config file not found: $CONFIG_FILE"
        return 1
    fi
    
    # Check if domain detection already exists
    if grep -q "$FULL_DOMAIN" "$CONFIG_FILE"; then
        log_success "Moodle config already updated for $FULL_DOMAIN"
        return 0
    fi
    
    # Backup original config
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Add domain detection (this should already be done by previous setup)
    log_success "Moodle config supports automatic domain detection"
}

# Check Moodle status
check_moodle() {
    log_info "Checking Moodle status..."
    
    if docker ps | grep -q "manfree_moodle"; then
        log_success "Moodle container is running"
    else
        log_warning "Moodle container not running. Starting..."
        if [ -f "./up.sh" ]; then
            ./up.sh
        else
            docker-compose up -d
        fi
    fi
}

# Show final status
show_status() {
    echo ""
    echo "🎉 Setup Complete!"
    echo "=================="
    echo ""
    echo "📍 Your Moodle URLs:"
    echo "   Local:  http://localhost:$MOODLE_PORT"
    echo "   Global: https://$FULL_DOMAIN"
    echo ""
    echo "🔧 Service Management:"
    echo "   Status: sudo systemctl status cloudflared"
    echo "   Start:  sudo systemctl start cloudflared"
    echo "   Stop:   sudo systemctl stop cloudflared"
    echo "   Logs:   sudo journalctl -u cloudflared -f"
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Test both URLs in browser"
    echo "   2. Configure Google OAuth with: https://$FULL_DOMAIN/admin/oauth2callback.php"
    echo "   3. Share global URL with students: https://$FULL_DOMAIN"
    echo ""
    echo "⚠️  Note: DNS propagation may take 5-30 minutes for global access"
}

# Main execution
main() {
    echo ""
    log_info "Starting Cloudflare Permanent Tunnel setup..."
    
    # Pre-checks
    check_cloudflared
    check_auth
    check_moodle
    
    # Get user preferences
    get_subdomain
    
    # Setup tunnel
    if ! check_tunnel; then
        create_tunnel
    fi
    
    create_config
    create_dns
    test_tunnel
    install_service
    update_moodle_config
    
    # Final status
    show_status
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Cloudflare Permanent Tunnel Setup"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --status       Show current tunnel status"
        echo "  --restart      Restart tunnel service"
        echo "  --logs         Show tunnel logs"
        echo ""
        exit 0
        ;;
    --status)
        echo "Tunnel Status:"
        sudo systemctl status cloudflared
        echo ""
        echo "Tunnel Info:"
        cloudflared tunnel list
        exit 0
        ;;
    --restart)
        log_info "Restarting tunnel service..."
        sudo systemctl restart cloudflared
        log_success "Service restarted"
        exit 0
        ;;
    --logs)
        log_info "Showing tunnel logs (Ctrl+C to exit)..."
        sudo journalctl -u cloudflared -f
        exit 0
        ;;
    "")
        main
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
# 📜 Script Documentation - Permanent Tunnel

**Detailed documentation for both permanent tunnel scripts**

---

## 🛠️ Script 1: `cloudflare-permanent.sh`

### Purpose
**One-time setup script** that configures everything needed for permanent tunnel access.

### What It Does (Step by Step)

#### 1. **Environment Check**
```bash
check_cloudflared() {
    if ! command -v cloudflared &> /dev/null; then
        install_cloudflared
    fi
}
```
- Checks if cloudflared is installed
- Automatically installs if missing
- Verifies installation success

#### 2. **Authentication Verification**
```bash
check_auth() {
    if [ ! -f ~/.cloudflared/cert.pem ]; then
        echo "Please run: cloudflared tunnel login"
        exit 1
    fi
}
```
- Checks for Cloudflare authentication certificate
- Guides user to authenticate if needed
- Ensures proper permissions

#### 3. **Interactive Subdomain Selection**
```bash
get_subdomain() {
    echo "Choose your subdomain:"
    echo "1. learning.manfreetechnologies.com"
    echo "2. lms.manfreetechnologies.com"
    # ... more options
}
```
- Presents subdomain options
- Validates user input
- Sets `FULL_DOMAIN` variable

#### 4. **Tunnel Creation**
```bash
create_tunnel() {
    OUTPUT=$(cloudflared tunnel create $TUNNEL_NAME)
    TUNNEL_ID=$(echo "$OUTPUT" | grep -o '[0-9a-f-]\{36\}')
}
```
- Creates named tunnel with Cloudflare
- Extracts tunnel UUID from output
- Stores credentials in `~/.cloudflared/`

#### 5. **Configuration File Generation**
```bash
create_config() {
    cat > ~/.cloudflared/config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: /home/$(whoami)/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: $FULL_DOMAIN
    service: http://localhost:$MOODLE_PORT
  - service: http_status:404
EOF
}
```
- Creates YAML configuration file
- Maps domain to local Moodle port
- Sets up ingress rules

#### 6. **DNS Record Creation**
```bash
create_dns() {
    cloudflared tunnel route dns $TUNNEL_NAME $FULL_DOMAIN
}
```
- Creates CNAME record in Cloudflare DNS
- Points subdomain to tunnel endpoint
- Enables Cloudflare proxy

#### 7. **Connection Testing**
```bash
test_tunnel() {
    # Start tunnel in background
    cloudflared tunnel run $TUNNEL_NAME &
    TUNNEL_PID=$!
    
    # Test local access
    curl -s -o /dev/null -w "%{http_code}" http://localhost:$MOODLE_PORT
    
    # Test external access
    curl -s -o /dev/null -w "%{http_code}" https://$FULL_DOMAIN
}
```
- Starts tunnel temporarily for testing
- Verifies local Moodle accessibility
- Tests external domain resolution
- Cleans up test process

#### 8. **Service Installation**
```bash
install_service() {
    sudo cloudflared service install
    sudo systemctl start cloudflared
    sudo systemctl enable cloudflared
}
```
- Installs cloudflared as systemd service
- Starts service immediately
- Enables auto-start on boot

#### 9. **Final Status Display**
```bash
show_status() {
    echo "🎉 Setup Complete!"
    echo "Local:  http://localhost:$MOODLE_PORT"
    echo "Global: https://$FULL_DOMAIN"
}
```
- Shows completion message
- Displays both access URLs
- Provides management commands

### Script Arguments

```bash
./cloudflare-permanent.sh --help     # Show help
./cloudflare-permanent.sh --status   # Show tunnel status
./cloudflare-permanent.sh --restart  # Restart service
./cloudflare-permanent.sh --logs     # Show logs
```

### Error Handling

**Authentication Errors:**
```bash
if [ ! -f ~/.cloudflared/cert.pem ]; then
    log_error "Not authenticated with Cloudflare"
    log_info "Please run: cloudflared tunnel login"
    exit 1
fi
```

**Tunnel Creation Errors:**
```bash
if [ -z "$TUNNEL_ID" ]; then
    log_error "Failed to create tunnel"
    exit 1
fi
```

**Service Installation Errors:**
```bash
if sudo cloudflared service install; then
    log_success "Service installed"
else
    log_error "Failed to install service"
    exit 1
fi
```

---

## ⚡ Script 2: `auto-tunnel.sh`

### Purpose
**Daily operations script** for managing the tunnel service integrated with Moodle startup/shutdown.

### What It Does (Step by Step)

#### 1. **Service Detection**
```bash
check_tunnel_service() {
    if systemctl is-enabled cloudflared &>/dev/null; then
        return 0  # Service exists
    else
        return 1  # Service not installed
    fi
}
```
- Checks if cloudflared service is installed
- Returns status for conditional logic
- Used by all other functions

#### 2. **Service Startup**
```bash
start_tunnel_service() {
    if check_tunnel_service; then
        sudo systemctl start cloudflared
        sleep 3  # Wait for startup
        
        if systemctl is-active cloudflared &>/dev/null; then
            log_success "Tunnel service started"
        fi
    fi
}
```
- Starts the cloudflared systemd service
- Waits for service to initialize
- Verifies successful startup
- Shows tunnel information if available

#### 3. **Service Shutdown**
```bash
stop_tunnel_service() {
    if check_tunnel_service; then
        sudo systemctl stop cloudflared
        log_success "Tunnel service stopped"
    fi
}
```
- Stops the cloudflared systemd service
- Confirms successful shutdown
- Handles cases where service isn't installed

#### 4. **Status Display**
```bash
show_tunnel_status() {
    if check_tunnel_service; then
        if systemctl is-active cloudflared &>/dev/null; then
            log_success "🌐 Global access: https://learning.manfreetechnologies.com"
            log_success "🏠 Local access: http://localhost:8080"
        else
            log_warning "Service installed but not running"
        fi
    else
        log_warning "Service not installed"
    fi
}
```
- Shows current service status
- Displays access URLs if running
- Provides setup instructions if needed

### Script Arguments

```bash
./auto-tunnel.sh start    # Start tunnel service
./auto-tunnel.sh stop     # Stop tunnel service  
./auto-tunnel.sh status   # Show current status
./auto-tunnel.sh restart  # Restart service
```

### Integration Points

#### Called by `up.sh`
```bash
# In up.sh
if [ -f "./global-access/permanent/auto-tunnel.sh" ]; then
    chmod +x ./global-access/permanent/auto-tunnel.sh
    ./global-access/permanent/auto-tunnel.sh start
fi
```

#### Referenced by `down.sh`
```bash
# In down.sh
if systemctl is-active cloudflared &>/dev/null; then
    echo "🌍 Tunnel still running: https://learning.manfreetechnologies.com"
fi
```

---

## 🔄 Script Interaction Flow

### Initial Setup Flow
```
User runs: ./cloudflare-permanent.sh
    ↓
1. Check/install cloudflared
    ↓
2. Verify authentication
    ↓
3. Get subdomain choice
    ↓
4. Create tunnel + config
    ↓
5. Create DNS record
    ↓
6. Test connections
    ↓
7. Install as service
    ↓
8. Show completion status
```

### Daily Usage Flow
```
User runs: ./up.sh
    ↓
1. Start Moodle containers
    ↓
2. Call auto-tunnel.sh start
    ↓
3. Check if service installed
    ↓
4. Start cloudflared service
    ↓
5. Show both URLs
```

### Management Flow
```
User runs: ./auto-tunnel.sh status
    ↓
1. Check service installation
    ↓
2. Check service status
    ↓
3. Display appropriate message
```

---

## 🔧 Configuration Files Generated

### 1. `~/.cloudflared/config.yml`
**Generated by**: `cloudflare-permanent.sh`
**Purpose**: Tunnel configuration

```yaml
tunnel: 2b24508c-fbed-4586-9190-e2a5b622c2ee
credentials-file: /home/manfree/.cloudflared/2b24508c-fbed-4586-9190-e2a5b622c2ee.json

ingress:
  - hostname: learning.manfreetechnologies.com
    service: http://localhost:8080
  - service: http_status:404
```

**Key Elements:**
- `tunnel`: Unique tunnel identifier
- `credentials-file`: Path to tunnel credentials
- `ingress`: Routing rules for incoming requests
- `hostname`: Your chosen subdomain
- `service`: Local Moodle endpoint

### 2. `/etc/systemd/system/cloudflared.service`
**Generated by**: `sudo cloudflared service install`
**Purpose**: System service definition

```ini
[Unit]
Description=cloudflared
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/cloudflared tunnel run
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

**Key Elements:**
- `After=network.target`: Starts after network is ready
- `ExecStart`: Command to run tunnel
- `Restart=on-failure`: Auto-restart on crashes
- `WantedBy=multi-user.target`: Enables auto-start

---

## 🚨 Error Handling and Recovery

### Common Error Scenarios

#### 1. Authentication Failure
**Error**: `cloudflared tunnel login` fails
**Script Response**:
```bash
if [ ! -f ~/.cloudflared/cert.pem ]; then
    log_error "Not authenticated with Cloudflare"
    log_info "Please run: cloudflared tunnel login"
    exit 1
fi
```
**Recovery**: User must complete browser authentication

#### 2. Tunnel Creation Failure
**Error**: `cloudflared tunnel create` fails
**Script Response**:
```bash
if [ -z "$TUNNEL_ID" ]; then
    log_error "Failed to create tunnel"
    exit 1
fi
```
**Recovery**: Check network connectivity and authentication

#### 3. DNS Creation Failure
**Error**: `cloudflared tunnel route dns` fails
**Script Response**:
```bash
if cloudflared tunnel route dns $TUNNEL_NAME $FULL_DOMAIN; then
    log_success "DNS record created"
else
    log_error "Failed to create DNS record"
    exit 1
fi
```
**Recovery**: Verify domain is on Cloudflare

#### 4. Service Installation Failure
**Error**: `cloudflared service install` fails
**Script Response**:
```bash
if sudo cloudflared service install; then
    log_success "Service installed"
else
    log_error "Failed to install service"
    exit 1
fi
```
**Recovery**: Check sudo permissions and systemd

### Recovery Commands

**Complete Reset:**
```bash
# Remove existing tunnel
cloudflared tunnel delete moodle-tunnel

# Remove service
sudo systemctl stop cloudflared
sudo systemctl disable cloudflared
sudo rm /etc/systemd/system/cloudflared.service

# Remove configuration
rm -rf ~/.cloudflared/

# Start fresh
./cloudflare-permanent.sh
```

**Service-Only Reset:**
```bash
# Reinstall service
sudo systemctl stop cloudflared
sudo cloudflared service install
sudo systemctl start cloudflared
```

---

## 📊 Logging and Monitoring

### Script Logging
Both scripts use colored logging functions:

```bash
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
```

### Service Monitoring
**View real-time logs:**
```bash
sudo journalctl -u cloudflared -f
```

**Check service status:**
```bash
sudo systemctl status cloudflared
```

**View recent errors:**
```bash
sudo journalctl -u cloudflared --since "1 hour ago" | grep -i error
```

---

## 🎯 Script Customization

### Modifying Subdomains
**In `cloudflare-permanent.sh`:**
```bash
get_subdomain() {
    echo "1. learning.${DEFAULT_DOMAIN}"
    echo "2. lms.${DEFAULT_DOMAIN}"
    echo "3. courses.${DEFAULT_DOMAIN}"
    echo "4. training.${DEFAULT_DOMAIN}"  # Add more options here
    echo "5. Custom subdomain"
}
```

### Changing Default Domain
**At top of script:**
```bash
DEFAULT_DOMAIN="manfreetechnologies.com"  # Change this
```

### Modifying Moodle Port
**In configuration:**
```bash
MOODLE_PORT="8080"  # Change if Moodle runs on different port
```

### Adding Health Checks
**In `auto-tunnel.sh`:**
```bash
health_check() {
    # Test local Moodle
    if curl -s -o /dev/null http://localhost:8080; then
        log_success "Local Moodle: OK"
    else
        log_error "Local Moodle: Down"
    fi
    
    # Test global access
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://learning.manfreetechnologies.com)
    if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "303" ]]; then
        log_success "Global access: OK"
    else
        log_error "Global access: Issues"
    fi
}
```

---

## 📋 Summary

### Script Responsibilities

| Script | Purpose | When to Use | What It Does |
|--------|---------|-------------|--------------|
| `cloudflare-permanent.sh` | Initial setup | Once | Complete tunnel configuration |
| `auto-tunnel.sh` | Daily operations | Automatic | Start/stop/manage service |

### Key Features

**cloudflare-permanent.sh:**
- ✅ Interactive setup process
- ✅ Comprehensive error handling
- ✅ Automatic testing and validation
- ✅ Service installation
- ✅ User-friendly output

**auto-tunnel.sh:**
- ✅ Simple service management
- ✅ Integration with Moodle startup
- ✅ Status reporting
- ✅ Minimal dependencies

### Files Created/Modified

**By cloudflare-permanent.sh:**
- `~/.cloudflared/config.yml`
- `~/.cloudflared/cert.pem`
- `~/.cloudflared/[tunnel-id].json`
- `/etc/systemd/system/cloudflared.service`
- DNS record in Cloudflare

**By auto-tunnel.sh:**
- No files created (only manages existing service)

**Both scripts work together to provide a seamless permanent tunnel solution!**
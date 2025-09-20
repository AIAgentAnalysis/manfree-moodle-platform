# 🛠️ Tunnel Installation & Usage Guide

Complete installation and usage instructions for all tunneling solutions.

## 1. Bore.pub ⭐ (Recommended - No Payment Risk)

### Installation
```bash
# Download bore binary
curl -L https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz | tar xz
chmod +x bore
```

### Usage
```bash
# Start tunnel
./bore local 8080 --to bore.pub

# Output example:
# 2025-09-20T07:30:00Z [INFO] listening at bore.pub:12345
# Your URL: https://bore.pub:12345
```

### Features
- ✅ **No Account Required**: Works immediately
- ✅ **No Payment Risk**: Completely free
- ✅ **Reliable**: Stable connections
- ✅ **Fast Setup**: 30 seconds to start

---

## 2. Cloudflare Tunnel (Enterprise Grade)

### Installation
```bash
# Download and install cloudflared
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
rm cloudflared-linux-amd64.deb
```

### Usage
```bash
# Start quick tunnel (no account needed)
cloudflared tunnel --url http://localhost:8080

# Output example:
# Your quick Tunnel has been created! Visit it at:
# https://abc-def-ghi.trycloudflare.com
```

### Features
- ✅ **Enterprise Infrastructure**: Cloudflare's global network
- ✅ **Automatic HTTPS**: SSL certificates included
- ✅ **No Account Required**: For quick tunnels
- ✅ **High Performance**: Fast global access

---

## 3. Ngrok (Popular Choice)

### Installation
```bash
# Method 1: Official repository
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install ngrok

# Method 2: Direct download
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar xvzf ngrok-v3-stable-linux-amd64.tgz
sudo mv ngrok /usr/local/bin
```

### Account Setup (Optional for 2hr sessions)
```bash
# 1. Create account at https://dashboard.ngrok.com/signup
# 2. Get authtoken from https://dashboard.ngrok.com/get-started/your-authtoken
# 3. Configure authtoken
ngrok config add-authtoken YOUR_AUTHTOKEN_HERE
```

### Usage
```bash
# Start tunnel
ngrok http 8080

# Output example:
# Session Status: online
# Forwarding: https://abc123.ngrok-free.app -> http://localhost:8080
```

### Features
- ✅ **Well-Known Service**: Widely used and trusted
- ✅ **Automatic HTTPS**: SSL certificates included
- ✅ **Traffic Inspection**: Web interface at http://127.0.0.1:4040
- ⚠️ **Time Limit**: 2 hours per session (free tier)

---

## 4. Pinggy.io (SSH-Based)

### Installation
```bash
# No installation required - uses SSH
# SSH client must be installed (usually pre-installed on Linux)
```

### Usage
```bash
# Start tunnel
ssh -p 443 -R0:localhost:8080 a.pinggy.io

# Output example:
# Your URL: https://randomstring.a.pinggy.io
```

### Features
- ✅ **No Installation**: Uses built-in SSH
- ✅ **Quick Setup**: One command to start
- ⚠️ **Session Limit**: 60 minutes per session
- ⚠️ **Random URLs**: Changes each time

---

## 5. LocalTunnel (Node.js Based)

### Installation
```bash
# Install Node.js first
sudo apt update
sudo apt install nodejs npm

# Install localtunnel globally
sudo npm install -g localtunnel
```

### Usage
```bash
# Start tunnel with custom subdomain
lt --port 8080 --subdomain manfree-moodle

# Output example:
# your url is: https://manfree-moodle.loca.lt
```

### Features
- ✅ **Custom Subdomains**: Choose your own URL
- ✅ **Unlimited Usage**: No time limits
- ⚠️ **Requires Node.js**: Additional dependency
- ⚠️ **Less Reliable**: Can have connection issues

---

## 6. Serveo (Local SSH Only)

### Installation
```bash
# No installation required - uses SSH
```

### Usage
```bash
# Start tunnel
ssh -R 80:localhost:8080 serveo.net

# Output example:
# Forwarding HTTP traffic from https://randomstring.serveo.net
```

### Features
- ✅ **No Installation**: Uses built-in SSH
- ✅ **Simple**: One command setup
- ❌ **Local Only**: Only works from admin PC, not for students
- ❌ **Not Recommended**: Limited functionality

---

## 🔧 Platform Auto-Configuration

### Smart URL Detection
Your Moodle platform automatically detects tunnel URLs and configures itself:

```php
// In customizations/config/config.php
if (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'ngrok') !== false) {
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
    $CFG->sslproxy = true;
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
} elseif (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'trycloudflare') !== false) {
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
    $CFG->sslproxy = true;
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
} elseif (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'bore.pub') !== false) {
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
    $CFG->sslproxy = true;
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
} else {
    $CFG->wwwroot = 'http://localhost:8080';
}
```

### What This Means
- ✅ **Automatic HTTPS**: Platform detects tunnel and enables SSL
- ✅ **No Manual Config**: URLs update automatically
- ✅ **Multiple Tunnels**: Supports all tunnel services
- ✅ **Fallback**: Works locally if no tunnel detected

---

## 🚀 Quick Start Workflow

### 1. Start Your Platform
```bash
./up.sh
```

### 2. Choose Your Tunnel
```bash
cd tunneling

# Recommended (no payment risk)
./bore-tunnel.sh

# OR Enterprise grade
./cloudflare-tunnel.sh

# OR Popular choice (2hr limit)
./ngrok-tunnel.sh

# OR SSH-based (60min limit)
./pinggy-tunnel.sh

# OR Node.js based
./localtunnel.sh
```

### 3. Share URL with Students
Copy the URL from tunnel output and share with students.

### 4. Monitor Access
- **Ngrok**: Visit http://127.0.0.1:4040 for traffic monitoring
- **Moodle**: Check admin panel for user activity
- **System**: Use `docker stats` for resource monitoring

---

## 🔍 Troubleshooting

### Common Issues

#### Tunnel Not Starting
```bash
# Check if Moodle is running
docker ps | grep manfree_moodle

# Test local access
curl -I http://localhost:8080

# Restart platform if needed
./down.sh && ./up.sh
```

#### Authentication Errors (Ngrok)
```bash
# Add authtoken
ngrok config add-authtoken YOUR_TOKEN

# Verify configuration
ngrok config check
```

#### Connection Refused
```bash
# Check firewall
sudo ufw status

# Allow port if needed
sudo ufw allow 8080

# Check if port is in use
sudo netstat -tlnp | grep 8080
```

#### SSL/HTTPS Issues
```bash
# Platform auto-configures SSL for tunnels
# If issues persist, restart Moodle container
docker-compose restart moodle
```

---

## 📊 Performance Comparison

| Service | Setup Time | Reliability | Speed | Features |
|---------|------------|-------------|-------|----------|
| Bore.pub | 30 sec | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Basic |
| Cloudflare | 1 min | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Advanced |
| Ngrok | 2 min | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Advanced |
| Pinggy | 30 sec | ⭐⭐⭐ | ⭐⭐⭐ | Basic |
| LocalTunnel | 5 min | ⭐⭐ | ⭐⭐ | Basic |
| Serveo | 30 sec | ⭐ | ⭐⭐ | Limited |

---

## 🎯 Recommendations

### For Different Use Cases

#### **Quick Testing** → Use Bore.pub
- No setup required
- No payment risk
- Reliable connections

#### **Production Classes** → Use Cloudflare Tunnel
- Enterprise infrastructure
- Best performance
- Most reliable

#### **Familiar Users** → Use Ngrok
- Well-documented
- Traffic monitoring
- Professional features

#### **Minimal Setup** → Use Pinggy
- SSH-based
- No installation
- Quick start

---

## 🔐 Security Best Practices

### For All Tunnels
1. **Change Default Passwords**: Update admin and user passwords
2. **Monitor Access**: Check Moodle logs regularly
3. **Limit Permissions**: Set proper user roles
4. **Session Management**: Configure session timeouts
5. **Regular Updates**: Keep platform updated

### Tunnel-Specific Security
- **Ngrok**: Monitor traffic at http://127.0.0.1:4040
- **Cloudflare**: Leverage built-in DDoS protection
- **Others**: Monitor system resources for unusual activity

---

This guide ensures other developers can understand and implement any tunneling solution with complete installation and usage instructions.
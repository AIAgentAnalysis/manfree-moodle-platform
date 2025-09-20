# 🌐 Cloudflare Permanent Tunnel Setup Guide

**Create a permanent, static URL for your Moodle platform using your own domain**

## 📋 Overview

This guide shows how to create `learning.manfreetechnologies.com` (or any subdomain) that permanently points to your local Moodle, accessible from anywhere in the world.

### ✅ Benefits
- **Permanent URL** - Never changes (unlike trycloudflare.com)
- **Free** - No additional costs beyond domain ownership
- **HTTPS** - Automatic SSL certificates
- **Fast** - Cloudflare's global network
- **Perfect for Google OAuth** - Static redirect URLs

### 🎯 What You'll Get
- **Local Access**: `http://localhost:8080` (unchanged)
- **Global Access**: `https://learning.manfreetechnologies.com`
- **Automatic Detection** - Platform configures itself based on access method

---

## 🔧 Prerequisites

### Required
- ✅ **Own Domain** - You need `manfreetechnologies.com` (or any domain)
- ✅ **Domain on Cloudflare** - Nameservers pointing to Cloudflare
- ✅ **Moodle Running** - Docker containers active on port 8080
- ✅ **Linux/WSL2** - Where Moodle is running

### Verification
```bash
# Check domain is on Cloudflare
nslookup manfreetechnologies.com
# Should show Cloudflare nameservers

# Check Moodle is running
curl -I http://localhost:8080
# Should return HTTP 200 OK

# Check Docker containers
docker ps | grep moodle
# Should show manfree_moodle running
```

---

## 🚀 Step-by-Step Setup

### Step 1: Install cloudflared

```bash
# Add Cloudflare repository
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" | sudo tee /etc/apt/sources.list.d/cloudflared.list

# Install cloudflared
sudo apt-get update && sudo apt-get install -y cloudflared

# Verify installation
cloudflared --version
```

**Expected Output:**
```
cloudflared version 2025.9.0 (built 2025-09-01-1234 UTC)
```

### Step 2: Authenticate with Cloudflare

```bash
cloudflared tunnel login
```

**What Happens:**
1. Command shows a URL like: `https://dash.cloudflare.com/argotunnel?aud=...`
2. Copy URL and open in browser
3. Login to Cloudflare account
4. Select your domain (`manfreetechnologies.com`)
5. Click "Authorize"
6. Terminal shows: "You have successfully logged in"

**Verification:**
```bash
# Check certificate was created
ls ~/.cloudflared/
# Should show: cert.pem
```

### Step 3: Create Named Tunnel

```bash
cloudflared tunnel create moodle-tunnel
```

**Expected Output:**
```
Tunnel credentials written to /home/manfree/.cloudflared/2b24508c-fbed-4586-9190-e2a5b622c2ee.json
Created tunnel moodle-tunnel with id 2b24508c-fbed-4586-9190-e2a5b622c2ee
```

**📝 Important:** Copy the tunnel UUID (`2b24508c-fbed-4586-9190-e2a5b622c2ee`) - you'll need it!

### Step 4: Create Configuration File

```bash
# Create config directory
mkdir -p ~/.cloudflared

# Create config file
nano ~/.cloudflared/config.yml
```

**Paste this content** (replace UUID with your actual tunnel ID):

```yaml
tunnel: 2b24508c-fbed-4586-9190-e2a5b622c2ee
credentials-file: /home/manfree/.cloudflared/2b24508c-fbed-4586-9190-e2a5b622c2ee.json

ingress:
  - hostname: learning.manfreetechnologies.com
    service: http://localhost:8080
  - service: http_status:404
```

**Configuration Explained:**
- `tunnel`: Your unique tunnel ID
- `credentials-file`: Path to tunnel credentials
- `hostname`: Your chosen subdomain
- `service`: Points to local Moodle (port 8080)
- `http_status:404`: Catch-all for other requests

**Save and exit:** `Ctrl+X`, then `Y`, then `Enter`

### Step 5: Create DNS Record

```bash
cloudflared tunnel route dns moodle-tunnel learning.manfreetechnologies.com
```

**Expected Output:**
```
2025-09-20T14:06:39Z INF Added CNAME learning.manfreetechnologies.com which will route to this tunnel tunnelID=2b24508c-fbed-4586-9190-e2a5b622c2ee
```

**What This Does:**
- Creates CNAME record in Cloudflare DNS
- Points `learning.manfreetechnologies.com` → `<tunnel-id>.cfargotunnel.com`
- Enables Cloudflare proxy (orange cloud)

### Step 6: Test Tunnel (Manual Mode)

```bash
# Ensure Moodle is running
./up.sh

# Start tunnel in test mode
cloudflared tunnel run moodle-tunnel
```

**Expected Output:**
```
2025-09-20T14:08:06Z INF Starting tunnel tunnelID=2b24508c-fbed-4586-9190-e2a5b622c2ee
2025-09-20T14:08:07Z INF Registered tunnel connection connIndex=0 connection=db27832f-0295-4bef-8aee-949b365b1015 event=0 ip=198.41.192.37 location=maa01 protocol=quic
2025-09-20T14:08:08Z INF Registered tunnel connection connIndex=1 connection=d4f4d8eb-97d4-4a52-b301-dd242ef6b04d event=0 ip=198.41.200.73 location=bom10 protocol=quic
```

**✅ Success Indicators:**
- Multiple "Registered tunnel connection" messages
- Connections to different Cloudflare locations (maa01, bom10, etc.)
- No error messages

### Step 7: Test Access

**Test Local Access:**
```bash
curl -I http://localhost:8080
```
**Expected:** `HTTP/1.1 200 OK`

**Test Global Access:**
```bash
curl -I https://learning.manfreetechnologies.com
```
**Expected:** `HTTP/2 303` (redirect) or `HTTP/2 200 OK`

**Test in Browser:**
- Local: `http://localhost:8080`
- Global: `https://learning.manfreetechnologies.com`

Both should show your Moodle login page!

### Step 8: Install as Permanent Service

**Stop the test tunnel** (Ctrl+C) and install as system service:

```bash
# Install cloudflared as system service
sudo cloudflared service install

# Start the service
sudo systemctl start cloudflared

# Enable auto-start on boot
sudo systemctl enable cloudflared

# Check service status
sudo systemctl status cloudflared
```

**Expected Output:**
```
● cloudflared.service - cloudflared
     Loaded: loaded (/etc/systemd/system/cloudflared.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2025-09-20 14:30:00 UTC; 10s ago
```

**✅ Service Commands:**
```bash
# Start service
sudo systemctl start cloudflared

# Stop service
sudo systemctl stop cloudflared

# Restart service
sudo systemctl restart cloudflared

# Check status
sudo systemctl status cloudflared

# View logs
sudo journalctl -u cloudflared -f
```

---

## 🔧 Platform Configuration

### Automatic URL Detection

Your Moodle platform automatically detects access method and configures accordingly:

**File:** `customizations/config/config.php`

```php
// Dynamic URL detection for tunnels
if (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'learning.manfreetechnologies.com') !== false) {
    $CFG->wwwroot = 'https://learning.manfreetechnologies.com';
    $CFG->sslproxy = true;
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
} elseif (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'ngrok') !== false) {
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
    $CFG->sslproxy = true;
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
} else {
    $CFG->wwwroot = 'http://localhost:8080';
}
```

**What This Means:**
- ✅ **Local Access** (`localhost:8080`) → Uses HTTP
- ✅ **Cloudflare Access** (`learning.manfreetechnologies.com`) → Uses HTTPS
- ✅ **Other Tunnels** (ngrok, etc.) → Uses HTTPS
- ✅ **No Manual Changes** → Automatic detection

---

## 🌐 Google OAuth Integration

### Setup Google OAuth for Permanent URL

**1. Google Cloud Console Setup:**
- Go to: [Google Cloud Console](https://console.cloud.google.com/)
- Navigate to: APIs & Services → Credentials
- Create OAuth 2.0 Client ID (Web application)

**2. Authorized Redirect URI:**
```
https://learning.manfreetechnologies.com/admin/oauth2callback.php
```

**3. Moodle Configuration:**
- Site administration → Server → OAuth 2 services
- Add Google service with your Client ID and Secret
- Test connection

**4. Enable Google Login:**
- Site administration → Plugins → Authentication → OAuth 2
- Enable and configure Google authentication

---

## 🔍 Troubleshooting

### Common Issues and Solutions

#### 1. HTTP 530 Error
**Symptom:** `curl -I https://learning.manfreetechnologies.com` returns HTTP 530

**Cause:** Cloudflare can't reach your tunnel

**Solutions:**
```bash
# Check if tunnel is running
sudo systemctl status cloudflared

# Check if Moodle is running
docker ps | grep moodle

# Restart tunnel service
sudo systemctl restart cloudflared

# Check tunnel logs
sudo journalctl -u cloudflared -f
```

#### 2. DNS Not Resolving
**Symptom:** `nslookup learning.manfreetechnologies.com` fails

**Cause:** DNS propagation delay or incorrect setup

**Solutions:**
```bash
# Check DNS record exists
cloudflared tunnel route dns moodle-tunnel learning.manfreetechnologies.com

# Wait for DNS propagation (5-30 minutes)
# Try different DNS servers: 8.8.8.8, 1.1.1.1

# Clear local DNS cache
sudo systemctl flush-dns  # Linux
ipconfig /flushdns         # Windows
```

#### 3. Local Access Broken
**Symptom:** `http://localhost:8080` doesn't work

**Cause:** Incorrect Moodle configuration

**Solution:**
Check `customizations/config/config.php` has proper fallback:
```php
} else {
    $CFG->wwwroot = 'http://localhost:8080';
}
```

#### 4. Service Won't Start
**Symptom:** `sudo systemctl start cloudflared` fails

**Cause:** Configuration file issues

**Solutions:**
```bash
# Check config syntax
cloudflared tunnel ingress validate

# Check config file exists
ls ~/.cloudflared/config.yml

# Test tunnel manually
cloudflared tunnel run moodle-tunnel

# Check service logs
sudo journalctl -u cloudflared -n 50
```

#### 5. Tunnel Disconnects
**Symptom:** Intermittent connection issues

**Cause:** Network connectivity or firewall

**Solutions:**
```bash
# Check network connectivity
ping 1.1.1.1

# Check firewall rules
sudo ufw status

# Restart network service
sudo systemctl restart networking

# Monitor tunnel connections
sudo journalctl -u cloudflared -f
```

### Diagnostic Commands

```bash
# Check tunnel status
cloudflared tunnel info moodle-tunnel

# List all tunnels
cloudflared tunnel list

# Validate configuration
cloudflared tunnel ingress validate

# Test ingress rules
cloudflared tunnel ingress rule https://learning.manfreetechnologies.com

# Check service logs
sudo journalctl -u cloudflared -n 100

# Monitor real-time logs
sudo journalctl -u cloudflared -f

# Check Cloudflare connectivity
curl -I https://1.1.1.1

# Test local Moodle
curl -I http://localhost:8080

# Test external access
curl -I https://learning.manfreetechnologies.com
```

---

## 📊 Performance and Monitoring

### Monitoring Tunnel Health

**1. Service Status:**
```bash
# Check if service is running
sudo systemctl is-active cloudflared

# Get detailed status
sudo systemctl status cloudflared

# Check service uptime
sudo systemctl show cloudflared --property=ActiveEnterTimestamp
```

**2. Connection Monitoring:**
```bash
# Real-time tunnel logs
sudo journalctl -u cloudflared -f

# Check connection count
sudo journalctl -u cloudflared | grep "Registered tunnel connection" | tail -5

# Monitor for errors
sudo journalctl -u cloudflared | grep -i error
```

**3. Performance Metrics:**
```bash
# Check response times
curl -w "@curl-format.txt" -o /dev/null -s https://learning.manfreetechnologies.com

# Create curl-format.txt:
echo "     time_namelookup:  %{time_namelookup}\n        time_connect:  %{time_connect}\n     time_appconnect:  %{time_appconnect}\n    time_pretransfer:  %{time_pretransfer}\n       time_redirect:  %{time_redirect}\n  time_starttransfer:  %{time_starttransfer}\n                     ----------\n          time_total:  %{time_total}\n" > curl-format.txt
```

### Cloudflare Analytics

**Access Cloudflare Dashboard:**
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select your domain (`manfreetechnologies.com`)
3. Navigate to Analytics & Logs → Traffic

**Key Metrics:**
- **Requests per minute** - Traffic volume
- **Bandwidth usage** - Data transfer
- **Response codes** - Error rates
- **Geographic distribution** - User locations
- **Cache hit ratio** - Performance optimization

---

## 🔐 Security Best Practices

### Tunnel Security

**1. Protect Credentials:**
```bash
# Secure credentials file
chmod 600 ~/.cloudflared/*.json

# Backup credentials securely
cp ~/.cloudflared/*.json ~/backup/cloudflared-credentials-$(date +%Y%m%d).json
```

**2. Monitor Access:**
```bash
# Check Moodle access logs
docker exec manfree_moodle tail -f /var/log/apache2/access.log

# Monitor authentication attempts
grep "login" /var/log/apache2/access.log
```

**3. Firewall Configuration:**
```bash
# Allow only necessary ports
sudo ufw allow 22    # SSH
sudo ufw allow 8080  # Moodle (local only)
sudo ufw deny 8080 from any to any  # Block external access to 8080
sudo ufw enable
```

### Moodle Security

**1. Update Admin Passwords:**
- Change default admin password
- Use strong passwords (12+ characters)
- Enable two-factor authentication

**2. Configure User Permissions:**
- Limit admin access
- Set up proper user roles
- Enable course enrollment keys

**3. Monitor User Activity:**
- Site administration → Reports → Live logs
- Check for unusual login patterns
- Monitor file uploads and downloads

---

## 🚀 Advanced Configuration

### Custom Subdomains

**Create Multiple Subdomains:**

```yaml
# ~/.cloudflared/config.yml
tunnel: 2b24508c-fbed-4586-9190-e2a5b622c2ee
credentials-file: /home/manfree/.cloudflared/2b24508c-fbed-4586-9190-e2a5b622c2ee.json

ingress:
  - hostname: learning.manfreetechnologies.com
    service: http://localhost:8080
  - hostname: admin.manfreetechnologies.com
    service: http://localhost:8080/admin
  - hostname: api.manfreetechnologies.com
    service: http://localhost:8080/webservice
  - service: http_status:404
```

**Create DNS records:**
```bash
cloudflared tunnel route dns moodle-tunnel learning.manfreetechnologies.com
cloudflared tunnel route dns moodle-tunnel admin.manfreetechnologies.com
cloudflared tunnel route dns moodle-tunnel api.manfreetechnologies.com
```

### Load Balancing

**Multiple Moodle Instances:**

```yaml
ingress:
  - hostname: learning.manfreetechnologies.com
    service: http://localhost:8080
    originRequest:
      connectTimeout: 30s
      tlsTimeout: 30s
      tcpKeepAlive: 30s
  - hostname: learning2.manfreetechnologies.com
    service: http://localhost:8081
  - service: http_status:404
```

### Access Control

**IP Restrictions:**
```yaml
ingress:
  - hostname: admin.manfreetechnologies.com
    service: http://localhost:8080/admin
    originRequest:
      access:
        required: true
        teamName: your-team-name
  - service: http_status:404
```

---

## 📋 Maintenance Tasks

### Daily Tasks

**1. Check Service Status:**
```bash
# Quick health check
sudo systemctl is-active cloudflared && echo "✅ Tunnel running" || echo "❌ Tunnel down"

# Check Moodle accessibility
curl -s -o /dev/null -w "%{http_code}" https://learning.manfreetechnologies.com
```

**2. Monitor Logs:**
```bash
# Check for errors in last 24 hours
sudo journalctl -u cloudflared --since "24 hours ago" | grep -i error

# Check connection stability
sudo journalctl -u cloudflared --since "24 hours ago" | grep "Registered tunnel connection" | wc -l
```

### Weekly Tasks

**1. Update cloudflared:**
```bash
# Check current version
cloudflared --version

# Update via package manager
sudo apt update && sudo apt upgrade cloudflared

# Restart service after update
sudo systemctl restart cloudflared
```

**2. Backup Configuration:**
```bash
# Backup tunnel configuration
cp ~/.cloudflared/config.yml ~/backup/cloudflared-config-$(date +%Y%m%d).yml
cp ~/.cloudflared/*.json ~/backup/
```

**3. Performance Review:**
```bash
# Check tunnel uptime
sudo systemctl show cloudflared --property=ActiveEnterTimestamp

# Review Cloudflare analytics
# (Access via Cloudflare Dashboard)
```

### Monthly Tasks

**1. Security Review:**
```bash
# Check for unauthorized access attempts
grep "403\|404\|500" /var/log/apache2/access.log | tail -20

# Review Moodle user activity
# (Access via Moodle admin panel)
```

**2. Certificate Renewal:**
```bash
# Cloudflare handles SSL automatically, but verify:
curl -I https://learning.manfreetechnologies.com | grep -i "strict-transport-security"
```

---

## 🆘 Emergency Procedures

### Tunnel Down Emergency

**1. Quick Diagnosis:**
```bash
# Check service status
sudo systemctl status cloudflared

# Check if Moodle is accessible locally
curl -I http://localhost:8080

# Check network connectivity
ping 1.1.1.1
```

**2. Emergency Restart:**
```bash
# Restart cloudflared service
sudo systemctl restart cloudflared

# If that fails, restart manually
sudo systemctl stop cloudflared
cloudflared tunnel run moodle-tunnel &

# Check if tunnel connects
sudo journalctl -u cloudflared -f
```

**3. Fallback Options:**
```bash
# Use temporary tunnel as backup
cd tunneling
./cloudflare-tunnel.sh

# Or use ngrok as emergency backup
./ngrok-tunnel.sh
```

### Complete System Recovery

**1. Reinstall cloudflared:**
```bash
# Remove existing installation
sudo systemctl stop cloudflared
sudo systemctl disable cloudflared
sudo apt remove cloudflared

# Reinstall
sudo apt update && sudo apt install cloudflared

# Restore configuration
cp ~/backup/cloudflared-config-*.yml ~/.cloudflared/config.yml
cp ~/backup/*.json ~/.cloudflared/

# Reinstall service
sudo cloudflared service install
sudo systemctl start cloudflared
```

**2. Recreate Tunnel:**
```bash
# If tunnel is completely lost
cloudflared tunnel delete moodle-tunnel
cloudflared tunnel create moodle-tunnel-new

# Update config with new tunnel ID
nano ~/.cloudflared/config.yml

# Recreate DNS record
cloudflared tunnel route dns moodle-tunnel-new learning.manfreetechnologies.com
```

---

## 📚 Additional Resources

### Official Documentation
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Moodle Configuration Guide](https://docs.moodle.org/en/Configuration_file)
- [Docker Compose Reference](https://docs.docker.com/compose/)

### Community Resources
- [Cloudflare Community](https://community.cloudflare.com/)
- [Moodle Forums](https://moodle.org/forums/)
- [Docker Community](https://forums.docker.com/)

### Monitoring Tools
- [Cloudflare Analytics](https://dash.cloudflare.com/)
- [UptimeRobot](https://uptimerobot.com/) - External monitoring
- [Grafana](https://grafana.com/) - Advanced metrics

---

## 🎯 Summary

**What You've Accomplished:**
- ✅ **Permanent Static URL** - `https://learning.manfreetechnologies.com`
- ✅ **Automatic HTTPS** - SSL certificates managed by Cloudflare
- ✅ **Global Accessibility** - Available worldwide
- ✅ **Local Access Preserved** - `http://localhost:8080` still works
- ✅ **Auto-Start Service** - Tunnel starts automatically on boot
- ✅ **Google OAuth Ready** - Static URL for authentication
- ✅ **Production Ready** - Suitable for real classes and exams

**Key Benefits:**
- **No Port Forwarding** - No router configuration needed
- **No Public IP** - Works behind NAT/firewall
- **No VPS Costs** - Runs on your local machine
- **Enterprise Grade** - Cloudflare's global infrastructure
- **Easy Management** - Simple systemd service

**Your Moodle is now accessible at:**
- **Local**: `http://localhost:8080`
- **Global**: `https://learning.manfreetechnologies.com`

Both URLs work simultaneously with automatic detection!
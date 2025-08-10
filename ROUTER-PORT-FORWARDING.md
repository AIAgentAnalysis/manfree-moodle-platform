# 🌐 Router Port Forwarding Guide - Global Moodle Access

**Make your Moodle platform accessible from anywhere on the internet safely**

---

## 📋 **Overview**

Router Port Forwarding allows you to expose your local Moodle platform (running on `localhost:8080`) to the entire internet through your home router. This is the **safest** method for global access as you maintain full control.

### **How It Works:**
```
Internet User → Your Public IP:8080 → Your Router → Your PC:8080 → Moodle
```

---

## 🔧 **Prerequisites**

### **System Requirements:**
- ✅ Moodle platform running locally (`./up.sh`)
- ✅ Router admin access (username/password)
- ✅ Static local IP for your PC
- ✅ Internet connection with public IP

### **Information You'll Need:**
1. **Your PC's Local IP**: `172.19.15.20` (from `hostname -I`)
2. **Router Admin IP**: Usually `192.168.1.1` or `192.168.0.1`
3. **Router Login Credentials**: Check router sticker or manual
4. **Your Public IP**: Will be obtained during setup

---

## 🚀 **Step-by-Step Setup**

### **Step 1: Prepare Your System**

#### **1.1 Ensure Moodle is Running**
```bash
cd ~/workspace/MF/manfree-moodle-platform
./up.sh
# Verify: http://localhost:8080 works
```

#### **1.2 Find Your Local IP**
```bash
hostname -I
# Output: 172.19.15.20 192.168.127.2 172.17.0.1 172.18.0.1
# Use the first IP: 172.19.15.20
```

#### **1.3 Set Static IP (Recommended)**
```bash
# Method 1: Router DHCP Reservation (Preferred)
# - Access router admin
# - Find DHCP settings
# - Reserve 172.19.15.20 for your PC's MAC address

# Method 2: Static IP on PC
sudo nano /etc/netplan/01-netcfg.yaml
# Add static IP configuration
```

### **Step 2: Access Router Admin Panel**

#### **2.1 Find Router IP**
```bash
ip route | grep default
# Output: default via 192.168.1.1 dev wlp3s0
# Router IP: 192.168.1.1
```

#### **2.2 Access Router Web Interface**
1. Open browser
2. Go to: `http://192.168.1.1` (or your router IP)
3. Login with admin credentials

**Common Default Credentials:**
- Username: `admin`, Password: `admin`
- Username: `admin`, Password: `password`
- Check router sticker for defaults

### **Step 3: Configure Port Forwarding**

#### **3.1 Navigate to Port Forwarding**
Look for these menu items (varies by router brand):
- **Linksys**: Advanced → Security → Apps and Gaming → Single Port Forwarding
- **Netgear**: Advanced → Dynamic DNS/Port Forwarding → Port Forwarding
- **TP-Link**: Advanced → NAT Forwarding → Virtual Servers
- **ASUS**: Adaptive QoS → Traditional QoS → Port Forwarding
- **D-Link**: Advanced → Port Forwarding

#### **3.2 Create Port Forwarding Rule**
```
Rule Name: Moodle-Platform
Service Type: HTTP (or Custom)
External Port Range: 8080 - 8080
Internal IP Address: 172.19.15.20
Internal Port Range: 8080 - 8080
Protocol: TCP
Status: Enabled
```

#### **3.3 Save and Apply Settings**
- Click "Save" or "Apply"
- Router may restart (wait 2-3 minutes)

### **Step 4: Configure Firewall (If Needed)**

#### **4.1 Ubuntu/Linux Firewall**
```bash
# Allow port 8080
sudo ufw allow 8080
sudo ufw status
```

#### **4.2 Router Firewall**
- Some routers have built-in firewall
- Ensure port 8080 is allowed in firewall rules

### **Step 5: Get Your Public IP**

#### **5.1 Find Public IP**
```bash
curl ifconfig.me
# Output: 203.45.67.89 (example)
```

#### **5.2 Alternative Methods**
```bash
# Method 2
curl ipinfo.io/ip

# Method 3
dig +short myip.opendns.com @resolver1.opendns.com

# Method 4: Check router admin panel (Status/WAN section)
```

### **Step 6: Test Global Access**

#### **6.1 Test from External Network**
1. Use mobile data (not same WiFi)
2. Go to: `http://YOUR-PUBLIC-IP:8080`
3. Example: `http://203.45.67.89:8080`

#### **6.2 Test from Different Location**
- Ask friend to test the URL
- Use online tools: `https://www.canyouseeme.org/`

---

## 🔒 **Security Configuration**

### **Essential Security Steps:**

#### **1. Change Default Moodle Admin Password**
```bash
# Access: http://YOUR-PUBLIC-IP:8080/admin
# Change default admin credentials immediately
```

#### **2. Enable HTTPS (Recommended)**
```bash
# Install SSL certificate (Let's Encrypt)
sudo apt install certbot
# Configure SSL for your domain
```

#### **3. Firewall Rules**
```bash
# Only allow necessary ports
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 8080
sudo ufw enable
```

#### **4. Router Security**
- Change router admin password
- Disable WPS
- Use WPA3 WiFi security
- Enable router firewall

### **Advanced Security (Optional):**

#### **1. IP Whitelisting**
```bash
# In router: Only allow specific IPs to access port 8080
# Example: Only allow your office/school IP range
```

#### **2. VPN Access Only**
```bash
# Set up VPN server on router
# Only allow VPN users to access Moodle
```

---

## 🌐 **Dynamic DNS Setup (Optional)**

If your ISP changes your public IP frequently:

### **1. Choose Dynamic DNS Provider**
- **DuckDNS** (Free): `yourname.duckdns.org`
- **No-IP** (Free): `yourname.ddns.net`
- **Dynu** (Free): `yourname.dynu.net`

### **2. Setup Dynamic DNS**
```bash
# Example with DuckDNS
curl "https://www.duckdns.org/update?domains=yourname&token=YOUR-TOKEN&ip="

# Add to crontab for auto-update
crontab -e
# Add: */5 * * * * curl "https://www.duckdns.org/update?domains=yourname&token=YOUR-TOKEN&ip="
```

### **3. Access via Domain**
```
http://yourname.duckdns.org:8080
```

---

## 🔧 **Troubleshooting**

### **Common Issues:**

#### **1. Cannot Access Router Admin**
```bash
# Reset router to factory defaults
# Hold reset button for 10 seconds while powered on
# Use default credentials from router sticker
```

#### **2. Port Forwarding Not Working**
```bash
# Check if port is open
nmap -p 8080 YOUR-PUBLIC-IP

# Test locally first
curl http://172.19.15.20:8080

# Check router logs for blocked connections
```

#### **3. ISP Blocks Port 8080**
```bash
# Try different port (8081, 8082, etc.)
# Update both router forwarding and Moodle config
```

#### **4. Dynamic IP Changes**
```bash
# Set up Dynamic DNS (see section above)
# Or contact ISP for static IP
```

#### **5. Moodle Redirects to Localhost**
```bash
# Update Moodle config
nano customizations/config/config.php
# Change: $CFG->wwwroot = 'http://YOUR-PUBLIC-IP:8080';
docker-compose restart moodle
```

### **Testing Commands:**
```bash
# Test local access
curl -I http://localhost:8080

# Test LAN access
curl -I http://172.19.15.20:8080

# Test external access (from different network)
curl -I http://YOUR-PUBLIC-IP:8080

# Check port status
sudo netstat -tlnp | grep 8080

# Check Docker containers
docker-compose ps
```

---

## 📊 **Router Brand Specific Guides**

### **Linksys Routers:**
1. Login to `http://192.168.1.1`
2. Go to: **Smart Wi-Fi Tools** → **Port Range Forwarding**
3. Add new rule with Moodle settings
4. Save and restart router

### **Netgear Routers:**
1. Login to `http://192.168.1.1` or `http://routerlogin.net`
2. Go to: **Advanced** → **Dynamic DNS/Port Forwarding**
3. Click **Port Forwarding** tab
4. Add custom service for Moodle

### **TP-Link Routers:**
1. Login to `http://192.168.0.1` or `http://tplinkwifi.net`
2. Go to: **Advanced** → **NAT Forwarding** → **Virtual Servers**
3. Click **Add** and configure Moodle rule

### **ASUS Routers:**
1. Login to `http://192.168.1.1`
2. Go to: **WAN** → **Virtual Server/Port Forwarding**
3. Enable port forwarding and add rule

### **D-Link Routers:**
1. Login to `http://192.168.0.1`
2. Go to: **Advanced** → **Port Forwarding**
3. Add new rule for Moodle platform

---

## ⚠️ **Important Considerations**

### **Security Risks:**
- ❌ **Exposes your home network** to internet
- ❌ **Potential for attacks** if not secured properly
- ❌ **ISP may block certain ports**

### **ISP Limitations:**
- Some ISPs block common ports (80, 8080, etc.)
- Dynamic IP addresses change frequently
- Upload speed limits may affect performance

### **Legal Considerations:**
- Check ISP terms of service for hosting restrictions
- Some ISPs prohibit running servers on residential connections
- Consider business internet plan for commercial use

---

## 🎯 **Alternative Solutions**

If port forwarding doesn't work:

### **1. Cloud Hosting**
```bash
# Deploy to DigitalOcean, AWS, or Linode
# Get permanent domain and IP
# More reliable but costs money
```

### **2. VPN Solutions**
```bash
# Tailscale, WireGuard, or OpenVPN
# Private network access only
# More secure but requires setup on client devices
```

### **3. Reverse Proxy Services**
```bash
# Cloudflare Argo Tunnel (paid)
# Ngrok (paid plans)
# More features but monthly cost
```

---

## 📞 **Support and Resources**

### **Router Documentation:**
- Check manufacturer's website for specific model guides
- YouTube tutorials for your router brand
- Router manual (usually available online)

### **Network Tools:**
- **Port Checker**: `https://www.canyouseeme.org/`
- **IP Lookup**: `https://whatismyipaddress.com/`
- **Speed Test**: `https://speedtest.net/`

### **Moodle Resources:**
- **Official Docs**: `https://docs.moodle.org/`
- **Community Forums**: `https://moodle.org/forums/`

---

## 📈 **Performance Optimization**

### **For Better Performance:**

#### **1. Router Settings**
- Enable QoS (Quality of Service)
- Prioritize port 8080 traffic
- Use 5GHz WiFi band

#### **2. System Optimization**
```bash
# Increase Docker resources
# Edit docker-compose.yml to add resource limits
# Monitor system performance
htop
```

#### **3. Network Optimization**
```bash
# Use wired connection instead of WiFi
# Upgrade internet plan if needed
# Consider CDN for static content
```

---

## 🎓 **Educational Use Best Practices**

### **For Classroom/Institute Use:**

#### **1. Access Control**
- Set up user authentication in Moodle
- Create student accounts with limited permissions
- Use course enrollment keys

#### **2. Content Management**
- Regular backups before exams
- Test all features before student access
- Have backup internet connection

#### **3. Monitoring**
```bash
# Monitor system resources
docker stats

# Check access logs
docker-compose logs moodle

# Monitor network usage
iftop
```

---

## 📝 **Quick Reference**

### **Essential Commands:**
```bash
# Start Moodle
./up.sh

# Stop Moodle
./down.sh

# Check local IP
hostname -I

# Check public IP
curl ifconfig.me

# Test port
nmap -p 8080 YOUR-PUBLIC-IP

# Restart Moodle
docker-compose restart moodle
```

### **Important URLs:**
- **Local Access**: `http://localhost:8080`
- **LAN Access**: `http://172.19.15.20:8080`
- **Global Access**: `http://YOUR-PUBLIC-IP:8080`
- **Admin Panel**: `http://YOUR-PUBLIC-IP:8080/admin`

### **Configuration Files:**
- **Moodle Config**: `customizations/config/config.php`
- **Docker Config**: `docker-compose.yml`
- **Backup Location**: `backup/`

---

**Last Updated**: August 2025  
**Platform Version**: Moodle 4.5.6  
**Compatibility**: All major router brands  

*This guide provides the safest method for global Moodle access while maintaining full control over your platform.*
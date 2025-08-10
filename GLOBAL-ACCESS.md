# 🌐 Global Access Guide - Tunnel Solutions

**Make your Moodle platform accessible from anywhere on the internet**

---

## 📋 **Overview**

This guide covers different methods to make your local Moodle platform accessible globally, allowing students and instructors to connect from anywhere in the world.

### **Available Methods:**
1. **Ngrok Tunnel** (Recommended) - Easy setup, reliable
2. **Router Port Forwarding** - Most secure, requires router access
3. **Cloud Deployment** - Professional solution, requires hosting

---

## 🚀 **Method 1: Ngrok Tunnel (Recommended)**

### **What is Ngrok?**
Ngrok creates secure tunnels to your localhost, providing public HTTPS URLs that work globally.

### **Setup Steps:**

#### **1. Install Ngrok**
```bash
# Download and install ngrok
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install ngrok
```

#### **2. Create Free Account**
1. Visit: https://dashboard.ngrok.com/signup
2. Sign up with email
3. Get your authtoken from: https://dashboard.ngrok.com/get-started/your-authtoken

#### **3. Configure Authtoken**
```bash
ngrok config add-authtoken YOUR_AUTHTOKEN_HERE
```

#### **4. Start Global Tunnel**
```bash
# Ensure Moodle is running
./up.sh

# Start tunnel
./ngrok-tunnel.sh
```

### **What You'll Get:**
```
Session Status                online
Account                       your-email@example.com (Plan: Free)
Forwarding                    https://abc123.ngrok-free.app -> http://localhost:8080

🌐 Share this URL: https://abc123.ngrok-free.app
```

### **Features:**
- ✅ **Automatic HTTPS** - Secure connection
- ✅ **Global Access** - Works from anywhere
- ✅ **Smart Detection** - Platform auto-configures for tunnel
- ✅ **Traffic Monitoring** - View requests at http://127.0.0.1:4040
- ✅ **Free Tier** - No cost for basic usage

### **Limitations:**
- ❌ **URL Changes** - New URL each restart (free tier)
- ❌ **Session Limits** - 8 hours max per session (free tier)
- ❌ **Bandwidth Limits** - 1GB/month (free tier)

---

## 🔒 **Method 2: Router Port Forwarding**

### **When to Use:**
- Need permanent URL
- Want full control over security
- Have router admin access
- Professional/production use

### **Quick Setup:**
1. **Access Router**: http://192.168.1.1 (or your router IP)
2. **Find Port Forwarding**: Usually under Advanced/NAT settings
3. **Create Rule**:
   ```
   Service Name: Moodle
   External Port: 8080
   Internal IP: YOUR-PC-IP
   Internal Port: 8080
   Protocol: TCP
   ```
4. **Get Public IP**: `curl ifconfig.me`
5. **Access Globally**: `http://YOUR-PUBLIC-IP:8080`

### **Detailed Guide:**
See [ROUTER-PORT-FORWARDING.md](ROUTER-PORT-FORWARDING.md) for complete instructions.

---

## ☁️ **Method 3: Cloud Deployment**

### **Professional Hosting Options:**

#### **DigitalOcean Droplet**
```bash
# Create $20/month droplet
# Deploy with Docker
# Get permanent domain
```

#### **AWS EC2**
```bash
# Use t3.medium instance
# Configure security groups
# Set up Elastic IP
```

#### **Google Cloud Platform**
```bash
# Use Compute Engine
# Configure firewall rules
# Set up static IP
```

---

## 🔧 **Platform Configuration**

### **Smart URL Detection**

Your platform automatically detects the access method and configures accordingly:

```php
// Dynamic URL detection in config.php
if (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'ngrok') !== false) {
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
    $CFG->sslproxy = true;
} elseif (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'trycloudflare') !== false) {
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
    $CFG->sslproxy = true;
} else {
    $CFG->wwwroot = 'http://localhost:8080';
}
```

### **What This Means:**
- ✅ **Localhost**: Works normally
- ✅ **Ngrok**: Automatically uses HTTPS
- ✅ **Cloudflare**: Automatically uses HTTPS
- ✅ **Port Forwarding**: Uses configured URL
- ✅ **No Manual Changes**: Everything automatic

---

## 🛡️ **Security Considerations**

### **For All Methods:**

#### **Essential Security Steps:**
1. **Change Default Passwords**
   ```bash
   # Access admin panel
   # Change admin password immediately
   # Create strong user passwords
   ```

2. **Configure User Permissions**
   ```bash
   # Limit admin access
   # Set up proper user roles
   # Enable course enrollment keys
   ```

3. **Monitor Access**
   ```bash
   # Check Moodle logs regularly
   # Monitor unusual activity
   # Set up user session limits
   ```

### **Ngrok Specific:**
- ✅ **HTTPS by Default** - All traffic encrypted
- ⚠️ **Public URL** - Anyone with URL can access
- ⚠️ **Free Tier Limits** - Monitor usage

### **Port Forwarding Specific:**
- ✅ **Full Control** - You manage everything
- ⚠️ **Home Network Exposed** - Requires firewall setup
- ⚠️ **ISP Restrictions** - Some ISPs block ports

---

## 📊 **Comparison Table**

| Feature | Ngrok | Port Forwarding | Cloud Hosting |
|---------|-------|-----------------|---------------|
| **Setup Time** | 5 minutes | 30 minutes | 2 hours |
| **Cost** | Free/Paid | Free | $20+/month |
| **Security** | Good | Excellent | Excellent |
| **Reliability** | Good | Excellent | Excellent |
| **Performance** | Good | Excellent | Excellent |
| **URL Stability** | Changes | Permanent | Permanent |
| **Technical Skill** | Beginner | Intermediate | Advanced |

---

## 🚀 **Quick Start Commands**

### **Start Platform:**
```bash
./up.sh
```

### **Create Global Access:**
```bash
# Option 1: Ngrok (easiest)
./ngrok-tunnel.sh

# Option 2: Check your public IP for port forwarding
curl ifconfig.me

# Option 3: Deploy to cloud (advanced)
# See cloud provider documentation
```

### **Stop Platform:**
```bash
./down.sh
```

---

## 🔍 **Troubleshooting**

### **Ngrok Issues:**

#### **Authentication Failed**
```bash
# Error: Usage of ngrok requires a verified account
# Solution: Add authtoken
ngrok config add-authtoken YOUR_TOKEN
```

#### **Too Many Redirects**
```bash
# Error: ERR_TOO_MANY_REDIRECTS
# Solution: Platform auto-fixes this, restart Moodle
docker-compose restart moodle
```

#### **Tunnel Not Accessible**
```bash
# Check if tunnel is running
curl -I https://your-tunnel-url.ngrok-free.app

# Check Moodle is running
curl -I http://localhost:8080
```

### **Port Forwarding Issues:**

#### **Can't Access Router**
```bash
# Find router IP
ip route | grep default

# Try common IPs
# 192.168.1.1, 192.168.0.1, 10.0.0.1
```

#### **Port Not Open**
```bash
# Test port externally
nmap -p 8080 YOUR-PUBLIC-IP

# Check local firewall
sudo ufw status
sudo ufw allow 8080
```

---

## 📱 **Mobile Access**

### **For Students Using Mobile Devices:**

#### **Ngrok Access:**
1. Share tunnel URL: `https://abc123.ngrok-free.app`
2. Works on any mobile browser
3. Full Moodle functionality

#### **LAN Access:**
1. Connect to same WiFi
2. Use instructor's IP: `http://192.168.1.100:8080`
3. Bookmark for easy access

#### **Mobile Optimization:**
- Moodle 4.5.6 is mobile-responsive
- Touch-friendly interface
- Works on iOS and Android
- Supports file uploads from mobile

---

## 📈 **Usage Analytics**

### **Monitor Your Platform:**

#### **Ngrok Dashboard:**
- Visit: http://127.0.0.1:4040
- View real-time requests
- Monitor bandwidth usage
- Check response times

#### **Moodle Analytics:**
```bash
# Access Moodle admin panel
# Go to: Reports → Live logs
# Monitor user activity
# Check system performance
```

#### **System Monitoring:**
```bash
# Check Docker stats
docker stats

# Monitor system resources
htop

# Check disk usage
df -h
```

---

## 🎯 **Best Practices**

### **For Educational Use:**

#### **Before Exams:**
1. **Test All Access Methods**
   ```bash
   # Test local access
   curl http://localhost:8080
   
   # Test tunnel access
   curl https://your-tunnel-url.ngrok-free.app
   ```

2. **Prepare Backup Plans**
   - Have multiple access methods ready
   - Test with student devices
   - Prepare offline alternatives

3. **Security Setup**
   - Change all default passwords
   - Set up proper user roles
   - Enable session monitoring

#### **During Exams:**
1. **Monitor Connections**
   - Watch ngrok dashboard
   - Check Moodle logs
   - Monitor system resources

2. **Have Support Ready**
   - Keep troubleshooting guide handy
   - Have backup internet connection
   - Prepare alternative access methods

#### **After Exams:**
1. **Backup Data**
   ```bash
   ./down.sh  # Creates automatic backup
   ```

2. **Review Logs**
   - Check for any issues
   - Review student submissions
   - Monitor system performance

---

## 📞 **Support**

### **Getting Help:**

#### **For Ngrok Issues:**
- Check: https://ngrok.com/docs
- Community: https://github.com/inconshreveable/ngrok

#### **For Platform Issues:**
- Check: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Review: [README.md](README.md)

#### **For Network Issues:**
- Check: [ROUTER-PORT-FORWARDING.md](ROUTER-PORT-FORWARDING.md)
- Contact: Your network administrator

---

**Last Updated**: August 2025  
**Platform Version**: Moodle 4.5.6  
**Ngrok Version**: 3.26.0+  

*Making education accessible worldwide* 🌍
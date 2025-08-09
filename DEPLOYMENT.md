# 🚀 Deployment Guide

**Manfree Technologies Moodle Platform**  
*Step-by-step guide for deploying on different systems*

---

## 📋 Pre-Deployment Checklist

### System Requirements Verification

**Minimum Requirements:**
- **OS**: Linux, macOS, or Windows with WSL2
- **RAM**: 4GB minimum, 8GB recommended  
- **Storage**: 10GB free space
- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+

**Check Commands:**
```bash
# Verify Docker installation
docker --version          # Should be 20.10+
docker-compose --version  # Should be 2.0+

# Check available resources
free -h                   # RAM check
df -h                     # Disk space check

# Test Docker functionality
docker run hello-world
```

---

## 🖥️ Platform-Specific Setup

### Ubuntu/Debian Linux

**1. Install Docker:**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install docker.io docker-compose -y

# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again, then test
docker run hello-world
```

**2. Clone and Deploy:**
```bash
# Clone repository
git clone <repository-url>
cd manfree-moodle-platform

# Verify files are executable
chmod +x *.sh

# Start platform
docker-compose up -d

# Check status
docker-compose ps
```

### CentOS/RHEL/Rocky Linux

**1. Install Docker:**
```bash
# Install Docker
sudo yum install -y docker docker-compose

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again
```

**2. Configure Firewall:**
```bash
# Open required ports
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --add-port=4000/tcp --permanent
sudo firewall-cmd --reload
```

### macOS

**1. Install Docker Desktop:**
```bash
# Install via Homebrew
brew install --cask docker

# Or download from: https://www.docker.com/products/docker-desktop
# Start Docker Desktop application
```

**2. Configure Resources:**
```bash
# Docker Desktop → Settings → Resources
# Memory: 4GB minimum, 8GB recommended
# Disk: 20GB minimum
```

### Windows with WSL2

**1. Enable WSL2:**
```powershell
# Run as Administrator
wsl --install
# Restart computer
```

**2. Install Docker Desktop:**
```bash
# Download from: https://www.docker.com/products/docker-desktop
# Enable WSL2 integration in Docker Desktop settings
```

**3. Deploy in WSL2:**
```bash
# Open WSL2 terminal
wsl

# Clone and deploy
git clone <repository-url>
cd manfree-moodle-platform
docker-compose up -d
```

---

## 🌐 Network Configuration

### For Local Development
```bash
# Default configuration works out of the box
# Access: http://localhost:8080
```

### For LAN Access (Students)

**1. Get Host IP:**
```bash
# Linux/macOS
hostname -I
ip addr show | grep inet

# Windows
ipconfig
```

**2. Configure Firewall:**
```bash
# Ubuntu/Debian
sudo ufw allow 8080
sudo ufw allow 4000

# CentOS/RHEL
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --add-port=4000/tcp --permanent
sudo firewall-cmd --reload

# macOS
# System Preferences → Security & Privacy → Firewall
# Allow incoming connections for Docker
```

**3. Update Moodle Configuration:**
```bash
# Edit customizations/config/config.php
$CFG->wwwroot = 'http://YOUR-IP-ADDRESS:8080';

# Restart Moodle
docker-compose restart moodle
```

### For Production Deployment

**1. Domain Configuration:**
```bash
# Edit customizations/config/config.php
$CFG->wwwroot = 'https://moodle.manfree.edu';
```

**2. SSL Certificate Setup:**
```yaml
# Add to docker-compose.yml
services:
  moodle:
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./ssl:/etc/ssl/certs
```

---

## 📦 Deployment Scenarios

### Scenario 1: Single Instructor PC

**Use Case**: One instructor, local students via LAN

**Setup:**
```bash
# Standard deployment
git clone <repository-url>
cd manfree-moodle-platform
docker-compose up -d

# Share IP with students
echo "Students access: http://$(hostname -I | awk '{print $1}'):8080"
```

**Daily Workflow:**
```bash
# Morning
./up.sh

# Evening  
./down.sh
```

### Scenario 2: Multiple Instructor PCs

**Use Case**: Multiple instructors, shared content

**Setup on each PC:**
```bash
# Clone repository
git clone <repository-url>
cd manfree-moodle-platform

# Sync customizations (if shared)
# Copy shared plugins/themes/config

# Deploy
docker-compose up -d
```

**Content Synchronization:**
```bash
# Option 1: Git-based sharing
git pull origin main  # Get latest customizations

# Option 2: Manual sync
rsync -av instructor1:/path/to/customizations/ ./customizations/
```

### Scenario 3: Offline Exam Environment

**Use Case**: Isolated network for secure exams

**Network Setup:**
```bash
# Create isolated WiFi network
# Configure router to block internet access
# Allow only local network communication
```

**Platform Configuration:**
```bash
# Disable external connections in config.php
$CFG->disableupdateautodeploy = true;
$CFG->disableupdatenotifications = true;

# Enable offline mode
$CFG->forced_plugin_settings = array(
    'tool_mobile' => array('enablemobilewebservice' => 0)
);
```

---

## 🔄 Migration & Backup

### Migrating to New PC

**1. Backup Current System:**
```bash
# On old PC
./auto-backup.sh

# Copy backup files
cp -r backup/ /path/to/external/storage/
```

**2. Setup New PC:**
```bash
# On new PC
git clone <repository-url>
cd manfree-moodle-platform

# Copy backup files
cp -r /path/to/external/storage/backup/ ./

# Deploy and restore
docker-compose up -d
./auto-restore.sh
```

### Bulk Deployment Script

**Create deployment script:**
```bash
#!/bin/bash
# deploy.sh - Automated deployment script

set -e

echo "🚀 Manfree Moodle Platform Deployment"

# Check requirements
command -v docker >/dev/null 2>&1 || { echo "Docker required"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "Docker Compose required"; exit 1; }

# Clone repository
if [ ! -d "manfree-moodle-platform" ]; then
    git clone <repository-url>
fi

cd manfree-moodle-platform

# Make scripts executable
chmod +x *.sh

# Deploy
echo "Starting deployment..."
docker-compose up -d

# Wait for services
echo "Waiting for services to start..."
sleep 30

# Check status
docker-compose ps

# Get access URL
IP=$(hostname -I | awk '{print $1}')
echo "✅ Deployment complete!"
echo "🌐 Access URL: http://$IP:8080"
echo "👨‍💼 Admin URL: http://$IP:8080/admin"
```

---

## 🔧 Post-Deployment Configuration

### Initial Moodle Setup

**1. Access Installation:**
```bash
# Open browser
http://localhost:8080/install.php

# Or for LAN access
http://YOUR-IP:8080/install.php
```

**2. Configuration Values:**
```
Language: English
Database Type: MariaDB
Database Host: mariadb
Database Name: moodle
Database User: moodle
Database Password: moodle123
Database Prefix: mdl_
```

**3. Site Information:**
```
Site Name: Manfree Technologies Institute - Learning Platform
Site Short Name: Manfree LMS
Admin Username: admin
Admin Password: [Choose strong password]
Admin Email: admin@manfree.edu
```

### Plugin Installation

**1. CodeRunner (Programming Exams):**
```bash
# Download CodeRunner plugin
wget https://moodle.org/plugins/download.php/xxxxx/qtype_coderunner.zip

# Place in plugins directory
cp qtype_coderunner.zip plugins/

# Restart platform
docker-compose restart moodle

# Complete installation in Moodle admin panel
```

**2. Additional Plugins:**
```bash
# Place plugin files in plugins/ directory
ls plugins/
# qtype_coderunner.zip
# qtype_drawio.zip
# quizaccess_seb.zip

# Restart and install via admin panel
docker-compose restart moodle
```

---

## 📊 Monitoring & Maintenance

### Health Checks

**Daily Checks:**
```bash
# Container status
docker-compose ps

# Resource usage
docker stats --no-stream

# Disk space
df -h

# Backup status
ls -la backup/ | tail -5
```

**Weekly Maintenance:**
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Clean Docker
docker system prune -f

# Backup cleanup (keep last 30 days)
find backup/ -name "*.tar.gz" -mtime +30 -delete

# Check logs
docker-compose logs --tail=100 moodle | grep -i error
```

### Performance Monitoring

**Resource Monitoring:**
```bash
# Create monitoring script
#!/bin/bash
# monitor.sh

echo "=== Moodle Platform Status ==="
echo "Date: $(date)"
echo

echo "Container Status:"
docker-compose ps

echo -e "\nResource Usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo -e "\nDisk Usage:"
df -h | grep -E "(Filesystem|/var/lib/docker)"

echo -e "\nRecent Errors:"
docker-compose logs --tail=20 moodle | grep -i error || echo "No recent errors"
```

---

## 🆘 Emergency Procedures

### Platform Won't Start

**Quick Fix:**
```bash
# Stop everything
docker-compose down

# Clean Docker
docker system prune -f

# Restart
docker-compose up -d

# Check logs
docker-compose logs
```

### Data Recovery

**From Backup:**
```bash
# Stop platform
docker-compose down

# Remove volumes
docker volume rm manfree-moodle-platform_moodle_data
docker volume rm manfree-moodle-platform_moodle_data_files
docker volume rm manfree-moodle-platform_mariadb_data

# Restore from backup
./auto-restore.sh

# Start platform
docker-compose up -d
```

### Contact Information

**For Technical Support:**
- Repository Issues: [GitHub Issues]
- Email: admin@manfree.edu
- Documentation: README.md, TROUBLESHOOTING.md

---

**Last Updated**: August 2025  
**Platform Version**: Moodle 4.5.6 (Build: 20250811)  
**Tested On**: Ubuntu 22.04, CentOS 8, macOS 13, Windows 11 WSL2
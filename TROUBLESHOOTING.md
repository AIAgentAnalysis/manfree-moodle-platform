# 🔧 Troubleshooting Guide

**Manfree Technologies Moodle Platform**  
*Common issues and solutions based on actual deployment experience*

---

## 🚨 Critical Issues & Solutions

### 1. Database Connection Failed

**Symptoms:**
```
Error: Database connection failed
Warning: mysqli::__construct(): (HY000/2002): No such file or directory
```

**Root Cause:** Incorrect database driver configuration

**Solution:**
```bash
# 1. Check if config.php exists
docker exec manfree_moodle ls -la /var/www/html/config.php

# 2. If exists, verify database type
docker exec manfree_moodle grep dbtype /var/www/html/config.php

# 3. Should show: $CFG->dbtype = 'mariadb';
# If shows 'mysqli', fix it:
```

Edit `customizations/config/config.php`:
```php
$CFG->dbtype = 'mariadb';  // NOT 'mysqli'
```

Then restart:
```bash
docker-compose restart moodle
```

### 2. PHP max_input_vars Error

**Symptoms:**
```
PHP setting max_input_vars must be at least 5000
```

**Solution:**
```bash
# 1. Check current setting
docker exec manfree_moodle php -i | grep max_input_vars

# 2. If shows 1000, rebuild container
docker-compose down
docker-compose up -d --build

# 3. Verify fix
docker exec manfree_moodle php -i | grep max_input_vars
# Should show: max_input_vars => 5000 => 5000
```

### 3. Container Won't Start

**Symptoms:**
```
manfree_moodle    Restarting
```

**Diagnosis:**
```bash
# Check logs
docker-compose logs moodle

# Common errors:
# - Permission denied
# - File system read-only
# - Database connection failed
```

**Solutions:**
```bash
# For permission errors
docker-compose down
docker system prune -f
docker-compose up -d --build

# For database issues
docker-compose restart mariadb
sleep 10
docker-compose restart moodle
```

---

## 🔍 Diagnostic Commands

### Check System Status
```bash
# All containers running?
docker-compose ps

# Container logs
docker-compose logs moodle
docker-compose logs mariadb
docker-compose logs jobe

# Resource usage
docker stats

# Network connectivity
docker exec manfree_moodle ping mariadb
```

### Check Moodle Configuration
```bash
# PHP configuration
docker exec manfree_moodle php -i | grep -E "(max_input_vars|memory_limit|upload_max_filesize)"

# Database connection test
docker exec manfree_moodle php -r "
\$conn = new mysqli('mariadb', 'moodle', 'moodle123', 'moodle');
echo \$conn->connect_error ? 'Connection failed' : 'Connection OK';
"

# File permissions
docker exec manfree_moodle ls -la /var/www/html/config.php
docker exec manfree_moodle ls -la /var/www/moodledata/
```

---

## 🌐 Network Issues

### Students Can't Access Platform

**Check Host IP:**
```bash
# Get your IP address
hostname -I
ip addr show | grep inet

# Test local access
curl http://localhost:8080

# Test network access
curl http://$(hostname -I | awk '{print $1}'):8080
```

**Firewall Issues:**
```bash
# Ubuntu/Debian
sudo ufw status
sudo ufw allow 8080

# CentOS/RHEL
sudo firewall-cmd --list-ports
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

**Port Conflicts:**
```bash
# Check what's using port 8080
sudo netstat -tlnp | grep 8080
sudo lsof -i :8080

# Kill conflicting process
sudo kill -9 <PID>
```

---

## 💾 Data Issues

### Lost Data After Restart

**Check Volumes:**
```bash
# List Docker volumes
docker volume ls

# Inspect volume
docker volume inspect manfree-moodle-platform_moodle_data

# Backup volumes
docker run --rm -v manfree-moodle-platform_moodle_data:/data -v $(pwd):/backup alpine tar czf /backup/moodle_data_backup.tar.gz -C /data .
```

### Backup/Restore Problems

**Manual Backup:**
```bash
# Create backup
./auto-backup.sh

# Check backup files
ls -la backup/

# Test backup integrity
tar -tzf backup/manfree-backup-*_moodle_data.tar.gz | head
```

**Manual Restore:**
```bash
# Stop containers
docker-compose down

# Remove volumes (CAUTION: Deletes all data)
docker volume rm manfree-moodle-platform_moodle_data
docker volume rm manfree-moodle-platform_moodle_data_files
docker volume rm manfree-moodle-platform_mariadb_data

# Start and restore
./up.sh
```

---

## 🔄 Performance Issues

### Slow Loading

**Check Resources:**
```bash
# Container resource usage
docker stats

# Host resources
free -h
df -h
```

**Optimize Docker:**
```bash
# Clean unused data
docker system prune -f

# Increase Docker memory (Docker Desktop)
# Settings → Resources → Memory: 4GB+
```

### Database Performance

**Check Database:**
```bash
# Database size
docker exec manfree_mariadb mysql -u moodle -pmoodle123 -e "
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'moodle';"

# Active connections
docker exec manfree_mariadb mysql -u moodle -pmoodle123 -e "SHOW PROCESSLIST;"
```

---

## 🛠️ Recovery Procedures

### Complete Reset (Nuclear Option)

**⚠️ WARNING: This deletes ALL data**

```bash
# Stop everything
docker-compose down

# Remove all containers and volumes
docker system prune -a -f
docker volume prune -f

# Rebuild from scratch
docker-compose up -d --build

# Reconfigure Moodle
# Go to http://localhost:8080/install.php
```

### Partial Reset (Keep Database)

```bash
# Stop containers
docker-compose down

# Remove only Moodle container
docker rm manfree_moodle
docker rmi manfree-moodle:v4.5.6

# Rebuild Moodle only
docker-compose up -d --build moodle
```

---

## 📞 Getting Help

### Information to Collect

When reporting issues, include:

```bash
# System information
uname -a
docker --version
docker-compose --version

# Container status
docker-compose ps
docker-compose logs --tail=50

# Configuration
cat docker-compose.yml
ls -la customizations/config/

# Resource usage
docker stats --no-stream
free -h
df -h
```

### Log Locations

```bash
# Moodle logs
docker-compose logs moodle > moodle.log

# Database logs  
docker-compose logs mariadb > mariadb.log

# System logs
journalctl -u docker > docker.log
```

---

## 🔄 Update Procedures

### Update Moodle Version

```bash
# Backup first
./auto-backup.sh

# Update moodle-source/ directory with new version
# Update Dockerfile version number
# Rebuild
docker-compose down
docker-compose up -d --build

# Run Moodle upgrade
# Visit: http://localhost:8080/admin
```

### Update Docker Images

```bash
# Pull latest base images
docker pull php:8.1-apache
docker pull mariadb:10.6
docker pull trampgeek/jobeinabox

# Rebuild
docker-compose down
docker-compose up -d --build
```

---

**Last Updated**: August 2025  
**Platform Version**: Moodle 4.5.6 with MariaDB 10.6.22
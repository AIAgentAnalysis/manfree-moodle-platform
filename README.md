# 🎓 Manfree Technologies Moodle Platform

**Official Moodle 4.5.6 Learning Management System for Manfree Technologies Institute**  
*Docker containerized platform for programming courses and offline exams*

> **Status**: ✅ **Production Ready** - Successfully built and tested
> **Version**: Moodle 4.5.6 (Build: 20250811) with MariaDB 10.6.22

---

## 📋 Table of Contents

1. [Quick Start](#-quick-start)
2. [What We Built](#-what-we-built)
3. [Installation Guide](#-installation-guide)
4. [Configuration Details](#-configuration-details)
5. [Issues & Solutions](#-issues--solutions)
6. [Repository Structure](#-repository-structure)
7. [User Workflows](#-user-workflows)
8. [Documentation](#-documentation)

📚 **[Complete Documentation Index](docs/README.md)** - All guides in one place

---

## 🚀 Quick Start

### Simple Bitnami-like Usage
```bash
# Clone repository (one-time setup)
git clone <repository-url>
cd manfree-moodle-platform

# Start platform (like Bitnami)
docker-compose up -d
# OR use our script: ./up.sh

# Access Moodle
# Open browser: http://localhost:8080

# Stop platform
docker-compose down
# OR use our script: ./down.sh
```

### Access Points
- **Local Access**: http://localhost:8080
- **LAN Access**: http://YOUR-IP:8080 (for students)
- **Global Access**: Use `global-access/` for worldwide access
- **Admin Panel**: http://localhost:8080/admin

---

## 🏢 What We Built

### Current Configuration (As of August 2025)

**Core Platform:**
- **Moodle Version**: 4.5.6 (Build: 20250811)
- **Database**: MariaDB 10.6.22
- **PHP Version**: 8.1.33
- **Web Server**: Apache 2.4.62
- **CodeRunner**: Jobe server for programming exams

**Key Settings Applied:**
- Database Type: `mariadb` (not mysqli)
- PHP max_input_vars: `5000` (increased from 1000)
- File Upload Limits: `100MB` (increased from 2MB default)
- Database Host: `mariadb` (container name)
- Data Directory: `/var/www/moodledata`
- Site URL: `http://localhost:8080`

**Docker Services:**
```yaml
Services Running:
- manfree_moodle:8080    # Main Moodle application
- manfree_mariadb:3306   # Database (internal)
- manfree_jobe:4000      # CodeRunner server
```

**Database Configuration:**
```php
$CFG->dbtype = 'mariadb';
$CFG->dbhost = 'mariadb';
$CFG->dbname = 'moodle';
$CFG->dbuser = 'moodle';
$CFG->dbpass = 'moodle123';
```

### What Works Now
✅ **Moodle Installation**: Complete and functional  
✅ **Database Connection**: MariaDB working properly  
✅ **PHP Configuration**: All requirements met  
✅ **Container Orchestration**: Docker Compose setup  
✅ **Local Access**: http://localhost:8080 working  
✅ **Admin Panel**: Accessible and configured  
✅ **Backup System**: Automatic backup/restore ready  

---

## 💻 System Requirements

### Minimum Requirements
- **OS**: Linux, macOS, or Windows with WSL2
- **Docker**: Docker Desktop or Docker Engine
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 10GB free space
- **Network**: LAN access for student connectivity

### Recommended Specifications
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Storage**: SSD with 20GB+ free space
- **Network**: Gigabit LAN for multiple students

---

## 📦 Installation Guide

### 1. Initial Setup (One-time)
```bash
# Install Docker (if not installed)
# Ubuntu/Debian:
sudo apt update && sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER
# Logout and login again

# Clone repository
git clone <repository-url>
cd manfree-moodle-platform

# Verify files are executable
ls -la *.sh
```

### 2. Pre-pull Docker Images (CRITICAL!)
```bash
# Pull required base images first (prevents build failures)
docker pull php:8.1-apache
docker pull mariadb:10.6
docker pull trampgeek/jobeinabox
sudo apt install git-lfs -y
sudo snap install ngrok

# This step is essential on fresh systems
```

### 3. First Launch
```bash
# Start platform
./up.sh

# Access Moodle setup
# Open browser: http://localhost:8080
# Follow Moodle installation wizard
```

### 3. Initial Configuration
1. **Database Settings** (auto-configured):
   - Host: `mariadb`
   - Database: `moodle`
   - User: `moodle`
   - Password: `moodle123`
   - **Important**: Use `mariadb` driver, not `mysqli`

2. **Admin Account**: Create during first setup
3. **Site Settings**: Configure institute details

---

## ⚙️ Configuration Details

### Docker Configuration

**Dockerfile Key Settings:**
```dockerfile
FROM php:8.1-apache
# PHP Extensions: gd, mysqli, pdo_mysql, zip, intl, soap, opcache, xsl
# Apache: mod_rewrite enabled
# PHP Settings:
#   - max_input_vars = 5000
#   - upload_max_filesize = 100M
#   - post_max_size = 100M
#   - max_execution_time = 300
#   - memory_limit = 256M
```

**docker-compose.yml Services:**
```yaml
services:
  mariadb:
    image: mariadb:10.6
    environment:
      MYSQL_ROOT_PASSWORD: manfree2024
      MYSQL_DATABASE: moodle
      MYSQL_USER: moodle
      MYSQL_PASSWORD: moodle123
  
  moodle:
    build: .
    ports: ["8080:80"]
    depends_on: [mariadb]
  
  jobe:
    image: trampgeek/jobeinabox
    ports: ["4000:80"]
```

### Moodle Configuration (config.php)

**Critical Settings Applied:**
```php
$CFG->dbtype = 'mariadb';        // NOT 'mysqli'
$CFG->dbhost = 'mariadb';        // Container name
$CFG->wwwroot = 'http://localhost:8080';
$CFG->dataroot = '/var/www/moodledata';
$CFG->directorypermissions = 0777;
$CFG->maxbytes = 104857600;      // 100MB file upload limit
```

---

## 🔧 Issues & Solutions

### Issues Encountered During Build

#### 1. Database Connection Failed
**Error**: `mysqli::__construct(): No such file or directory`

**Root Cause**: 
- Moodle was trying to use `mysqli` driver
- Should use `mariadb` driver for MariaDB 10.6+

**Solution Applied**:
```php
// Changed in config.php
$CFG->dbtype = 'mariadb';  // Was: 'mysqli'
```

#### 2. PHP max_input_vars Too Low
**Error**: `PHP setting max_input_vars must be at least 5000`

**Root Cause**: Default PHP setting was 1000

**Solution Applied**:
```dockerfile
# Added to Dockerfile
RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/moodle.ini
```

#### 3. File Permission Issues
**Error**: `chown: changing ownership: Read-only file system`

**Root Cause**: Docker entrypoint script trying to change read-only files

**Solution Applied**:
```bash
# Modified docker-entrypoint.sh
chown -R www-data:www-data /var/www/html 2>/dev/null || true
```

#### 4. Container Restart Loop
**Issue**: Moodle container kept restarting

**Root Cause**: Entrypoint script failing due to permission errors

**Solution Applied**: Added error handling to all chown commands

#### 5. File Upload Size Limit (2MB Default)
**Issue**: Default Moodle file upload limit too small for course materials

**Root Cause**: PHP and Moodle default settings limit uploads to 2MB

**Solution Applied**:
```php
// In customizations/config/config.php
$CFG->maxbytes = 104857600; // 100MB

// In Dockerfile PHP settings
upload_max_filesize = 100M
post_max_size = 100M
max_execution_time = 300
```

### Common Setup Issues & Fixes

#### 5. PHP 8.1-Apache Image Missing
**Error**: `Unable to find image 'php:8.1-apache:latest' locally`

**Root Cause**: Fresh system doesn't have base Docker images

**Solution Applied**:
```bash
# Pre-pull required images
docker pull php:8.1-apache
docker pull mariadb:10.6
docker pull trampgeek/jobeinabox

# Then start platform
./up.sh
```

#### Build Takes Too Long
**Normal**: First build takes 5-15 minutes
- Downloads Moodle source (~200MB)
- Installs PHP dependencies
- Configures Apache

**Check Progress**: `docker ps` to see running containers

#### HTTPS Warning
**Warning**: "Site not secured using HTTPS"
**Action**: Safe to ignore for local development
**Fix Later**: Add SSL certificates when deploying to production

#### Port Already in Use
**Error**: `Port 8080 already in use`
**Fix**: 
```bash
# Check what's using port 8080
sudo netstat -tlnp | grep 8080
# Kill the process or change port in docker-compose.yml
```

---

## 👥 User Workflows

### Remote Staff Workflow

#### Daily Routine
```bash
# Morning: Start platform
cd manfree-moodle-platform
./up.sh
# Platform starts + restores latest backup

# Share IP with students
hostname -I  # Get your IP address
# Students access: http://YOUR-IP:8080

# Evening: Stop platform
./down.sh
# Platform stops + creates backup automatically
```

#### Weekly Tasks
```bash
# Update repository (get latest changes)
git pull origin main

# Check backup status
ls -la backup/

# Clean old backups (optional)
find backup/ -name "*.tar.gz" -mtime +30 -delete
```

### Student Workflow

1. **Connect to Network**: Same WiFi/LAN as instructor
2. **Access Platform**: http://INSTRUCTOR-IP:8080
3. **Login**: Use provided credentials
4. **Take Exams**: Complete assignments/quizzes
5. **Submit Work**: All data saved automatically

### Administrator Workflow

#### Repository Management
```bash
# Create new release
git tag -a v1.0 -m "Release v1.0"
git push origin v1.0

# Update all staff installations
# Staff run: git pull origin main
```

#### Backup Management
```bash
# Manual backup
./auto-backup.sh

# Manual restore specific backup
# Edit auto-restore.sh to specify backup name
./auto-restore.sh
```

---

## 📁 Repository Structure

```
manfree-moodle-platform/
├── 📄 README.md                    # This documentation
├── 📄 staff-workflow.md            # Quick reference for staff
├── 📄 .gitignore                   # Git ignore rules
│
├── 🐳 Docker Configuration
│   ├── docker-compose.yml          # Container orchestration
│   ├── Dockerfile                  # Official Moodle build
│   └── docker-entrypoint.sh        # Container startup script
│
├── 🚀 Deployment Scripts
│   ├── up.sh                       # Start platform + restore
│   ├── down.sh                     # Stop platform + backup
│   ├── auto-backup.sh              # Backup system data
│   └── auto-restore.sh             # Restore latest backup
│
├── 📂 Content Directories
│   ├── plugins/                    # Moodle plugins (.zip files)
│   ├── themes/                     # Custom themes
│   └── backup/                     # Automatic backups
│       ├── manfree-backup-YYYYMMDD_HHMMSS_moodle_data.tar.gz
│       ├── manfree-backup-YYYYMMDD_HHMMSS_moodle_files.tar.gz
│       └── manfree-backup-YYYYMMDD_HHMMSS_mariadb_data.tar.gz
│
└── 📋 Documentation
    └── staff-workflow.md            # Quick staff reference
```

### File Descriptions

| File | Purpose | User |
|------|---------|------|
| `up.sh` | Start platform, restore backup | Staff |
| `down.sh` | Stop platform, create backup | Staff |
| `docker-compose.yml` | Container configuration | Admin |
| `Dockerfile` | Moodle build instructions | Admin |
| `auto-backup.sh` | Backup system data | System |
| `auto-restore.sh` | Restore system data | System |
| `staff-workflow.md` | Quick reference guide | Staff |

---

## ✨ Features

### Core Features
- ✅ **Official Moodle 4.0** (not Bitnami - more stable)
- ✅ **Offline Operation** (LAN-based, no internet required)
- ✅ **Docker Containerized** (easy deployment)
- ✅ **Automatic Backup/Restore** (data persistence)
- ✅ **CodeRunner Integration** (programming exams)
- ✅ **Plugin Support** (easy installation)
- ✅ **Multi-user Access** (students + instructors)

### Technical Stack
- **Moodle**: Official 4.0 from source
- **Database**: MariaDB 10.6
- **Web Server**: Apache with PHP 8.1
- **Code Execution**: Jobe server for CodeRunner
- **Containerization**: Docker Compose

### Network Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Staff PC      │    │   Student PC    │    │   Student PC    │
│   (Instructor)  │    │                 │    │                 │
│                 │    │                 │    │                 │
│ 🖥️  Moodle      │◄───┤ 🌐 Browser      │    │ 🌐 Browser      │
│    :8080        │    │    :8080        │    │    :8080        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                        ┌─────────────────┐
                        │   LAN Network   │
                        │  (WiFi/Switch)  │
                        └─────────────────┘
```

---

## 💾 Backup & Restore

### Automatic Backup System

**When backups are created:**
- Every time `./down.sh` is executed
- Before system shutdown
- Manual execution of `./auto-backup.sh`

**What gets backed up:**
1. **Moodle Core Files** (`moodle_data.tar.gz`) - ~71MB
2. **User Data & Files** (`moodle_files.tar.gz`) - ~3-4MB
3. **Database** (`mariadb_data.tar.gz`) - ~12MB

**Enhanced Features:**
- ✅ **Size Monitoring**: Warns about Git limits (>90MB files)
- ✅ **Automatic Cleanup**: Keeps only last 3 backups
- ✅ **Git LFS Ready**: Configured for large file handling
- ✅ **Storage Management**: Prevents unlimited growth

**Backup naming convention:**
```
manfree-backup-20250109_143022_moodle_data.tar.gz
manfree-backup-20250109_143022_moodle_files.tar.gz
manfree-backup-20250109_143022_mariadb_data.tar.gz
```

### Restore Process

**Automatic restore:**
- Every time `./up.sh` is executed
- Restores latest backup automatically
- If no backup exists, starts fresh

**Manual restore:**
```bash
# Restore specific backup
# Edit auto-restore.sh to specify backup timestamp
./auto-restore.sh
```

### Backup Management

```bash
# View all backups
ls -la backup/

# Check backup sizes
du -sh backup/*

# Manual backup
./auto-backup.sh

# Automatic cleanup (keeps last 3 backups)
# No manual cleanup needed - handled automatically
```

### Git LFS for Large Files

**When backup files exceed 90MB:**
```bash
# Install Git LFS (one-time setup)
git lfs install

# Track large files (already configured in .gitattributes)
git lfs track "*.tar.gz"

# Commit and push normally
git add .
git commit -m "Add backups with Git LFS"
git push
```

**Storage Limits:**
- **Without Git LFS**: 100MB per file limit
- **With Git LFS**: No practical limit
- **Auto-cleanup**: Keeps only 3 backups (~258MB max)

---

## 🔌 Plugin Management

### Installing Plugins

1. **Download Plugin**: Get `.zip` file from Moodle.org
2. **Place in Directory**: Copy to `./plugins/` folder
3. **Restart Platform**:
   ```bash
   ./down.sh
   ./up.sh
   ```
4. **Complete Installation**: Visit Moodle admin panel

### Recommended Plugins

| Plugin | Purpose | File |
|--------|---------|------|
| CodeRunner | Programming exams | `qtype_coderunner.zip` |
| Draw.io | Diagram questions | `qtype_drawio.zip` |
| Safe Exam Browser | Lockdown exams | `quizaccess_seb.zip` |

### Plugin Directory Structure
```
plugins/
├── qtype_coderunner.zip         # Programming questions
├── qtype_drawio.zip             # Diagram questions
├── mod_quiz_lockdown.zip        # Exam security
└── theme_custom.zip             # Custom themes
```

---

## 🌐 Network Configuration

### LAN Setup for Exams

1. **Instructor Setup**:
   ```bash
   # Start platform
   ./up.sh
   
   # Get IP address
   hostname -I
   # Example output: 192.168.1.100
   ```

2. **Student Access**:
   - Connect to same WiFi/LAN
   - Open browser: `http://192.168.1.100:8080`
   - Login with provided credentials

3. **Firewall Configuration**:
   ```bash
   # Ubuntu/Debian
   sudo ufw allow 8080
   
   # CentOS/RHEL
   sudo firewall-cmd --add-port=8080/tcp --permanent
   sudo firewall-cmd --reload
   ```

### Network Troubleshooting

```bash
# Check if Moodle is running
docker ps

# Test local access
curl http://localhost:8080

# Test network access
curl http://$(hostname -I | awk '{print $1}'):8080

# Check port availability
netstat -tlnp | grep 8080
```

---

## 🔧 Troubleshooting

### Common Issues

#### Platform Won't Start
```bash
# Check Docker status
docker ps -a

# View logs
docker-compose logs

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

#### Students Can't Connect
```bash
# Check firewall
sudo ufw status
sudo ufw allow 8080

# Verify IP address
hostname -I

# Test connectivity
ping INSTRUCTOR-IP
```

#### Database Issues
```bash
# Reset database (CAUTION: Deletes all data)
docker-compose down -v
docker volume prune
./up.sh
```

#### Backup/Restore Problems
```bash
# Check backup integrity
tar -tzf backup/latest_backup.tar.gz | head

# Manual backup
./auto-backup.sh

# Check Docker volumes
docker volume ls
```

### Performance Optimization

```bash
# Increase Docker memory (Docker Desktop)
# Settings → Resources → Memory: 4GB+

# Monitor resource usage
docker stats

# Clean unused Docker data
docker system prune
```

---

## 🛠️ Development

### Repository Management

```bash
# Clone for development
git clone <repository-url>
cd manfree-moodle-platform

# Create feature branch
git checkout -b feature/new-plugin

# Make changes and commit
git add .
git commit -m "Add new plugin support"

# Push changes
git push origin feature/new-plugin
```

### Customization

#### Adding Custom Themes
1. Place theme folder in `./themes/`
2. Restart platform
3. Activate in Moodle admin panel

#### Environment Variables
Edit `docker-compose.yml` to modify:
- Database credentials
- Port mappings
- Volume mounts

#### Custom Configuration
Create `.env` file for environment-specific settings:
```bash
# .env
MOODLE_DB_PASSWORD=custom_password
MOODLE_ADMIN_EMAIL=admin@manfree.edu
```

---

## 🎨 Customization Guide

### Directory Structure for Customizations

```
customizations/
├── config/
│   └── config.php              # Moodle configuration
├── themes/
│   └── manfree/               # Custom institute theme
├── plugins/
│   └── local_custom/          # Custom developed plugins
├── lang/
│   └── en/                    # Language customizations
└── patches/
    └── core_modifications.txt # Core file changes log
```

### Adding Custom Plugins

**For Downloaded Plugins (.zip files):**
1. Place `.zip` file in `plugins/` directory
2. Restart platform: `docker-compose restart moodle`
3. Complete installation via Moodle admin panel

**For Custom Developed Plugins:**
1. Develop in `customizations/plugins/`
2. Gets automatically deployed on container start
3. Protected during Moodle upgrades

### Theme Customization

**Install Downloaded Themes:**
1. Extract theme folder to `themes/` directory
2. Restart platform
3. Activate via Moodle admin → Appearance → Themes

**Custom Theme Development:**
1. Create theme in `customizations/themes/manfree/`
2. Protected during upgrades
3. Version controlled with Git

### Configuration Management

**Current Configuration (customizations/config/config.php):**
```php
$CFG->dbtype = 'mariadb';
$CFG->dbhost = 'mariadb';
$CFG->wwwroot = 'http://localhost:8080';
$CFG->dataroot = '/var/www/moodledata';
// Add custom settings here
```

**Environment-Specific Settings:**
- Development: `http://localhost:8080`
- LAN Access: `http://YOUR-IP:8080`
- Production: `https://moodle.manfree.edu`

---

## 📚 Documentation

### Complete Documentation Set

| Document | Purpose | Audience |
|----------|---------|----------|
| **README.md** | Main documentation & overview | All users |
| **[DEPLOYMENT.md](DEPLOYMENT.md)** | Platform-specific setup guide | IT Staff |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | Issue resolution guide | IT Staff |
| **[staff-workflow.md](staff-workflow.md)** | Daily usage guide | Instructors |

### Quick Reference

**Daily Commands:**
```bash
# Start platform
docker-compose up -d
# OR: ./up.sh

# Stop platform  
docker-compose down
# OR: ./down.sh

# Check status
docker-compose ps

# View logs
docker-compose logs moodle
```

**Access Points:**
- **Student Access**: http://localhost:8080
- **Admin Panel**: http://localhost:8080/admin
- **CodeRunner**: http://localhost:4000 (internal)

---

## 📞 Support

### Getting Help

**Step-by-Step Troubleshooting:**
1. **Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)** for common issues
2. **Review [DEPLOYMENT.md](DEPLOYMENT.md)** for setup problems
3. **Check container logs**: `docker-compose logs`
4. **Verify system requirements** in this README
5. **Contact technical support** with diagnostic information

### Reporting Issues

**Include this information:**
```bash
# System info
uname -a
docker --version
docker-compose --version

# Platform status
docker-compose ps
docker-compose logs --tail=50

# Resource usage
docker stats --no-stream
free -h
df -h
```

### Resources

**Official Documentation:**
- [Moodle Documentation](https://docs.moodle.org/)
- [Docker Documentation](https://docs.docker.com/)
- [MariaDB Documentation](https://mariadb.org/documentation/)

**Plugin Resources:**
- [CodeRunner Plugin](https://github.com/trampgeek/moodle-qtype_coderunner)
- [Moodle Plugins Directory](https://moodle.org/plugins/)
- [Jobe Server](https://github.com/trampgeek/jobe)

**Community Support:**
- [Moodle Forums](https://moodle.org/forums/)
- [Docker Community](https://forums.docker.com/)

---

## 📈 Project Status

### Current Status: ✅ Production Ready

**Completed Features:**
- ✅ Moodle 4.5.6 installation and configuration
- ✅ MariaDB 10.6.22 database setup
- ✅ Docker containerization with Docker Compose
- ✅ Automatic backup/restore system
- ✅ CodeRunner integration for programming exams
- ✅ Custom configuration management
- ✅ Multi-platform deployment support
- ✅ Comprehensive documentation

**Tested Environments:**
- ✅ Ubuntu 22.04 LTS
- ✅ Local development (localhost:8080)
- ✅ LAN access for students
- ✅ Container orchestration
- ✅ Database connectivity
- ✅ Plugin installation

**Performance Metrics:**
- **Build Time**: 5-15 minutes (first time)
- **Startup Time**: 30-60 seconds (subsequent)
- **Memory Usage**: ~2GB (recommended 4GB+)
- **Storage**: ~1GB (Moodle + database)

### Version History

| Version | Date | Changes |
|---------|------|----------|
| v1.0 | Aug 2025 | Initial release with Moodle 4.5.6 |
| | | MariaDB 10.6.22, Docker setup |
| | | Comprehensive documentation |

---

## 📄 License

This project is licensed under the same terms as Moodle (GPL v3+).

**Third-Party Components:**
- **Moodle**: GPL v3+ License
- **MariaDB**: GPL v2 License  
- **Docker Images**: Various licenses (see individual images)
- **CodeRunner/Jobe**: GPL v3+ License

---

## 🏢 About

**Built for Manfree Technologies Institute**  
*Empowering education through technology*

**Development Team:**
- Platform Architecture & Implementation
- Docker Containerization
- Documentation & Support

**Contact:**
- **Email**: admin@manfree.edu
- **Repository**: [GitHub Repository URL]
- **Documentation**: This README and linked guides

**Last Updated**: August 2025  
**Platform Version**: Moodle 4.5.6 (Build: 20250811)  
**Documentation Version**: 1.0

---

*"Simple like Bitnami, powerful like custom Moodle"* 🚀

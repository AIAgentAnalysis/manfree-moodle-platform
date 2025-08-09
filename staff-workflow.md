# 👥 Staff Workflow - Manfree Technologies Moodle Platform

## 🚀 Quick Start for Remote Staff

### **Daily Startup**
```bash
# Navigate to project folder
cd manfree-moodle-platform

# Start the platform (restores latest backup automatically)
./up.sh
```

### **Daily Shutdown**
```bash
# Stop platform (creates backup automatically)
./down.sh
```

## 🌐 Student Access

Once started, students can access:
- **Local**: http://localhost:8080
- **LAN**: http://YOUR-IP:8080

Find your IP: `hostname -I`

## 📚 Platform Features

- ✅ Official Moodle 4.0 (not Bitnami)
- ✅ CodeRunner for programming exams
- ✅ Offline LAN-based operation
- ✅ Automatic backup/restore
- ✅ Easy plugin installation

## 🔧 Adding Plugins

1. Place plugin files in `./plugins/` folder
2. Restart platform: `./down.sh && ./up.sh`
3. Complete installation in Moodle admin panel

## 💾 Backup Management

- Backups created automatically on shutdown
- Stored in `./backup/` folder
- Latest backup restored automatically on startup

## 🆘 Troubleshooting

### Platform won't start
```bash
# Check Docker status
docker ps

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

### Students can't connect
```bash
# Check firewall (Ubuntu)
sudo ufw allow 8080

# Find your IP
hostname -I
```

### Reset everything
```bash
# Stop platform
./down.sh

# Remove all data (CAUTION: This deletes everything!)
docker-compose down -v

# Start fresh
./up.sh
```

## 📞 Support

Contact system administrator for technical issues or access problems.
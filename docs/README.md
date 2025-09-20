# 📚 Documentation Index

Centralized documentation for Manfree Moodle Platform.

## 🚀 Quick Start
- **[Main README](../README.md)** - Platform overview and setup
- **[Staff Workflow](../staff-workflow.md)** - Daily operations guide

## ⚙️ Configuration
- **[File Upload Limits](../FILE-UPLOAD-LIMITS.md)** - 100MB upload configuration
- **[Docker Setup](../docker-compose.yml)** - Container configuration
- **[Environment Variables](../.env.example)** - Configuration template

## 🌐 Global Access
- **[Tunneling Guide](../tunneling/README.md)** - All tunnel solutions
- **[Router Port Forwarding](../ROUTER-PORT-FORWARDING.md)** - Network setup

## 🔧 Operations
- **[Deployment Guide](../DEPLOYMENT.md)** - Production deployment
- **[Troubleshooting](../TROUBLESHOOTING.md)** - Common issues
- **[Project Status](../PROJECT-STATUS.md)** - Current state

## 📁 File Structure
```
docs/                    # This directory
├── README.md           # This index
tunneling/              # Global access solutions
├── README.md           # Complete tunneling guide
├── bore-tunnel.sh      # Recommended (no payment risk)
├── cloudflare-tunnel.sh # Enterprise grade
├── ngrok-tunnel.sh     # Popular choice
├── pinggy-tunnel.sh    # SSH-based
├── localtunnel.sh      # Node.js required
└── serveo-tunnel.sh    # Local only
customizations/         # Persistent settings
├── config/config.php   # Moodle configuration
repository/             # Permanent file storage
├── Course1/            # Course folders
├── Course2/
└── Shared/
```

## 🎯 Common Tasks

### Start Platform
```bash
./up.sh
```

### Global Access
```bash
cd tunneling
./bore-tunnel.sh    # Recommended
```

### File Upload
- Configured for 100MB uploads
- See [FILE-UPLOAD-LIMITS.md](../FILE-UPLOAD-LIMITS.md)

### Backup/Restore
```bash
./down.sh    # Auto-backup
./up.sh      # Auto-restore option
```
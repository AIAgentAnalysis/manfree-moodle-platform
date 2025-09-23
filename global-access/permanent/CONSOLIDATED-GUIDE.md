# 📚 Permanent Tunnel - Complete Documentation

**Everything you need to know about the permanent tunnel solution**

---

## 📁 Files Overview

### 🔧 Scripts
- **`setup.sh`** - **Main script** - handles everything (setup, health checks, management)
- `auto-tunnel.sh` - Legacy daily operations script (replaced by setup.sh)
- `cloudflare-permanent.sh` - Legacy setup script (replaced by setup.sh)
- `tunnel-health-check.sh` - Legacy health check (integrated into setup.sh)

### 📖 Documentation
- **`README.md`** - **Quick start guide** - essential information
- `CONSOLIDATED-GUIDE.md` - This complete documentation
- `CLOUDFLARE-PERMANENT-TUNNEL.md` - Detailed technical guide
- `SCRIPT-DOCUMENTATION.md` - Technical script details

---

## 🎯 Current Recommended Approach

### ✅ Use This (Consolidated)
```bash
# One-time setup
cloudflared tunnel login
./global-access/permanent/setup.sh

# Daily management
./global-access/permanent/setup.sh --status
./global-access/permanent/setup.sh --health-check-fix
```

### ❌ Don't Use These (Legacy)
- `cloudflare-permanent.sh` - Replaced by `setup.sh`
- `auto-tunnel.sh` - Integrated into `setup.sh`
- `tunnel-health-check.sh` - Integrated into `setup.sh`

---

## 🚀 Complete Workflow

### 1. Initial Setup
```bash
# Authenticate once
cloudflared tunnel login

# Complete setup
./global-access/permanent/setup.sh
```

### 2. Daily Usage
```bash
# Start Moodle (automatically checks tunnel)
./up.sh

# Your URLs:
# Local:  http://localhost:8080
# Global: https://learning.manfreetechnologies.com
```

### 3. Management
```bash
# Check status
./global-access/permanent/setup.sh --status

# Fix issues
./global-access/permanent/setup.sh --health-check-fix

# Manual control
./global-access/permanent/setup.sh --start
./global-access/permanent/setup.sh --stop
./global-access/permanent/setup.sh --restart
```

### 4. OAuth 2 Configuration (Optional)
```bash
# For Google sign-in integration:
# 1. Enable OAuth 2 in Moodle admin panel
# 2. Configure Google service with Client ID/Secret
# 3. Update Google Cloud Console redirect URI:
#    https://learning.manfreetechnologies.com/admin/oauth2callback.php
# 4. Test OAuth callback:
curl -I https://learning.manfreetechnologies.com/admin/oauth2callback.php
```

---

## 🔄 Integration Points

### With `up.sh`
```bash
# Automatically runs health check and fixes issues
./up.sh
```

### With WSL Auto-Start
- Automatically configured during setup
- Checks tunnel when WSL starts
- Fixes issues if Moodle running but tunnel down

### With Moodle Configuration
- Smart URL detection in `customizations/config/config.php`
- Automatically switches between local and global URLs

---

## 🛠️ What Gets Created

### System Files
```
~/.cloudflared/
├── cert.pem                    # Authentication certificate
├── config.yml                  # Tunnel configuration
└── [tunnel-id].json           # Tunnel credentials

/etc/systemd/system/
└── cloudflared.service         # System service

~/
└── tunnel-autostart.sh        # WSL auto-start script
```

### Cloudflare Resources
- Named tunnel: `moodle-tunnel`
- DNS record: `learning.manfreetechnologies.com`
- CNAME pointing to tunnel endpoint

---

## 🔍 Troubleshooting

### Common Issues

#### "Not authenticated with Cloudflare"
```bash
cloudflared tunnel login
```

#### "Tunnel service not running"
```bash
./global-access/permanent/setup.sh --health-check-fix
```

#### "Global URL not working"
```bash
# Check status
./global-access/permanent/setup.sh --status

# Fix issues
./global-access/permanent/setup.sh --health-check-fix

# Check logs
sudo journalctl -u cloudflared -f
```

#### "Tunnel status shows inconsistency"
```bash
# Problem: Service running but tunnel shows "Not created"
# Status shows: ❌ Tunnel: Not created, ✅ Service: Running

# Fix commands:
cd manfree-moodle-platform

# Check what tunnels actually exist
cloudflared tunnel list

# If moodle-tunnel exists but not detected, re-run setup
./global-access/permanent/setup.sh --setup

# If no tunnels exist, create one
./global-access/permanent/setup.sh --setup

# Restart everything to ensure consistency
./down.sh && ./up.sh

# Verify final status
./global-access/permanent/setup.sh --status
```

#### "Google OAuth sign-in not working"
```bash
# 1. Enable OAuth 2 authentication in Moodle
# Site administration → Plugins → Authentication → Manage authentication
# Enable "OAuth 2" plugin

# 2. Test OAuth callback URL
curl -I https://learning.manfreetechnologies.com/admin/oauth2callback.php
# Should return 200 OK, not 404

# 3. Update Google Cloud Console
# Add redirect URI: https://learning.manfreetechnologies.com/admin/oauth2callback.php

# 4. Clear Moodle cache
./down.sh && ./up.sh
```

### Diagnostic Commands
```bash
# Complete system check
./global-access/permanent/setup.sh --status

# Test local access
curl -I http://localhost:8080

# Test global access
curl -I https://learning.manfreetechnologies.com

# Check service
sudo systemctl status cloudflared
```

---

## 📋 Scenarios Handled

### ✅ PC Restart
- Service auto-starts with system
- No manual intervention needed

### ✅ WSL Restart  
- Auto-check runs on WSL start
- Fixes tunnel if Moodle running

### ✅ Moodle Restart
- `./up.sh` checks tunnel health
- Auto-fixes any issues

### ✅ Configuration Issues
- Health check recreates missing files
- Auto-repair for common problems

### ✅ OAuth 2 Integration Issues
- Google sign-in configuration problems
- OAuth callback URL 404 errors
- Authentication plugin not enabled
- Redirect URI mismatches

---

## 🎯 Summary

### Before Consolidation
- ❌ Multiple scripts to manage
- ❌ Complex troubleshooting
- ❌ Scattered documentation

### After Consolidation
- ✅ **One script** (`setup.sh`) does everything
- ✅ **Simple commands** for all operations
- ✅ **Integrated documentation**
- ✅ **Automatic integration** with Moodle

### Key Benefits
- **Single Point of Control**: One script manages everything
- **Auto-Integration**: Works seamlessly with `./up.sh`
- **Self-Healing**: Automatically fixes common issues
- **WSL Ready**: Handles PC restarts and WSL scenarios
- **Zero Maintenance**: Set once, works forever

---

## 📚 Documentation Hierarchy

1. **`README.md`** - Start here (quick setup)
2. **`CONSOLIDATED-GUIDE.md`** - This file (complete overview)
3. **`CLOUDFLARE-PERMANENT-TUNNEL.md`** - Technical deep dive
4. **`SCRIPT-DOCUMENTATION.md`** - Script implementation details

**Everything is documented and consolidated for permanent tunnel solution!** 🎉
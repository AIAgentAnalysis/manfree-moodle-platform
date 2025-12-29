# VPL (Virtual Programming Lab) Setup Guide

## ✅ Integration Complete

VPL Jail Server has been successfully integrated and is running!

**Status:** ✅ Running and accessible  
**Internal URL:** `http://manfree_vpl_jail` (for Moodle configuration)  
**External URL:** `http://YOUR_SERVER_IP:8081` (for testing only)

## 📦 Current Architecture

```
manfree_network (Docker Bridge)
├── manfree_mariadb     → Database (Port 3306 internal)
├── manfree_moodle      → Moodle LMS (Port 8080)
├── manfree_jobe        → CodeRunner execution (Port 4000)
├── manfree_vpl_jail    → VPL execution (Port 8081) ✨ NEW
└── manfree_cloudflared → Cloudflare Tunnel
```

## 🚀 Quick Start

### Start Platform (includes VPL)
```bash
./up.sh
```

### Stop Platform
```bash
./down.sh
```

### Check VPL Status
```bash
docker ps | grep vpl
docker logs manfree_vpl_jail
```

## ⚙️ Moodle Configuration

### 1. Access VPL Settings
1. Login to Moodle as admin
2. Go to: **Site administration → Plugins → Activity modules → Virtual programming lab**

### 2. Update Execution Server
Change the execution server from:
```
https://demojail.dis.ulpgc.es
```

To (for internal Docker communication):
```
http://manfree_vpl_jail
```

Or (for external testing):
```
http://YOUR_SERVER_IP:8081
```

### 3. Test Connection
- Click "Save changes"
- Look for a connection test feature in VPL settings
- Should show successful connection

## 🧪 Testing VPL

### Create a Test Assignment
1. Go to a course → Turn editing on
2. Add an activity → Virtual programming lab
3. Configure:
   - Name: "Python Hello World Test"
   - Execution files: Add `vpl_run.sh`
   ```bash
   #!/bin/bash
   python3 vpl_execution
   ```
   - Requested files: `solution.py`
4. Submit test code:
   ```python
   print("Hello from VPL!")
   ```

## 🔧 Files Modified

### Docker Configuration
- ✅ `docker-compose.yml` - Added vpl-jail service
- ✅ `vpl-jail/Dockerfile` - VPL jail server image

### Startup Scripts
- ✅ `up.sh` - Shows VPL status on startup
- ✅ `down.sh` - Handles VPL shutdown

## 📊 Service Ports

| Service | Internal Port | External Port | Purpose |
|---------|--------------|---------------|---------|
| Moodle | 80 | 8080 | Web interface |
| Jobe | 80 | 4000 | CodeRunner execution |
| **VPL Jail** | **80** | **8081** | **VPL execution** |
| VPL Jail HTTPS | 443 | 8443 | Secure VPL (optional) |

## 🔐 Security Notes

### Internal Communication (Recommended)
- VPL jail communicates with Moodle via Docker network
- Configuration: `http://manfree_vpl_jail`
- Ports 8081/8443 are exposed but not required for operation
- More secure as traffic stays within Docker network

### External Access (Testing Only)
- Use `http://YOUR_IP:8081` only for testing
- Not recommended for production
- Consider firewall rules if exposed

## 🐛 Troubleshooting

### VPL Container Not Running
```bash
docker ps -a | grep vpl
docker logs manfree_vpl_jail
docker compose restart vpl-jail
```

### Connection Errors in Moodle
1. Verify container is running: `docker ps | grep vpl`
2. Check VPL logs: `docker logs manfree_vpl_jail`
3. Verify network: `docker network inspect manfree_network`
4. Test connectivity from Moodle container:
   ```bash
   docker exec -it manfree_moodle curl -v http://manfree_vpl_jail
   ```

### Configuration Issues
```bash
# Check VPL configuration
docker exec -it manfree_vpl_jail cat /etc/vpl/vpl-jail-system.conf

# Rebuild if needed
docker compose down vpl-jail
docker compose build vpl-jail --no-cache
docker compose up -d vpl-jail
```

## 📝 Supported Languages

VPL Jail Server (standard installation) includes:
- ✅ Python 3
- ✅ Java (OpenJDK 11)
- ✅ C / C++ (GCC)
- ✅ JavaScript (Node.js)
- ✅ PHP
- ✅ Perl
- ✅ Ruby
- ✅ Shell scripting

## 🔄 Updates

### Rebuild VPL Jail
```bash
cd /root/workspace/manfree-moodle-platform
docker compose down vpl-jail
docker compose build vpl-jail --no-cache
docker compose up -d vpl-jail
```

### Check VPL Version
```bash
docker exec -it manfree_vpl_jail /usr/sbin/vpl/vpl-jail-system --version
```

## 📚 Additional Resources

- VPL Plugin: https://moodle.org/plugins/mod_vpl
- VPL Documentation: https://vpl.dis.ulpgc.es/
- VPL Jail System: https://github.com/jcrodriguez-dis/vpl-jail-system
- Moodle VPL Guide: https://docs.moodle.org/en/VPL

## ✨ What's Next?

1. **Configure VPL in Moodle** (see above)
2. **Create your first VPL assignment**
3. **Test with sample code**
4. **Set up automatic grading** (optional)
5. **Configure test cases** (optional)

---

**Installation Date:** December 29, 2025  
**Platform Version:** Manfree Moodle v4.5.6  
**VPL Jail Version:** Latest (master branch)

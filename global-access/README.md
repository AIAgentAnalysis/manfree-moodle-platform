# 🌐 Global Access Solutions

Make your Moodle platform accessible from anywhere in the world.

## 📁 Folder Structure

```
global-access/
├── permanent/          # Static URLs with your own domain
│   ├── CLOUDFLARE-PERMANENT-TUNNEL.md
│   ├── cloudflare-permanent.sh
│   └── auto-tunnel.sh
└── temporary/          # Quick tunnels with changing URLs
    ├── README.md
    ├── INSTALLATION-GUIDE.md
    ├── bore-tunnel.sh
    ├── cloudflare-tunnel.sh
    ├── ngrok-tunnel.sh
    ├── pinggy-tunnel.sh
    ├── localtunnel.sh
    └── serveo-tunnel.sh
```

## 🎯 Choose Your Solution

### 🏆 Permanent Solutions (Recommended)
**Best for: Production, Google OAuth, Real Classes**

| Solution | URL Example | Cost | Setup Time |
|----------|-------------|------|------------|
| **Cloudflare Tunnel** | `learning.manfreetechnologies.com` | Free* | 15 min |

*Requires owning a domain (~$10/year)

**Features:**
- ✅ **Static URL** - Never changes
- ✅ **Automatic HTTPS** - SSL certificates included
- ✅ **Auto-start** - Integrated with Moodle startup
- ✅ **Google OAuth Ready** - Perfect for authentication
- ✅ **Professional** - Enterprise-grade infrastructure

**Quick Start:**
```bash
cd global-access/permanent
./cloudflare-permanent.sh
```

### ⚡ Temporary Solutions
**Best for: Quick Testing, Demos, Short Sessions**

| Solution | URL Example | Time Limit | Features |
|----------|-------------|------------|----------|
| **Bore.pub** | `https://bore.pub:12345` | None | No payment risk |
| **Cloudflare Quick** | `https://abc.trycloudflare.com` | None | Enterprise grade |
| **Ngrok** | `https://abc.ngrok-free.app` | 2 hours | Traffic monitoring |
| **Pinggy** | `https://abc.pinggy.io` | 60 min | SSH-based |
| **LocalTunnel** | `https://custom.loca.lt` | None | Custom subdomain |

**Quick Start:**
```bash
cd global-access/temporary
./bore-tunnel.sh        # Recommended for testing
```

## 🚀 Integration with Moodle

### Automatic Startup
When you run `./up.sh`, the platform automatically:
1. **Starts Moodle containers**
2. **Starts permanent tunnel** (if configured)
3. **Shows all access URLs**

### Smart URL Detection
Your Moodle automatically detects how it's being accessed:
- `localhost:8080` → HTTP mode
- `learning.manfreetechnologies.com` → HTTPS mode
- `ngrok.io` domains → HTTPS mode
- Other tunnel domains → HTTPS mode

## 📋 Quick Commands

### Setup Permanent Access (One-time)
```bash
cd global-access/permanent
./cloudflare-permanent.sh
```

### Daily Operations
```bash
# Start Moodle + Tunnel
./up.sh

# Check tunnel status
./global-access/permanent/auto-tunnel.sh status

# Stop everything
./down.sh
```

### Quick Testing
```bash
# Start temporary tunnel
cd global-access/temporary
./bore-tunnel.sh
```

## 🎯 Recommendations

### For Production Use
→ **Use Permanent Solution** with your domain
- Reliable for students
- Works with Google OAuth
- Professional appearance
- Auto-starts with Moodle

### For Quick Testing
→ **Use Temporary Solution**
- No domain needed
- Instant setup
- Perfect for demos

### For Development
→ **Use Local Access**
- Fastest performance
- No internet dependency
- `http://localhost:8080`

## 📚 Documentation

- **[Permanent Setup Guide](permanent/CLOUDFLARE-PERMANENT-TUNNEL.md)** - Complete setup instructions
- **[Temporary Solutions Guide](temporary/INSTALLATION-GUIDE.md)** - All temporary options
- **[Main README](../README.md)** - Platform overview

## 🆘 Support

**Common Issues:**
- DNS propagation delays (wait 15-30 minutes)
- Firewall blocking connections
- Moodle not running locally

**Get Help:**
- Check troubleshooting sections in guides
- Review service logs: `sudo journalctl -u cloudflared -f`
- Test local access first: `curl -I http://localhost:8080`
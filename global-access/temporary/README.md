# Tunneling Solutions for Moodle

All tunneling scripts and documentation in one place.

## Available Tunnels

### 1. Bore.pub ⭐ (Recommended - Completely Free)
```bash
./bore-tunnel.sh
```
- **Free**: No account, no payment info needed
- **Reliable**: Stable connections
- **URL**: Random bore.pub subdomain
- **Best for**: Production use without payment risk

### 2. Cloudflare Tunnel (Enterprise Grade)
```bash
./cloudflare-tunnel.sh
```
- **Free**: Unlimited usage
- **Reliable**: Enterprise infrastructure
- **URL**: Random trycloudflare.com subdomain
- **Best for**: High reliability needs

### 3. Ngrok (Popular Choice)
```bash
./ngrok-tunnel.sh
```
- **Free**: 2 hours sessions, then reconnect
- **Reliable**: Well-known service
- **URL**: Random ngrok.io subdomain
- **Best for**: Familiar users, short sessions

### 4. Pinggy.io (Simple SSH)
```bash
./pinggy-tunnel.sh
```
- **Free**: 60-minute sessions
- **Simple**: SSH-based, no installation
- **URL**: Random pinggy.io subdomain
- **Best for**: Quick testing

### 5. LocalTunnel (Node.js based)
```bash
./localtunnel.sh
```
- **Free**: Unlimited usage
- **Requires**: Node.js/npm installation
- **URL**: Custom subdomain available
- **Best for**: When you have Node.js

### 6. Serveo (Local SSH only)
```bash
./serveo-tunnel.sh
```
- **Free**: SSH-based
- **Limitation**: Only works from admin PC
- **Best for**: Local testing only

## Quick Start

1. **Make scripts executable:**
```bash
chmod +x tunneling/*.sh
```

2. **Start your preferred tunnel:**
```bash
cd tunneling
./bore-tunnel.sh        # Recommended
```

3. **Share the URL** with students

📖 **[Complete Installation Guide](INSTALLATION-GUIDE.md)** - Detailed setup for all services

## Comparison

| Service | Free | Reliable | Account Needed | Payment Risk | Time Limit |
|---------|------|----------|----------------|--------------|------------|
| Bore.pub | ✅ | ✅ | ❌ | ❌ | None |
| Cloudflare | ✅ | ✅ | ❌ | ❌ | None |
| Ngrok | ✅ | ✅ | ❌ | ❌ | 2 hours |
| Pinggy | ✅ | ⚠️ | ❌ | ❌ | 60 min |
| LocalTunnel | ✅ | ⚠️ | ❌ | ❌ | None |
| Serveo | ✅ | ❌ | ❌ | ❌ | None |

## Troubleshooting

### Tunnel Not Working
1. Check if Moodle is running: `docker ps`
2. Test local access: `curl http://localhost:8080`
3. Try different tunnel service

### Connection Errors
- Normal for image loading cancellations
- Main site should still be accessible
- Restart tunnel if needed

## Notes
- Keep terminal open while tunnel is active
- URL changes each time you restart tunnel
- For permanent URLs, consider cloud hosting platforms
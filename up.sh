#!/bin/bash
set -e

echo "🚀 Starting Manfree Technologies Moodle Platform..."

# Ask before restoring backup
if [ -f "./auto-restore.sh" ] && [ -d "./backup" ] && [ "$(ls -A ./backup/*.tar.gz 2>/dev/null)" ]; then
    echo "📦 Backup found. Restore it?"
    read -p "Restore backup? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Restoring backup..."
        ./auto-restore.sh
    else
        echo "⏭️  Skipping backup restore"
    fi
fi

# Build and start containers
docker compose up -d --build

# Auto-setup and start tunnel
if [ -f "./global-access/permanent/setup.sh" ]; then
    chmod +x ./global-access/permanent/setup.sh
    
    # Check if tunnel is set up, if not run full setup
    if ! systemctl list-unit-files | grep -q "cloudflared.service" || ! [ -f ~/.cloudflared/cert.pem ]; then
        echo "🔧 Running initial tunnel setup..."
        ./global-access/permanent/setup.sh --setup 2>/dev/null || {
            echo "⚠️  Tunnel setup requires authentication. Run:"
            echo "   cloudflared tunnel login"
            echo "   Then restart: ./up.sh"
        }
    else
        # Tunnel already set up, just health check and fix
        ./global-access/permanent/setup.sh --health-check-fix
    fi
else
    echo "⚠️  Permanent tunnel script not found."
fi

echo "✅ Platform started successfully!"
echo ""
echo "📦 Services Running:"
echo "   🎓 Moodle LMS        → http://localhost:8080"
echo "   🏃 CodeRunner (Jobe) → http://localhost:4000"
echo ""
echo "🌐 LAN Access: http://$(hostname -I | awk '{print $1}'):8080"
if systemctl is-active cloudflared &>/dev/null; then
    echo "🌍 Global Access: https://learning.manfreetechnologies.com"
    echo "📊 Tunnel Status: Active and running"
    echo "🔄 Auto-start: Configured for WSL restarts"
else
    echo "⚠️  Global access not available - tunnel service not running"
fi
echo ""
echo "👤 First time setup required - create admin account"
echo "🔧 CodeRunner available at: http://localhost:4000"
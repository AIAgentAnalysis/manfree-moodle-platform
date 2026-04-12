#!/bin/bash
set -e

echo "🛑 Stopping Manfree Technologies Moodle Platform..."

# Ask before creating backup
if [ -f "./auto-backup.sh" ]; then
    echo "💾 Create backup before stopping?"
    read -p "Create backup? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "💾 Creating backup..."
        if ! ./auto-backup.sh; then
            echo "⚠️  Backup creation failed, continuing with shutdown"
        fi
    else
        echo "⏭️  Skipping backup creation"
    fi
fi

# Stop containers
docker compose down

# Show tunnel status
if systemctl is-active cloudflared &>/dev/null; then
    echo "🌍 Tunnel still running: https://learning.manfreetechnologies.com"
    echo "   Stop with: sudo systemctl stop cloudflared"
fi

echo "✅ Platform stopped successfully!"
echo "💾 Backup saved (if backup script exists)"
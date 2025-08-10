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
docker-compose up -d --build

echo "✅ Platform started successfully!"
echo "🌐 Access: http://localhost:8080"
echo "🌐 LAN Access: http://$(hostname -I | awk '{print $1}'):8080"
echo "👤 First time setup required - create admin account"
echo "🔧 CodeRunner available at: http://localhost:4000"
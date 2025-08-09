#!/bin/bash
set -e

echo "🚀 Starting Manfree Technologies Moodle Platform..."

# Restore backup if exists
if [ -f "./auto-restore.sh" ]; then
    ./auto-restore.sh
fi

# Build and start containers
docker-compose up -d --build

echo "✅ Platform started successfully!"
echo "🌐 Access: http://localhost:8080"
echo "🌐 LAN Access: http://$(hostname -I | awk '{print $1}'):8080"
echo "👤 First time setup required - create admin account"
echo "🔧 CodeRunner available at: http://localhost:4000"
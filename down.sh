#!/bin/bash
set -e

echo "🛑 Stopping Manfree Technologies Moodle Platform..."

# Create backup before stopping
if [ -f "./auto-backup.sh" ]; then
    ./auto-backup.sh
fi

# Stop containers
docker-compose down

echo "✅ Platform stopped successfully!"
echo "💾 Backup saved (if backup script exists)"
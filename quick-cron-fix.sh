#!/bin/bash

# Quick Moodle Cron Fix Script
# Run this when you have server access to process pending AI tasks

echo "🔄 Running Moodle cron to process AI tasks..."

# Check if Docker container is running
if ! docker ps | grep -q "manfree_moodle"; then
    echo "❌ Moodle container not running. Starting..."
    docker-compose up -d moodle
    sleep 10
fi

# Run cron inside Moodle container
echo "⚡ Executing cron tasks..."
docker exec manfree_moodle php /var/www/html/admin/cli/cron.php

echo "✅ Cron execution completed!"
echo "📊 Check Site Administration → Server → Scheduled tasks for 'Last run' timestamps"
echo "🤖 AI question generation should now progress past 0%"
#!/bin/bash

# Update File Upload Limits - Manfree Moodle Platform
# This script increases file upload limits from 2MB to 100MB

echo "🔧 Updating Moodle file upload limits to 100MB..."

# Stop current containers
echo "📦 Stopping containers..."
docker-compose down

# Rebuild with new PHP settings
echo "🏗️ Rebuilding containers with new upload limits..."
docker-compose build --no-cache moodle

# Start containers
echo "🚀 Starting updated containers..."
docker-compose up -d

# Wait for containers to be ready
echo "⏳ Waiting for containers to start..."
sleep 30

echo "✅ Upload limits updated! Next steps:"
echo ""
echo "1. Access Moodle admin: http://localhost:8080/admin"
echo "2. Go to: Site administration > Server > HTTP"
echo "3. Set 'Maximum uploaded file size' to 100MB"
echo "4. Go to: Site administration > Courses > Course default settings"
echo "5. Set 'Maximum upload size' to 100MB"
echo ""
echo "🔍 To verify PHP settings:"
echo "   docker exec manfree_moodle php -i | grep -E 'upload_max_filesize|post_max_size'"
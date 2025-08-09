#!/bin/bash
set -e

# Moodle Version Upgrade Script
# Safely upgrades Moodle while preserving all data

CURRENT_VERSION=$(cat VERSION | grep MOODLE_VERSION | cut -d'=' -f2)
NEW_VERSION=${1:-"v4.0.13"}  # Default to next patch version

echo "🔄 Moodle Version Upgrade"
echo "========================="
echo "Current: $CURRENT_VERSION"
echo "Target:  $NEW_VERSION"
echo ""

# Confirmation
read -p "Continue with upgrade? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Upgrade cancelled"
    exit 1
fi

echo "📦 Step 1: Creating backup before upgrade..."
./auto-backup.sh

echo "🛑 Step 2: Stopping current platform..."
docker-compose down

echo "🔧 Step 3: Downloading new Moodle version..."
rm -rf moodle-source
git clone --depth 1 --branch $NEW_VERSION https://github.com/moodle/moodle.git moodle-source
rm -rf moodle-source/.git
sed -i "s/echo \"v[0-9]\+\.[0-9]\+\.[0-9]\+\"/echo \"$NEW_VERSION\"/g" Dockerfile

echo "📝 Step 4: Updating VERSION file..."
sed -i "s/MOODLE_VERSION=.*/MOODLE_VERSION=$NEW_VERSION/" VERSION
sed -i "s/BUILD_DATE=.*/BUILD_DATE=$(date +%Y-%m-%d)/" VERSION

echo "🐳 Step 5: Rebuilding with new version..."
docker-compose build --no-cache

echo "🔄 Step 6: Starting with data restore..."
./up.sh

echo "✅ Upgrade completed!"
echo "🌐 Access: http://localhost:8080"
echo "📋 Visit Moodle admin to complete database upgrade"
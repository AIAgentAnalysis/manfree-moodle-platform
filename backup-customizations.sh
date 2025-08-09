#!/bin/bash
set -e

echo "💾 Backing up current customizations..."

# Create customizations backup directory
mkdir -p customizations/{config,themes,plugins,lang,patches}

# Backup config if it exists and is customized
if docker exec manfree_moodle test -f /var/www/html/config.php 2>/dev/null; then
    echo "Backing up config.php..."
    docker cp manfree_moodle:/var/www/html/config.php customizations/config/config.php
fi

# Backup custom themes (exclude default Moodle themes)
echo "Backing up custom themes..."
docker exec manfree_moodle find /var/www/html/theme -maxdepth 1 -type d ! -name "theme" ! -name "boost" ! -name "classic" -exec basename {} \; 2>/dev/null | while read theme; do
    if [ "$theme" != "theme" ]; then
        docker cp manfree_moodle:/var/www/html/theme/$theme customizations/themes/ 2>/dev/null || true
    fi
done

# Backup local plugins
echo "Backing up local plugins..."
docker exec manfree_moodle find /var/www/html -name "local" -type d 2>/dev/null | while read localdir; do
    docker cp manfree_moodle:$localdir customizations/plugins/ 2>/dev/null || true
done

# Backup language customizations
echo "Backing up language customizations..."
docker exec manfree_moodle find /var/www/html/lang -name "local" -type d 2>/dev/null | while read langdir; do
    docker cp manfree_moodle:$langdir customizations/lang/ 2>/dev/null || true
done

echo "✅ Customizations backed up to ./customizations/"
echo "📋 These will be automatically restored during upgrades"
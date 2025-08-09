#!/bin/bash
set -e

# Install plugins if they exist
if [ -d "/tmp/plugins" ] && [ "$(ls -A /tmp/plugins)" ]; then
    echo "Installing plugins..."
    cp -r /tmp/plugins/* /var/www/html/ 2>/dev/null || true
    chown -R www-data:www-data /var/www/html 2>/dev/null || true
fi

# Install themes if they exist
if [ -d "/tmp/themes" ] && [ "$(ls -A /tmp/themes)" ]; then
    echo "Installing themes..."
    cp -r /tmp/themes/* /var/www/html/theme/
    chown -R www-data:www-data /var/www/html/theme
fi

# Restore customizations if they exist
if [ -d "/tmp/customizations" ]; then
    echo "Restoring customizations..."
    
    # Restore custom config
    if [ -f "/tmp/customizations/config/config.php" ]; then
        cp /tmp/customizations/config/config.php /var/www/html/config.php
    fi
    
    # Restore custom themes
    if [ -d "/tmp/customizations/themes" ]; then
        cp -r /tmp/customizations/themes/* /var/www/html/theme/ 2>/dev/null || true
    fi
    
    # Restore custom plugins
    if [ -d "/tmp/customizations/plugins" ]; then
        cp -r /tmp/customizations/plugins/* /var/www/html/ 2>/dev/null || true
    fi
    
    # Restore language customizations
    if [ -d "/tmp/customizations/lang" ]; then
        cp -r /tmp/customizations/lang/* /var/www/html/lang/ 2>/dev/null || true
    fi
    
    chown -R www-data:www-data /var/www/html 2>/dev/null || true
fi

# Execute the original command
exec "$@"
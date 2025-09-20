#!/bin/bash

# Setup WSL Auto-start for Tunnel
# Run this once to enable automatic tunnel startup

echo "🔧 Setting up WSL auto-start for tunnel..."

# Make auto-start script executable
chmod +x auto-start-tunnel.sh

# Add to WSL startup (via .bashrc)
BASHRC_LINE="# Auto-start Moodle tunnel check"
SCRIPT_LINE="cd ~/workspace/manfree-moodle-platform && ./auto-start-tunnel.sh 2>/dev/null &"

# Check if already added
if ! grep -q "auto-start-tunnel.sh" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "$BASHRC_LINE" >> ~/.bashrc
    echo "$SCRIPT_LINE" >> ~/.bashrc
    echo "✅ Added to ~/.bashrc"
else
    echo "✅ Already configured in ~/.bashrc"
fi

# Create systemd user service for more reliable startup
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/moodle-tunnel-check.service << EOF
[Unit]
Description=Moodle Tunnel Health Check
After=network.target

[Service]
Type=oneshot
WorkingDirectory=%h/workspace/manfree-moodle-platform
ExecStart=%h/workspace/manfree-moodle-platform/auto-start-tunnel.sh
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF

# Enable the service
systemctl --user daemon-reload
systemctl --user enable moodle-tunnel-check.service

echo "✅ WSL auto-start configured!"
echo ""
echo "📋 What this does:"
echo "   • Checks tunnel when WSL starts"
echo "   • Fixes tunnel if Moodle is running but tunnel is down"
echo "   • Runs automatically in background"
echo ""
echo "🔄 To test: restart WSL or run ./auto-start-tunnel.sh"
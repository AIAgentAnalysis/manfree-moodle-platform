#!/bin/bash

# Cloudflare Tunnel Setup - Free & Reliable Alternative to ngrok
echo "🌐 Setting up Cloudflare Tunnel for Moodle..."

# Install cloudflared
if ! command -v cloudflared &> /dev/null; then
    echo "📦 Installing cloudflared..."
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb
    rm cloudflared-linux-amd64.deb
fi

# Start tunnel
echo "🚀 Starting Cloudflare tunnel..."
echo "📋 Copy the URL that appears below:"
cloudflared tunnel --url http://localhost:8080

# Note: This creates a temporary tunnel
# For permanent tunnel, follow Cloudflare Zero Trust setup
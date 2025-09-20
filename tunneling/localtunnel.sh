#!/bin/bash

# LocalTunnel - Simple ngrok alternative
echo "🌐 Setting up LocalTunnel for Moodle..."

# Install localtunnel
if ! command -v lt &> /dev/null; then
    echo "📦 Installing LocalTunnel..."
    sudo npm install -g localtunnel
fi

# Start tunnel with custom subdomain
echo "🚀 Starting LocalTunnel..."
echo "📋 Your Moodle will be available at: https://manfree-moodle.loca.lt"
lt --port 8080 --subdomain manfree-moodle
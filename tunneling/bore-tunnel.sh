#!/bin/bash

# Bore.pub Tunnel - Completely Free, No Account Needed
echo "🌐 Setting up Bore.pub tunnel for Moodle..."

# Download bore if not exists
if [ ! -f "bore" ]; then
    echo "📦 Downloading bore..."
    curl -L https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz | tar xz
    chmod +x bore
fi

# Start tunnel
echo "🚀 Starting Bore.pub tunnel..."
echo "📋 Your Moodle will be available at the URL shown below:"
./bore local 8080 --to bore.pub
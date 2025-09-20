#!/bin/bash

# Pinggy.io Tunnel - Free SSH-based tunnel
echo "🌐 Setting up Pinggy.io tunnel for Moodle..."
echo "📋 Your Moodle will be available at the URL shown below:"
echo "🚀 Starting tunnel..."

# Create SSH tunnel
ssh -p 443 -R0:localhost:8080 a.pinggy.io
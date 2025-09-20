#!/bin/bash

# Serveo - SSH-based tunnel (no installation needed)
echo "🌐 Setting up Serveo tunnel for Moodle..."
echo "📋 Your Moodle will be available at a serveo.net URL"
echo "🚀 Starting tunnel..."

# Create SSH tunnel
ssh -R 80:localhost:8080 serveo.net
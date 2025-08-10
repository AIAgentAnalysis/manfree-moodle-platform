#!/bin/bash

echo "🌐 Starting Global Tunnel for Moodle Platform..."
echo "📍 Manfree Technologies - Learning Management System"
echo ""

# Check if Moodle is running
if ! curl -s http://localhost:8080 > /dev/null; then
    echo "❌ Moodle not running. Start it first with: ./up.sh"
    exit 1
fi

# Check if ngrok is installed and configured
if ! command -v ngrok &> /dev/null; then
    echo "❌ Ngrok not found. Please install it first:"
    echo "   1. Download: https://ngrok.com/download"
    echo "   2. Create account: https://dashboard.ngrok.com/signup"
    echo "   3. Add authtoken: ngrok config add-authtoken YOUR_TOKEN"
    exit 1
fi

# Check if authtoken is configured
if ! ngrok config check &> /dev/null; then
    echo "❌ Ngrok authtoken not configured."
    echo "   1. Create account: https://dashboard.ngrok.com/signup"
    echo "   2. Get authtoken: https://dashboard.ngrok.com/get-started/your-authtoken"
    echo "   3. Run: ngrok config add-authtoken YOUR_TOKEN"
    exit 1
fi

echo "✅ Moodle platform is running"
echo "✅ Ngrok is configured"
echo ""
echo "🚀 Creating secure global tunnel..."
echo "⚠️  WARNING: This makes your Moodle accessible worldwide!"
echo "🔗 Share the HTTPS URL only with authorized users"
echo "🛡️  Platform automatically detects tunnel and configures SSL"
echo "🛑 Press Ctrl+C to stop the tunnel"
echo ""
echo "📊 Monitor traffic at: http://127.0.0.1:4040"
echo ""

# Start ngrok tunnel with custom subdomain if available
ngrok http 8080 --log=stdout
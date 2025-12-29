#!/bin/bash

echo "🔍 VPL Jail Server Health Check"
echo "================================"
echo ""

# Check if container is running
if docker ps | grep -q manfree_vpl_jail; then
    echo "✅ VPL Jail container is running"
    
    # Get container ID
    CONTAINER_ID=$(docker ps | grep manfree_vpl_jail | awk '{print $1}')
    echo "   Container ID: $CONTAINER_ID"
    
    # Check logs for errors
    echo ""
    echo "📋 Recent logs:"
    docker logs --tail 10 manfree_vpl_jail 2>&1 | sed 's/^/   /'
    
    # Test internal connectivity
    echo ""
    echo "🔌 Testing internal connectivity..."
    if docker exec manfree_moodle curl -s -o /dev/null -w "%{http_code}" http://manfree_vpl_jail 2>/dev/null | grep -q "200\|404"; then
        echo "✅ Moodle can reach VPL jail server"
    else
        echo "❌ Moodle cannot reach VPL jail server"
    fi
    
    # Test external connectivity
    echo ""
    echo "🌐 Testing external connectivity..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 2>/dev/null)
    if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 404 ]; then
        echo "✅ VPL jail accessible on port 8081 (HTTP $HTTP_CODE)"
    else
        echo "⚠️  VPL jail not accessible on port 8081 (HTTP $HTTP_CODE)"
    fi
    
    # Show configuration
    echo ""
    echo "⚙️  Configuration:"
    echo "   Internal URL: http://manfree_vpl_jail"
    echo "   External URL: http://$(hostname -I | awk '{print $1}'):8081"
    
else
    echo "❌ VPL Jail container is NOT running"
    echo ""
    echo "To start it:"
    echo "   docker compose up -d vpl-jail"
    echo ""
    echo "To check why it's not running:"
    echo "   docker ps -a | grep vpl"
    echo "   docker logs manfree_vpl_jail"
fi

echo ""
echo "================================"

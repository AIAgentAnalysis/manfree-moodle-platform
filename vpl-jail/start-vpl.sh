#!/bin/bash
set -e

echo "Starting VPL Jail Server in foreground mode..."

# Start VPL daemon process
/usr/sbin/vpl/vpl-jail-system start

# Find the actual daemon process and monitor it
# This keeps the container alive by tailing the log file
tail -f /var/log/vpl-jail-service.log 2>/dev/null || tail -f /dev/null

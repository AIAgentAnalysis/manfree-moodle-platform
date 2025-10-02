# Moodle Cron Setup Guide

## 🚨 Critical Issue: AI Tasks Not Running

**Problem**: AI question generation stuck at 0% because Moodle cron is not running.

**Evidence**: Site Administration → Server → Scheduled tasks shows "Last run: Never" for all tasks.

## 🔍 Current Status

- **Web cron disabled**: `/admin/cron.php` returns `cronerrorclionly` error
- **CLI-only cron**: Security setting prevents web-based cron execution
- **AI tasks pending**: All AdHoc tasks (including AI question generation) require cron to execute

## ✅ Solution: Enable CLI Cron

### 1. Access Server/WSL2
```bash
# Navigate to Moodle root directory
cd /home/manfree/workspace/manfree-moodle-platform

# If using Docker, access Moodle container
docker exec -it manfree_moodle bash
cd /var/www/html
```

### 2. Test Manual Cron
```bash
# Run cron manually to test
php admin/cli/cron.php

# Expected output:
# Starting task: \local_ai_manager\task\reset_user_usage
# Task completed successfully.
# ...AI tasks processing...
```

### 3. Setup Automatic Cron (WSL2/Linux)
```bash
# Open crontab editor
crontab -e

# Add this line (run every 5 minutes)
*/5 * * * * /usr/bin/php /home/manfree/workspace/manfree-moodle-platform/admin/cli/cron.php >/dev/null 2>&1

# Save and exit
```

### 4. Docker-Specific Cron Setup
```bash
# Create cron script for Docker environment
cat > /home/manfree/workspace/manfree-moodle-platform/run-moodle-cron.sh << 'EOF'
#!/bin/bash
docker exec manfree_moodle php /var/www/html/admin/cli/cron.php
EOF

# Make executable
chmod +x /home/manfree/workspace/manfree-moodle-platform/run-moodle-cron.sh

# Add to host crontab
crontab -e
# Add line:
*/5 * * * * /home/manfree/workspace/manfree-moodle-platform/run-moodle-cron.sh >/dev/null 2>&1
```

## 🔧 Temporary Web Cron (Emergency Only)

**⚠️ Use only when CLI access unavailable**

### Enable Web Cron Temporarily
1. Access Moodle as admin
2. Site Administration → Server → Cron
3. Set "Enable web cron" → Yes
4. Visit: `http://localhost:8080/admin/cron.php`
5. **Important**: Disable web cron after testing for security

### Online Cron Service
- Use services like cron-job.org
- Set URL: `http://your-server:8080/admin/cron.php`
- Schedule: Every 5 minutes
- **Remember**: Re-disable web cron after setup

## 📊 Verification Steps

### 1. Check Scheduled Tasks
- Site Administration → Server → Scheduled tasks
- Verify "Last run" shows recent timestamps
- Look for AI-related tasks completion

### 2. Test AI Question Generation
- Go to course → Question bank
- AI text to questions generator
- Submit content → progress should move past 0%

### 3. Monitor Cron Logs
```bash
# View cron execution logs
tail -f /var/log/cron.log

# Or check Moodle logs
# Site Administration → Reports → Logs
# Filter by "cron" activities
```

## 🛠️ Troubleshooting

### Cron Not Running
```bash
# Check if cron service is active
sudo systemctl status cron

# Start cron service if stopped
sudo systemctl start cron
sudo systemctl enable cron
```

### PHP Path Issues
```bash
# Find correct PHP path
which php
# Use full path in crontab: /usr/bin/php or /usr/local/bin/php
```

### Docker Container Issues
```bash
# Verify container is running
docker ps | grep moodle

# Check container logs
docker logs manfree_moodle

# Restart if needed
docker-compose restart moodle
```

## 📋 Cron Schedule Recommendations

| Frequency | Use Case | Crontab Entry |
|-----------|----------|---------------|
| Every 5 min | Development/Testing | `*/5 * * * *` |
| Every 15 min | Production (Light) | `*/15 * * * *` |
| Every hour | Production (Heavy) | `0 * * * *` |

## 🔐 Security Notes

- **Never enable web cron permanently** in production
- **Use CLI cron only** for security
- **Monitor cron logs** for failed executions
- **Set proper file permissions** on cron scripts

## 📝 Current Configuration

- **Moodle Version**: 4.5.6
- **Docker Setup**: manfree-moodle-platform
- **Cron Status**: ❌ Not configured (needs setup)
- **Web Cron**: ❌ Disabled (security setting)
- **AI Tasks**: ❌ Pending (waiting for cron)

---

**Next Action Required**: Set up CLI cron to enable AI question generation functionality.

**Last Updated**: $(date +"%Y-%m-%d %H:%M:%S")
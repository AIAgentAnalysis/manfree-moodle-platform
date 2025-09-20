# 🔄 PC Restart Scenario - Automatic Handling

**Complete automation for PC shutdown → WSL auto-start → Tunnel auto-fix**

---

## 🎯 Scenario Covered

### What Happens:
1. **PC Shutdown** - You shut down your PC
2. **PC Restart** - You start PC, VS Code opens, WSL connects
3. **Docker Auto-Start** - Moodle containers start automatically
4. **Tunnel Auto-Fix** - Tunnel service automatically checks and fixes itself

### Expected Result:
- ✅ **No manual intervention needed**
- ✅ **Tunnel automatically working**
- ✅ **Both URLs accessible immediately**
  - Local: `http://localhost:8080`
  - Global: `https://learning.manfreetechnologies.com`

---

## 🛠️ How It Works

### 1. **Initial Setup** (One-time)
```bash
# Authenticate once
cloudflared tunnel login

# Run up.sh (automatically sets up everything)
./up.sh
```

### 2. **PC Restart Automation**

#### Layer 1: System Service
- `cloudflared.service` auto-starts with system
- Systemd ensures service reliability

#### Layer 2: WSL Auto-Start
- `~/tunnel-autostart.sh` runs when WSL starts
- Checks if Moodle running but tunnel down
- Fixes any issues automatically

#### Layer 3: Systemd Timer
- Runs health check every 5 minutes
- Ensures tunnel stays healthy
- Auto-repairs any configuration issues

#### Layer 4: up.sh Integration
- Every time you run `./up.sh`
- Automatically checks tunnel health
- Fixes any issues before showing URLs

---

## 🔄 Complete Flow

```
PC Shutdown
    ↓
PC Restart
    ↓
WSL Auto-connects
    ↓
Docker containers auto-start (Moodle running)
    ↓
~/tunnel-autostart.sh runs automatically
    ↓
Checks: Is tunnel service running?
    ↓
If NO → Runs health-check-fix automatically
    ↓
Tunnel service starts
    ↓
Global URL works: https://learning.manfreetechnologies.com
    ↓
No manual intervention needed! ✅
```

---

## 🔧 What Gets Auto-Fixed

### ✅ Service Not Running
- Automatically starts `cloudflared` service
- Enables auto-start if disabled

### ✅ Configuration Issues
- Recreates missing config files
- Fixes corrupted configurations

### ✅ DNS Problems
- Detects DNS resolution issues
- Provides guidance for manual fixes

### ✅ Authentication Issues
- Detects missing authentication
- Guides user to re-authenticate

---

## 📋 Verification Steps

### Check Auto-Start Setup
```bash
# Verify WSL auto-start script exists
ls -la ~/tunnel-autostart.sh

# Check if added to .bashrc
grep "tunnel-autostart" ~/.bashrc

# Verify systemd timer
systemctl --user status tunnel-autocheck.timer
```

### Test the Scenario
```bash
# 1. Ensure everything is working
./up.sh

# 2. Simulate PC restart by stopping service
sudo systemctl stop cloudflared

# 3. Run the auto-start script manually
~/tunnel-autostart.sh

# 4. Check if tunnel is back up
./global-access/permanent/setup.sh --status
```

---

## 🚨 Troubleshooting

### If Auto-Start Doesn't Work

#### Check WSL Auto-Start
```bash
# Verify script exists and is executable
ls -la ~/tunnel-autostart.sh
chmod +x ~/tunnel-autostart.sh

# Check .bashrc entry
tail -5 ~/.bashrc
```

#### Check Systemd Timer
```bash
# Check timer status
systemctl --user status tunnel-autocheck.timer

# Check recent runs
systemctl --user list-timers tunnel-autocheck.timer

# View logs
journalctl --user -u tunnel-autocheck.service -f
```

#### Manual Fix
```bash
# Re-run setup to fix auto-start
./global-access/permanent/setup.sh --setup
```

---

## 📊 Reliability Layers

| Layer | Purpose | Frequency | Reliability |
|-------|---------|-----------|-------------|
| **System Service** | Auto-start with PC | Boot time | High |
| **WSL Auto-Start** | Fix when WSL opens | WSL start | High |
| **Systemd Timer** | Periodic health check | Every 5 min | Medium |
| **up.sh Integration** | Manual trigger | When you run up.sh | High |

---

## 🎯 Expected Behavior

### ✅ Normal Scenario
1. PC restarts
2. WSL auto-connects
3. Moodle containers auto-start
4. Tunnel auto-fixes and starts
5. **Both URLs work immediately**

### ✅ Problem Scenario
1. PC restarts
2. Something goes wrong with tunnel
3. Auto-fix detects and repairs issue
4. **URLs work within 2-5 minutes**

### ✅ Worst Case Scenario
1. Multiple issues occur
2. Auto-fix can't resolve everything
3. **Clear error messages guide you**
4. **Simple commands to fix manually**

---

## 📝 Summary

**The PC restart scenario is fully automated:**

- ✅ **No manual tunnel startup needed**
- ✅ **Auto-detects and fixes issues**
- ✅ **Multiple reliability layers**
- ✅ **Works with Docker auto-start**
- ✅ **Integrated with WSL auto-connect**
- ✅ **Handles configuration corruption**
- ✅ **Provides clear error messages**

**Just shut down your PC, restart, open VS Code → everything works automatically!** 🎉
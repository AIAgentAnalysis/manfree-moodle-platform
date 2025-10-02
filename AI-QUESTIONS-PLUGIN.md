# AI Question Generator - Usage Guide

## ✅ **What's Implemented**

- **Plugin**: local_aiquestions (AI Text to Questions Generator)
- **API**: OpenAI GPT-4o-mini
- **Status**: ✅ Working
- **Cost**: ~$0.01-0.05 per question set

## 📋 **Step-by-Step: Generate Questions**

### **1. Access the Plugin**
```
1. Login to Moodle: http://localhost:8080
2. Go to any course (e.g., "Data Types SA")
3. Click: Course Administration → AI Questions → Story
```

### **2. Generate Questions**
```
1. Enter topic: "C++ programming basics"
2. Click: Generate
3. Wait: Progress bar shows 0% → 100%
4. Result: Questions appear in GIFT format
```

### **3. Process Background Tasks**
If stuck at 0%, run cron:
```bash
./quick-cron-fix.sh
```

### **4. Check Generated Questions**
```
1. Go to: Course → Question bank
2. Look for: Questions with "GPT-created:" prefix
3. Use: In quizzes and assignments
```

## ✅ **Verify It's Working**

### **Test 1: Check Plugin Status**
```bash
docker exec manfree_moodle php -r "
define('CLI_SCRIPT', true);
require_once('/var/www/html/config.php');
\$plugin = \$DB->get_record('config_plugins', array('plugin' => 'local_aiquestions', 'name' => 'version'));
echo \$plugin ? 'Plugin: Installed\n' : 'Plugin: NOT installed\n';
echo 'Model: ' . get_config('local_aiquestions', 'model') . '\n';
echo 'API Key: ' . (get_config('local_aiquestions', 'key') ? 'Configured' : 'Missing') . '\n';
"
```

**Expected Output:**
```
Plugin: Installed
Model: gpt-4o-mini
API Key: Configured
```

### **Test 2: Generate Sample Questions**
```
1. Go to: Course → AI Questions → Story
2. Topic: "basic C program"
3. Generate: Should complete to 100%
4. Check: Question bank for new questions
```

### **Test 3: Verify API Connection**
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
https://api.openai.com/v1/models | grep gpt-4o-mini
```

**Expected:** Should show gpt-4o-mini model available

## 🚨 **Common Issues & Fixes**

### **Issue 1: Plugin Not Visible**
**Fix:**
```bash
docker exec manfree_moodle php /var/www/html/admin/cli/purge_caches.php
# Then refresh browser (Ctrl+F5)
```

### **Issue 2: Stuck at 0%**
**Fix:**
```bash
./quick-cron-fix.sh
# Wait 1-2 minutes, then check question bank
```

### **Issue 3: Error After 10 Tries**
**Cause:** API key issue or rate limit
**Fix:**
```bash
# Check API key is valid
curl -H "Authorization: Bearer YOUR_API_KEY" \
https://api.openai.com/v1/models

# If invalid, update in Moodle:
# Site Administration → Plugins → Local plugins → AI Questions
```

## 🔧 **What We Fixed**

**Moodle 4.5.6 Compatibility Issue**
- **Problem**: Plugin used deprecated `$result->noticeyesno` parameter
- **Fix**: Removed deprecated parameter in `plugins/local/aiquestions/locallib.php` (line 160)
- **Result**: Plugin now works with Moodle 4.5.6

## 💰 **Cost Information**

- **Per question set (4 questions)**: $0.01-0.05
- **100 question sets**: $1-5
- **Monthly moderate use**: $20-50
- **Monitor usage**: https://platform.openai.com/usage

---

**Status**: ✅ Implemented and working
**Access**: Course Administration → AI Questions → Story
**Verify**: Run tests above to confirm functionality
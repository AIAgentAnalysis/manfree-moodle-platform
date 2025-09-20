# File Upload Limits Configuration

## Overview
This document explains how file upload limits are configured in the Manfree Moodle Platform to support 100MB file uploads.

## Configuration Files

### 1. PHP Settings (Dockerfile)
```dockerfile
# File Upload Limits: Increased from 2MB to 100MB for large file support
RUN echo "upload_max_filesize = 100M" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "max_input_time = 300" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/moodle.ini
```

### 2. Moodle Settings (customizations/config/config.php)
```php
// File upload limits - 100MB
$CFG->maxbytes = 104857600; // 100MB in bytes
```

## Settings Explanation

| Setting | Value | Purpose |
|---------|-------|---------|
| `upload_max_filesize` | 100M | Maximum size for uploaded files |
| `post_max_size` | 100M | Maximum POST data size |
| `max_execution_time` | 300 | Script timeout for large uploads |
| `max_input_time` | 300 | Input parsing timeout |
| `memory_limit` | 256M | Memory limit for processing |
| `$CFG->maxbytes` | 104857600 | Moodle's file size limit |

## Verification

### Check PHP Settings
```bash
docker exec manfree_moodle php -i | grep -E 'upload_max_filesize|post_max_size'
```

### Check Moodle Settings
1. Access: http://localhost:8080/admin
2. Go to: Site administration > Server > HTTP
3. Verify "Maximum uploaded file size" shows 100MB

## Troubleshooting

### Upload Still Limited
1. Check course-level settings:
   - Course administration > Edit settings
   - Set "Maximum upload size" to 100MB

2. Check activity-level settings:
   - Individual activities may have their own limits
   - Update each activity's file size limit

### Large File Upload Timeout
- Increase `max_execution_time` if needed
- Consider using chunked upload for very large files

## Apply Changes

```bash
# Using your existing scripts (recommended)
./down.sh
./up.sh

# OR manually
docker-compose down
docker-compose build --no-cache moodle
docker-compose up -d
```

## File Locations
- **PHP Config**: Built into Docker image via Dockerfile
- **Moodle Config**: `customizations/config/config.php` (persistent)
- **Documentation**: This file and README.md
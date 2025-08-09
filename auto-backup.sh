#!/bin/bash
set -e

BACKUP_DIR="./backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="manfree-backup-${TIMESTAMP}"

echo "💾 Creating backup: ${BACKUP_NAME}"

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Backup Moodle data
echo "Backing up Moodle data..."
docker run --rm \
    -v manfree-moodle-platform_moodle_data:/data \
    -v "$(pwd)/${BACKUP_DIR}:/backup" \
    alpine tar czf "/backup/${BACKUP_NAME}_moodle_data.tar.gz" -C /data .

# Backup Moodle files
echo "Backing up Moodle files..."
docker run --rm \
    -v manfree-moodle-platform_moodle_data_files:/data \
    -v "$(pwd)/${BACKUP_DIR}:/backup" \
    alpine tar czf "/backup/${BACKUP_NAME}_moodle_files.tar.gz" -C /data .

# Backup MariaDB
echo "Backing up database..."
docker run --rm \
    -v manfree-moodle-platform_mariadb_data:/data \
    -v "$(pwd)/${BACKUP_DIR}:/backup" \
    alpine tar czf "/backup/${BACKUP_NAME}_mariadb_data.tar.gz" -C /data .

# Check sizes and warn about Git limits
echo "📊 Backup size analysis:"
MAX_SIZE_MB=90  # GitHub limit consideration
for file in "${BACKUP_DIR}/${BACKUP_NAME}"*.tar.gz; do
    if [ -f "$file" ]; then
        size_mb=$(du -m "$file" | cut -f1)
        echo "  $(basename "$file"): ${size_mb}MB"
        
        if [ "$size_mb" -gt "$MAX_SIZE_MB" ]; then
            echo "⚠️  WARNING: $(basename "$file") (${size_mb}MB) exceeds ${MAX_SIZE_MB}MB"
            echo "   Consider using Git LFS: git lfs install && git lfs track '*.tar.gz'"
        fi
    fi
done

# Cleanup old backups - keep only last 3
echo "🧹 Cleaning up old backups (keeping last 3)..."
ls -t "${BACKUP_DIR}"/*_moodle_data.tar.gz 2>/dev/null | tail -n +4 | while read old_backup; do
    old_name=$(basename "$old_backup" "_moodle_data.tar.gz")
    echo "  Removing: $old_name"
    rm -f "${BACKUP_DIR}/${old_name}"*.tar.gz
done

echo "✅ Backup completed: ${BACKUP_NAME}"
echo "📁 Location: ${BACKUP_DIR}/"
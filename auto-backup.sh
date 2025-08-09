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

echo "✅ Backup completed: ${BACKUP_NAME}"
echo "📁 Location: ${BACKUP_DIR}/"
#!/bin/bash
set -e

BACKUP_DIR="./backup"

# Check if backup directory exists
if [ ! -d "${BACKUP_DIR}" ]; then
    echo "ℹ️  No backup directory found. Starting fresh."
    exit 0
fi

# Find latest backup
LATEST_BACKUP=$(ls -t "${BACKUP_DIR}"/*_moodle_data.tar.gz 2>/dev/null | head -n1 || echo "")

if [ -z "${LATEST_BACKUP}" ]; then
    echo "ℹ️  No backup found. Starting fresh."
    exit 0
fi

# Extract backup name
BACKUP_NAME=$(basename "${LATEST_BACKUP}" "_moodle_data.tar.gz")

echo "🔄 Restoring backup: ${BACKUP_NAME}"

# Create volumes if they don't exist
docker volume create manfree-moodle-platform_moodle_data >/dev/null 2>&1 || true
docker volume create manfree-moodle-platform_moodle_data_files >/dev/null 2>&1 || true
docker volume create manfree-moodle-platform_mariadb_data >/dev/null 2>&1 || true

# Restore Moodle data
if [ -f "${BACKUP_DIR}/${BACKUP_NAME}_moodle_data.tar.gz" ]; then
    echo "Restoring Moodle data..."
    docker run --rm \
        -v manfree-moodle-platform_moodle_data:/data \
        -v "$(pwd)/${BACKUP_DIR}:/backup" \
        alpine tar xzf "/backup/${BACKUP_NAME}_moodle_data.tar.gz" -C /data
fi

# Restore Moodle files
if [ -f "${BACKUP_DIR}/${BACKUP_NAME}_moodle_files.tar.gz" ]; then
    echo "Restoring Moodle files..."
    docker run --rm \
        -v manfree-moodle-platform_moodle_data_files:/data \
        -v "$(pwd)/${BACKUP_DIR}:/backup" \
        alpine tar xzf "/backup/${BACKUP_NAME}_moodle_files.tar.gz" -C /data
fi

# Restore MariaDB
if [ -f "${BACKUP_DIR}/${BACKUP_NAME}_mariadb_data.tar.gz" ]; then
    echo "Restoring database..."
    docker run --rm \
        -v manfree-moodle-platform_mariadb_data:/data \
        -v "$(pwd)/${BACKUP_DIR}:/backup" \
        alpine tar xzf "/backup/${BACKUP_NAME}_mariadb_data.tar.gz" -C /data
fi

echo "✅ Restore completed: ${BACKUP_NAME}"
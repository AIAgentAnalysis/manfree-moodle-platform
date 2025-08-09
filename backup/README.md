# 💾 Backup Directory

Automatic backups are stored in this directory.

## 📋 Backup Files

Each backup creates 3 files with timestamp:
- `manfree-backup-YYYYMMDD_HHMMSS_moodle_data.tar.gz` - Moodle core files
- `manfree-backup-YYYYMMDD_HHMMSS_moodle_files.tar.gz` - User data and uploads
- `manfree-backup-YYYYMMDD_HHMMSS_mariadb_data.tar.gz` - Database

## 🔄 Backup Schedule

### Automatic Backups
- **When**: Every time `./down.sh` is executed
- **Retention**: Manual cleanup recommended after 30 days
- **Location**: This directory

### Manual Backup
```bash
# Create backup manually
./auto-backup.sh
```

## 📊 Backup Management

### View Backups
```bash
# List all backups
ls -la backup/

# Check backup sizes
du -sh backup/*

# Find latest backup
ls -t backup/*_moodle_data.tar.gz | head -1
```

### Clean Old Backups
```bash
# Remove backups older than 30 days
find backup/ -name "*.tar.gz" -mtime +30 -delete

# Remove specific backup
rm backup/manfree-backup-20250101_120000_*
```

## 🔧 Restore Process

### Automatic Restore
- Latest backup is restored automatically when running `./up.sh`
- If no backup exists, platform starts fresh

### Manual Restore
1. Stop platform: `./down.sh`
2. Edit `auto-restore.sh` to specify backup timestamp
3. Run restore: `./auto-restore.sh`
4. Start platform: `./up.sh`

## ⚠️ Important Notes

- **Never delete this directory** - it contains critical backups
- Backups are compressed to save space
- Each backup set (3 files) must stay together
- Test restore process regularly
- Consider offsite backup for disaster recovery

## 📁 Example Structure
```
backup/
├── manfree-backup-20250109_143022_moodle_data.tar.gz
├── manfree-backup-20250109_143022_moodle_files.tar.gz
├── manfree-backup-20250109_143022_mariadb_data.tar.gz
├── manfree-backup-20250108_170015_moodle_data.tar.gz
├── manfree-backup-20250108_170015_moodle_files.tar.gz
├── manfree-backup-20250108_170015_mariadb_data.tar.gz
└── README.md (this file)
```
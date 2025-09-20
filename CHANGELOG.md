# Changelog - Manfree Moodle Platform

## [v1.1.0] - 2025-01-27

### Added
- **File Upload Limits**: Increased from 2MB to 100MB
  - PHP settings: `upload_max_filesize = 100M`, `post_max_size = 100M`
  - Moodle config: `$CFG->maxbytes = 104857600`
  - Extended timeouts: `max_execution_time = 300`

- **Permanent Repository Structure**: 
  - Host-mounted repository folder at `./repository`
  - Pre-created course folders: Course1, Course2, Shared
  - Survives container restarts without manual recreation

### Modified Files
- `Dockerfile`: Added PHP upload limit settings with comments
- `docker-compose.yml`: Added repository volume mapping
- `customizations/config/config.php`: Added `$CFG->maxbytes` setting
- `README.md`: Updated documentation for upload limits
- `FILE-UPLOAD-LIMITS.md`: New dedicated documentation

### Benefits
- ✅ Support for large course materials (videos, presentations)
- ✅ Permanent file organization structure
- ✅ No manual folder creation needed
- ✅ Settings persist across container rebuilds
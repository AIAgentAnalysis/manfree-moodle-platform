# Permanent Repository Folder

This folder is **permanently mounted** to your Moodle container.

## Structure
```
repository/
├── Course1/
│   ├── Lectures/
│   ├── Assignments/
│   └── Resources/
├── Course2/
│   ├── Lectures/
│   ├── Assignments/
│   └── Resources/
└── Shared/
    ├── Templates/
    └── Common/
```

## Usage
1. **Upload files**: Place files in appropriate subfolders
2. **Access in Moodle**: Add activity/resource → File → Choose repository → File system
3. **Permanent**: Files survive Docker restarts/rebuilds

## Benefits
- ✅ **Permanent**: Survives container restarts
- ✅ **Organized**: Separate folders per course
- ✅ **No commands**: No need to create folders via CLI
- ✅ **Easy access**: Direct file management from host
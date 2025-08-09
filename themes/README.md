# 🎨 Themes Directory

Place custom Moodle themes in this directory.

## 📥 Installation Process

1. **Extract Theme**: Unzip theme files to create a folder
2. **Place Here**: Copy theme folder to this `themes/` directory
3. **Restart Platform**: Run `./down.sh && ./up.sh`
4. **Activate Theme**: Go to Moodle admin → Appearance → Themes

## 🏢 Manfree Institute Theme

A custom theme for Manfree Technologies Institute will be placed here when available.

## 📁 Example Structure
```
themes/
├── manfree/                    # Custom institute theme
│   ├── config.php
│   ├── version.php
│   ├── lang/
│   ├── layout/
│   └── style/
├── custom_theme/               # Additional custom theme
└── README.md (this file)
```

## 🎯 Theme Resources

- [Moodle Theme Development](https://docs.moodle.org/dev/Themes)
- [Theme Directory](https://moodle.org/plugins/browse.php?list=category&id=3)
- [Bootstrap Themes](https://moodle.org/plugins/browse.php?list=category&id=3&name=theme)

## ⚠️ Important Notes

- Themes should be folders (not .zip files)
- Theme installation requires platform restart
- Always test themes before production use
- Keep original theme files as backup
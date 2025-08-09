# 🎨 Customizations Directory

Store all Moodle customizations here to protect them during upgrades.

## 📁 Structure
```
customizations/
├── config/
│   └── config.php              # Custom Moodle config
├── themes/
│   └── manfree/               # Custom themes
├── plugins/
│   └── local_custom/          # Custom plugins
├── lang/
│   └── en/                    # Language customizations
└── patches/
    └── core_modifications.txt # Core file changes
```

## 🔒 Protected During Upgrades
- All files here are preserved during version upgrades
- Automatically restored after container rebuild
- Version controlled with Git
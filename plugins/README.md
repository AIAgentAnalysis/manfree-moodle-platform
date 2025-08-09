# 🔌 Plugins Directory

Place Moodle plugin `.zip` files in this directory.

## 📥 Installation Process

1. **Download Plugin**: Get `.zip` file from [Moodle.org](https://moodle.org/plugins/)
2. **Place Here**: Copy `.zip` file to this `plugins/` directory
3. **Restart Platform**: Run `./down.sh && ./up.sh`
4. **Complete Setup**: Visit Moodle admin panel to finish installation

## 🎯 Recommended Plugins

### Programming Courses
- **CodeRunner** (`qtype_coderunner.zip`)
  - Auto-grade programming assignments
  - Supports C, C++, Python, Java, etc.
  - Download: [CodeRunner Plugin](https://moodle.org/plugins/qtype_coderunner)

### Diagram Questions
- **Draw.io** (`qtype_drawio.zip`)
  - Create diagram-based questions
  - Interactive drawing interface
  - Download: [Draw.io Plugin](https://moodle.org/plugins/qtype_drawio)

### Exam Security
- **Safe Exam Browser** (`quizaccess_seb.zip`)
  - Lockdown browser integration
  - Secure exam environment
  - Download: [SEB Plugin](https://moodle.org/plugins/quizaccess_seb)

## 📁 Example Structure
```
plugins/
├── qtype_coderunner.zip
├── qtype_drawio.zip
├── quizaccess_seb.zip
└── README.md (this file)
```

## ⚠️ Important Notes

- Only place `.zip` files here (not extracted folders)
- Plugin installation requires platform restart
- Some plugins may need additional configuration
- Always backup before installing new plugins
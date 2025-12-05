# 📚 Documentation Index

Complete guide for running GoApp on Raspberry Pi touchscreen kiosk.

## 🚀 Getting Started

**New to this?** Start here:

1. **[SUMMARY.md](SUMMARY.md)** - Overview of what you're getting
2. **[README.md](README.md)** - Main setup guide (start here for installation)
3. **[QUICKSTART.md](QUICKSTART.md)** - Quick command reference

## 📖 Documentation Files

### Core Setup Guides

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[README.md](README.md)** | Main setup guide | Setting up for the first time |
| **[QUICKSTART.md](QUICKSTART.md)** | Quick reference | Need a command quickly |
| **[SUMMARY.md](SUMMARY.md)** | Overview & TL;DR | Want to understand what this is |
| **[CHECKLIST.md](CHECKLIST.md)** | Step-by-step validation | Ensure nothing is missed |

### Technical Documentation

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | System architecture | Understand how it works |
| **[CONFIGURATION.md](CONFIGURATION.md)** | Advanced settings | Optimize or customize |
| **[VISUAL_GUIDE.md](VISUAL_GUIDE.md)** | Visual diagrams | See it visually |

### Setup Files

| File | Type | Purpose |
|------|------|---------|
| **setup.sh** | Script | Automated installer |
| **kiosk.sh** | Script | Kiosk launcher |
| **monitor.sh** | Script | Auto-restart on crash |
| **autostart** | Config | Boot configuration |
| **.env.example** | Template | Environment config |
| **goapp-kiosk.service** | Service | Systemd service |
| **install-service.sh** | Script | Service installer |

## 🎯 Common Tasks - Quick Links

### First Time Setup
1. Read [SUMMARY.md](SUMMARY.md) to understand what you're building
2. Follow [README.md](README.md) for complete setup
3. Use [CHECKLIST.md](CHECKLIST.md) to validate each step

### Troubleshooting
1. Check [QUICKSTART.md](QUICKSTART.md) troubleshooting section
2. Review [CONFIGURATION.md](CONFIGURATION.md) for advanced fixes
3. See [ARCHITECTURE.md](ARCHITECTURE.md) to understand the system

### Customization
1. [CONFIGURATION.md](CONFIGURATION.md) - Performance, rotation, keyboard
2. [ARCHITECTURE.md](ARCHITECTURE.md) - Understanding the stack
3. [kiosk.sh](kiosk.sh) - Chromium flags and settings

### Maintenance
1. [QUICKSTART.md](QUICKSTART.md) - Common commands
2. [CONFIGURATION.md](CONFIGURATION.md) - Maintenance schedule
3. [CHECKLIST.md](CHECKLIST.md) - Production checklist

## 📊 Document Comparison

### SUMMARY.md vs README.md
- **SUMMARY.md**: High-level overview, what you get, quick concepts
- **README.md**: Detailed step-by-step installation instructions

### QUICKSTART.md vs CONFIGURATION.md
- **QUICKSTART.md**: Quick commands you'll use regularly
- **CONFIGURATION.md**: In-depth settings, optimizations, advanced topics

### CHECKLIST.md vs README.md
- **CHECKLIST.md**: Validation checkboxes for each step
- **README.md**: Detailed explanations of what to do

### ARCHITECTURE.md vs VISUAL_GUIDE.md
- **ARCHITECTURE.md**: Technical diagrams with explanations
- **VISUAL_GUIDE.md**: ASCII art visual representations

## 🗺️ Reading Path by Role

### For System Administrators
```
1. SUMMARY.md (understand scope)
2. ARCHITECTURE.md (understand system)
3. README.md (perform setup)
4. CONFIGURATION.md (optimize)
5. CHECKLIST.md (validate)
```

### For Developers
```
1. ARCHITECTURE.md (understand stack)
2. ../RASPBERRY_PI_SETUP.md (detailed guide)
3. CONFIGURATION.md (customization options)
4. kiosk.sh (review settings)
```

### For End Users / Installers
```
1. SUMMARY.md (overview)
2. VISUAL_GUIDE.md (see what it looks like)
3. README.md (follow step-by-step)
4. CHECKLIST.md (validate setup)
5. QUICKSTART.md (bookmark for later)
```

### For Troubleshooters
```
1. QUICKSTART.md (common issues)
2. CONFIGURATION.md (advanced fixes)
3. ARCHITECTURE.md (understand system)
4. ../RASPBERRY_PI_SETUP.md (full reference)
```

## 📝 Document Sizes

| Document | Approx. Reading Time | Complexity |
|----------|---------------------|------------|
| SUMMARY.md | 5 min | ⭐ Easy |
| README.md | 10 min | ⭐⭐ Moderate |
| QUICKSTART.md | 3 min | ⭐ Easy |
| CHECKLIST.md | 15 min (doing) | ⭐⭐ Moderate |
| ARCHITECTURE.md | 8 min | ⭐⭐⭐ Advanced |
| CONFIGURATION.md | 12 min | ⭐⭐⭐ Advanced |
| VISUAL_GUIDE.md | 5 min | ⭐ Easy |

## 🎓 Learning Path

### Beginner Path (Never used Raspberry Pi before)
```
Day 1: Read SUMMARY.md, VISUAL_GUIDE.md
       Understand what you're building

Day 2: Follow README.md carefully
       Run setup.sh script
       Configure .env file

Day 3: Use CHECKLIST.md to validate
       Test touchscreen functionality
       Reboot and verify auto-start

Day 4: Bookmark QUICKSTART.md
       Test full user workflow
       Production ready!
```

### Advanced Path (Experienced with Pi/Linux)
```
Hour 1: Skim ARCHITECTURE.md
        Review kiosk.sh and autostart
        
Hour 2: Run setup.sh
        Configure .env
        docker-compose up -d
        
Hour 3: Configure optimizations from CONFIGURATION.md
        Test and validate with CHECKLIST.md
        Deploy!
```

## 🔍 Quick Search

### I want to...

**Understand the system**
→ [ARCHITECTURE.md](ARCHITECTURE.md)

**Set it up for the first time**
→ [README.md](README.md)

**See what it looks like**
→ [VISUAL_GUIDE.md](VISUAL_GUIDE.md)

**Fix an issue**
→ [QUICKSTART.md](QUICKSTART.md) → Troubleshooting

**Optimize performance**
→ [CONFIGURATION.md](CONFIGURATION.md) → Performance

**Validate my setup**
→ [CHECKLIST.md](CHECKLIST.md)

**Change keyboard**
→ [CONFIGURATION.md](CONFIGURATION.md) → Touchscreen section

**Rotate screen**
→ [CONFIGURATION.md](CONFIGURATION.md) → Display Orientation

**Auto-reboot daily**
→ [CONFIGURATION.md](CONFIGURATION.md) → Scheduled reboot

**See all commands**
→ [QUICKSTART.md](QUICKSTART.md)

**Get quick overview**
→ [SUMMARY.md](SUMMARY.md)

## 📦 What Files to Keep Where

### On Your Development Machine
```
goapp/
└── raspberry-pi/
    ├── All .md files (documentation)
    ├── setup.sh
    ├── kiosk.sh
    ├── monitor.sh
    ├── autostart
    └── .env.example
```

### On the Raspberry Pi (After Setup)
```
/home/pi/
├── kiosk.sh
├── monitor.sh
├── .config/lxsession/LXDE-pi/autostart
└── goapp/
    ├── .env (your config)
    ├── docker-compose.yml
    └── raspberry-pi/ (optional, for reference)
```

## 🎯 Success Checklist

- [ ] Read at least SUMMARY.md or README.md
- [ ] Understand the ARCHITECTURE (optional but helpful)
- [ ] Followed setup steps from README.md
- [ ] Validated setup with CHECKLIST.md
- [ ] Bookmarked QUICKSTART.md for daily use
- [ ] Know where CONFIGURATION.md is for later customization

## 💡 Pro Tips

1. **Print CHECKLIST.md** - Check off items as you go
2. **Bookmark QUICKSTART.md** - Reference it frequently
3. **Save CONFIGURATION.md** - You'll need it later
4. **Share SUMMARY.md** - Great for explaining to others
5. **Keep INDEX.md** - This file helps you find everything

## 📞 Still Lost?

1. Start with [SUMMARY.md](SUMMARY.md) - Get the big picture
2. Look at [VISUAL_GUIDE.md](VISUAL_GUIDE.md) - See it visually
3. Follow [README.md](README.md) step-by-step - Don't skip steps
4. Use [CHECKLIST.md](CHECKLIST.md) - Validate each step
5. Reference [QUICKSTART.md](QUICKSTART.md) - For commands

## 📚 External Resources

- **Main Project**: [../README.md](../README.md)
- **Detailed Pi Guide**: [../RASPBERRY_PI_SETUP.md](../RASPBERRY_PI_SETUP.md)
- **Frontend Code**: [../frontend/](../frontend/)
- **Backend Code**: [../backend/](../backend/)

---

**Last Updated**: December 2025

**Quick Start**: [README.md](README.md) | **Commands**: [QUICKSTART.md](QUICKSTART.md) | **Validation**: [CHECKLIST.md](CHECKLIST.md)

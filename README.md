
# 💻 Terminal-Center ⚡

The heart of a bloat-free, automated development environment. Terminal Center is a collection of scripts and configurations designed to transform a raw Windows 11 or Linux (Ubuntu/Fedora) installation into a perfectly tuned, developer-ready workstation. It serves as the primary deployment hub for the "System Forge" automation engine.🛡️🔥

---

## 🚀 Quick Start (Linux)

To initialize a fresh Ubuntu or Fedora machine with the custom environment, run this one-liner:

```bash
curl -sL https://raw.githubusercontent.com/gs6651/Terminal-Center/main/system-forge.sh | bash
```

## 📖 The Master Guide
For a full step-by-step breakdown of how to rebuild the system manually, or to understand the specific registry tweaks and configurations applied, refer to:

👉 [The-Forge.md](C:\Users\gaurav\Documents\GitLocal\Terminal-Center\The-Forge.md) (The Single Source of Truth)


## ✨ What’s Under the Hood?

### 🟦 Windows 11: Apex-Zero

- **System Purge:** Removes ads, tracking, Bing Search, and pre-installed bloat via `Apex-Zero.ps1`.
- **PowerShell 7 Optimization:** Custom profiles with SSH-agent auto-start and directory shortening.
- **Localization Fixes:** Synchronizes 12H lock screen formats and system-wide regional settings.

### 🟧 Linux: System Hardening

- **Ubuntu De-Snapping:** Complete removal of `snapd` and implementation of APT pinning to prevent its return.
- **Modern Tooling:** Automated installation of Starship, Flatpak (Flathub), and official Mozilla PPA Firefox.
- **Clean UI:** Purges unnecessary desktop packages like Shotwell and Fcitx.

### 🔄 Cross-Platform: `gitsync`

The `gitsync` tool is a custom protocol (PowerShell/Bash) that manages five core repositories simultaneously:

- **gs6651** (Personal Profile)
- **Terminal-Center** (This Hub)
- **The-Inkwell** (Documentation/Stats)
- **Six-String-Sanctuary** (Music/Guitar)
- **Packet-Foundry** (Networking/Dev)

## 🛠️ Tech Stack

- **Shells 🐚:** PowerShell 7 (Windows), Bash (Linux)
- **Prompt:** [Starship](https://starship.rs/)
- **Version Control:** Git (SSH Ed25519)
- **OS Support 🖥️:** Windows 11, Ubuntu 25.10+, Fedora 43+

## 📂 Repository Structure

- `The-Forge.md`: The consolidated master manual for all platforms.
- `system-forge.sh`: The Linux execution engine.
- `Apex-Zero.ps1`: The Windows optimization script.
- `starship.toml`: Unified prompt configuration.

## 🛡️ Credits & Acknowledgments

Special thanks to GitHub user [wz790](https://github.com/wz790) for the foundational Fedora setup tweaks, encrypted DNS configurations, and GNOME optimization strategies found in the `Fedora-Noble-Setup` repository.

## 🤝 Contributions

Found a way to optimize a kernel parameter? Open a Pull Request! 🍻

# 🛠️ system-forge.sh 🚀

Welcome to the **System Forge!** This is a "Universal-Settle" automation script designed to take a raw Linux installation and forge it into a perfectly tuned, developer-ready, and pro-audio-capable workstation. 🧠💻

Whether I'm on **Ubuntu 🟠** or **Fedora 🔵**, this script detects the environment and applies the correct magic.

## ✨ What’s Under the Hood?

### 🛡️ Distro-Agnostic Power

- **Intelligent Detection:** Automatically senses if you're on Ubuntu/Debian or Fedora. 🕵️‍♂️
- **Universal Package Management:** Uses `apt` or `dnf` + `RPM Fusion` depending on your "*flavor*" of Linux. 🍬
- **Repo Mastery:** Handles Ubuntu PPAs and Fedora Copr/Yum repos for VS Code and Firefox. 🦊

### 🧹 System Debloating & Optimization

- **Snap-B-Gone:** (Ubuntu) Completely purges `snapd` and pins APT to keep it clean. 🧼
- **Flatpak Integration:** Sets up Flathub for the best sandboxed apps. 📦
- **Pro Audio & Bluetooth:** Configures PipeWire/FFMPEG and enables experimental Bluetooth battery reporting for your peripherals. 🎧🔋

### 🔄 The "Second Brain" Workflow

- **SSH & Git Setup:** Generates secure Ed25519 keys and configures your identity. 🔑- 
- **Shallow Clone:** Grabs your repo without the heavy history—keeping things lean. 📂- 
- **`gitsync` Tool:** Creates a custom command in `~/.local/bin/` so you can sync your entire life with one word. ⚡

## 🚀 How to Run (The One-Liner)

Fresh install? Just fire up the terminal and paste this:

```Bash
curl -sL https://raw.githubusercontent.com/gs6651/SecondBrain/main/Misc/system-forge.sh | bash
```

## 📝 Step-by-Step Usage

- **Kickoff:** Run the one-liner above. 🏃‍♂️
- **Identity:** Enter your Git email and username when prompted. 👤
- **Keys:** If the script gives you a new SSH key, **copy-paste it into your GitHub Settings before hitting Enter**. 🗝️
- **Pathing:** Tell the script exactly where you want your "Second Brain" folder to live. 🧠
- **Choose your Apps:** Use `y/n` to pick and choose your software (Firefox, VS Code, Audacity, etc.). ✅❌
- **Ghost Busting:** Optionally use the EFI cleanup to delete those annoying "ghost" boot entries from previous OS hops. 👻🚫

## 💫 Post-Forge Magic: `gitsync`

Once the forge is complete and you've rebooted: Simply type `gitsync` from anywhere in your terminal to:

- **Pull** latest cloud changes. ☁️⬇️- 
- **Commit** all local edits with a timestamp. 📝- 
- **Push** everything back to GitHub. ☁️⬆️

## 🎉 Happy Forging!

May your compile times be short and your latency be low. 🍻


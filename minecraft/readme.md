# Minecraft Bedrock Server Setup

This project contains configuration, setup scripts, and environment files for running a Minecraft Bedrock Dedicated Server on Linux, including Raspberry Pi.

> ⚠️ Note: The server version must match the client version exactly. If the server is running 1.21.83, your Minecraft client must also be on 1.21.83.

---

## 🚀 Features

- Easy-to-run Bedrock server with `start.sh`
- Modular installation via `install.sh`
- PM2 process management for background operation
- Automatic download of the latest server version
- Git-ignored binary files and world data to keep repo clean

---

## 📦 Cloning the Repository

```bash
git clone https://github.com/TBoneMendez/raspberry-projects.git
cd raspberry-projects/minecraft
```

---

## 🔧 Installation

Run from the root of the repo:

```bash
chmod +x install.sh
./install.sh
```

Choose `minecraft` from the menu, and the script will:

- Download the latest official server zip
- Extract contents
- Make `bedrock_server` and `start.sh` executable

---

## ▶️ Running the Server

Start manually:

```bash
cd minecraft
./start.sh
```

Or use PM2:

```bash
pm2 start pm2.config.js
pm2 save
```

---

## 🔁 Auto-Start on Boot (optional)

```bash
pm2 startup
# Copy and run the suggested command
pm2 save
```

---

## 📁 Server Files (git-tracked)

Only the following are tracked in this repository:

- `server.properties`
- `start.sh`
- `install.sh`
- `README.md`
- `.gitignore`

All large/binary/runtime files are excluded via `.gitignore`.

---

## 🧠 Tips

- The server listens on port **19132 (UDP)** by default
- Ensure port 19132 is **open in your firewall** if connecting from another device
- Add `enable-query=true` to `server.properties` for LAN discovery
- To update the server later, just rerun the install script

---

## 📤 World Backups

Worlds are stored in the `worlds/` folder, which is excluded from version control. Create your own `backup.sh` script or use cron jobs to periodically archive the folder.

---

## ✅ License

MIT – use freely, share openly.

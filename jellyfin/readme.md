# Jellyfin (Dockerized)

This folder contains a complete setup for running [Jellyfin](https://jellyfin.org/) in Docker, with optional media directory configuration and backup/restore support for persistent settings.

> **Jellyfin** is a free, open-source media server that lets you organize, stream, and share your media collection to any device.

---

## ✨ Features
- Docker-based headless media server
- Configurable media mount path via `.env`
- Simple CLI scripts: `start.sh`, `stop.sh`, `restore-config.sh`, `config-backup.sh`
- Persistent settings using version-controlled backups
- Optional usage with Infuse (Apple TV / iOS)

---

## ⚙️ Prerequisites
- Docker and Docker Compose installed
- A media folder on your host machine with read access
- `bash` available (WSL or Linux/Unix shell)

---

## 📒 Folder structure
```
jellyfin/
├── config/                 # Live config used by the Jellyfin container (gitignored)
├── config-backup/         # Version-controlled config files for backup/restore
├── .env                   # You need to create this. See .env.example
├── .env.example           # Template for .env
├── docker-compose.yml     # Jellyfin Docker setup
├── start.sh               # Starts Jellyfin container
├── stop.sh                # Stops Jellyfin container
├── restore-config.sh      # Restores config-backup to active config
├── config-backup.sh       # Backs up current config to config-backup/
```

---

## ⚡ Quickstart

### 1. Clone the repository
```bash
git clone https://github.com/TBoneMendez/raspberry-projects.git
cd raspberry-projects/jellyfin
```

### 2. Create your `.env` file
```bash
cp .env.example .env
```
Edit `.env` and set your media path:
```env
MEDIA_PATH=/mnt/c/Users/YOURUSERNAME/Documents/mediacenter
```
> This path will be mounted as `/media` inside the container.

### 3. (Optional) Restore saved config
```bash
./restore-config.sh
```

### 4. Start Jellyfin
```bash
./start.sh
```
Access it at: [http://localhost:8096](http://localhost:8096)

---

## 📁 Media setup
Your media files (movies, shows, etc.) must reside in the path defined by `MEDIA_PATH` in .env.
Inside the Jellyfin UI, configure libraries pointing to `/media`.

You can then stream to:
- Web browser
- Jellyfin mobile app
- **Infuse on Apple TV/iOS** (recommended)
  - Infuse supports Jellyfin libraries directly

---

## 🛠️ Scripts
### `start.sh`
Starts the Docker container in detached mode.

### `stop.sh`
Stops and removes the container.

### `restore-config.sh`
Copies backed-up config files from `config-backup/` into `config/` before running Jellyfin. Use this on new setups.

### `config-backup.sh`
Creates a copy of selected non-sensitive config files from the live `config/` folder into `config-backup/`, which is version-controlled.

---

## 🔐 Persistent config (safe backup)
Only safe, non-sensitive files are included in backup:
- `system.xml`
- `network.xml`
- `encoding.xml`
- `logging.default.json`
- `displaypreferences.db`

Sensitive files like `auth.db`, `users.db`, and runtime data are excluded via `.gitignore`.

---

## ✨ Tips
- Use `config-backup.sh` after making config changes
- Keep `.env` out of Git, but version `.env.example`
- Works on Raspberry Pi as well after minor path adjustments

---

Enjoy your self-hosted media server experience! 🎥🎧
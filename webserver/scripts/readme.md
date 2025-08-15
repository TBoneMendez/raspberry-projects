# Startpage Web Server (Raspberry Pi)

Serve a static website (your **startpage**) from a Raspberry Pi using either **systemd** (recommended) or simple **bash scripts**.

- Static files: `/home/pi/github/web/startpage`
- Web server code: `/home/pi/github/raspberry-projects/webserver`
- Default port: `8080`  
- Python: `python3` (usually `/usr/bin/python3`)

> Adjust paths/port below if your setup differs.

---

## Prerequisites

```bash
sudo apt update
sudo apt install -y python3
```

Verify your paths:

```bash
ls /home/pi/github/web/startpage/index.html
ls /home/pi/github/raspberry-projects/webserver/server.py
which python3
```

---

## Option A — systemd service (recommended)

`systemd` will start your webserver at boot, keep it alive, and provide easy logs.

### 1) Create the service unit

```bash
sudo tee /etc/systemd/system/startpage.service > /dev/null <<'EOF'
[Unit]
Description=Startpage static web server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=pi
Group=pi
WorkingDirectory=/home/pi/github/raspberry-projects/webserver
Environment=PORT=8080
Environment=WEBROOT=/home/pi/github/web/startpage
Environment=LOGDIR=/home/pi/github/raspberry-projects/webserver/logs
ExecStart=/usr/bin/python3 /home/pi/github/raspberry-projects/webserver/server.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
```

> If `which python3` is not `/usr/bin/python3`, update `ExecStart` accordingly.

### 2) Enable and start

```bash
sudo systemctl daemon-reload
sudo systemctl enable startpage.service
sudo systemctl start startpage.service
```

### 3) Check status & logs

```bash
sudo systemctl status startpage.service
journalctl -u startpage.service -f
```

### 4) Stop / restart

```bash
sudo systemctl stop startpage.service
sudo systemctl restart startpage.service
```

### 5) Change port or webroot

```bash
sudo systemctl stop startpage.service
sudo nano /etc/systemd/system/startpage.service
# Adjust Environment=PORT=... or Environment=WEBROOT=...
sudo systemctl daemon-reload
sudo systemctl start startpage.service
```

---

## Option B — start.sh (simple background scripts)

If you prefer not to use systemd, you can run the server with `nohup` and helper scripts.

Create these files under:
```
/home/pi/github/raspberry-projects/webserver/scripts/
```

Make them executable:
```bash
chmod +x /home/pi/github/raspberry-projects/webserver/scripts/{start.sh,stop.sh,status.sh,restart.sh}
```

### start.sh
```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/pi/github/raspberry-projects/webserver"
PY="/usr/bin/python3"            # change if different
export PORT=8080
export WEBROOT="/home/pi/github/web/startpage"
export LOGDIR="$ROOT/logs"

RUN="$ROOT/run"
PIDFILE="$RUN/startpage.pid"

mkdir -p "$LOGDIR" "$RUN"
cd "$ROOT"

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "Startpage already running (PID $(cat "$PIDFILE"))."
  exit 0
fi

nohup "$PY" "$ROOT/server.py" >> "$LOGDIR/stdout.log" 2>&1 &
echo $! > "$PIDFILE"
echo "Started Startpage (PID $(cat "$PIDFILE")). Logs: $LOGDIR/stdout.log"
```

### stop.sh
```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="/home/pi/github/raspberry-projects/webserver"
PIDFILE="$ROOT/run/startpage.pid"

if [[ -f "$PIDFILE" ]]; then
  PID=$(cat "$PIDFILE")
  if kill -0 "$PID" 2>/dev/null; then
    kill "$PID"
    echo "Stopped PID $PID."
  else
    echo "No running process for PID $PID."
  fi
  rm -f "$PIDFILE"
else
  echo "No PID file. Service is probably not running."
fi
```

### status.sh
```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="/home/pi/github/raspberry-projects/webserver"
PIDFILE="$ROOT/run/startpage.pid"

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "Running (PID $(cat "$PIDFILE"))."
else
  echo "Not running."
fi
```

### restart.sh
```bash
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
"$DIR/stop.sh" || true
sleep 1
"$DIR/start.sh"
```

### Auto-start at boot with cron (optional)

```bash
crontab -e
```

Add:
```
@reboot /home/pi/github/raspberry-projects/webserver/scripts/start.sh
```

---

## Test locally

On the Pi:
```bash
curl -I http://localhost:8080
```

From another device on your LAN:
```
http://<YOUR_PI_LAN_IP>:8080
```
Find your LAN IP:
```bash
hostname -I
```

---

## Expose to the Internet (optional — be careful)

1. **Port forward** TCP `8080` (or your chosen port) on your router to the Pi’s LAN IP.  
2. Use your static IP or a dynamic DNS hostname.  
3. Strongly consider **TLS** behind a reverse proxy (e.g., Nginx + Let’s Encrypt) before exposing publicly.

---

## Troubleshooting

- **Blank page / 404**: verify `WEBROOT` exists and contains `index.html`.
- **Service won’t start**: check `systemctl status` and `journalctl -u startpage.service -f`.
- **Port already in use**: `sudo lsof -i :8080` then stop the other service or change `PORT`.
- **Permission issues**: ensure `pi` can read your web folder and write to `logs/`.

---

## Update site content

```bash
# Update repository with site files
cd /home/pi/github/web
git pull

# Restart service (systemd)
sudo systemctl restart startpage.service

# or (scripts)
/home/pi/github/raspberry-projects/webserver/scripts/restart.sh
```

---

## Layout (example)

```
/home/pi/github/
└── raspberry-projects/
    └── webserver/
        ├── server.py
        ├── logs/
        ├── run/
        └── scripts/
            ├── start.sh
            ├── stop.sh
            ├── status.sh
            ├── restart.sh
            └── README.md   ← this file
/home/pi/github/web/startpage/
└── index.html  (and the rest of your site)
```

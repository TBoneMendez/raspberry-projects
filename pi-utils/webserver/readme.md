# Startpage on Raspberry Pi (HTTPS via Caddy + Python static server)

This guide shows how to serve your **Startpage** from a Raspberry Pi with:
- A tiny Python static web server on **port 8080** (systemd service).
- **Caddy** on **ports 80/443** as a reverse proxy with automatic HTTPS (Let’s Encrypt / ZeroSSL).
- Auto-start on boot.
- Safe, manual updates from GitHub (no auto-pull timers).

> Domain used in examples: `tbonemendez.duckdns.org`. Replace with your own domain if different.

---

## 0) Prerequisites

- Raspberry Pi with Raspberry Pi OS (Bookworm or similar)
- User `pi` with `sudo` privileges
- Your domain (e.g. DuckDNS) pointing to your **public IP**
- Router port-forwarding access (forward **TCP 80 and 443** to the Pi’s **LAN IP**)
- Repos:
  - Startpage: `https://github.com/TBoneMendez/web` (site lives in `startpage/`)
  - Simple webserver: `https://github.com/TBoneMendez/raspberry-projects` (uses `webserver/`)

---

## 1) Get the code on the Pi

```bash
# 1) Make a workspace
mkdir -p ~/github && cd ~/github

# 2) Clone your repos
git clone https://github.com/TBoneMendez/web.git
git clone https://github.com/TBoneMendez/raspberry-projects.git

# Startpage lives here:
#   /home/pi/github/web/startpage

# Webserver lives here:
#   /home/pi/github/raspberry-projects/webserver
```

---

## 2) Python static server as a systemd service (port 8080)

The webserver is a tiny Python script that serves static files from `WEBROOT`.  
Make sure your `server.py` uses the `WEBROOT` environment variable (fallback = startpage path):

```python
# /home/pi/github/raspberry-projects/webserver/server.py (top of file)
import os, http.server, socketserver

WEBROOT = os.environ.get("WEBROOT", os.path.expanduser("~/github/web/startpage"))
os.chdir(WEBROOT)

PORT = int(os.environ.get("PORT", "8080"))

class Handler(http.server.SimpleHTTPRequestHandler):
    # You can customize headers/mime types here if needed
    pass

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving {WEBROOT} on port {PORT}")
    httpd.serve_forever()
```

Create the service unit:

```bash
sudo tee /etc/systemd/system/startpage.service >/dev/null <<'EOF'
[Unit]
Description=Startpage static web server
After=network-online.target
Wants=network-online.target

[Service]
User=pi
Group=pi
Environment=WEBROOT=/home/pi/github/web/startpage
Environment=PORT=8080
ExecStart=/usr/bin/python3 /home/pi/github/raspberry-projects/webserver/server.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable --now startpage.service

# Verify
systemctl status startpage.service
curl -I http://127.0.0.1:8080
```

You should see `HTTP/1.0 200 OK` from the local probe.

---

## 3) Install Caddy (HTTPS reverse proxy on 80/443)

Caddy will terminate TLS and forward to your local server on `127.0.0.1:8080`.

### 3.1 Install Caddy

```bash
sudo apt update
sudo apt install -y curl debian-keyring debian-archive-keyring apt-transport-https

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
  | sudo tee /etc/apt/trusted.gpg.d/caddy-stable.asc >/dev/null

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
  | sudo tee /etc/apt/sources.list.d/caddy-stable.list

sudo apt update
sudo apt install -y caddy

# Make sure it’s enabled
sudo systemctl enable --now caddy
```

### 3.2 Configure Caddy

Create/edit `/etc/caddy/Caddyfile`:

```bash
sudo tee /etc/caddy/Caddyfile >/dev/null <<'EOF'
tbonemendez.duckdns.org {
    encode zstd gzip
    reverse_proxy 127.0.0.1:8080
    log {
        output file /var/log/caddy/access.log
        format console
    }
}
EOF
```

Reload Caddy:

```bash
sudo systemctl reload caddy
sudo systemctl status caddy
```

> **Important:** Ensure your router/NAT forwards **TCP 80 & 443** to your Pi’s LAN IP (e.g. `192.168.68.101`).  
> Caddy must be reachable on **80** (for ACME HTTP-01 verification) and will serve **443**.

### 3.3 Verify DNS & certificate issuance

```bash
# Optional tools for testing
sudo apt install -y dnsutils

# Does DuckDNS resolve to your public IP?
dig +short tbonemendez.duckdns.org @1.1.1.1

# What is your public IP?
curl -s ifconfig.me

# HTTP should redirect to HTTPS (308)
curl -I http://tbonemendez.duckdns.org

# Test HTTPS handshake (verbose)
curl -vk https://tbonemendez.duckdns.org
```

If Caddy can reach ports 80/443 publicly, it will auto-provision a certificate. You’ll see success messages in:

```bash
sudo journalctl -u caddy -f
```

---

## 4) Geolocation in the browser

Browser geolocation requires **HTTPS** (or `localhost`).  
Once your site is served via `https://tbonemendez.duckdns.org`, the weather widget’s geolocation will work (if the user allows it).

---

## 5) Daily operations

```bash
# Start/stop/restart/startpage web server (Python on 8080)
sudo systemctl start startpage
sudo systemctl stop startpage
sudo systemctl restart startpage
systemctl status startpage
journalctl -u startpage -f

# Caddy (HTTPS on 80/443)
sudo systemctl reload caddy
sudo systemctl restart caddy
systemctl status caddy
sudo journalctl -u caddy -f

# Check listeners
sudo ss -ltnp | grep -E ':(80|443|8080)\s'

# Sanity tests
curl -I http://127.0.0.1:8080
curl -I http://tbonemendez.duckdns.org
curl -vk https://tbonemendez.duckdns.org
```

---

## 6) Auto-start on reboot

Both services are enabled already:

```bash
systemctl is-enabled startpage
systemctl is-enabled caddy
```

On every reboot:
- `startpage.service` will start your Python static server on port 8080.
- `caddy.service` will start and serve HTTPS on 443 and HTTP->HTTPS redirect on 80.

---

## 7) Router / Port forwarding notes

- Forward **TCP 80 → Pi:80**, **TCP 443 → Pi:443** (do **not** forward 8080 to WAN).
- If your router has an “Application” or “Virtual Server” mode, ensure it’s TCP (not UDP).
- Avoid duplicate/overlapping rules that forward ports away from the Pi.

---

## 8) Troubleshooting

- **Certificate errors (ACME/Let’s Encrypt)**  
  - Confirm DNS points to your public IP.
  - Ensure ports **80/443** are forwarded to the Pi and not blocked by your ISP.
  - Check Caddy logs: `sudo journalctl -u caddy -f`.
  - Reload Caddy after changing the Caddyfile: `sudo systemctl reload caddy`.

- **Site not reachable on LAN but Caddy running**  
  - Test locally: `curl -I http://127.0.0.1:8080` (Python) and `curl -I http://localhost` (Caddy).  
  - If local works but remote fails, it’s usually DNS or port-forwarding.
  
- **Geolocation not working**  
  - Use **HTTPS** URL (or `localhost`). Accept the browser prompt.

- **“Connection reset by peer” in Python logs**  
  - Normal when clients drop connections early. Not harmful.

---

## 9) Quick local preview (no Caddy, for development)

From the `startpage/` folder on your dev machine:

```bash
cd startpage
python3 -m http.server 8080
# open http://localhost:8080/
```

---

## 10) File/Folder Map (on the Pi)

```
/home/pi/github/
  web/
    startpage/          # <-- your site (index.html, assets/...)
  raspberry-projects/
    webserver/
      server.py         # <-- tiny Python static server
/etc/caddy/Caddyfile    # <-- Caddy config
/var/log/caddy/         # <-- Caddy access logs (if configured)
```

---

## 11) What happens on boot?

1. `startpage.service` starts the Python static server on `127.0.0.1:8080` and serves files from `~/github/web/startpage`.
2. `caddy.service` listens on `:80` and `:443`. It redirects HTTP→HTTPS and proxies HTTPS to `127.0.0.1:8080`.
3. Your browser visits `https://tbonemendez.duckdns.org` and the site loads with geolocation enabled.

That’s it 🎉

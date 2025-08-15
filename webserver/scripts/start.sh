#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/pi/github/raspberry-projects/webserver"
PY="/usr/bin/python3"   # juster ved behov
export PORT=8080
export WEBROOT="/home/pi/github/web/startpage"
export LOGDIR="$ROOT/logs"

RUN="$ROOT/run"
PIDFILE="$RUN/startpage.pid"

mkdir -p "$LOGDIR" "$RUN"
cd "$ROOT"

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "Startpage kjører allerede (PID $(cat "$PIDFILE"))."
  exit 0
fi

nohup "$PY" "$ROOT/server.py" >> "$LOGDIR/stdout.log" 2>&1 &
echo $! > "$PIDFILE"
echo "Startet Startpage (PID $(cat "$PIDFILE")). Logger: $LOGDIR/stdout.log"

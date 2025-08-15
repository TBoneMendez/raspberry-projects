#!/usr/bin/env bash
set -euo pipefail
ROOT="/home/pi/github/raspberry-projects/webserver"
PIDFILE="$ROOT/run/startpage.pid"

if [[ -f "$PIDFILE" ]]; then
  PID=$(cat "$PIDFILE")
  if kill -0 "$PID" 2>/dev/null; then
    kill "$PID"
    echo "Stoppet PID $PID."
  else
    echo "Prosess med PID $PID finnes ikke."
  fi
  rm -f "$PIDFILE"
else
  echo "Ingen PID-fil. Tjenesten kjører trolig ikke."
fi

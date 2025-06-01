#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"
LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/server.log"

mkdir -p "$LOG_DIR"

PID=$(pgrep -f server.py)
if [ -n "$PID" ]; then
  echo "🧹 Stopper tidligere Python-server (PID: $PID)"
  kill $PID
fi

echo "🚀 Starter Python-server i bakgrunnen..."
nohup python3 "$PROJECT_ROOT/server.py" > "$LOG_FILE" 2>&1 &
echo "📂 Logger til: $LOG_FILE"

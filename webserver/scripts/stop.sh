#!/bin/bash

PID=$(pgrep -f server.py)

if [ -n "$PID" ]; then
  kill $PID
  echo "🛑 Python-server stoppet (PID: $PID)"
else
  echo "ℹ️ Fant ingen kjørende Python-server å stoppe."
fi

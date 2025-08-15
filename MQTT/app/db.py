from __future__ import annotations
import sqlite3, os, time
from contextlib import contextmanager

SCHEMA = """
CREATE TABLE IF NOT EXISTS mqtt_events(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts_utc TEXT NOT NULL,         -- ISO8601
  direction TEXT NOT NULL,      -- 'in' (from Homey) | 'out' (to Homey)
  topic TEXT NOT NULL,
  payload TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_mqtt_events_ts ON mqtt_events(ts_utc);
CREATE INDEX IF NOT EXISTS idx_mqtt_events_topic ON mqtt_events(topic);
"""

@contextmanager
def get_conn(db_path: str):
    os.makedirs(os.path.dirname(db_path), exist_ok=True)
    conn = sqlite3.connect(db_path, isolation_level=None)  # autocommit
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.execute("PRAGMA synchronous=NORMAL;")
    yield conn
    conn.close()

def init(db_path: str):
    with get_conn(db_path) as c:
        c.executescript(SCHEMA)

def insert_event(db_path: str, direction: str, topic: str, payload: str, ts_utc: str):
    with get_conn(db_path) as c:
        c.execute(
            "INSERT INTO mqtt_events(ts_utc, direction, topic, payload) VALUES(?,?,?,?)",
            (ts_utc, direction, topic, payload),
        )

def enforce_retention(db_path: str, days: int):
    if days <= 0: return
    cutoff = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime(time.time() - days*86400))
    with get_conn(db_path) as c:
        c.execute("DELETE FROM mqtt_events WHERE ts_utc < ?", (cutoff,))

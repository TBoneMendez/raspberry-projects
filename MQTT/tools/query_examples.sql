-- last 100 messages
SELECT ts_utc, direction, topic, payload
FROM mqtt_events
ORDER BY ts_utc DESC
LIMIT 100;

-- count per topic in the last 24h
SELECT topic, COUNT(*) AS n
FROM mqtt_events
WHERE ts_utc >= datetime('now','-1 day')
GROUP BY topic
ORDER BY n DESC;

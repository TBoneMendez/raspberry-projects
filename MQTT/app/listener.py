import json, time, tomli as toml
from paho.mqtt import client as mqtt
from db import init, insert_event, enforce_retention

cfg = toml.load("mqtt_config.toml")
BROKER = cfg["broker"]
DB     = cfg["sqlite"]
TOPICS = cfg["topics"]

init(DB["path"])

def iso_now():
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

def handle_command(topic, payload):
    # Add your routing here
    try:
        data = json.loads(payload)
    except json.JSONDecodeError:
        data = {"raw": payload}
    # Example action
    if topic == "homey/cmd/heatpump/set_temp":
        target = data.get("value")
        print(f"[ACTION] Set heatpump temp to {target}")

def on_connect(client, userdata, flags, reason_code, properties=None):
    print("Connected:", reason_code)
    client.subscribe(TOPICS["subscribe_commands"], qos=1)

def on_message(client, userdata, msg):
    payload = msg.payload.decode("utf-8")
    print("IN:", msg.topic, payload)
    insert_event(DB["path"], "in", msg.topic, payload, iso_now())

    # optional: prune occasionally
    enforce_retention(DB["path"], DB.get("retention_days", 30))
    handle_command(msg.topic, payload)

client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id=f'{BROKER.get("client_id_prefix","pi5")}-listener')
client.username_pw_set(BROKER["username"], BROKER["password"])
client.on_connect = on_connect
client.on_message = on_message
client.connect(BROKER["host"], BROKER["port"], keepalive=60)
client.loop_forever()

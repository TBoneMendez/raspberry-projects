import json, time, tomli as toml
from paho.mqtt import client as mqtt
from db import init, insert_event

cfg = toml.load("mqtt_config.toml")
BROKER = cfg["broker"]
DB     = cfg["sqlite"]
TOPICS = cfg["topics"]

init(DB["path"])

def iso_now():
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

def on_connect(client, userdata, flags, reason_code, properties=None):
    print("Connected:", reason_code)

client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id=f'{BROKER.get("client_id_prefix","pi5")}-publisher')
client.username_pw_set(BROKER["username"], BROKER["password"])
client.on_connect = on_connect
client.connect(BROKER["host"], BROKER["port"], keepalive=60)
client.loop_start()

payload = {"ts": iso_now(), "value": 22.6, "unit": "C", "source": "pi5-livingroom"}
client.publish(TOPICS["publish_temperature"], json.dumps(payload), qos=1, retain=False)
insert_event(DB["path"], "out", TOPICS["publish_temperature"], json.dumps(payload), iso_now())

time.sleep(1)
client.loop_stop(); client.disconnect()

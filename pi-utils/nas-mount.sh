#!/bin/bash
# Mount NAS share to /home/pi/mounts on Raspberry Pi

MOUNT_POINT="/home/pi/mounts"
REMOTE_PATH="//192.168.68.76/Volume_1/PUBLIC"

echo "🔄 Mounting NAS share from $REMOTE_PATH to $MOUNT_POINT..."

# Create mount point if it doesn't exist
sudo mkdir -p "$MOUNT_POINT"

# Attempt mount using SMBv1 and guest access
sudo mount -t cifs -o guest,uid=1000,gid=1000,vers=1.0 "$REMOTE_PATH" "$MOUNT_POINT"

echo "✅ Done. You can now access files at: $MOUNT_POINT"

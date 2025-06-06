# 🛠️ pi-utils

A collection of utility scripts to streamline the management and configuration of Raspberry Pi. These tools are designed to assist with system updates, network management, service control, and more, making the Raspberry Pi experience more efficient and user-friendly.

## 📂 Directory Overview

- **`pi-utils/`**: Contains shell scripts for various administrative tasks.
- **`README.md`**: This documentation file.

## 🔧 Utility Scripts

### System Maintenance

- **`update-system.sh`**: Updates and upgrades installed packages, and removes unnecessary ones.

  ```bash
  sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
  ```

### Network Management

- **`ip-address.sh`**: Displays the current IP addresses assigned to the Raspberry Pi.

  ```bash
  hostname -I
  ```

- **`network-scan.sh`**: Scans the local network to identify active devices (requires `nmap`).

  ```bash
  nmap -sn 192.168.68.0/24
  ```

- **`wifi-off.sh`**: Disables the Wi-Fi interface.

  ```bash
  sudo rfkill block wifi
  ```

- **`wifi-on.sh`**: Enables the Wi-Fi interface.

  ```bash
  sudo rfkill unblock wifi
  ```

### Service Control

- **`enable-gui.sh`**: Starts the graphical desktop environment.

  ```bash
  sudo systemctl start lightdm
  ```

- **`disable-gui.sh`**: Stops the graphical desktop environment.

  ```bash
  sudo systemctl stop lightdm
  ```

### Process Management

- **`list-processes.sh`**: Lists all running processes.

  ```bash
  ps aux
  ```

- **`kill-port.sh`**: Prompts for a port number and kills the process using that port.

  ```bash
  #!/bin/bash
  read -p "Enter port number to kill process: " port
  pid=$(sudo lsof -t -i :$port)
  if [ -n "$pid" ]; then
    sudo kill -9 $pid
    echo "Process on port $port has been terminated."
  else
    echo "No process is using port $port."
  fi
  ```

- **`htop.sh`**: Launches the `htop` process viewer (requires installation).

  ```bash
  htop
  ```

## 🧰 Raspberry Pi Configuration Commands

Utilize the `raspi-config` tool to configure various system settings:

```bash
sudo raspi-config
```

Key configuration options include:

- **System Options**: Set hostname, password, and boot preferences.
- **Display Options**: Adjust screen resolution and overscan.
- **Interface Options**: Enable/disable interfaces like SSH, VNC, SPI, and I2C.
- **Performance Options**: Overclocking and GPU memory settings.
- **Localization Options**: Set locale, timezone, keyboard layout, and Wi-Fi country.

For non-interactive configurations, use:

```bash
sudo raspi-config nonint do_<option>
```

Replace `<option>` with the desired configuration command. For example, to enable SSH:

```bash
sudo raspi-config nonint do_ssh 0
```

Refer to the [official Raspberry Pi documentation](https://www.raspberrypi.com/documentation/configuration/raspi-config.md) for a comprehensive list of non-interactive commands.

## 📦 Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/TBoneMendez/raspberry-projects.git
   ```

2. Navigate to the `pi-utils` directory:

   ```bash
   cd raspberry-projects/pi-utils
   ```

3. Make scripts executable:

   ```bash
   chmod +x *.sh
   ```

4. (Optional) Add `pi-utils` to your PATH:

   ```bash
   echo 'export PATH="$HOME/raspberry-projects/pi-utils:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

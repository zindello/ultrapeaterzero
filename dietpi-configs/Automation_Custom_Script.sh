#!/bin/bash

echo "Flash the blue LED to give a status indication that we're installing pyMC"
LED_PIN=16 # GPIO16
gpio mode $LED_PIN out
while true; do
    pinctrl set $LED_PIN op dh; sleep 1
    pinctrl set $LED_PIN op dl; sleep 1
done &

# 2. Capture the PID of the background process
FLASH_PID=$!

echo "=== Installing Git & Vim ==="
apt install -y git vim raspi-utils

PYMC_SCRIPT_DIR="/tmp/pymc_repeater_install"
PYMC_LOG_DIR="/var/log/pync_repeater"
PYMC_REPO_URL="${1:-https://github.com/rightup/pyMC_Repeater.git}"
PYMC_REPO_BRANCH="${2:-dev}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=== UltraPeaterZero System Reduction – Removing Unnecessary Bloat ==="

echo "=== Removing Cron ==="

systemctl disable --now cron 2>/dev/null || true
apt purge -y cron 2>/dev/null || true

echo "=== Configuring Journald for in-memory only, limiting to 24M total ==="
mkdir -p /etc/systemd/journald.conf.d
cat << EOF | sudo tee /etc/systemd/journald.conf.d/ultrapeater.conf
[Journal]
Storage=volatile
RuntimeMaxUse=8M
SystemMaxUse=16M
RateLimitIntervalSec=30s
RateLimitBurst=1000
EOF
systemctl restart systemd-journald

echo "=== Enabling SPI ==="
/boot/dietpi/func/dietpi-set_hardware spi enable
dtparam spi=on
modprobe spidev

echo "=== Fixing ramdisk log directory to prevent failure to start after reboot ==="
echo "d /var/log/pymc_repeater 0755 repeater repeater -" > /etc/tmpfiles.d/pymc-repeater.conf

echo "=== Cloning down repo ==="
git clone --single-branch --branch $PYMC_REPO_BRANCH $PYMC_REPO_URL $PYMC_SCRIPT_DIR

echo "=== Setup the default config to turn the blue LED on solid when pyMC starts"
sed -i "/^  rxen_pin:.*/a\\  en_pins: [ 16 ] " "$PYMC_SCRIPT_DIR/config.yaml.example"
sed -i "s/cs_pin: 21/cs_pin: -1/" "$PYMC_SCRIPT_DIR/config.yaml.example"

echo "=== Copying in our custom radio config ==="
echo "# Copy in our BoardConfig so that you only get the options of our two variants"
rm $PYMC_SCRIPT_DIR/radio-settings.json
cat << EOF | sudo tee $PYMC_SCRIPT_DIR/radio-settings.json
{
  "hardware": {
      "ultrapeaterzero-e22": {
      "name": "Zindello Industries UltraPeater Zero E22",
      "bus_id": 0,
      "cs_id": 0,
      "cs_pin": 24,
      "reset_pin": 25,
      "busy_pin": 5,
      "irq_pin": 12,
      "txen_pin": 27,
      "rxen_pin": 17,
      "en_pins": [ 16 ],
      "txled_pin": 21,
      "rxled_pin": 20,
      "tx_power": 22,
      "use_dio2_rf": false,
      "use_dio3_tcxo": true,
      "preamble_length": 17
    },
      "ultrapeaterzero-e22p": {
      "name": "Zindello Industries UltraPeater Zero E22P",
      "bus_id": 0,
      "cs_id": 0,
      "cs_pin": 24,
      "reset_pin": 25,
      "busy_pin": 5,
      "irq_pin": 12,
      "txen_pin": 27,
      "rxen_pin": -1,
      "en_pins": [16, 17],
      "txled_pin": 21,
      "rxled_pin": 20,
      "tx_power": 22,
      "use_dio2_rf": false,
      "use_dio3_tcxo": true,
      "preamble_length": 17
    }
  }
}
EOF


echo "=== Installing pyMC ==="
cd $PYMC_SCRIPT_DIR
./manage.sh install

echo "=== Cleaning Up ==="
rm -rf $PYMC_SCRIPT_DIR

kill $FLASH_PID
pinctrl set $LED_PIN op dh; sleep 1


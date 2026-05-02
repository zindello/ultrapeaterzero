# UltrapeaterZero

> A ready-to-run MeshCore repeater built on a Raspberry Pi Zero 2W, powered by DietPi.

This repository contains the configuration files needed to get your UltrapeaterZero board up and running quickly. The setup is largely automated — once you've copied a few files to your SD card and filled in your Wi-Fi details, the board will configure itself on first boot.

---

## What You'll Need Before Starting

- A Raspberry Pi Zero 2W
- The [UltraPeaterZero board](https://zindello.com.au/shop/ultrapeaterzero/)
- A microSD card (8 GB or larger recommended)
- A computer with an SD card reader
- Your Wi-Fi network name (SSID) and password
- [Balena Etcher](https://etcher.balena.io/) installed on your computer (free, Windows/macOS/Linux)

---

## Step 1 — Download the DietPi Image

1. Go to the [DietPi downloads page](https://dietpi.com/#download).
2. Under **Raspberry Pi**, find the image labelled **"Raspberry Pi 2/3/4/Zero 2"** — this is the correct image for the Pi Zero 2W. The default download will be the **Trixie (Debian 13)** image, which is what you want.
3. Download the `.img.xz` file to your computer. You do not need to extract it — Balena Etcher handles that automatically.

---

## Step 2 — Flash the Image to Your SD Card

1. Insert your microSD card into your computer's card reader.
2. Open **Balena Etcher**.
3. Click **Flash from file** and select the `.img.xz` file you just downloaded.
4. Click **Select target** and choose your microSD card from the list.
   > ⚠️ **Double-check you've selected the correct drive.** Etcher will erase everything on the chosen target.
5. Click **Flash!** and wait for the process to complete. This may take a few minutes.
6. Once flashing and verification are done, remove the SD card from your computer and reinsert it. Wait for it to reappear before continuing — **do not eject the SD card yet** after it shows up, as you need to copy some files to it first.

---

## Step 3 — Download This Repository

1. Go to [github.com/zindello/ultrapeaterzero](https://github.com/zindello/ultrapeaterzero).
2. Click the green **Code** button near the top right of the page.
3. Click **Download ZIP**.
4. Once downloaded, extract the ZIP file. You should see a folder called `ultrapeaterzero-main` (or similar) on your computer.

---

## Step 4 — Copy the Configuration Files to the SD Card

After flashing, your SD card will have a small partition visible on your computer called **`bootfs`** (it may also appear as `boot` on some systems).

Open the extracted folder and navigate into the **`dietpi-configs`** subfolder. Copy the following three files from there into the **root** of the `bootfs` partition (i.e., directly into the drive, not inside any subfolder):

| File | Purpose |
|------|---------|
| `dietpi.txt` | Main DietPi configuration — sets up the system automatically on first boot |
| `dietpi-wifi.txt` | Wi-Fi credentials — tells the Pi which network to connect to |
| `Automation_Custom_Script.sh` | Runs automatically after DietPi installs to set up the UltrapeaterZero software |

> **Tip:** On Windows, the `bootfs` partition will appear as a new drive letter (e.g., `D:\` or `E:\`) in File Explorer after flashing. On macOS, it will appear on your Desktop or in Finder under Locations. On Linux, it will be mounted under `/media/` or `/mnt/`.

---

## Step 5 — Configure Your Wi-Fi Details

Before ejecting the SD card, you need to add your Wi-Fi credentials so the Pi can connect to your network on first boot.

1. Open the `dietpi-wifi.txt` file you just copied to the SD card in a plain text editor.
   - **Windows:** Notepad or Notepad++
   - **macOS:** TextEdit (make sure it's in plain text mode: Format → Make Plain Text)
   - **Linux:** gedit, nano, or any text editor

2. The file contains the following two lines:

```
aWIFI_SSID[0]='<your-ssid>'
aWIFI_KEY[0]='<your-psk>'
```

3. Replace `<your-ssid>` with your Wi-Fi network name and `<your-psk>` with your Wi-Fi password, keeping the single quotes. For example:

```
aWIFI_SSID[0]='MyNetwork'
aWIFI_KEY[0]='MyPassword123'
```

> Your Wi-Fi network name is case-sensitive — make sure it matches exactly as it appears on your devices.

4. Save the file.

---

## Step 6 — Eject the SD Card and Insert It into the Pi

1. Safely eject the SD card from your computer.
   - **Windows:** Right-click the drive in File Explorer → Eject
   - **macOS:** Click the eject icon next to the drive in Finder
   - **Linux:** Right-click the mounted volume → Unmount/Eject
2. Insert the microSD card into the microSD slot on the UltrapeaterZero board.
3. Connect power to the board.

---

## Step 7 — Find the IP Address of Your UltrapeaterZero

After powering on, the device will connect to your Wi-Fi network within a minute or two. You'll need its IP address for the next step.

The easiest way to find it is through your **router's admin page**:

1. Open a web browser and go to your router's admin address. Common addresses are:
   - `http://192.168.1.1`
   - `http://192.168.0.1`
   - `http://10.0.0.1`
   - (Check the label on the back of your router if unsure)
2. Log in with your router's admin username and password (also usually on the router label).
3. Look for a section called **Connected Devices**, **DHCP Clients**, **Device List**, or similar.
4. Find the device named `UltraPeaterZero` in the list — the IP address will be shown next to it.

---

## Step 8 — Monitor the First Boot via SSH

The first boot will take several minutes while DietPi expands the filesystem, applies your configuration, installs required packages, and prepares the system. You can watch its progress by connecting via SSH.

Open a terminal on your computer and run:

```bash
ssh root@<ip-address>
```

Replace `<ip-address>` with the IP you found in the previous step. For example:

```bash
ssh root@192.168.0.80
```

> **Windows users:** Windows 10 and 11 include SSH built into Command Prompt and PowerShell. Alternatively, you can use [PuTTY](https://www.putty.org/).

When prompted for a password, enter: `dietpi`

Once connected, you'll see output similar to this while the automated setup is running:

```
 ─────────────────────────────────────────────────────
 DietPi v10.2.3 : Update available
 ─────────────────────────────────────────────────────
 - LAN IP : <ip-address> (wlan0)
[ INFO ] DietPi-Login | [ INFO ] DietPi first run setup is currently running on another screen (PID=857).
Automated setup is in progress. The system might be rebooted in between.
[ INFO ] DietPi-Login | Waiting 5 seconds before checking again. Please wait... (Press CTRL+C to abort)
```

This is normal — just leave it running. The setup will continue in the background and the terminal will update as it progresses. Do not power off the board during this process.

Once the automated setup finishes you'll be dropped into a terminal prompt. At this point, **the blue LED on the UltrapeaterZero board will begin flashing** — this indicates that pyMC is currently being installed. Depending on your hardware this can take anywhere from 15 minutes to nearly an hour, so sit tight.

**When the blue LED becomes solid (stops flashing), pyMC is fully installed and ready.**

---

## Step 9 — Access the Web Interface

Once the blue LED is solid, open a web browser on any device connected to the same Wi-Fi network and go to:

```
http://<ip-address>:8000/
```

You should see the UltrapeaterZero web interface, where you can configure and monitor your MeshCore repeater.

---

## Troubleshooting

**I can't find the device in my router:**
- Try waiting a few more minutes and refreshing the router device list.
- Some routers take a while to show newly connected devices.
- If the device still doesn't appear, remove the SD card, insert it back into your computer and check the Wi-Fi credentials in `dietpi-wifi.txt` are correct.

**The blue LED never came on / never went solid:**
- Ensure the SD card is fully seated in the slot.
- If the Pi can't connect to Wi-Fi, it may stall. Remove the SD card, insert it back into your computer and check the Wi-Fi credentials in `dietpi-wifi.txt` are correct, then reflash the card and try again.
- The flashing LED indicates pyMC is installing — this can take up to 60 minutes on slower hardware. If it is still flashing after 60 minutes, try rebooting the board.

**The web interface won't load:**
- Make sure you're using `http://` not `https://`.
- Make sure you're on the same Wi-Fi network as the UltrapeaterZero.
- Make sure you're including `:8000` at the end of the address.

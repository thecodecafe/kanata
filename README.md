# Kanata macOS Keyboard Configuration

This repository contains my personal **Kanata keyboard configuration** for macOS.

The setup focuses on:

* Home-row modifiers
* Caps Lock / Escape remapping
* A Vim-style navigation layer
* A stable macOS setup that avoids DriverKit issues

This document explains **what the config does**, **what you must install**, and **how to set it up correctly on macOS**.

---

## What this configuration does

This Kanata config provides:

* **Home-row modifiers**

  * `a` → Ctrl (hold)
  * `s` → Alt (hold)
  * `d` → Command (hold)
  * `f` → Shift (hold)
  * `j k l ;` mirror the same modifiers on the right hand
  * Tap any of these keys → normal character
  * **Double-tap and hold any home-row key** → the original key is sent and **repeats normally** (as long as key repeat is enabled in macOS)

* **Caps Lock / Escape behavior**

  * Caps Lock → Escape
  * Escape → Caps Lock (tap)
  * Escape (hold) → navigation layer

* **Navigation layer (Vim-style)**

  * Hold **Escape** and press:

    * `h` for ←
    * `j` for ↓
    * `k` for ↑
    * `l` for →

* **Mouse layer**

  * Hold **Space** to enter the mouse layer
  * While holding Space:

    * `h` → move mouse left
    * `j` → move mouse down
    * `k` → move mouse up
    * `l` → move mouse right
  * While in the mouse layer:

    * Tap `f` → left mouse click
    * Tap `d` → right mouse click

*

* **Function keys remapped to macOS media & system controls**

  * `F1–F12` provide brightness, media, volume, and other standard macOS system controls
  * The original function keys are still available via layer logic defined in the config

* All other keys behave normally

---

## Installation

### 1. Clone this repository

This repository contains the `kanata.kbd` configuration file.

Clone it to **any directory you prefer**. The project location is **not fixed** and is determined entirely by the person cloning it.

For example:

```sh
git clone <REPO_URL> <YOUR_KANATA_DIRECTORY>
# Eample
git clone <REPO_URL> ~/projects/kanata
```

---

### 2. Create a symbolic link to Kanata’s config directory (IMPORTANT)

I do not edit Kanata config files directly inside **`~/.config/kanata`**.

Instead, I keep the repository in a directory of my choosing (for example `<KANATA_REPO_DIR>`) and create a symbolic link:

```sh
ln -s <KANATA_REPO_DIR> ~/.config/kanata
# Example
ln -s ~/projects/kanata ~/.config/kanata
```

This ensures:

* The config is version-controlled
* The config is edited from a proper project directory
* The home directory is not directly modified by the editor

**This approach is strongly recommended.**

---

### 3. macOS prerequisites (IMPORTANT)

### 1. Install Karabiner-Elements (driver only)

Kanata **requires a virtual HID keyboard driver on macOS**.
This driver is provided by **Karabiner-Elements**.

Download and install Karabiner-Elements from:

[https://karabiner-elements.pqrs.org/](https://karabiner-elements.pqrs.org/)

**Important notes:**

* Karabiner is used **only** to provide the **VirtualHIDDevice**
* You **must not** configure key mappings in Karabiner
* Let Kanata handle all remapping logic

> ⚠️ Mapping keys in Karabiner **will interfere with Kanata** and cause undefined behavior.

After installation, ensure:

* Karabiner-Elements Virtual Keyboard is enabled
* The DriverKit VirtualHIDDevice is **activated and enabled** in macOS

---

### 2. Install Kanata

Kanata is the tool that performs all key remapping.

Kanata repository:

[https://github.com/jtroo/kanata](https://github.com/jtroo/kanata)

On macOS (Homebrew):

```sh
brew install kanata
```

---

## Granting macOS permissions (CRITICAL)

Kanata will not work without **Accessibility** and **Input Monitoring** permissions.

### Required permissions

* Accessibility
* Input Monitoring

### How to grant them

1. Open **System Settings → Privacy & Security**
2. Go to **Accessibility**
3. Enable **kanata**
4. Go to **Input Monitoring**
5. Enable **kanata**

### If Kanata does NOT appear in the list

macOS only shows binaries that have attempted to run.

1. Run Kanata once:

   ```sh
   sudo kanata -c ~/.config/kanata/kanata.kbd
   ```
2. Return to **Privacy & Security**
3. Click **➕**
4. Add the Kanata binary manually:

   * Apple Silicon: `/opt/homebrew/bin/kanata`
   * Intel Macs: `/usr/local/bin/kanata`

After granting permissions, **restart Kanata**.

---

## Running Kanata automatically on startup (macOS)

Kanata must run as **root** to access the virtual HID device.
The correct mechanism is a **LaunchDaemon**, not a LaunchAgent.

### Create the LaunchDaemon

Create the file:

```sh
sudo nano /Library/LaunchDaemons/kanata.plist
```

Paste the following (update paths if needed):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0.dtd"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>kanata</string>

    <key>ProgramArguments</key>
    <array>
      <string>/opt/homebrew/bin/kanata</string>
      <string>-c</string>
      <string>/Users/YOUR_USERNAME/.config/kanata/kanata.kbd</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>
  </dict>
</plist>
```

Fix permissions:

```sh
sudo chown root:wheel /Library/LaunchDaemons/kanata.plist
sudo chmod 644 /Library/LaunchDaemons/kanata.plist
```

Load it:

```sh
sudo launchctl bootstrap system /Library/LaunchDaemons/kanata.plist
```

Kanata will now start automatically on boot.

---

## Repository layout & symbolic linking (IMPORTANT)

I do **not** edit my Kanata config directly in `~/.config/kanata`.

Instead, the repository lives in a directory chosen by the user (for example `<KANATA_REPO_DIR>`), and I create a **symbolic link**:

```sh
ln -s <KANATA_REPO_DIR> ~/.config/kanata
```

### Why this matters

* Your editor works inside a normal project directory
* The repo location is flexible and not hard‑coded
* The config remains version‑controlled and safe
* `~/.config/kanata` stays clean and minimal

**This approach is strongly recommended.****

---

## Important warnings

* ❌ Do NOT configure key mappings in Karabiner
* ❌ Do NOT uninstall Karabiner after Kanata is working
* ❌ Do NOT run Kanata as a LaunchAgent
* ❌ Do NOT run multiple keyboard remappers at once

✅ Karabiner = driver only
✅ Kanata = all keyboard logic

---

## Summary

This setup provides:

* A powerful, ergonomic keyboard layout
* Stable macOS behavior
* No DriverKit churn
* No remapping conflicts
* A reproducible, version-controlled configuration

If something breaks after a macOS update, check:

* Accessibility permission for Kanata
* Input Monitoring permission for Kanata
* That Karabiner’s VirtualHIDDevice is still enabled

---

Happy hacking. ⌨️

## Kanata Control Scripts

This repository includes a unified control script for managing Kanata as a **system LaunchDaemon** on macOS.

### Script: `kanata.sh`

Supported subcommands:

```bash
./kanata.sh start    # Start Kanata if not running
./kanata.sh stop     # Stop Kanata if running
./kanata.sh restart  # Validate config, then restart Kanata
./kanata.sh status   # Show current Kanata status
```

### Logging & Journaling

* All actions are logged with timestamps (systemd-style)
* Logs are written to:

```
/var/log/kanata.log
```

You can inspect logs with:

```bash
tail -f /var/log/kanata.log
```

### Config Validation

Before restarting, the script validates the configuration using:

```bash
kanata -c ~/.config/kanata/kanata.kbd --check
```

If validation fails, Kanata will **not** be restarted.

### Makefile Integration

Convenience targets are provided:

```bash
make kstart
make kstop
make krestart
make kstatus
```

These simply delegate to `kanata.sh`.

### Notes

* Kanata runs as **root** via a system LaunchDaemon
* Commands will automatically re-run with `sudo` if required
* Do **not** remap keys in Karabiner while using Kanata — it will interfere with behavior

# 🔒 IPv6Shield

A simple yet powerful bash script for **disabling or re-enabling IPv6** on Linux systems, with optional systemd integration and sysctl-based hardening. Designed for servers, workstations, and privacy-focused setups.

---

## ✨ Features

- ✅ Disable or re-enable IPv6 with one command
- ✅ Automatically updates `/etc/sysctl.conf`
- ✅ Creates and manages a persistent `systemd` service
- ✅ Colorful, interactive menu for easy use
- ✅ Includes backup and safety checks
- ✅ Compatible with modern Linux distros

---

## ⚙️ Requirements

- Bash (v4+)
- `sudo` access or root user
- `systemd` (optional, for persistent service)

Tested on:

- Debian / Ubuntu
- Arch / Manjaro
- Fedora
- Kali / Parrot
- Most cloud-based VPS setups

---

## 🛠 Installation

Clone the repo and run the script:

```bash
   git clone https://github.com/DouglasFreshHabian/IPv6Shield.git
   cd IPv6Shield
   chmod +x ./disable-ipv6.sh
   sudo ./disable-ipv6.sh
```
Or move it to a system path:

```bash
   sudo cp disable-ipv6.sh /usr/local/bin/disable-ipv6
   sudo chmod +x /usr/local/bin/disable-ipv6
   disableIPv6
```

## 📋 Menu Options

1) Disable IPv6
2) Re-enable IPv6
3) Check IPv6 Status
4) Create systemd service
5) Check for systemd Support
6) Exit

## 🧠 What This Script Does
This script sets sysctl parameters to disable or re-enable IPv6 by modifying /etc/sysctl.conf and applying changes using sysctl -p.

To disable IPv6, it applies the following:

```bash
   net.ipv6.conf.all.disable_ipv6=1
   net.ipv6.conf.default.disable_ipv6=1
   net.ipv6.conf.lo.disable_ipv6=1
```

If desired, it creates a systemd unit at:
```bash
   /etc/systemd/system/disable-ipv6.service

   /usr/local/sbin/disable-ipv6.sh
```

This ensures IPv6 remains disabled on every boot.

## 🔄 Reversing Changes

You can safely re-enable IPv6 using the script's menu option (2), which:

1. Reverts sysctl settings to 0
2. Removes the systemd unit and IPv6 script
3. Reloads systemd and sysctl

## 🚨 Warnings & Notes

* Always backup your system or test in a VM before applying network stack changes.

* Some VPNs, DNS resolvers, and applications may expect IPv6. Test carefully.

* A reboot may be required for full effect on some distros.

## 📂 Project Structure
```bash
   ipv6.sh        # Main script
   /etc/sysctl.conf        # Updated with IPv6 flags
   /usr/local/sbin/disable-ipv6.sh   # Optional helper script for systemd
   /etc/systemd/system/disable-ipv6.service  # Optional persistent service
```
## ✅ License

MIT License — use it freely in personal or commercial projects. Attribution appreciated but not required.

## ✍️ Author

Name: Douglas Habian
GitHub: @DouglasFreshHabian
Website: https://DouglasFreshHabian/DouglasFreshHabian
Youtube: https://www.youtube.com/@DouglasHabian-tq5ck

## 💬 Feedback & Contributions

Got ideas, bug reports, or improvements?
Feel free to open an issue or submit a pull request!

### If you have not done so already, please head over to the channel and hit that subscribe button to show some support. Thank you!!!

## 👍 [Stay Fresh](https://www.youtube.com/@DouglasHabian-tq5ck) 

<!-- Reach out to me if you are interested in collaboration or want to contract with me for any of the following:
	Building Github Pages
	Creating Youtube Videos
	Editing Youtube Videos
	Youtube Thumbnail Creation
	Anything Pertaining to Linux! -->

<!-- 
 _____              _       _____                        _          
|  ___| __ ___  ___| |__   |  ___|__  _ __ ___ _ __  ___(_) ___ ___ 
| |_ | '__/ _ \/ __| '_ \  | |_ / _ \| '__/ _ \ '_ \/ __| |/ __/ __|
|  _|| | |  __/\__ \ | | | |  _| (_) | | |  __/ | | \__ \ | (__\__ \
|_|  |_|  \___||___/_| |_| |_|  \___/|_|  \___|_| |_|___/_|\___|___/
        dfresh@tutanota.com Fresh Forensics, LLC 2025 -->

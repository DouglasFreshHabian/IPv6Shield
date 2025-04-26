![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen.svg)
![Shell Script](https://img.shields.io/badge/made%20with-bash-1f425f.svg)
![Status](https://img.shields.io/badge/status-stable-success.svg)
![Issues](https://img.shields.io/github/issues/DouglasFreshHabian/IPv6Shield)
![Stars](https://img.shields.io/github/stars/DouglasFreshHabian/IPv6Shield?style=social)
![IPv6](https://img.shields.io/badge/IPv6-Support%20Control-red.svg)
![Sysctl](https://img.shields.io/badge/Sysctl-Hardening-yellow.svg)
![Systemd](https://img.shields.io/badge/systemd-Compatible-blue.svg)

# 🛡🗡  IPv6Shield™️ 
![harden-system-service png](https://github.com/DouglasFreshHabian/IPv6Shield/blob/main/Assets/harden-system.png)
A simple yet powerful bash script for **disabling or re-enabling IPv6** on Linux systems, with optional systemd integration and sysctl-based hardening. Designed for servers, workstations, and privacy-focused setups.

---

## 🧪 Tested On

![Debian](https://img.shields.io/badge/Tested-Debian%2FUbuntu-lightgrey.svg)
![Arch](https://img.shields.io/badge/Tested-Arch%2FManjaro-blue.svg)
![Fedora](https://img.shields.io/badge/Tested-Fedora%2FRedHat-lightblue.svg)
![Kali Linux](https://img.shields.io/badge/Tested-Kali%20Linux-557C94?logo=kalilinux&logoColor=white)
![Parrot OS](https://img.shields.io/badge/Tested-Parrot%20OS-1BD96A?logo=parrot-security&logoColor=white)
![Raspberry Pi](https://img.shields.io/badge/Tested-Raspberry%20Pi-green.svg)

- Debian / Ubuntu
- Arch / Manjaro
- Fedora
- Kali / Parrot
- Most Raspberry Pi's

---
## ✴️ Features

- ✅ Disable or re-enable IPv6 with one command
- ☑️ Automatically updates `/etc/sysctl.conf`
- ✅ Creates and manages a persistent `systemd` service
- ☑️ Colorful, interactive menu for easy use
- ✅ Includes backup and safety checks
- ☑️ Compatible with modern Linux distros

---
## 🛠 Installation


Clone the repo and run the script:

```bash
   git clone https://github.com/DouglasFreshHabian/IPv6Shield.git
   cd IPv6Shield
   chmod +x ./ipv6shield.sh
   sudo ./ipv6shield.sh
```
Or move it to a system path:

```bash
   sudo cp ipv6shield.sh /usr/local/bin/ipv6shield
   sudo chmod +x /usr/local/bin/ipv6shield
   ipv6shield
```
## 📅 Versioning & Releases
We maintain versioned releases under the "Releases" section of the repository. If you want a specific version, check out the [releases page](https://github.com/DouglasFreshHabian/IPv6Shield/releases) to download and use it directly.


## 📋 Menu Options

1) Disable IPv6
2) Re-enable IPv6
3) Check IPv6 Status
4) Create systemd service
5) Check for systemd Support
6) Harden System (Now)
7) Clean up old backup files
8) Exit

## 🧠 What This Script Does
This script sets sysctl parameters to disable or re-enable IPv6 by modifying /etc/sysctl.conf and applying changes using sysctl -p.

To disable IPv6, it applies the following:

## ✔️ IPv6 Control

| Setting | Description |
|--------|-------------|
| `net.ipv6.conf.all.disable_ipv6=1` | Disables IPv6 for all interfaces. |
| `net.ipv6.conf.default.disable_ipv6=1` | Disables IPv6 for newly created interfaces. |
| `net.ipv6.conf.lo.disable_ipv6=1` | Disables IPv6 on the loopback interface (`lo`). |

> Disabling IPv6 reduces attack surface if it's unused on the system. Ideal for internal servers or legacy setups.

## 🕘 Reversing Changes 

You can safely re-enable IPv6 using the script's menu option (2), which:

◽ Reverts sysctl settings to 0

◾ Removes the systemd unit and IPv6 script (if it exists)

◽ Reloads systemd and sysctl

## 🚨 Warnings & Notes 

🔹Always backup your system or test in a VM before applying network stack changes.

🔸Some VPNs, DNS resolvers, and applications may expect IPv6. Test carefully.

🔹A reboot may be required for full effect on some distros.

## But Wait... 😲 There's More!!!

> We now have an enhanced hardening option available...

## 💻🌐 Enhanced Hardening Settings: Explained
> These settings not only disable IPv6 but also apply additional **network hardening** and **TCP optimizations** to prevent attacks like spoofing, denial of service (DoS), and improve overall security.

---

## 🔍 IP Spoofing Protection

| Setting | Description |
|--------|-------------|
| `net.ipv4.conf.all.rp_filter=1` | Enables reverse path filtering on all interfaces (helps prevent spoofing). |
| `net.ipv4.conf.default.rp_filter=1` | Enables reverse path filtering by default for new interfaces. |

> Helps block spoofed IP packets by validating source IP against routing table. Crucial for routers and multi-homed systems.

---

## 🚫 Disable Source Routing

| Setting | Description |
|--------|-------------|
| `net.ipv4.conf.all.accept_source_route=0` | Disables IP source routing (packet sender defines route). |
| `net.ipv4.conf.default.accept_source_route=0` | Disables it by default on all new interfaces. |

> Source routing is rarely used today and can be exploited for network mapping or bypassing controls.

---

## ↩️ Disable ICMP Redirects

| Setting | Description |
|--------|-------------|
| `net.ipv4.conf.all.accept_redirects=0` | Prevents system from accepting ICMP redirects. |
| `net.ipv4.conf.default.accept_redirects=0` | Applies same setting to default interface behavior. |

> Attackers can exploit redirects to reroute traffic or spoof gateways. These should be off for security.

---

## 🧠 TCP Protections

| Setting | Description |
|--------|-------------|
| `net.ipv4.tcp_syncookies=1` | Enables TCP SYN cookies to defend against SYN flood (DoS) attacks. |
| `net.ipv4.tcp_fin_timeout=15` | Reduces FIN timeout (default is 60 seconds) to free memory quicker. |
| `net.ipv4.tcp_keepalive_time=300` | Sets time (in seconds) before TCP sends keepalive probes. |
| `net.ipv4.tcp_retries1=5` | Sets retry limit for initial TCP SYN packets. |
| `net.ipv4.tcp_retries2=15` | Limits retries before dropping unresponsive connections. |

> These values fine-tune TCP behavior for resilience against slow-scan attacks, half-open connections, or misbehaving clients.

---

## 🚀 Kernel Buffer Tuning

| Setting | Description |
|--------|-------------|
| `net.core.rmem_max=16777216` | Increases max kernel receive buffer size (default is often 212992). |
| `net.core.wmem_max=16777216` | Increases max kernel send buffer size. |

> Useful for high-bandwidth or latency-sensitive applications. Prevents buffer overflow or bottlenecking under load.

---

## 📌 When to Use These Settings

These are especially useful for:

- Servers exposed to the internet  
- Systems with sensitive data  
- Performance-critical applications (e.g. gaming, VoIP, media)  
- Privacy-hardened setups

---
 
## Option 4: Create systemd Service (Auto-Harden on Boot)

* This option creates a `systemd` service that will **automatically apply the hardening settings**, including disabling IPv6 and all additional sysctl settings, **every time the system boots up**.

* It’s intended for **automated, persistent protection**.

* Once created, the service runs on every reboot and ensures the settings are reapplied, even if they are reset by other services or kernel updates.

## Option 6: Harden System (Apply settings immediately)

* This option **immediately applies** all IPv6 disabling and hardening sysctl settings **to the current system session**.

* It **does** update /etc/sysctl.conf, making most changes persist after reboot.

* However, if the system resets settings at boot, this option **alone** may not guarantee they remain active — **use Option 4 for persistence via systemd**.

## Key Differences Between Option 4 (Create systemd service) and Option 6 (Harden System):
| Option                          | Purpose                                         | Immediate Effect                     | Persistence After Reboot            |
|---------------------------------|-------------------------------------------------|--------------------------------------|-------------------------------------|
| **4. Create systemd service**   | Automates hardening at every boot               | ❌ No – just sets up the service     | ✅ Yes – runs automatically at boot |
| **6. Harden System (Now)**      | Applies settings now, updates /etc/sysctl.conf  | ✅ Yes – immediate changes           | ⚠️ Mostly yes, but may vary         |


## 📝 License

MIT License — use it freely in personal or commercial projects. Attribution appreciated but not required.

## ✍️ Author

| Name:             | Description                                       |
| :---------------- | :------------------------------------------------ |
| Script:           | ipv6shield.sh                                     |
| Author:           | Douglas Habian                                    |
| Version:          | 1.2                                               |
| Repo:             | https://github.com/DouglasFreshHabian/IPv6Shield  |

## 💬 Feedback & Contributions

Got ideas, bug reports, or improvements?  
Feel free to **open an issue**, **submit a pull request**, or **fork the repo** and contribute!

- 👍 [How to Contribute](https://github.com/DouglasFreshHabian/IPv6Shield/blob/main/CONTRIBUTING.md) — Please review the contribution guidelines.
- 🤝 [View Code of Conduct](https://github.com/DouglasFreshHabian/IPv6Shield/blob/main/CODE_OF_CONDUCT.md) — A respectful community is key!
- 🔐 [Security Policy](https://github.com/DouglasFreshHabian/IPv6Shield/blob/main/SECURITY.md) — Found a vulnerability? Here's how to report it.
---
## 🗒 Issue Templates

For more structured feedback, please use the appropriate templates when opening an issue:

- 🐛 [Bug Report](https://github.com/DouglasFreshHabian/IPv6Shield/blob/main/.github/ISSUE_TEMPLATE/bug_report.md) — Report bugs or unexpected behavior.
- 💡 [Feature Request](https://github.com/DouglasFreshHabian/IPv6Shield/blob/main/.github/ISSUE_TEMPLATE/feature_request.md) — Suggest new features or improvements.
- 🆘 [Support Request](https://github.com/DouglasFreshHabian/IPv6Shield/blob/main/.github/ISSUE_TEMPLATE/support_request.md) — Ask for help or guidance.
---

### 📺 If you haven’t already, head over to the channel and hit that **Subscribe** button to show some support. Thank you!

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

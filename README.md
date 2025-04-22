# 🛡🗡  IPv6Shield™️ 

A simple yet powerful bash script for **disabling or re-enabling IPv6** on Linux systems, with optional systemd integration and sysctl-based hardening. Designed for servers, workstations, and privacy-focused setups.

---

## ✨ Features

- ✅ Disable or re-enable IPv6 with one command
- ☑️ Automatically updates `/etc/sysctl.conf`
- ✅ Creates and manages a persistent `systemd` service
- ☑️ Colorful, interactive menu for easy use
- ✅ Includes backup and safety checks
- ☑️ Compatible with modern Linux distros

---

## ⚙️ Tested On:

- Debian / Ubuntu
- Arch / Manjaro
- Fedora
- Kali / Parrot
- Most Raspberry Pi's

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
   disable-ipv6
```

## 📋 Menu Options

1) Disable IPv6
2) Re-enable IPv6
3) Check IPv6 Status
4) Create systemd service
5) Check for systemd Support
6) Harden System (Ehanced)
7) Exit

## 🧠 What This Script Does
This script sets sysctl parameters to disable or re-enable IPv6 by modifying /etc/sysctl.conf and applying changes using sysctl -p.

To disable IPv6, it applies the following:

## ✅ IPv6 Control

| Setting | Description |
|--------|-------------|
| `net.ipv6.conf.all.disable_ipv6=1` | Disables IPv6 for all interfaces. |
| `net.ipv6.conf.default.disable_ipv6=1` | Disables IPv6 for newly created interfaces. |
| `net.ipv6.conf.lo.disable_ipv6=1` | Disables IPv6 on the loopback interface (`lo`). |

> Disabling IPv6 reduces attack surface if it's unused on the system. Ideal for internal servers or legacy setups.

If desired, it creates a systemd unit at:
```bash
   /etc/systemd/system/disable-ipv6.service
```

This ensures IPv6 remains disabled on every boot.

## 🕘 Reversing Changes 

You can safely re-enable IPv6 using the script's menu option (2), which:

◽ Reverts sysctl settings to 0
◾ Removes the systemd unit and IPv6 script
◽ Reloads systemd and sysctl

## 🚨 Warnings & Notes 

🔹Always backup your system or test in a VM before applying network stack changes.

🔸Some VPNs, DNS resolvers, and applications may expect IPv6. Test carefully.

🔹A reboot may be required for full effect on some distros.

## 🗃 Project Structure  
```bash
   disable-ipv6.sh        # Main script
   /etc/sysctl.conf        # Updated with IPv6 flags
   /usr/local/sbin/disable-ipv6.sh   # Optional helper script for systemd
   /etc/systemd/system/disable-ipv6.service  # Optional persistent service
```
## But Wait... 😲 There's More!!!
We now have an enhanced hardening option available...

# 💻🌐 Enhanced Hardening Settings: Explained
#### These additional settings are designed to not only **disable IPv6**,but to **harden networking behavior**, and **tune TCP parameters** to defend against spoofing, scanning, and various attacks.
---

> 🔨 6) Harden System (Ehanced)

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

## 📝 License

MIT License — use it freely in personal or commercial projects. Attribution appreciated but not required.

## ✍️ Author

| Name:             | Description                                       |
| :---------------- | :------------------------------------------------ |
| Script:           | disable-ipv6.sh                                   |
| Author:           | Douglas Habian                                    |
| Version:          | 1.1                                               |
| Repo:             | https://github.com/DouglasFreshHabian/IPv6Shield  |

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

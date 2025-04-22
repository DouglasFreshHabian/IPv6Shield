#!/bin/bash

#------------- Color Setup -------------#
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
PURPLE='\033[1;35m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Colors for sysctl output cycling
COLORS=($RED $GREEN $YELLOW $BLUE $CYAN $PURPLE)

#------------- ASCII Banner -------------#
ascii_banner() {
    echo -e "${WHITE}"
    cat << "EOF"

                                         )  (  (    (
                                         (  )  () @@  )  (( (
                                     (      (  )( @@  (  )) ) (
                                   (    (  ( ()( /---\   (()( (
     _______                            )  ) )(@ !O O! )@@  ( ) ) )
    <   ____)                      ) (  ( )( ()@ \ o / (@@@@@ ( ()( )
 /--|  |(  o|                     (  )  ) ((@@(@@ !o! @@@@(@@@@@)() (
|   >   \___|                      ) ( @)@@)@ /---\-/---\ )@@@@@()( )
|  /---------+                    (@@@@)@@@( // /-IPV6\ \\ @@@)@@@@@(  .
| |    \ =========______/|@@@@@@@@@@@@@(@@@ // @ /---\ @ \\ @(@@@(@@@ .  .
|  \   \\=========------\|@@@@@@@@@@@@@@@@@ O @@@ /-\ @@@ O @@(@@)@@ @   .
|   \   \----+--\-)))           @@@@@@@@@@ !! @@@@ % @@@@ !! @@)@@@ .. .
|   |\______|_)))/             .    @@@@@@ !! @@ /---\ @@ !! @@(@@@ @ . .
 \__==========           *        .    @@ /MM  /\O   O/\  MM\ @@@@@@@. .
    |   |-\   \          (       .      @ !!!  !! \-/ !!  !!! @@@@@ .
    |   |  \   \          )   -cfbd-   .  @@@@ !!     !!  .(. @.  .. .
    |   |   \   \        (    /   .(  . \)). ( |O  )( O! @@@@ . )      .
    |   |   /   /         ) (      )).  ((  .) !! ((( !! @@ (. ((. .   .
    |   |  /   /   ()  ))   ))   .( ( ( ) ). ( !!  )( !! ) ((   ))  ..
    |   |_<   /   ( ) ( (  ) )   (( )  )).) ((/ |  (  | \(  )) ((. ).
____<_____\\__\__(___)_))_((_(____))__(_(___.oooO_____Oooo.(_(_)_)((_
	    _ _          _    _       ___ _____   ____ 
	 __| (_)___ __ _| |__| |___  |_ _| _ \ \ / / / 
	/ _` | (_-</ _` | '_ \ / -_)  | ||  _/\ V / _ \
	\__,_|_/__/\__,_|_.__/_\___| |___|_|   \_/\___/
	                                               

EOF
    echo -e "${RESET}"
}

#------------- Check if systemd is present -------------#
is_systemd() {
    if [[ "$(ps -p 1 -o comm=)" == "systemd" ]] && \
       command -v systemctl >/dev/null && \
       [[ -d /run/systemd/system ]]; then
        return 0
    else
        return 1
    fi
}

check_systemd() {
    echo
    echo -e "${CYAN}Checking for systemd support...${RESET}\n"
    if is_systemd; then
        echo -e "${GREEN}✅  systemd is present and active on this system.${RESET}"
    else
        echo -e "${RED}❌  systemd is not available or not running as PID 1.${RESET}"
        echo -e "${YELLOW}This system may be using another init system like SysVinit, OpenRC, or runit.${RESET}"
    fi
}

#------------- Add/Update Sysctl Setting -------------#
add_sysctl_setting() {
    local key="$1"
    local value="$2"

    if grep -qE "^\s*${key}\s*=" /etc/sysctl.conf; then
        sed -i "s|^\s*${key}\s*=.*|${key} = ${value}|" /etc/sysctl.conf
    else
        echo "${key} = ${value}" >> /etc/sysctl.conf
    fi
}

#------------- Disable IPv6 -------------#
disable_ipv6() {
    echo
    echo -e "${CYAN}Disabling IPv6 permanently...${RESET}\n"

    [[ $EUID -ne 0 ]] && { echo -e "${RED}Please run as root using sudo.${RESET}"; return; }

    BACKUP_FILE="/etc/sysctl.conf.bak.$(date +%s)"
    cp /etc/sysctl.conf "$BACKUP_FILE"
    echo -e "${WHITE}Backup saved to:${RESET} ${GREEN}$BACKUP_FILE${RESET}"

    add_sysctl_setting "net.ipv6.conf.all.disable_ipv6" 1
    add_sysctl_setting "net.ipv6.conf.default.disable_ipv6" 1
    add_sysctl_setting "net.ipv6.conf.lo.disable_ipv6" 1

    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
    sysctl -w net.ipv6.conf.lo.disable_ipv6=1
   
    echo
    echo -e "${WHITE}Reloading sysctl...${RESET}\n"

    index=0
    sysctl -p /etc/sysctl.conf | while IFS= read -r line; do
        [[ $((index % 5)) -eq 0 ]] && color=${COLORS[$(( (index / 5) % ${#COLORS[@]} ))]}
        echo -e "${color}$line${RESET}"
        ((index++))
    done
    echo
    echo -e "${GREEN}✅  IPv6 has been disabled successfully...${RESET}"
    echo -e "${YELLOW}Note: A reboot may be required for all changes to fully apply.${RESET}"
}

#------------- Check IPv6 Status -------------#
check_ipv6_status() {
    echo -e "${CYAN}IPv6 Disable Status:${RESET}"
    for intf in all default lo; do
        echo -e "${WHITE}$intf:${RESET} "
        cat /proc/sys/net/ipv6/conf/${intf}/disable_ipv6
        echo -e "${GREEN}✅  Done checking status...${RESET}"

    done
}

#------------- Create systemd Service -------------#
create_systemd_service() {
    echo
    echo -e "${CYAN}Creating systemd service to Harden System at boot...${RESET}"

    [[ $EUID -ne 0 ]] && { echo -e "${RED}Please run as root using sudo.${RESET}"; return; }

    if ! is_systemd; then
        echo -e "${RED}❌  Cannot proceed: systemd is not available or active on this system...${RESET}"
        return
    fi

    SERVICE_PATH="/etc/systemd/system/harden-system.service"
    SCRIPT_PATH="/usr/local/sbin/harden-system.sh"

    # Secure the script by ensuring it's only accessible to root
    # This prevents other users from reading or modifying it
    # umask 077  # Files created after this line will have 600 permissions

    cat << 'EOSCRIPT' > "$SCRIPT_PATH"
#!/bin/bash

# Disable IPv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# IP Spoof Protection
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1

# Disable Source Routing
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv4.conf.default.accept_source_route=0

# Disable Redirects
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_redirects=0

# TCP Protections
sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.ipv4.tcp_fin_timeout=15
sysctl -w net.ipv4.tcp_keepalive_time=300
sysctl -w net.ipv4.tcp_retries1=5
sysctl -w net.ipv4.tcp_retries2=15

# Buffer Sizes
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216

sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1
EOSCRIPT

    chmod +x "$SCRIPT_PATH"

    cat << EOSERVICE > "$SERVICE_PATH"
[Unit]
Description=Harden System Networking with sysctl
After=network.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOSERVICE

    # Optional: Reset umask back to default if needed
    # umask 022 # Optional: Reset to typical system-wide default

    systemctl daemon-reexec
    systemctl daemon-reload
    systemctl enable harden-system.service
    systemctl start harden-system.service

    echo
    echo -e "${GREEN}✅  systemd service created and enabled...${RESET}"
    echo -e "${WHITE}Service path:${RESET} ${BLUE}$SERVICE_PATH${RESET}"
    echo -e "${WHITE}Script path: ${RESET} ${BLUE}$SCRIPT_PATH${RESET}"
}


#------------- Re-enable IPv6 -------------#
reenable_ipv6() {
    echo
    echo -e "${CYAN}Re-enabling IPv6...${RESET}"

    [[ $EUID -ne 0 ]] && { echo -e "${RED}Please run as root using sudo...${RESET}"; return; }

    # Backup
    BACKUP_FILE="/etc/sysctl.conf.reenable.bak.$(date +%s)"
    cp /etc/sysctl.conf "$BACKUP_FILE"
    echo -e "${WHITE}Backup saved to:${RESET} ${GREEN}$BACKUP_FILE${RESET}"

    # Reset IPv6 flags
    add_sysctl_setting "net.ipv6.conf.all.disable_ipv6" 0
    add_sysctl_setting "net.ipv6.conf.default.disable_ipv6" 0
    add_sysctl_setting "net.ipv6.conf.lo.disable_ipv6" 0

    sysctl -w net.ipv6.conf.all.disable_ipv6=0
    sysctl -w net.ipv6.conf.default.disable_ipv6=0
    sysctl -w net.ipv6.conf.lo.disable_ipv6=0

    # Reload sysctl
    sysctl -p > /dev/null
    echo
    echo -e "${GREEN}✅  IPv6 has been re-enabled...${RESET}"

    # Clean up systemd service if it exists
    if [[ -f /etc/systemd/system/disable-ipv6.service ]]; then
        echo -e "${YELLOW}Found systemd service. Disabling and removing it...${RESET}"
        systemctl stop disable-ipv6.service 2>/dev/null
        systemctl disable disable-ipv6.service 2>/dev/null
        rm -f /etc/systemd/system/disable-ipv6.service
        rm -f /usr/local/sbin/disable-ipv6.sh
        systemctl daemon-reload
        echo -e "${GREEN}🧹 systemd service removed successfully...${RESET}"
    fi

    echo -e "${CYAN}You may need to reboot for full effect...${RESET}"
}

#------------- Harden System -------------#
harden_system() {
    echo
    echo -e "${GREEN}Applying system hardening settings...${RESET}"

    [[ $EUID -ne 0 ]] && { echo -e "${RED}Please run as root using sudo.${RESET}"; return; }

    # Step 1: Disable IPv6 using existing function
    disable_ipv6

    # Step 2: Apply additional hardening settings
    echo -e "\n${WHITE}Applying additional sysctl settings...${RESET}"
    declare -A sysctl_settings=(
        ["net.ipv4.conf.all.rp_filter"]=1
        ["net.ipv4.conf.default.rp_filter"]=1
        ["net.ipv4.conf.all.accept_source_route"]=0
        ["net.ipv4.conf.default.accept_source_route"]=0
        ["net.ipv4.conf.all.accept_redirects"]=0
        ["net.ipv4.conf.default.accept_redirects"]=0
        ["net.ipv4.tcp_syncookies"]=1
        ["net.ipv4.tcp_fin_timeout"]=15
        ["net.ipv4.tcp_keepalive_time"]=300
        ["net.ipv4.tcp_retries1"]=5
        ["net.ipv4.tcp_retries2"]=15
        ["net.core.rmem_max"]=16777216
        ["net.core.wmem_max"]=16777216
    )

    for key in "${!sysctl_settings[@]}"; do
        add_sysctl_setting "$key" "${sysctl_settings[$key]}"
        sysctl -w "$key=${sysctl_settings[$key]}" > /dev/null
    done

    echo -e "\n${WHITE}Reloading sysctl...${RESET}\n"

    index=0
    sysctl -p /etc/sysctl.conf | while IFS= read -r line; do
        [[ $((index % 5)) -eq 0 ]] && color=${COLORS[$(( (index / 5) % ${#COLORS[@]} ))]}
        echo -e "${color}$line${RESET}"
        ((index++))
    done

    echo -e "\n${GREEN}✅ System hardening applied successfully.${RESET}"
    echo -e "${YELLOW}Reboot is recommended to ensure all settings take full effect.${RESET}"
}

#------------- Menu Interface -------------#

main_menu() {
    while true; do
        clear
        ascii_banner
        PS3=$'\nChoose an option: '
        options=(
            "Disable IPv6"
            "Re-enable IPv6"
            "Check IPv6 Status"
            "Create systemd service"
            "Check for systemd Support"
	    "Harden System"
            "Exit"
        )

        echo -e "${RESET}"
        select opt in "${options[@]}"; do
            case $REPLY in
                1)
                    disable_ipv6
                    break
                    ;;
                2)
                    reenable_ipv6
                    break
                    ;;
                3)
                    check_ipv6_status
                    break
                    ;;
                4)
                    create_systemd_service
                    break
                    ;;
                5)
                    check_systemd
                    break
                    ;;
		6)
		    harden_system
		    break
		    ;;
                7)
                    echo -e "${WHITE}Exiting.${RESET}"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}❌  Invalid option. Please try again.${RESET}"
                    break
                    ;;
            esac
        done

        echo -e "\n${WHITE}Press Enter to return to the main menu...${RESET}"
        read -r
    done
}

main_menu

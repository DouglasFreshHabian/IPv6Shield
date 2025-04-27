#!/bin/bash

# You are using the Beta Version of this script with a new/dfferent menu

#------------- Color Setup -------------#
REDu='\033[0;31m'
GREENu='\033[0;32m'
YELLOWu='\033[0;33m'
BLUEu='\033[0;34m'
CYANu='\033[0;36m'
PURPLEu='\033[0;35m'
WHITEu='\033[0;37m'

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
PURPLE='\033[1;95m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Colors for sysctl output cycling
COLORS=($RED $GREEN $YELLOW $BLUE $CYAN $PURPLE)

# Array of color names
allcolors=("RED" "GREEN" "YELLOW" "BLUE" "CYAN" "PURPLE" "WHITE")

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
EOF
    echo -e "${RESET}"
}

# Function to print banner with a random color
print_banner() {

    # Pick a random color from the allcolors array
    random_color="${allcolors[$((RANDOM % ${#allcolors[@]}))]}"

    # Convert the color name to the actual escape code
    case $random_color in
        "RED") color_code=$RED ;;
        "GREEN") color_code=$GREEN ;;
        "YELLOW") color_code=$YELLOW ;;
        "BLUE") color_code=$BLUE ;;
        "CYAN") color_code=$CYAN ;;
        "PURPLE") color_code=$PURPLE ;;
        "WHITE") color_code=$WHITE ;;
    esac

    # Print the banner in the chosen color
    echo -e "${color_code}"
    cat << "EOF"
	    _ _          _    _       ___ _____   ____ 
	 __| (_)___ __ _| |__| |___  |_ _| _ \ \ / / / 
	/ _` | (_-</ _` | '_ \ / -_)  | ||  _/\ V / _ \
	\__,_|_/__/\__,_|_.__/_\___| |___|_|   \_/\___/
	                                               
EOF
    echo -e "${RESET}"
}

#------------- Cleanup Old Backup Files -------------#
cleanup_backups() {
    echo -e "${CYAN}Cleaning up old backup files...${RESET}"

    # Define the backup directory (assuming backups are saved in /etc)
    BACKUP_DIR="/etc"
    # Find and delete backups older than 30 days (you can change this value)
    find "$BACKUP_DIR" -name '*.bak.*' -type f -mtime +30 -exec rm -f {} \;

    echo -e "${GREEN}✅ Old backup files cleaned up successfully.${RESET}"
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

disable_ipv6() {
    echo
    echo -e "${CYAN}Disabling IPv6 permanently...${RESET}\n"

    [[ $EUID -ne 0 ]] && { echo -e "${RED}Please run as root using sudo.${RESET}"; return; }

    # Check if IPv6 is already disabled
    if [[ $(sysctl -n net.ipv6.conf.all.disable_ipv6) -eq 1 && \
          $(sysctl -n net.ipv6.conf.default.disable_ipv6) -eq 1 && \
          $(sysctl -n net.ipv6.conf.lo.disable_ipv6) -eq 1 ]]; then
        echo -e "${GREEN}✅  IPv6 is already disabled. No changes needed.${RESET}"
        return
    fi

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
        echo -e "${GREEN}✅  0 = Enabled / 1 = Disabled${RESET}"

    done
}

#------------- Check and Handle Existing systemd Service -------------#

# Before creating a new systemd service, let’s check if the service file already exists. 
check_and_create_systemd_service() {
    echo -e "${CYAN}Checking if systemd service already exists...${RESET}"

    SERVICE_PATH="/etc/systemd/system/harden-system.service"
    SCRIPT_PATH="/usr/local/sbin/harden-system.sh"

    if [[ -f "$SERVICE_PATH" ]]; then
        echo -e "${YELLOW}⚠️  The systemd service already exists at: ${SERVICE_PATH}${RESET}"
        read -p "Do you want to overwrite it? (y/n): " overwrite_choice
        if [[ "$overwrite_choice" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Overwriting existing systemd service...${RESET}"
            systemctl stop harden-system.service
            systemctl disable harden-system.service
            rm -f "$SERVICE_PATH" "$SCRIPT_PATH"
        else
            echo -e "${RED}❌  Skipping systemd service creation. Exiting.${RESET}"
            return
        fi
    fi

    # Proceed with creating the systemd service if not skipping
    create_systemd_service
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
    # Check if IPv6 is already disabled before proceeding
    if [[ $(sysctl -n net.ipv6.conf.all.disable_ipv6) -eq 1 && \
          $(sysctl -n net.ipv6.conf.default.disable_ipv6) -eq 1 && \
          $(sysctl -n net.ipv6.conf.lo.disable_ipv6) -eq 1 ]]; then
        echo -e "${GREEN}✅  IPv6 is already disabled. Skipping this step...${RESET}"
    else
        disable_ipv6  # If not already disabled, call disable_ipv6
    fi

    # Step 2: Apply additional hardening settings
    echo -e "\n${WHITE}Applying additional sysctl settings...${RESET}"

    # Check if the system is already hardened by checking key sysctl settings
    local is_hardened=true
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
        current_value=$(sysctl -n "$key")
        if [[ "$current_value" -eq "${sysctl_settings[$key]}" ]]; then
            echo -e "${GREEN}$key is already set to ${sysctl_settings[$key]}. Skipping...${RESET}"
        else
            is_hardened=false
            add_sysctl_setting "$key" "${sysctl_settings[$key]}"
            sysctl -w "$key=${sysctl_settings[$key]}" > /dev/null
        fi
    done

    if $is_hardened; then
        echo -e "${GREEN}✅  System is already hardened. No changes needed.${RESET}"
        return
    fi

    echo -e "\n${WHITE}Reloading sysctl...${RESET}\n"

    # Reload sysctl
    sysctl -p > /dev/null

    # Print the current settings only for important sysctl changes
    for key in "${!sysctl_settings[@]}"; do
        echo -e "${WHITE}$key${RESET}: ${sysctl_settings[$key]}"
    done

    echo -e "\n${GREEN}✅ System hardening applied successfully.${RESET}"
    echo -e "${YELLOW}Reboot is recommended to ensure all settings take full effect.${RESET}"
}

#------------- Remove systemd Service -------------#
remove_systemd_service() {
    echo
    echo -e "${CYAN}Removing systemd service...${RESET}"

    [[ $EUID -ne 0 ]] && { echo -e "${RED}Please run as root using sudo.${RESET}"; return; }

    SERVICE_PATH="/etc/systemd/system/harden-system.service"
    SCRIPT_PATH="/usr/local/sbin/harden-system.sh"

    if [[ ! -f "$SERVICE_PATH" ]]; then
        echo -e "${RED}❌  The systemd service does not exist. Nothing to remove.${RESET}"
        return
    fi

    # Stop and disable the service before removal
    systemctl stop harden-system.service
    systemctl disable harden-system.service

    # Remove the service file and the script
    rm -f "$SERVICE_PATH" "$SCRIPT_PATH"

    # Reload systemd to reflect the changes
    systemctl daemon-reexec
    systemctl daemon-reload

    echo -e "${GREEN}✅  Systemd service and associated script have been removed successfully.${RESET}"
}

#------------- Function to Display Script Info  -------------#
about() {
  echo -e "${BLUE}Script Name:${RESET}   ${YELLOW}ipv6shield.sh${RESET}"
  echo -e "${RED}Version:${RESET}       ${WHITE}1.4${RESET}"
  echo -e "${PURPLE}Author:${RESET}        ${YELLOW}Douglas Habian${RESET}"
  echo -e "${GREEN}Repo:${RESET}          ${WHITE}https://github.com/DouglasFreshHabian/IPv6Shield.git${RESET}"
  exit 0
}

#------------- Help menu with command-line options -------------#
ascii_banner
print_banner

show_help() {
    echo -e "${BLUE}Usage:${RESET} ${CYAN}$0 ${RESET}<${REDu}options${RESET}>"
    echo -e "${BPURPLE}Options:${RESET}"
    echo -e "${BLUE}  -h, --help                 ${GREEN}Show this help menu."
    echo -e "${CYAN}  -d, --disable-ipv6         ${PURPLE}Disable IPv6 on the system."
    echo -e "${WHITE}  -r, --reenable-ipv6        ${YELLOW}Re-enable IPv6 on the system."
    echo -e "${CYAN}  -s, --check-status         ${PURPLE}Check the current IPv6 status."
    echo -e "${BLUE}  -C, --create-service       ${GREEN}Create a systemd service to harden the system."
    echo -e "${CYAN}  -R, --remove-service       ${PURPLE}Remove the systemd service for hardening."
    echo -e "${WHITE}  -S, --check-systemd        ${YELLOW}Check if systemd is present and active."
    echo -e "${CYAN}  -H, --harden-system        ${PURPLE}Apply system hardening settings."
    echo -e "${BLUE}  -b, --cleanup-backups      ${GREEN}Clean up old backup files."
    echo -e "${CYAN}  -a, --about                ${YELLOW}About Author, Version, etc."
}

#------------- Process command-line arguments -------------#
process_args() {
    case "$1" in
        -h|--help)
            show_help
            ;;
        -d|--disable-ipv6)
            disable_ipv6
            ;;
        -r|--reenable-ipv6)
            reenable_ipv6
            ;;
        -s|--check-status)
            check_ipv6_status
            ;;
        -C|--create-service)
            check_and_create_systemd_service
            ;;
        -R|--remove-service)
            remove_systemd_service
            ;;
        -S|--check-systemd)
            check_systemd
            ;;
        -H|--harden-system)
            harden_system
            ;;
        -b|--cleanup-backups)
            cleanup_backups
            ;;
        -a|--about)
            about
            ;;
        *)
            echo -e "${RED}❌  Invalid option. Use --help for available options.${RESET}"
            ;;
    esac
}

#------------- Main Program -------------#
main() {
    if [ $# -eq 0 ]; then
        echo -e "${RED}❌  No arguments provided. Use --help for available options.${RESET}"
        exit 1
    fi

    for arg in "$@"; do
        process_args "$arg"
    done
}

main "$@"

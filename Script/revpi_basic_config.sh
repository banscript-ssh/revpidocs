#!/bin/bash

show_menu() {
    echo "===================================="
    echo " RevPi Configuration Menu By N4cv"
    echo "===================================="
    echo "1. Set Static IP"
    echo "2. Update System"
    echo "3. Fix Pictory Config Error"
    echo "4. Enable Port Forwarding"
    echo "5. Exit"
    echo "===================================="
}

set_static_ip() {
    echo "--- Static IP Configuration ---"
    read -p "Enter network interface (e.g., eth0): " iface
    read -p "Enter IP address (e.g., 192.168.1.10): " ipaddr
    read -p "Enter subnet mask (e.g., 24): " subnet
    read -p "Enter gateway (e.g., 192.168.1.1): " gateway
    read -p "Enter DNS (e.g., 8.8.8.8): " dns

    config="interface $iface\nstatic ip_address=$ipaddr/$subnet\nstatic routers=$gateway\nstatic domain_name_servers=$dns"
    echo -e "$config" | sudo tee -a /etc/dhcpcd.conf
    echo "Static IP configuration has been added to /etc/dhcpcd.conf. Please reboot to apply changes."
}

update_system() {
    echo "--- Updating System ---"
    sudo apt update && sudo apt upgrade -y
    echo "System update completed."
}

fix_pictory_config() {
    echo "--- Fixing Pictory Config Error ---"
    if [ -f /etc/revpi/config.rsc ]; then
        echo "/etc/revpi/config.rsc already exists. No action needed."
    else
        sudo ln -s /var/www/revpi/pictory/project/_config.rsc /etc/revpi/config.rsc
        echo "Symbolic link created from /var/www/revpi/pictory/project/_config.rsc to /etc/revpi/config.rsc."
    fi
}

enable_port_forwarding() {
    echo "--- Enabling Port Forwarding ---"
    if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
        echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        echo "Port forwarding enabled."
    else
        echo "Port forwarding is already enabled."
    fi
}

handle_choice() {
    case $1 in
        1)
            set_static_ip
            ;;
        2)
            update_system
            ;;
        3)
            fix_pictory_config
            ;;
        4)
            enable_port_forwarding
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
}

while true; do
    show_menu
    read -p "Enter your choice [1-5]: " choice
    handle_choice $choice
    echo ""
done
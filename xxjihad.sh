#!/bin/bash

# XxXjihad VPN Manager (Encrypted Edition) Main Loader
# GitHub: https://github.com/jamal7720077-debug/XxXjihadVPN_Encrypted

XXJIHAD_DIR="/etc/xxjihad"
XXJIHAD_LIB="/usr/local/lib/xxjihad"
ENCRYPTION_KEY_PATH="$XXJIHAD_DIR/encryption.key"

# Anti-Theft Lock: Check for jihad file
if [[ ! -f "$XXJIHAD_DIR/jihad" ]]; then
    echo -e "\033[38;5;196m[ERROR]\033[0m Anti-theft lock file missing. Exiting."
    exit 1
fi

# Ensure OpenSSL is available
if ! command -v openssl &>/dev/null; then
    echo -e "\033[38;5;196m[ERROR]\033[0m openssl is not installed. Please install it to run XxXjihad."
    exit 1
fi

# Read encryption key
if [[ ! -f "$ENCRYPTION_KEY_PATH" ]]; then
    echo -e "\033[38;5;196m[ERROR]\033[0m Encryption key not found at $ENCRYPTION_KEY_PATH. Exiting."
    exit 1
fi
ENCRYPTION_KEY=$(cat "$ENCRYPTION_KEY_PATH")

# Function to decrypt and source a module in memory
decrypt_and_source() {
    local encrypted_file="$1"
    if [[ ! -f "$encrypted_file" ]]; then
        echo -e "\033[38;5;196m[ERROR]\033[0m Encrypted module $encrypted_file not found. Exiting."
        exit 1
    fi
    # Decrypt and execute in the CURRENT shell environment
    # Using source /dev/stdin to ensure functions are available in this process
    source <(openssl enc -aes-256-cbc -d -salt -pbkdf2 -in "$encrypted_file" -k "$ENCRYPTION_KEY" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo -e "\033[38;5;196m[ERROR]\033[0m Failed to decrypt or execute $encrypted_file. Exiting."
        exit 1
    fi
}

# Source all modules in correct order
decrypt_and_source "$XXJIHAD_LIB/dnstt-core.sh.enc"
decrypt_and_source "$XXJIHAD_LIB/net-optimizer.sh.enc"
decrypt_and_source "$XXJIHAD_LIB/user-manager.sh.enc"
decrypt_and_source "$XXJIHAD_LIB/ssl-tunnel.sh.enc"
decrypt_and_source "$XXJIHAD_LIB/protocols.sh.enc"
decrypt_and_source "$XXJIHAD_LIB/menu-system.sh.enc"
decrypt_and_source "$XXJIHAD_LIB/uninstall.sh.enc"

# Initialize directories (if not already done by installer)
if declare -f init_dirs > /dev/null; then
    init_dirs
fi

# Handle arguments
case "${1:-}" in
    --status)
        if declare -f xxjihad_status > /dev/null; then xxjihad_status; else echo "Error: xxjihad_status not found."; fi
        ;;
    --info)
        if declare -f show_dnstt_info > /dev/null; then show_dnstt_info; else echo "Error: show_dnstt_info not found."; fi
        ;;
    --help|-h)
        echo "Usage: xxjihad [option]"
        echo "  (no args)  Open management menu"
        echo "  --status   Show service status"
        echo "  --info     Show DNSTT connection info"
        echo "  --help     Show this help"
        ;;
    *)
        if declare -f main_menu > /dev/null; then main_menu; else echo "Error: main_menu not found."; fi
        ;;
esac

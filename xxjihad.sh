#!/bin/bash

XXJIHAD_DIR="/etc/xxjihad"
XXJIHAD_LIB="/usr/local/lib/xxjihad"
ENCRYPTION_KEY_PATH="/etc/xxjihad/encryption.key"

# Anti-Theft Lock: Check for jihad file
if [[ ! -f "$XXJIHAD_DIR/jihad" ]]; then
    echo "Error: Anti-theft lock file missing. Exiting."
    exit 1
fi

# Ensure OpenSSL is available
if ! command -v openssl &>/dev/null; then
    echo "Error: openssl is not installed. Please install it to run XxXjihad."
    exit 1
fi

# Read encryption key
if [[ ! -f "$ENCRYPTION_KEY_PATH" ]]; then
    echo "Error: Encryption key not found at $ENCRYPTION_KEY_PATH. Exiting."
    exit 1
fi
ENCRYPTION_KEY=$(cat "$ENCRYPTION_KEY_PATH")

# Function to decrypt and source a module in memory
decrypt_and_source() {
    local encrypted_file="$1"
    if [[ ! -f "$encrypted_file" ]]; then
        echo "Error: Encrypted module $encrypted_file not found. Exiting."
        exit 1
    fi
    # Decrypt and execute in memory
    openssl enc -aes-256-cbc -d -salt -pbkdf2 -in "$encrypted_file" -k "$ENCRYPTION_KEY" 2>/dev/null | bash
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to decrypt or execute $encrypted_file. Exiting."
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

# Initialize directories (if not already done by installer)
init_dirs

# Handle arguments
case "${1:-}" in
    --status)
        xxjihad_status
        ;;
    --info)
        show_dnstt_info
        ;;
    --help|-h)
        echo "Usage: xxjihad [option]"
        echo "  (no args)  Open management menu"
        echo "  --status   Show service status"
        echo "  --info     Show DNSTT connection info"
        echo "  --help     Show this help"
        ;;
    *)
        main_menu
        ;;
	esac

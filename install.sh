#!/bin/bash

# XxXjihad VPN Manager (Encrypted Edition) Installer
# GitHub: https://github.com/jamal7720077-debug/XxXjihadVPN_Encrypted

REPO_RAW="https://raw.githubusercontent.com/jamal7720077-debug/XxXjihadVPN_Encrypted/main"
XXJIHAD_DIR="/etc/xxjihad"
XXJIHAD_BIN="/usr/local/bin"
XXJIHAD_LIB="/usr/local/lib/xxjihad"
ENCRYPTION_KEY_PATH="$XXJIHAD_DIR/encryption.key"

# Function to display messages
msg_ok()   { echo -e "\033[38;5;46m[OK]\033[0m $*"; }
msg_err()  { echo -e "\033[38;5;196m[ERROR]\033[0m $*"; }
msg_info() { echo -e "\033[38;5;39m[INFO]\033[0m $*"; }
msg_warn() { echo -e "\033[38;5;226m[WARN]\033[0m $*"; }

# Pre-checks
if [[ $EUID -ne 0 ]]; then
    msg_err "This script must be run as root (sudo)."
    exit 1
fi

# Create necessary directories
mkdir -p "$XXJIHAD_DIR" "$XXJIHAD_LIB"

# Install dependencies
msg_info "Installing system dependencies (openssl, curl, wget)..."
apt-get update -qq >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openssl curl wget >/dev/null 2>&1

if ! command -v openssl &>/dev/null; then
    msg_err "Failed to install openssl. Aborting."
    exit 1
fi
msg_ok "Dependencies installed."

# Download encryption key
msg_info "Downloading encryption key..."
if ! wget -q -O "$ENCRYPTION_KEY_PATH" "$REPO_RAW/encryption.key"; then
    msg_err "Failed to download encryption key. Aborting."
    exit 1
fi
chmod 600 "$ENCRYPTION_KEY_PATH"
msg_ok "Encryption key downloaded."

# Download encrypted library files
msg_info "Downloading encrypted library files..."
MODULES=(dnstt-core.sh.enc net-optimizer.sh.enc user-manager.sh.enc menu-system.sh.enc ssl-tunnel.sh.enc protocols.sh.enc uninstall.sh.enc)
for mod in "${MODULES[@]}"; do
    if ! wget -q -O "$XXJIHAD_LIB/$mod" "$REPO_RAW/lib/$mod"; then
        msg_err "Failed to download module: $mod. Aborting."
        exit 1
    fi
done
chmod 600 "$XXJIHAD_LIB"/*.enc
msg_ok "Encrypted library files downloaded."

# Create anti-theft lock file
msg_info "Creating anti-theft lock file..."
touch "$XXJIHAD_DIR/jihad"
chmod 600 "$XXJIHAD_DIR/jihad"
msg_ok "Anti-theft lock file created."

# Download the main loader script from GitHub instead of generating it
msg_info "Downloading main loader script..."
if ! wget -q -O "$XXJIHAD_BIN/xxjihad" "$REPO_RAW/xxjihad.sh"; then
    msg_err "Failed to download main loader script. Generating local copy..."
    # Fallback to local generation if download fails
    cat > "$XXJIHAD_BIN/xxjihad" << 'EOF'
#!/bin/bash
XXJIHAD_DIR="/etc/xxjihad"
XXJIHAD_LIB="/usr/local/lib/xxjihad"
ENCRYPTION_KEY_PATH="$XXJIHAD_DIR/encryption.key"
if [[ ! -f "$XXJIHAD_DIR/jihad" ]]; then echo "Error: Anti-theft lock file missing. Exiting."; exit 1; fi
if ! command -v openssl &>/dev/null; then echo "Error: openssl is not installed."; exit 1; fi
if [[ ! -f "$ENCRYPTION_KEY_PATH" ]]; then echo "Error: Encryption key not found."; exit 1; fi
ENCRYPTION_KEY=$(cat "$ENCRYPTION_KEY_PATH")
decrypt_and_source() {
    local encrypted_file="$1"
    if [[ ! -f "$encrypted_file" ]]; then echo "Error: Module $encrypted_file not found."; exit 1; fi
    openssl enc -aes-256-cbc -d -salt -pbkdf2 -in "$encrypted_file" -k "$ENCRYPTION_KEY" 2>/dev/null | bash
}
decrypt_and_source "$XXJIHAD_LIB/dnstt-core.sh.enc"
decrypt_and_source "$XXJIHAD_LIB/net-optimizer.sh.enc"
decrypt_and_source "$XXJIHAD_LIB/user-manager.sh.enc"
decrypt_and_source "$XXJIHAD_LIB/ssl-tunnel.sh.enc"
decrypt_and_source "$XXJIHAD_LIB/protocols.sh.enc"
decrypt_and_source "$XXJIHAD_LIB/menu-system.sh.enc"
decrypt_and_source "$XXJIHAD_LIB/uninstall.sh.enc"
if declare -f init_dirs > /dev/null; then init_dirs; fi
case "${1:-}" in
    --status) if declare -f xxjihad_status > /dev/null; then xxjihad_status; fi ;;
    --info) if declare -f show_dnstt_info > /dev/null; then show_dnstt_info; fi ;;
    *) if declare -f main_menu > /dev/null; then main_menu; fi ;;
esac
EOF
fi
chmod +x "$XXJIHAD_BIN/xxjihad"
msg_ok "Main loader script ready."

msg_ok "XxXjihad VPN Manager (Encrypted Edition) installation complete!"
msg_info "Type 'xxjihad' to run the manager."

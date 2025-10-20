#!/bin/sh
set -e

# Resolve runtime variables
SMB_USER="${SMB_USER:-}"
SMB_PASS="${SMB_PASS:-}"
SMB_GROUP="${SMB_GROUP:-smb}"
SMB_STORAGE="${SMB_STORAGE:-/storage}"

echo "[INFO] Starting Samba setup..."

# Ensure storage exists
mkdir -p "$SMB_STORAGE"

# Ensure group exists
if ! getent group "$SMB_GROUP" >/dev/null 2>&1; then
    echo "[INFO] Creating group: $SMB_GROUP"
    addgroup -S "$SMB_GROUP"
fi

# If user is defined, create it and set Samba password
if [ -n "$SMB_USER" ]; then
    if ! id "$SMB_USER" >/dev/null 2>&1; then
        echo "[INFO] Creating user: $SMB_USER"
        adduser -S -D -H -G "$SMB_GROUP" "$SMB_USER"
    fi
    if [ -n "$SMB_PASS" ]; then
        echo "[INFO] Setting Samba password for user: $SMB_USER"
        printf "%s\n%s\n" "$SMB_PASS" "$SMB_PASS" | smbpasswd -a -s "$SMB_USER"
    else
        echo "[WARN] No SMB_PASS provided. User will exist only on system, not Samba."
    fi
else
    echo "[WARN] No SMB_USER provided. Samba will only allow guest if enabled."
fi

echo "[INFO] Launching Samba..."
exec "$@"

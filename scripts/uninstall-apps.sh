#!/bin/bash

# Uninstall iOS apps from apps.txt using ideviceinstaller
# Usage: ./uninstall-apps.sh [--dry-run]
#
# Prerequisites:
#   brew install libimobiledevice ideviceinstaller
#
# To dump all installed iOS apps to apps.txt:
#   ideviceinstaller -l -o list_all > apps.txt
#
# This generates a CSV with columns: CFBundleIdentifier, CFBundleVersion, CFBundleDisplayName
# Example output:
#   CFBundleIdentifier, CFBundleVersion, CFBundleDisplayName
#   com.apple.mobilesafari, 8617.2.1, "Safari"
#   com.spotify.client, 9.0.24, "Spotify"
#
# To list only user-installed apps (excludes system apps):
#   ideviceinstaller -l -o list_user > apps.txt
#
# To list only system apps:
#   ideviceinstaller -l -o list_system > apps.txt

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_FILE="${SCRIPT_DIR}/apps.txt"
LOG_FILE="${SCRIPT_DIR}/uninstall.log"

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "DRY RUN MODE - No apps will be uninstalled"
    echo "============================================"
fi

# Check if apps.txt exists
if [[ ! -f "$APPS_FILE" ]]; then
    echo "Error: apps.txt not found at $APPS_FILE"
    exit 1
fi

# Check if ideviceinstaller is available
if ! command -v ideviceinstaller &>/dev/null; then
    echo "Error: ideviceinstaller not found. Install with: brew install ideviceinstaller"
    exit 1
fi

# Initialize log file
echo "Uninstall started at $(date)" >>"$LOG_FILE"
echo "==============================" >>"$LOG_FILE"

# Read apps.txt, skip header, and process each line
tail -n +2 "$APPS_FILE" | while IFS=, read -r bundle_id version name; do
    # Trim whitespace from bundle_id
    bundle_id=$(echo "$bundle_id" | xargs)
    name=$(echo "$name" | tr -d '"' | xargs)

    if [[ -z "$bundle_id" ]]; then
        continue
    fi

    echo "Processing: $name ($bundle_id)"

    if [[ "$DRY_RUN" == true ]]; then
        echo "  [DRY RUN] Would uninstall: $bundle_id"
        echo "[DRY RUN] $bundle_id - $name" >>"$LOG_FILE"
    else
        if ideviceinstaller -U "$bundle_id" 2>&1; then
            echo "  [SUCCESS] Uninstalled: $bundle_id"
            echo "[SUCCESS] $(date) - $bundle_id - $name" >>"$LOG_FILE"
        else
            echo "  [FAILED] Could not uninstall: $bundle_id"
            echo "[FAILED] $(date) - $bundle_id - $name" >>"$LOG_FILE"
        fi
    fi
done

echo "==============================" >>"$LOG_FILE"
echo "Uninstall completed at $(date)" >>"$LOG_FILE"
echo "" >>"$LOG_FILE"

echo ""
echo "Done! Check $LOG_FILE for details."

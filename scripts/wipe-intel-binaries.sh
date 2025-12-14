#!/usr/bin/env bash

# Script to identify macOS applications with x86_64 binaries
# Usage: ./wipe-intel-binaries.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Scanning for applications with x86_64 binaries...${NC}\n"

# Array to store apps with x86_64
declare -a x86_apps=()

# Counter for statistics
total_apps=0
x86_count=0
arm_only_count=0
skipped_count=0

# Function to check a single app
check_app() {
    local app_path="$1"
    local app_name=$(basename "$app_path" .app)
    local binary_path="$app_path/Contents/MacOS/$app_name"
    
    total_apps=$((total_apps + 1))
    
    # Check if binary exists
    if [[ ! -f "$binary_path" ]]; then
        # Try to find the actual binary (some apps have different names)
        local actual_binary=$(find "$app_path/Contents/MacOS" -type f -perm +111 2>/dev/null | head -n 1)
        if [[ -n "$actual_binary" ]]; then
            binary_path="$actual_binary"
        else
            skipped_count=$((skipped_count + 1))
            return
        fi
    fi
    
    # Run lipo -info
    local lipo_output=$(lipo -info "$binary_path" 2>/dev/null || echo "")
    
    if [[ -z "$lipo_output" ]]; then
        skipped_count=$((skipped_count + 1))
        return
    fi
    
    # Check if it contains x86_64
    if echo "$lipo_output" | grep -q "x86_64"; then
        echo -e "${RED}[x86_64]${NC} $app_name"
        echo "  Path: $binary_path"
        echo "  Info: $lipo_output"
        echo ""
        x86_apps+=("$app_path")
        x86_count=$((x86_count + 1))
    else
        arm_only_count=$((arm_only_count + 1))
    fi
}

# Scan /Applications
if [[ -d "/Applications" ]]; then
    while IFS= read -r -d '' app; do
        check_app "$app"
    done < <(find /Applications -maxdepth 1 -name "*.app" -print0)
fi

# Scan ~/Applications if it exists
if [[ -d "$HOME/Applications" ]]; then
    while IFS= read -r -d '' app; do
        check_app "$app"
    done < <(find "$HOME/Applications" -maxdepth 1 -name "*.app" -print0)
fi

# Print summary
echo -e "${YELLOW}=====================================${NC}"
echo -e "${YELLOW}Summary:${NC}"
echo -e "Total apps scanned: $total_apps"
echo -e "${RED}Apps with x86_64: $x86_count${NC}"
echo -e "${GREEN}ARM-only apps: $arm_only_count${NC}"
echo -e "Skipped: $skipped_count"
echo -e "${YELLOW}=====================================${NC}\n"

# Save list to file
if [[ ${#x86_apps[@]} -gt 0 ]]; then
    output_file="$HOME/x86_apps_list.txt"
    printf '%s\n' "${x86_apps[@]}" > "$output_file"
    echo -e "${GREEN}Full list saved to: $output_file${NC}"
    echo -e "\n${YELLOW}Note: This script only identifies x86_64 binaries.${NC}"
    echo -e "${YELLOW}To remove x86_64 architecture from a specific app, use:${NC}"
    echo -e "${YELLOW}  lipo -remove x86_64 <binary_path> -output <binary_path>_arm${NC}"
    echo -e "${YELLOW}  (Make backups before modifying binaries!)${NC}"
fi

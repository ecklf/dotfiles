#!/usr/bin/env bash
# Ubuntu Desktop VM Setup Script for Clawdbot

set -euo pipefail

# Configuration
VM_NAME="${1:-clawdbot-vm}"
VM_DISK_SIZE="${2:-60G}" # 60GB Disk
VM_RAM="${3:-4096}"      # 4GB RAM
VM_CPUS="${4:-2}"        # 4 vCPUs
VNC_PORT="${5:-5900}"
UBUNTU_VERSION="24.04.1"
ISO_URL="https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-desktop-amd64.iso"
VM_DIR="/var/lib/libvirt/images"
ISO_PATH="${VM_DIR}/ubuntu-${UBUNTU_VERSION}-desktop-amd64.iso"
DISK_PATH="${VM_DIR}/${VM_NAME}.qcow2"

echo "=== Clawdbot Ubuntu VM Setup ==="
echo "VM Name:    ${VM_NAME}"
echo "Disk Size:  ${VM_DISK_SIZE}"
echo "RAM:        ${VM_RAM} MB"
echo "CPUs:       ${VM_CPUS}"
echo "VNC Port:   ${VNC_PORT}"
echo ""

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root or with sudo"
    exit 1
fi

# Create VM directory if needed
mkdir -p "${VM_DIR}"

# Download Ubuntu ISO if not present
if [[ ! -f "${ISO_PATH}" ]]; then
    echo "Downloading Ubuntu ${UBUNTU_VERSION} Desktop ISO..."
    wget -O "${ISO_PATH}" "${ISO_URL}"
else
    echo "Ubuntu ISO already exists at ${ISO_PATH}"
fi

# Create disk image if not present
if [[ ! -f "${DISK_PATH}" ]]; then
    echo "Creating ${VM_DISK_SIZE} disk image..."
    qemu-img create -f qcow2 "${DISK_PATH}" "${VM_DISK_SIZE}"
else
    echo "Disk image already exists at ${DISK_PATH}"
fi

# Check if VM already exists
if virsh dominfo "${VM_NAME}" &>/dev/null; then
    echo "VM '${VM_NAME}' already exists!"
    echo "To delete: virsh destroy ${VM_NAME}; virsh undefine ${VM_NAME}"
    exit 1
fi

echo "Creating VM '${VM_NAME}'..."

# Create the VM with virt-install
# Key settings for headless VNC access:
# - --graphics vnc,listen=0.0.0.0,port=${VNC_PORT} : VNC accessible from network
# - --video qxl : Good video driver for VNC
# - --noautoconsole : Don't try to open a console (headless)
virt-install \
    --name "${VM_NAME}" \
    --ram "${VM_RAM}" \
    --vcpus "${VM_CPUS}" \
    --cpu host-passthrough \
    --disk path="${DISK_PATH}",format=qcow2,bus=virtio \
    --cdrom "${ISO_PATH}" \
    --os-variant ubuntu24.04 \
    --network network=default,model=virtio \
    --graphics vnc,listen=0.0.0.0,port="${VNC_PORT}",password=clawdbot \
    --video qxl \
    --boot uefi \
    --noautoconsole

echo ""
echo "=== VM Created Successfully! ==="
echo ""
echo "Next steps:"
echo ""
echo "1. Connect to the VM via VNC to install Ubuntu:"
echo "   - Use any VNC client to connect to: yun-ip-address:${VNC_PORT}"
echo "   - VNC password is: clawdbot"
echo "   - Example: vncviewer yun.local:${VNC_PORT}"
echo ""
echo "2. Install Ubuntu Desktop (follow the installer):"
echo "   - Choose 'Minimal installation' for less bloat"
echo "   - Enable auto-login for clawdbot"
echo "   - Username suggestion: clawdbot"
echo ""
echo "3. After Ubuntu is installed, configure for clawdbot:"
echo "   - Remove the CDROM: virsh change-media ${VM_NAME} sda --eject"
echo "   - Reboot the VM: virsh reboot ${VM_NAME}"
echo ""
echo "4. Inside Ubuntu, set up clawdbot following their docs"
echo ""
echo "VM Management commands:"
echo "  virsh list --all         # List all VMs"
echo "  virsh start ${VM_NAME}   # Start VM"
echo "  virsh shutdown ${VM_NAME}# Graceful shutdown"
echo "  virsh destroy ${VM_NAME} # Force stop"
echo "  virsh console ${VM_NAME} # Serial console (if configured)"
echo ""
echo "To make VM start on boot:"
echo "  virsh autostart ${VM_NAME}"

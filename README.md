# dotfiles

## Darwin

### Setup 

> [!TIP]
> The Dock can be wiped with:
> ```sh
> defaults write com.apple.dock persistent-apps -array && killall Dock
> ```

**1: Install [nix](https://nixos.org/download) and [homebrew](https://brew.sh)**

**2: Ensure Xcode command line tools are installed (setting up _homebrew_ should have already done this)**

**3: Ensure you are signed into the App Store (if using app ids in `mas` configuration)**

### Using this repository

> [!IMPORTANT]  
> For the very first run, `darwin-rebuild` won't be installed in your path
> ```sh
> nix run nix-darwin --extra-experimental-features flakes --extra-experimental-features nix-command -- switch --flake ~/dotfiles#omega
> ```

```sh
# Build the flake `omega` (see flake.nix)
darwin-rebuild build --flake ~/dotfiles#omega
# Switch to `omega` (see flake.nix)
darwin-rebuild switch --flake ~/dotfiles#omega
```

## NixOS

> [!NOTE]  
> Also see the official guide:
> https://nixos.wiki/wiki/NixOS_Installation_Guide

### Setup

**1: Download [ISO image](https://nixos.org/download/#nixos-iso), flash it to USB, and boot**

**2: Setup Wireless (optional)**
```sh
sudo systemctl start wpa_supplicant
wpa_cli
> scan
> scan_results
> add_network
> 0
> set_network 0 ssid "NETWORK_SSID"
> set_network 0 psk "NETWORK_SECRET"
> enable_network 0
> quit
ip a
ping google.com
```

**3: Partition Disks**

These steps are for a UEFI system with GPT partitioning. Adjust as needed.

> [!IMPORTANT]  
> Ensure the label steps for `NIXROOT` and `NIXBOOT` are not skipped as they are used in the configuration.

```sh
# Identify disk
lsblk
# Partition disk
sudo fdisk /dev/sdX
> g (gpt disk label)
> n
> 1 (partition number [1/128])
> 2048 first sector
> +500M last sector (boot sector size)
> t
> 1 (EFI System)
> n
> 2
> default (fill up partition)
> default (fill up partition)
> w (write)
# Create file systems
sudo mkfs.fat -F 32 /dev/sdX1
sudo fatlabel /dev/sdX1 NIXBOOT
sudo mkfs.ext4 /dev/sdX2 -L NIXROOT
sudo mount /dev/disk/by-label/NIXROOT /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/NIXBOOT /mnt/boot
# Create swap file
sudo dd if=/dev/zero of=/mnt/.swapfile bs=1024 count=2097152 (2GB size)
sudo chmod 600 /mnt/.swapfile
sudo mkswap /mnt/.swapfile
sudo swapon /mnt/.swapfile
```

**4: Installation**
```sh
sudo nixos-generate-config --root /mnt
cd /mnt
sudo nixos-install
```

**5: Add nix channels**
```sh
# Add home-manager channel (update version if needed)
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
sudo nix-channel --update
```

### Using this repository
```sh
# Build the flake `snowflake` (see flake.nix)
sudo nixos-rebuild build --flake '~/dotfiles#snowflake'
# Switch to `snowflake` (see flake.nix)
sudo nixos-rebuild switch --flake '~/dotfiles#snowflake'
```

### Post Install

> [!IMPORTANT]  
> Update your user password
> ```sh
> sudo passwd
> ```

Set up Samba if used by configuration:

```sh
# See user info
sudo pdbedit -L -v
# Add samba password
sudo smbpasswd -a $(whoami) 
# Debug samba issues
sudo systemctl status mnt-share.mount
```

## Updating inputs

```sh
# Upgrading nix — https://nix.dev/manual/nix/2.22/installation/upgrading
# Updating flake inputs
nix flake lock --update-all
nix flake lock --update-input <input>
```

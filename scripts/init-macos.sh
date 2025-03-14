#!/bin/sh

confirm() {
  while true; do
    printf "%s (y/n): " "$1"
    read -r yn
    case $yn in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    *) echo "Please answer y or n." ;;
    esac
  done
}

echo "Checklist to bootstrap a new macOS installation"

open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
if ! confirm "Your macOS settings app just opened. Does your current Terminal have Full Disk Access enabled?"; then
  echo "Please enable the setting, restart the terminal, and re-run this script"
  exit 1
fi

if ! confirm "Do you have nix installed?"; then
  open "https://nixos.org/download"
  if ! confirm "Please run the installation command on the site that just opened. Done?"; then
    exit 1
  fi
fi

if ! confirm "Do you have homebrew installed?"; then
  open "https://brew.sh/"
  if ! confirm "Please run the installation command on the site that just opened. Done?"; then
    exit 1
  fi
fi

if confirm "Do you have App Store software that you want to use?"; then
  open /System/Applications/App\ Store.app
  if ! confirm "Please sign into the App Store. Done?"; then
    exit 1
  fi
fi

if confirm "Do you want to wipe the Dock content?"; then
  defaults write com.apple.dock persistent-apps -array && killall Dock
  echo "Dock wipe complete."
else
  echo "Dock wipe skipped."
fi

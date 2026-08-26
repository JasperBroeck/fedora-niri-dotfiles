#!/bin/bash

# -h help flag and -l laptop flag
if [ "$1" = "-h" ]; then
    echo "Welcome to the this installer script to install Fedora with Niri WM and custom configs!"
    echo "Usage: run ./install.sh"
    echo "Flags:"
    echo "  -l: laptop mode (installs battery management software for a better laptop experience)"
    echo "  -h: shows this screen"
    exit 0
fi

if [ "$1" = "-l" ]; then
    LAPTOP_MODE="yes"
fi
echo "=================================="
echo "=== Starting Fedora Niri Setup ==="
echo "=================================="
echo ""

# Ask for password ONCE and keep the sudo session alive
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# Update system
echo "======================="
echo "=== Updating System ==="
echo "======================="
echo ""
sudo dnf upgrade -y

# Installing Packages
echo "==========================="
echo "=== Installing Packages ==="
echo "==========================="
echo ""

## Installing Packages using DNF
while read -r pkg; do
    [ -z "$pkg" ] && continue
    [[ "$pkg" =~ ^# ]] && continue
    sudo dnf install -y "$pkg"
done < packages/dnf.txt

sudo ln -s /var/lib/snapd/snap /snap
sudo systemctl enable --now snapd.socket

## Installing Packages using Flatpak
while read -r pkg; do
    [ -z "$pkg" ] && continue
    [[ "$pkg" =~ ^# ]] && continue
    flatpak install flathub "$pkg" --noninteractive
done < packages/flatpak.txt

## Installing Packages using Snap
while read -r line; do
    [ -z "$line" ] && continue
    [[ "$line" =~ ^# ]] && continue
    sudo snap install $line
done < packages/snap.txt

# Laptop Mode
if [ "$LAPTOP_MODE" = "yes" ]; then
    echo "============================"
    echo "=== Enabling Laptop Mode ==="
    echo "============================"
    echo ""
    sudo dnf install -y tuned
    sudo systemctl enable --now tuned
    sudo tuned-adm profile powersave
fi

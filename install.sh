#!/bin/bash

# -h help flag and -l laptop flag
if [ "$1" = "-h" ]; then
    echo "===================================="
    echo "=== WELCOME - USAGE GUIDE _ HELP ==="
    echo "===================================="
    echo ""
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
echo "=== Starting Fedora Setup ==="
echo "=================================="
echo ""
echo "Your machine may automatically restart at the end, press CTRL+C if you would like to stop this now"
sleep 10
clear

# Ask for password ONCE and keep the sudo session alive
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# Random tweaks
echo "======================="
echo "=== Applying tweaks ==="
echo "======================="
echo ""
echo -e "max_parallel_downloads=10\nfastestmirror=true" | sudo tee -a /etc/dnf/dnf.conf
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

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

sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
sudo systemctl restart snapd.socket

## Installing Packages using Flatpak
while read -r pkg; do
    [ -z "$pkg" ] && continue
    [[ "$pkg" =~ ^# ]] && continue
    flatpak install flathub "$pkg" --noninteractive
done < packages/flatpak.txt

## Installing Packages using Snap
sudo snap install spotify
sudo snap install obsidian --classic

# Laptop Mode
if [ "$LAPTOP_MODE" = "yes" ]; then
    echo "============================"
    echo "=== Enabling Laptop Mode ==="
    echo "============================"
    echo ""
    sudo dnf remove tuned tuned-ppd
    sudo dnf install --allowerasing tlp tlp-pd
    sudo systemctl enable --now tlp.service
    sudo systemctl enable --now tlp-pd.service
fi

# Random tweaks
echo "========================="
echo "=== Firmware Upgrades ==="
echo "========================="
echo ""
sudo fwupdmgr refresh
sudo fwupdmgr update -y

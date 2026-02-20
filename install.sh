#!/bin/sh

# DNF Config
sudo dnf config-manager setopt installonly_limit=2
sudo dnf config-manager setopt max_parallel_downloads=10
sudo dnf config-manager setopt defaultyes=True

sudo dnf -y upgrade --refresh

# RPM Fusion
sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
sudo dnf -y update @core
sudo dnf -y upgrade --refresh

# KDE
sudo dnf -y install plasma-workspace-wayland plasma-login-manager plasma-nm plasma-pa --setopt=install_weak_deps=false

# KDE tools
sudo dnf -y install bash-completion konsole firefox gwenview dolphin ffmpegthumbs kate spectacle kde-gtk-config kscreen firewall-config NetworkManager-wifi NetworkManager-bluetooth bluedevil upower tuned-ppd plasma-milou switcheroo-control kwalletmanager --setopt=install_weak_deps=false
sudo dnf -y install ark

# Firmwares
sudo dnf -y install mt7xxx-firmware realtek-firmware

# Fonts
#sudo dnf -y group install fonts
sudo dnf install -y default-fonts-core-emoji default-fonts-core-math default-fonts-core-mono default-fonts-core-serif default-fonts-other-serif default-fonts-cjk-serif default-fonts-other-mono

# Multimedia
sudo dnf -y swap ffmpeg-free ffmpeg --allowerasing
sudo dnf -y group install multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

sudo systemctl --user --now enable wireplumber.service
sudo systemctl --user --now enable pipewire

# Plasma login manager
sudo systemctl set-default graphical.target
sudo systemctl enable plasmalogin

# Grub
sudo grub2-editenv - set menu_auto_hide=1

# Install Drivers
sudo dnf -y install pciutils
chmod +x drivers.sh
./drivers.sh

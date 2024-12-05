#!/bin/sh

# DNF Config
sudo dnf config-manager setopt installonly_limit=2
sudo dnf config-manager setopt max_parallel_downloads=15
sudo dnf config-manager setopt fastestmirror=1

sudo dnf upgrade --refresh

# RPM Fusion
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf config-manager --enable fedora-cisco-openh264
sudo dnf update @core
sudo dnf -y upgrade --refresh

# KDE
sudo dnf install plasma-workspace-wayland sddm-wayland-plasma sddm-breeze plasma-nm plasma-pa --setopt=install_weak_deps=false

# KDE tools
sudo dnf install bash-completion konsole firefox gwenview dolphin ffmpegthumbs kate spectacle kde-gtk-config kscreen sddm-kcm firewall-config NetworkManager-wifi NetworkManager-bluetooth bluedevil upower tuned-ppd  --setopt=install_weak_deps=false
sudo dnf in ark

# Firmwares
sudo dnf install alsa-sof-firmware intel-gpu-firmware mt7xxx-firmware nvidia-gpu-firmware realtek-firmware

# Fonts
sudo dnf group install fonts

# Multimedia
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf group install multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf install intel-media-driver

sudo systemctl --user --now enable wireplumber.service
sudo systemctl --user --now enable pipewire

# SDDM
sudo systemctl set-default graphical.target
sudo systemctl enable sddm

# Grub
sudo grub2-editenv - set menu_auto_hide=1

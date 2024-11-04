#!/bin/sh

# DNF Config
sudo dnf config-manager setopt installonly_limit=2
sudo dnf config-manager setopt max_parallel_downloads=10

# RPM Fusion
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf config-manager --enable fedora-cisco-openh264
sudo dnf update @core
sudo dnf -y upgrade --refresh

# Firmwares
sudo dnf install alsa-sof-firmware intel-gpu-firmware linux-firmware linux-firmware-whence mt7xxx-firmware nvidia-gpu-firmware realtek-firmware

# KDE
sudo dnf install plasma-workspace-wayland sddm-wayland-plasma sddm-breeze plasma-nm NetworkManager NetworkManager-wifi
sudo dnf install bash-completion konsole firefox gwenview dolphin ffmpegthumbs kate spectacle kde-gtk-config kscreen sddm-kcm firewall-config --setopt=install_weak_deps=false

sudo dnf in ark

sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf group install multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf install intel-media-driver

# Fonts
sudo dnf install curl cabextract xorg-x11-font-utils fontconfig
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# SDDM
sudo systemctl set-default graphical.target
sudo systemctl enable sddm

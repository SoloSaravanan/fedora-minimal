#!/bin/sh

# Intel driver 

if lspci | grep -Ei 'intel|intel corporation' > /dev/null 2>&1; then
    echo -e "\033[32mIntel driver found\033[0m"
    sudo dnf -y install alsa-sof-firmware intel-gpu-firmware intel-media-driver microcode_ctl
    sudo dnf -y install mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers
    sudo dnf -y remove amd-gpu-firmware amd-ucode-firmware

# AMD driver

elif lspci | grep -Ei 'amd|amd corporation' > /dev/null 2>&1; then
    echo -e "\033[32mAMD driver found\033[0m"
    sudo dnf -y install amd-gpu-firmware amd-ucode-firmware

    # AMD Mesa drivers
    sudo dnf -y swap mesa-va-drivers mesa-va-drivers-freeworld
    sudo dnf -y swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
fi

# NVIDIA driver

if lspci | grep -Ei 'nvidia|nvidia corporation' > /dev/null 2>&1; then
    echo -e "\033[32mNVIDIA driver found\033[0m"

    # Create NVIDIA modprobe configuration
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null << 'EOF'
blacklist nouveau
blacklist nova
blacklist nova_core
options nouveau modeset=0
softdep nvidia post: nvidia-drm
options nvidia-drm fbdev=1
EOF

sudo sed -i '/^enabled=1$/!b; n; /^[[:space:]]*exclude=/!i exclude=*nvidia*' /usr/share/dnf5/repos.d/rpmfusion-nonfree*.repo

    # Add NVIDIA driver repository
    sudo tee -a /usr/share/dnf5/repos.d/nvidia-driver.repo > /dev/null << 'EOF'
[nvidia-driver]
name=Nvidia Driver
baseurl=https://solosaravanan.github.io/nvidia-driver/
enabled=1
gpgcheck=1
gpgkey=https://solosaravanan.github.io/nvidia-driver/pubkey.gpg
EOF

    #  Install NVIDIA driver
    sudo dnf install -y \
  	nvidia-driver \
  	nvidia-gpu-firmware \
  	nvidia-common \
  	nvidia-modules-open \
  	nvidia-modprobe \
  	nvidia-egl \
  	nvidia-egl-wayland \
  	nvidia-egl-gbm \
  	nvidia-egl-xwayland \
  	nvidia-smi \
  	nvidia-gbm \
  	nvidia-gles \
  	nvidia-glx \
  	nvidia-vdpau \
  	nvidia-powerd \
  	nvidia-settings \
  	nvidia-ngx \
  	nvidia-cfg \
  	nvidia-utils \
  	nvidia-libs-32bit
    sudo dnf install -y libva-nvidia-driver

    #Enable Nvidia suspend, dynamic boost
    sudo systemctl enable nvidia-{suspend,resume,hibernate,suspend-then-hibernate}
    sudo cp /usr/share/dbus-1/system.d/nvidia-dbus.conf /etc/dbus-1/system.d/
    sudo systemctl enable --now nvidia-powerd

    echo -e "\033[32mNVIDIA driver installed successfully\033[0m"
fi

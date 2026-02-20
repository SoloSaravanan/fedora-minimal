#!/bin/sh

# Intel driver 

if lspci | grep -Ei 'intel|intel corporation' > /dev/null 2>&1; then
    echo -e "\033[32mIntel driver found\033[0m"
    sudo dnf -y install alsa-sof-firmware intel-gpu-firmware intel-media-driver
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
options nvidia-drm modeset=1 fbdev=1
options nvidia NVreg_UsePageAttributeTable=1 \
    NVreg_InitializeSystemMemoryAllocations=0 \
    NVreg_DynamicPowerManagement=0x03 \
    NVreg_EnableS0ixPowerManagement=1 \
    NVreg_RegistryDwords=RmEnableAggressiveVblank=1
EOF

    # Create NVIDIA udev rules
    sudo tee /lib/udev/rules.d/71-nvidia.rules > /dev/null << 'EOF'
# Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
ACTION=="add|bind", SUBSYSTEM=="pci", DRIVERS=="nvidia", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", TEST=="power/control", ATTR{power/control}="auto"

# Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
ACTION=="remove|unbind", SUBSYSTEM=="pci", DRIVERS=="nvidia", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", TEST=="power/control", ATTR{power/control}="on"
EOF

sudo sed -i '/^enabled=1$/!b; n; /^[[:space:]]*exclude=/!i exclude=*nvidia*' /etc/yum.repos.d/rpmfusion-nonfree*.repo

    # Add NVIDIA driver repository
    sudo tee -a /etc/yum.repos.d/nvidia-driver.repo > /dev/null << 'EOF'
[nvidia-driver]
name=Nvidia Driver
baseurl=https://solosaravanan.github.io/nvidia-driver/
enabled=1
gpgcheck=1
gpgkey=https://solosaravanan.github.io/nvidia-driver/pubkey.gpg
EOF

    #  Install NVIDIA driver
    sudo dnf install -y nvidia-cfg nvidia-common nvidia-cuda nvidia-driver nvidia-egl nvidia-egl-gbm nvidia-egl-wayland nvidia-gbm nvidia-gles nvidia-glx nvidia-gpu-firmware nvidia-modprobe nvidia-modules-open nvidia-ngx nvidia-opencl nvidia-powerd nvidia-security nvidia-settings nvidia-smi nvidia-vdpau nvidia-video nvidia-vision
    sudo dnf install -y libva-nvidia-driver
    #Enable Nvidia suspend, dynamic boost
    sudo systemctl enable nvidia-{suspend,resume,hibernate,suspend-then-hibernate}
    sudo cp /usr/share/dbus-1/system.d/nvidia-dbus.conf /etc/dbus-1/system.d/
    sudo systemctl enable --now nvidia-powerd

    echo -e "\033[32mNVIDIA driver installed successfully\033[0m"
fi

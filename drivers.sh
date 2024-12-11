#!/bin/sh

# Intel driver 

if lspci | grep -Ei 'intel|intel corporation' > /dev/null 2>&1; then
    echo -e "\033[32mIntel driver found\033[0m"
    sudo dnf install alsa-sof-firmware intel-gpu-firmware intel-media-driver -y

# AMD driver

elif lspci | grep -Ei 'amd|amd corporation' > /dev/null 2>&1; then
    echo -e "\033[32mAMD driver found\033[0m"
    sudo dnf install amd-gpu-firmware amd-ucode-firmware -y

    # AMD Mesa drivers
    sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld -y
    sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld -y
    sudo dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686 -y
    sudo dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686 -y
fi

# NVIDIA driver

# Define NVIDIA driver version
NVIDIA_VERSION="565.77"

if lspci | grep -Ei 'nvidia|nvidia corporation' > /dev/null 2>&1; then
    echo -e "\033[32mNVIDIA driver found\033[0m"
    sudo dnf install nvidia-gpu-firmware -y

    # Create NVIDIA modprobe configuration
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null << 'EOF'
options nvidia-drm modeset=1 fbdev=1
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_EnableS0ixPowerManagement=1
options nvidia NVreg_EnableGpuFirmware=0
EOF
    # Download latest NVIDIA driver
    cd /tmp
    wget "https://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run"

    # Make executable and run
    chmod +x "NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run"
    sudo "./NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run"

    # Add cleanup after installation
    rm -f "/tmp/NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run"
fi
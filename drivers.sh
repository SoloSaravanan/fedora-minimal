#!/bin/sh

# Intel driver 

if lspci | grep -Ei 'intel|intel corporation' > /dev/null 2>&1; then
    echo "Intel driver found"
    sudo dnf install alsa-sof-firmware intel-gpu-firmware intel-media-driver -y

# AMD driver

elif lspci | grep -Ei 'amd|amd corporation' > /dev/null 2>&1; then
    echo "AMD driver found"
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
    echo "NVIDIA driver found"
    sudo dnf install nvidia-gpu-firmware -y
    
    # Download latest NVIDIA driver
    cd /tmp
    wget "https://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run"

    # Make executable and run
    chmod +x "NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run"
    sudo "./NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run"
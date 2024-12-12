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

if lspci | grep -Ei 'nvidia|nvidia corporation' > /dev/null 2>&1; then
    echo -e "\033[32mNVIDIA driver found\033[0m"
    sudo dnf install nvidia-gpu-firmware akmod-nvidia-open xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs vulkan libva-nvidia-driver.{i686,x86_64} nvidia-vaapi-driver libva-utils vdpauinfo egl-gbm -y

    # Create NVIDIA modprobe configuration
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null << 'EOF'
options nvidia-drm modeset=1 fbdev=1
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_EnableS0ixPowerManagement=1
options nvidia NVreg_EnableGpuFirmware=0
options nvidia NVreg_DynamicPowerManagement=0x02
EOF

    #Nvidia Suspend
    sudo dnf install xorg-x11-drv-nvidia-power
    sudo systemctl enable nvidia-{suspend,resume,hibernate}
    sudo cp /usr/share/dbus-1/system.d/nvidia-dbus.conf /etc/dbus-1/system.d/
    sudo systemctl enable --now nvidia-powerd

    echo -e "\033[32mNVIDIA driver installed successfully\033[0m"
    echo "To verify NVIDIA kernel module installation, please run: modinfo -F version nvidia"


# Define NVIDIA driver version
#NVIDIA_VERSION="565.77"

    # Download latest NVIDIA driver
    #cd /tmp
    #wget "https://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run"

    # Make executable and run
    #chmod +x "NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run"
    #sudo "./NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run"

    # Add cleanup after installation
    #rm -f "/tmp/NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run"
fi
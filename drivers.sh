#!/bin/sh

# Intel driver 

if lspci | grep -Ei 'intel|intel corporation' > /dev/null 2>&1; then
    echo -e "\033[32mIntel driver found\033[0m"
    sudo dnf -y install alsa-firmware alsa-sof-firmware intel-gpu-firmware intel-media-driver intel-mediasdk intel-vpl-gpu-rt
    sudo dnf -y remove amd-gpu-firmware amd-ucode-firmware

# AMD driver

elif lspci | grep -Ei 'amd|amd corporation' > /dev/null 2>&1; then
    echo -e "\033[32mAMD driver found\033[0m"
    sudo dnf -y install amd-gpu-firmware amd-ucode-firmware

    # AMD Mesa drivers
    sudo dnf -y swap mesa-va-drivers mesa-va-drivers-freeworld
    sudo dnf -y swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
    sudo dnf -y swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
    sudo dnf -y swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
fi

# NVIDIA driver

if lspci | grep -Ei 'nvidia|nvidia corporation' > /dev/null 2>&1; then
    echo -e "\033[32mNVIDIA driver found\033[0m"
    #sudo dnf -y install rpmfusion-nonfree-release-tainted
    #sudo dnf -y install nvidia-gpu-firmware akmod-nvidia-open xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs vulkan libva-nvidia-driver.{i686,x86_64} nvidia-vaapi-driver libva-utils vdpauinfo egl-gbm.{i686,x86_64}

    ## Get new 570 beta driver from cuda repos
    sudo dnf -y config-manager addrepo --from-repofile=https://developer.download.nvidia.com/compute/cuda/repos/fedora41/x86_64/cuda-fedora41.repo
    sudo dnf -y install cuda-drivers --allowerasing
    sudo dnf -y install nvidia-driver kmod-nvidia-latest-dkms libva-utils libva-nvidia-driver.{i686,x86_64} nvidia-settings nvidia-persistenced

    # Create NVIDIA modprobe configuration
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null << 'EOF'
blacklist nouveau
options nouveau modeset=0
options nvidia-drm modeset=1 fbdev=1
options nvidia NVreg_EnableGpuFirmware=0
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
options nvidia NVreg_DynamicPowerManagement=0x02
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_EnableS0ixPowerManagement=1
EOF

    # Create NVIDIA udev rules
    sudo tee /lib/udev/rules.d/80-nvidia-pm.rules > /dev/null << 'EOF'
# Remove NVIDIA USB xHCI Host Controller devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"

# Remove NVIDIA USB Type-C UCSI devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"

# Remove NVIDIA Audio devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

# Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

# Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
EOF

    #Enable Nvidia suspend, dynamic boost, persistence
    #sudo dnf -y install xorg-x11-drv-nvidia-power
    sudo systemctl enable nvidia-{suspend,resume,hibernate}
    sudo cp /usr/share/dbus-1/system.d/nvidia-dbus.conf /etc/dbus-1/system.d/
    sudo systemctl enable --now nvidia-powerd
    sudo systemctl enable --now nvidia-persistenced.service

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

# ZBT Z8102AX-V2 eMMC Version Build Guide

[中文版本](./BUILD.md)

This repository provides a complete solution for building OpenWrt and ImmortalWrt firmware for the ZBT Z8102AX-V2 eMMC modified version.

## Table of Contents

- [Hardware Specifications](#hardware-specifications)
- [System Requirements](#system-requirements)
- [Quick Start](#quick-start)
- [Detailed Instructions](#detailed-instructions)
- [Flashing Guide](#flashing-guide)
- [Troubleshooting](#troubleshooting)

## Hardware Specifications

- **SoC**: MediaTek MT7981B (Filogic 820)
- **RAM**: 1GB DDR4
- **Storage**: eMMC (Modified version, original uses SPI-NAND)
- **WiFi**: MT7976CN (WiFi 6, 2.4GHz + 5GHz)
- **Ethernet**: 1x 2.5G WAN + 4x 1G LAN
- **USB**: 2x USB 3.0 (M.2 slots) + 1x USB 3.0 external
- **Buttons**: Reset, Mesh
- **LEDs**: Status, WAN, LAN, 4G, 5G

## System Requirements

### Ubuntu/Debian Dependencies

```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential clang flex bison g++ gawk \
    gcc-multilib g++-multilib gettext git \
    libncurses5-dev libssl-dev python3-setuptools rsync \
    swig unzip zlib1g-dev file wget
```

### Hardware Requirements

- **Disk Space**: At least 30GB free space
- **RAM**: At least 4GB RAM (8GB recommended)
- **CPU**: Multi-core CPU (build time inversely proportional to core count)

## Quick Start

### Building OpenWrt

```bash
# Clone this repository
git clone https://github.com/xyzy12345/ZBT-Z8102AX-V2-emmc.git
cd ZBT-Z8102AX-V2-emmc

# Run OpenWrt build script
chmod +x build-openwrt.sh
./build-openwrt.sh
```

### Building ImmortalWrt

```bash
# Run ImmortalWrt build script
chmod +x build-immortalwrt.sh
./build-immortalwrt.sh
```

After compilation, firmware images will be located at:
- OpenWrt: `openwrt-build/bin/targets/mediatek/filogic/`
- ImmortalWrt: `immortalwrt-build/bin/targets/mediatek/filogic/`

## Detailed Instructions

### Directory Structure

```
.
├── build-openwrt.sh           # OpenWrt automated build script
├── build-immortalwrt.sh       # ImmortalWrt automated build script
├── configs/                   # Build configuration files
│   ├── openwrt.config        # OpenWrt configuration
│   └── immortalwrt.config    # ImmortalWrt configuration
├── dts/                       # Device tree source files
│   └── mt7981b-zbtlink-zbt-z8102ax-v2-emmc.dts
├── patches/                   # Patch files
│   ├── openwrt/              # OpenWrt specific patches
│   └── immortalwrt/          # ImmortalWrt specific patches
└── README.md                  # This file
```

### Custom Configuration

#### Modifying Build Configuration

1. Edit configuration files:
   ```bash
   # For OpenWrt
   nano configs/openwrt.config
   
   # For ImmortalWrt
   nano configs/immortalwrt.config
   ```

2. Or use interactive configuration:
   ```bash
   cd openwrt-build  # or immortalwrt-build
   make menuconfig
   # Save configuration when done
   cp .config ../configs/openwrt.config  # or immortalwrt.config
   ```

#### Adding Custom Packages

Add desired packages to the configuration file:
```
CONFIG_PACKAGE_your-package-name=y
```

### Device Tree Explanation

The `dts/mt7981b-zbtlink-zbt-z8102ax-v2-emmc.dts` file defines hardware configuration for the eMMC version:

- **eMMC Configuration**: Supports HS400 mode, 8-bit bus width
- **Partition Layout**:
  - bl2: 1MB (Boot loader)
  - u-boot-env: 512KB (U-Boot environment variables)
  - factory: 2MB (Factory data, including WiFi calibration data)
  - fip: 2MB (Firmware Image Package)
  - kernel: 32MB (Kernel partition)
  - rootfs: 7GB (Root filesystem, SquashFS format)
  - overlay: ~105GB (Optional, user data partition on p7)

## Flashing Guide

### Method 1: Via U-Boot (Recommended for First Flash)

1. Connect serial port (115200 8N1)
2. Reboot device and press any key during U-Boot startup
3. Set network:
   ```
   setenv ipaddr 192.168.1.1
   setenv serverip 192.168.1.100
   ```
4. Download firmware via TFTP:
   ```
   tftpboot 0x46000000 openwrt-mediatek-filogic-zbtlink_zbt-z8102ax-v2-emmc-squashfs-sysupgrade.bin
   ```
5. Write to eMMC:
   ```
   mmc dev 0
   mmc write 0x46000000 0x580000 0x7a80000
   ```
6. Reboot:
   ```
   reset
   ```

### Method 2: Web Interface Upgrade

1. Access router management interface (usually `192.168.1.1`)
2. Go to "System" → "Backup/Flash Firmware"
3. Select sysupgrade.bin file
4. Upload and wait for flashing to complete

### Method 3: Command Line Upgrade

1. Copy firmware file to router:
   ```bash
   scp openwrt-*.bin root@192.168.1.1:/tmp/
   ```
2. SSH into router and execute:
   ```bash
   sysupgrade -v /tmp/openwrt-*.bin
   ```

## Features

### OpenWrt Features

- ✅ Basic LuCI web management interface
- ✅ IPv4/IPv6 dual stack support
- ✅ WiFi 6 support (MT7976CN)
- ✅ 2.5G WAN port
- ✅ USB 3.0 support
- ✅ 4G/5G modem support
- ✅ eMMC storage optimization

### ImmortalWrt Features

Additional features on top of OpenWrt:

- ✅ Argon theme
- ✅ Chinese language pack
- ✅ SSR Plus+ plugin
- ✅ PassWall plugin
- ✅ MosDNS plugin
- ✅ Turbo ACC acceleration

## Troubleshooting

### Build Failures

1. **Dependency Issues**:
   ```bash
   # Reinstall all dependencies
   sudo apt-get update
   sudo apt-get install -y build-essential clang flex bison g++ gawk ...
   ```

2. **Insufficient Disk Space**:
   ```bash
   # Clean build cache
   cd openwrt-build  # or immortalwrt-build
   make clean
   ```

3. **Network Issues**:
   - Some sources may require proxy access
   - Edit `~/.gitconfig` to add proxy configuration

4. **Configuration File Warnings**:
   If you see warnings like:
   ```
   .config:22:warning: symbol value '32768      # 32MB kernel partition' invalid for TARGET_KERNEL_PARTSIZE
   ```
   This is due to incorrect configuration file format. Configuration values cannot have inline comments; comments must be on separate lines:
   ```
   # Incorrect format:
   CONFIG_TARGET_KERNEL_PARTSIZE=32768      # 32MB kernel partition
   
   # Correct format:
   # 32MB kernel partition
   CONFIG_TARGET_KERNEL_PARTSIZE=32768
   ```
   The configuration files in this repository have been fixed.

### Device Won't Boot

1. **Check Serial Output**: Connect serial port to view boot logs
2. **Restore Factory Firmware**: Use factory recovery tool
3. **Reflash U-Boot**: May require professional tools (e.g., JTAG)

### WiFi Not Working

1. Ensure factory partition contains correct calibration data
2. Check if WiFi driver is loaded correctly:
   ```bash
   dmesg | grep mt76
   ```

### 5G Modem Not Recognized

1. Check USB devices:
   ```bash
   lsusb
   ```
2. Install appropriate drivers and tools:
   ```bash
   opkg update
   opkg install kmod-usb-net-qmi-wwan uqmi
   ```

## Contributing

Issues and Pull Requests are welcome!

## License

Scripts and configuration files in this project are licensed under GPL-2.0.

OpenWrt and ImmortalWrt projects have their own licenses, see their official websites for details.

## Related Links

- [OpenWrt Official Website](https://openwrt.org/)
- [ImmortalWrt Official Website](https://immortalwrt.org/)
- [OpenWrt Forum](https://forum.openwrt.org/)
- [ZBT Official Website](https://www.zbtwifi.com/)

## Acknowledgments

Thanks to the OpenWrt and ImmortalWrt communities for their contributions!

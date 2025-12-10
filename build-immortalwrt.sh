#!/bin/bash
# ImmortalWrt Build Script for ZBT Z8102AX-V2 eMMC Version
# 为 ZBT Z8102AX-V2 eMMC 改装版编译 ImmortalWrt

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMMORTALWRT_REPO="https://github.com/immortalwrt/immortalwrt.git"
IMMORTALWRT_BRANCH="master"
BUILD_DIR="immortalwrt-build"
DEVICE_NAME="zbtlink_zbt-z8102ax-v2-emmc"
TARGET="mediatek"
SUBTARGET="filogic"

echo -e "${GREEN}ZBT Z8102AX-V2 eMMC - ImmortalWrt Build Script${NC}"
echo "================================================"
echo ""

# Check dependencies
echo -e "${YELLOW}Checking build dependencies...${NC}"
REQUIRED_PACKAGES=(
    "build-essential"
    "clang"
    "flex"
    "bison"
    "g++"
    "gawk"
    "gcc-multilib"
    "g++-multilib"
    "gettext"
    "git"
    "libncurses5-dev"
    "libssl-dev"
    "python3-setuptools"
    "rsync"
    "swig"
    "unzip"
    "zlib1g-dev"
    "file"
    "wget"
)

missing_packages=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii  $pkg"; then
        missing_packages+=("$pkg")
    fi
done

if [ ${#missing_packages[@]} -ne 0 ]; then
    echo -e "${YELLOW}Missing packages detected. Installing...${NC}"
    echo "sudo apt-get update && sudo apt-get install -y ${missing_packages[*]}"
    echo -e "${RED}Please run the above command manually with sudo privileges.${NC}"
    exit 1
fi

# Clone ImmortalWrt if not exists
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${GREEN}Cloning ImmortalWrt repository (branch: $IMMORTALWRT_BRANCH)...${NC}"
    git clone -b "$IMMORTALWRT_BRANCH" "$IMMORTALWRT_REPO" "$BUILD_DIR"
else
    echo -e "${YELLOW}ImmortalWrt repository already exists, updating...${NC}"
    cd "$BUILD_DIR"
    git pull
    cd ..
fi

cd "$BUILD_DIR"

# Update feeds
echo -e "${GREEN}Updating and installing feeds...${NC}"
./scripts/feeds update -a
./scripts/feeds install -a

# Apply device-specific patches if they exist
if [ -d "../patches/immortalwrt" ]; then
    echo -e "${GREEN}Applying device-specific patches...${NC}"
    for patch in ../patches/immortalwrt/*.patch; do
        if [ -f "$patch" ]; then
            echo "Applying: $(basename $patch)"
            if ! patch -p1 --dry-run < "$patch" > /dev/null 2>&1; then
                echo -e "${YELLOW}Warning: Patch $(basename $patch) may already be applied or conflicts exist${NC}"
            else
                patch -p1 < "$patch" || {
                    echo -e "${RED}Error: Failed to apply patch $(basename $patch)${NC}"
                    exit 1
                }
            fi
        fi
    done
fi

# Copy device tree if exists
if [ -f "../dts/mt7981b-zbtlink-zbt-z8102ax-v2-emmc.dts" ]; then
    echo -e "${GREEN}Copying device tree source...${NC}"
    mkdir -p target/linux/mediatek/dts
    cp ../dts/mt7981b-zbtlink-zbt-z8102ax-v2-emmc.dts target/linux/mediatek/dts/
fi

# Configure build
echo -e "${GREEN}Configuring build...${NC}"
if [ -f "../configs/immortalwrt.config" ]; then
    cp ../configs/immortalwrt.config .config
else
    # Default configuration
    cat > .config << EOF
CONFIG_TARGET_${TARGET}=y
CONFIG_TARGET_${TARGET}_${SUBTARGET}=y
CONFIG_TARGET_${TARGET}_${SUBTARGET}_DEVICE_${DEVICE_NAME}=y
CONFIG_DEVEL=y
CONFIG_TOOLCHAINOPTS=y
CONFIG_BUSYBOX_CUSTOM=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-ssl-openssl=y
CONFIG_PACKAGE_luci-app-firewall=y
CONFIG_PACKAGE_luci-app-opkg=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-ssr-plus=y
EOF
fi

make defconfig

# Show configuration
echo -e "${GREEN}Build configuration:${NC}"
echo "Target: $TARGET"
echo "Subtarget: $SUBTARGET"
echo "Device: $DEVICE_NAME"
echo ""

# Build
echo -e "${GREEN}Starting build process...${NC}"
echo "This may take a long time (1-4 hours depending on your system)"
echo ""

# Determine number of cores
CORES=$(nproc)
echo "Using $CORES cores for compilation"

# Build with verbose output for debugging
make -j$((CORES + 1)) V=s || {
    echo -e "${RED}Build failed! Check the output above for errors.${NC}"
    exit 1
}

# Build results
echo -e "${GREEN}Build completed successfully!${NC}"
echo ""
echo "Firmware images are located in:"
echo "  $(pwd)/bin/targets/${TARGET}/${SUBTARGET}/"
echo ""
ls -lh "bin/targets/${TARGET}/${SUBTARGET}/"*sysupgrade.bin 2>/dev/null || echo "No sysupgrade images found"
ls -lh "bin/targets/${TARGET}/${SUBTARGET}/"*factory.bin 2>/dev/null || echo "No factory images found"

echo ""
echo -e "${GREEN}Build process finished!${NC}"

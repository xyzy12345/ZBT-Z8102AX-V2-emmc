# ImmortalWrt Patches

This directory contains patches specific to ImmortalWrt for the ZBT Z8102AX-V2 eMMC version.

## Usage

Patches in this directory will be automatically applied during the build process by the `build-immortalwrt.sh` script.

## Adding Patches

1. Create your patch file:
   ```bash
   cd immortalwrt-build
   # Make your changes
   git diff > ../patches/immortalwrt/001-your-description.patch
   ```

2. Name patches with a numeric prefix for ordering:
   - `001-first-patch.patch`
   - `002-second-patch.patch`
   - etc.

## Current Patches

Currently, no patches are required for basic functionality. This directory is provided for future customizations.

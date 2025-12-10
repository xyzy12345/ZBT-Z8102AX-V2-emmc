# ZBT Z8102AX-V2 eMMC 版本

为 ZBT Z8102AX-V2 eMMC 改装版编译 OpenWrt、ImmortalWrt 固件

## 简介

本仓库提供了为 ZBT Z8102AX-V2 eMMC 改装版路由器构建自定义固件的完整工具链和配置文件。支持编译官方 OpenWrt 和国内优化的 ImmortalWrt 固件。

## 快速开始

### 编译 OpenWrt

```bash
git clone https://github.com/xyzy12345/ZBT-Z8102AX-V2-emmc.git
cd ZBT-Z8102AX-V2-emmc
chmod +x build-openwrt.sh
./build-openwrt.sh
```

### 编译 ImmortalWrt

```bash
chmod +x build-immortalwrt.sh
./build-immortalwrt.sh
```

## 硬件规格

- **SoC**: MediaTek MT7981B (Filogic 820)
- **内存**: 1GB DDR4
- **存储**: eMMC（改装版）
- **WiFi**: MT7976CN (WiFi 6)
- **网口**: 1x 2.5G WAN + 4x 1G LAN
- **USB**: 2x USB 3.0 (M.2) + 1x USB 3.0 外置

## 文档

详细的编译和刷机指南请参阅：

- [中文构建指南](./BUILD.md) - 完整的中文文档
- [English Build Guide](./BUILD_EN.md) - Complete English documentation

## 目录结构

```
├── build-openwrt.sh          # OpenWrt 编译脚本
├── build-immortalwrt.sh      # ImmortalWrt 编译脚本
├── configs/                  # 配置文件目录
│   ├── openwrt.config
│   └── immortalwrt.config
├── dts/                      # 设备树文件
│   └── mt7981b-zbtlink-zbt-z8102ax-v2-emmc.dts
└── patches/                  # 补丁文件
    ├── openwrt/
    └── immortalwrt/
```

## 特性

### OpenWrt 版本
- 官方 OpenWrt 最新稳定版
- LuCI 网页管理界面
- IPv6 支持
- 完整的包管理系统

### ImmortalWrt 版本
- 基于 OpenWrt，国内优化
- Argon 主题
- 中文语言包
- 预装常用插件（SSR+, PassWall 等）

## 许可证

GPL-2.0

## 相关链接

- [OpenWrt 官网](https://openwrt.org/)
- [ImmortalWrt 官网](https://immortalwrt.org/)
- [ZBT 官网](https://www.zbtwifi.com/)

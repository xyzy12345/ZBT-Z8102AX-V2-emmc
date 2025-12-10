# ZBT Z8102AX-V2 eMMC 版本编译指南

[English Version](./BUILD_EN.md)

本仓库提供了为 ZBT Z8102AX-V2 eMMC 改装版编译 OpenWrt 和 ImmortalWrt 固件的完整解决方案。

## 目录

- [硬件规格](#硬件规格)
- [系统要求](#系统要求)
- [快速开始](#快速开始)
- [详细说明](#详细说明)
- [刷机指南](#刷机指南)
- [故障排除](#故障排除)

## 硬件规格

- **SoC**: MediaTek MT7981B (Filogic 820)
- **内存**: 1GB DDR4
- **存储**: eMMC（改装版，原版为 SPI-NAND）
- **WiFi**: MT7976CN (WiFi 6, 2.4GHz + 5GHz)
- **以太网**: 1x 2.5G WAN + 4x 1G LAN
- **USB**: 2x USB 3.0 (M.2 插槽) + 1x USB 3.0 外置
- **按钮**: Reset, Mesh
- **LED**: 状态、WAN、LAN、4G、5G

## 系统要求

### Ubuntu/Debian 系统依赖

```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential clang flex bison g++ gawk \
    gcc-multilib g++-multilib gettext git \
    libncurses5-dev libssl-dev python3-setuptools rsync \
    swig unzip zlib1g-dev file wget
```

### 硬件要求

- **磁盘空间**: 至少 30GB 可用空间
- **内存**: 至少 4GB RAM（推荐 8GB）
- **处理器**: 多核 CPU（编译时间与核心数成反比）

## 快速开始

### 编译 OpenWrt

```bash
# 克隆本仓库
git clone https://github.com/xyzy12345/ZBT-Z8102AX-V2-emmc.git
cd ZBT-Z8102AX-V2-emmc

# 运行 OpenWrt 编译脚本
chmod +x build-openwrt.sh
./build-openwrt.sh
```

### 编译 ImmortalWrt

```bash
# 运行 ImmortalWrt 编译脚本
chmod +x build-immortalwrt.sh
./build-immortalwrt.sh
```

编译完成后，固件镜像将位于：
- OpenWrt: `openwrt-build/bin/targets/mediatek/filogic/`
- ImmortalWrt: `immortalwrt-build/bin/targets/mediatek/filogic/`

## 详细说明

### 目录结构

```
.
├── build-openwrt.sh           # OpenWrt 自动编译脚本
├── build-immortalwrt.sh       # ImmortalWrt 自动编译脚本
├── configs/                   # 编译配置文件
│   ├── openwrt.config        # OpenWrt 配置
│   └── immortalwrt.config    # ImmortalWrt 配置
├── dts/                       # 设备树源文件
│   └── mt7981b-zbtlink-zbt-z8102ax-v2-emmc.dts
├── patches/                   # 补丁文件
│   ├── openwrt/              # OpenWrt 专用补丁
│   └── immortalwrt/          # ImmortalWrt 专用补丁
└── README.md                  # 本文件
```

### 自定义配置

#### 修改编译配置

1. 编辑配置文件：
   ```bash
   # 对于 OpenWrt
   nano configs/openwrt.config
   
   # 对于 ImmortalWrt
   nano configs/immortalwrt.config
   ```

2. 或者使用交互式配置：
   ```bash
   cd openwrt-build  # 或 immortalwrt-build
   make menuconfig
   # 配置完成后保存
   cp .config ../configs/openwrt.config  # 或 immortalwrt.config
   ```

#### 添加自定义软件包

在配置文件中添加所需软件包：
```
CONFIG_PACKAGE_your-package-name=y
```

### 设备树说明

`dts/mt7981b-zbtlink-zbt-z8102ax-v2-emmc.dts` 文件定义了 eMMC 版本的硬件配置：

- **eMMC 配置**: 支持 HS400 模式，8-bit 总线宽度
- **分区布局**:
  - bl2: 1MB (引导加载器)
  - u-boot-env: 512KB (U-Boot 环境变量)
  - factory: 2MB (出厂数据，包含 WiFi 校准数据)
  - fip: 2MB (固件镜像包)
  - ubi: ~122MB (根文件系统和用户数据)

## 刷机指南

### 方式一：通过 U-Boot (推荐首次刷机)

1. 连接串口（115200 8N1）
2. 重启设备并在 U-Boot 启动时按任意键进入
3. 设置网络：
   ```
   setenv ipaddr 192.168.1.1
   setenv serverip 192.168.1.100
   ```
4. 通过 TFTP 下载固件：
   ```
   tftpboot 0x46000000 openwrt-mediatek-filogic-zbtlink_zbt-z8102ax-v2-emmc-squashfs-sysupgrade.bin
   ```
5. 写入 eMMC：
   ```
   mmc dev 0
   mmc write 0x46000000 0x580000 0x7a80000
   ```
6. 重启：
   ```
   reset
   ```

### 方式二：通过 Web 界面升级

1. 访问路由器管理界面（通常是 `192.168.1.1`）
2. 进入"系统" → "备份/升级固件"
3. 选择 sysupgrade.bin 文件
4. 上传并等待刷机完成

### 方式三：通过命令行升级

1. 将固件文件复制到路由器：
   ```bash
   scp openwrt-*.bin root@192.168.1.1:/tmp/
   ```
2. SSH 登录路由器并执行：
   ```bash
   sysupgrade -v /tmp/openwrt-*.bin
   ```

## 功能特性

### OpenWrt 版本特性

- ✅ 基础 LuCI 网页管理界面
- ✅ IPv4/IPv6 双栈支持
- ✅ WiFi 6 支持 (MT7976CN)
- ✅ 2.5G WAN 端口
- ✅ USB 3.0 支持
- ✅ 4G/5G 调制解调器支持
- ✅ eMMC 存储优化

### ImmortalWrt 版本特性

在 OpenWrt 基础上额外包含：

- ✅ Argon 主题
- ✅ 中文语言包
- ✅ SSR Plus+ 插件
- ✅ PassWall 插件
- ✅ MosDNS 插件
- ✅ Turbo ACC 加速

## 故障排除

### 编译失败

1. **依赖问题**：
   ```bash
   # 重新安装所有依赖
   sudo apt-get update
   sudo apt-get install -y build-essential clang flex bison g++ gawk ...
   ```

2. **磁盘空间不足**：
   ```bash
   # 清理编译缓存
   cd openwrt-build  # 或 immortalwrt-build
   make clean
   ```

3. **网络问题**：
   - 某些源可能需要代理访问
   - 编辑 `~/.gitconfig` 添加代理配置

### 设备无法启动

1. **检查串口输出**：连接串口查看启动日志
2. **恢复出厂固件**：使用原厂提供的恢复工具
3. **重刷 U-Boot**：可能需要专业工具（如 JTAG）

### WiFi 无法工作

1. 确保 factory 分区包含正确的校准数据
2. 检查 WiFi 驱动是否正确加载：
   ```bash
   dmesg | grep mt76
   ```

### 5G 调制解调器无法识别

1. 检查 USB 设备：
   ```bash
   lsusb
   ```
2. 安装相应的驱动和工具：
   ```bash
   opkg update
   opkg install kmod-usb-net-qmi-wwan uqmi
   ```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目中的脚本和配置文件采用 GPL-2.0 许可证。

OpenWrt 和 ImmortalWrt 项目拥有各自的许可证，详见各自官方网站。

## 相关链接

- [OpenWrt 官方网站](https://openwrt.org/)
- [ImmortalWrt 官方网站](https://immortalwrt.org/)
- [OpenWrt 论坛](https://forum.openwrt.org/)
- [ZBT 官方网站](https://www.zbtwifi.com/)

## 致谢

感谢 OpenWrt 和 ImmortalWrt 社区的贡献！

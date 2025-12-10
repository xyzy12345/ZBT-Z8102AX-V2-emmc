#!/bin/sh
# ZBT Z8102AX-eMMC升级脚本

RAMFS_COPY_BIN='blkid blockdev fw_printenv fw_setenv mkfs.ext4'
RAMFS_COPY_DATA="/etc/fw_env.config /var/lock/fw_printenv.lock"

platform_do_upgrade() {
	local board=$(board_name)
	local diskdev partdev
    
	echo "设备检测: $board"
	
	case "$board" in
	zbt,z8102ax-emmc)
		# 对于EMMC设备，使用MTK MMC升级方法
		if [ -x /sbin/mtk_mmc_do_upgrade ]; then
			echo "使用mtk_mmc_do_upgrade升级EMMC..."
			mtk_mmc_do_upgrade "$1"
		else
			echo "使用generic_mmc_do_upgrade升级EMMC..."
			generic_mmc_do_upgrade "$1"
		fi
		;;
	*)
		echo "未知设备，使用默认升级方法"
		default_do_upgrade "$1"
		;;
	esac
}

PART_NAME=firmware

platform_check_image() {
	local board=$(board_name)
	local magic="$(get_magic_long "$1")"
	local tar_magic
	
	[ "$#" -gt 1 ] && return 1
	
	echo "检查固件兼容性..."
	
	case "$board" in
	zbt,z8102ax-emmc)
		# 检查是否为sysupgrade.tar格式
		tar_magic="$(dd if="$1" bs=1 skip=257 count=5 2>/dev/null)"
		
		if [ "$tar_magic" = "ustar" ]; then
			echo "✓ 检测到sysupgrade.tar格式固件"
			return 0
		fi
		
		# 检查是否为bin格式
		if [ "$magic" = "d00dfeed" ]; then
			echo "✓ 检测到bin格式固件"
			return 0
		fi
		
		echo "❌ 错误：不支持的固件格式"
		echo "期望: ustar (sysupgrade) 或 d00dfeed (bin)"
		echo "实际: tar_magic=$tar_magic, magic=$magic"
		return 1
		;;
	*)
		[ "$magic" != "d00dfeed" ] && {
			echo "❌ 错误：无效的固件格式"
			return 1
		}
		return 0
		;;
	esac
}

platform_copy_config() {
	local board=$(board_name)
	
	case "$board" in
	zbt,z8102ax-emmc)
		# 保存配置到持久存储
		if type mmc_copy_config >/dev/null 2>&1; then
			echo "保存配置到EMMC..."
			mmc_copy_config
		fi
		;;
	esac
}

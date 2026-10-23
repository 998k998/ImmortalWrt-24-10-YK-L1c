#!/bin/bash
#=================================================
# diy-part2.sh - 编译前执行
# 作用：调整 .config，添加 USB 打印 + Samba，精简不必要的包
#=================================================

# 默认 IP 改为 192.168.5.1（可选，看你需求）
# sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# ========== 1. 删除不需要的包，省空间 ==========
# 删 PPPoE（如果你需要拨号就注释掉这行）
sed -i 's/^CONFIG_PACKAGE_ppp=y/# CONFIG_PACKAGE_ppp is not set/' .config
sed -i 's/^CONFIG_PACKAGE_ppp-mod-pppoe=y/# CONFIG_PACKAGE_ppp-mod-pppoe is not set/' .config

# 删 wpad-mbedtls / wpad-openssl，换成 wpad-mini
sed -i 's/^CONFIG_PACKAGE_wpad-mbedtls=y/# CONFIG_PACKAGE_wpad-mbedtls is not set/' .config
sed -i 's/^CONFIG_PACKAGE_wpad-openssl=y/# CONFIG_PACKAGE_wpad-openssl is not set/' .config
sed -i 's/^CONFIG_PACKAGE_wpad-basic-mbedtls=y/# CONFIG_PACKAGE_wpad-basic-mbedtls is not set/' .config

# 删不需要的 LuCI 应用
sed -i 's/^CONFIG_PACKAGE_luci-app-opkg=y/# CONFIG_PACKAGE_luci-app-opkg is not set/' .config
sed -i 's/^CONFIG_PACKAGE_luci-app-upnp=y/# CONFIG_PACKAGE_luci-app-upnp is not set/' .config

# ========== 2. 添加你需要的功能包 ==========
# USB 存储相关
echo 'CONFIG_PACKAGE_kmod-usb-core=y' >> .config
echo 'CONFIG_PACKAGE_kmod-usb-ohci=y' >> .config
echo 'CONFIG_PACKAGE_kmod-usb2=y' >> .config
echo 'CONFIG_PACKAGE_kmod-usb-storage=y' >> .config
echo 'CONFIG_PACKAGE_kmod-scsi-core=y' >> .config
echo 'CONFIG_PACKAGE_kmod-usb-storage-uas=y' >> .config

# 文件系统
echo 'CONFIG_PACKAGE_kmod-fs-vfat=y' >> .config
echo 'CONFIG_PACKAGE_kmod-fs-ext4=y' >> .config
echo 'CONFIG_PACKAGE_kmod-fs-ntfs3=y' >> .config
echo 'CONFIG_PACKAGE_kmod-nls-cp437=y' >> .config
echo 'CONFIG_PACKAGE_kmod-nls-iso8859-1=y' >> .config
echo 'CONFIG_PACKAGE_kmod-nls-utf8=y' >> .config

# USB 打印服务
echo 'CONFIG_PACKAGE_kmod-usb-printer=y' >> .config
echo 'CONFIG_PACKAGE_p910nd=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-p910nd=y' >> .config

# Samba4 USB 共享
echo 'CONFIG_PACKAGE_luci-app-samba4=y' >> .config

# 工具
echo 'CONFIG_PACKAGE_block-mount=y' >> .config
echo 'CONFIG_PACKAGE_usbutils=y' >> .config
echo 'CONFIG_PACKAGE_blkid=y' >> .config

# wpad-mini（轻量 WiFi）
echo 'CONFIG_PACKAGE_wpad-mini=y' >> .config

# ========== 3. 固件大小设置 ==========
# YK-L1c 16M，firmware 分区 7.75MB，设置 Image 大小
echo 'CONFIG_TARGET_KERNEL_PARTSIZE=2' >> .config
echo 'CONFIG_TARGET_ROOTFS_PARTSIZE=5' >> .config

# ========== 4. 刷新配置 ==========
make defconfig

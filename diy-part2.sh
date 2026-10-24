#!/bin/bash
# diy-part2.sh - 编译前配置

# 基础包已经在.config里，这里只做精简和确认

# 确认删除samba4（如果之前误加了）
sed -i 's/^CONFIG_PACKAGE_luci-app-samba4=y/# CONFIG_PACKAGE_luci-app-samba4 is not set/' .config

# 确认USB打印包
echo 'CONFIG_PACKAGE_kmod-usb-printer=y' >> .config
echo 'CONFIG_PACKAGE_p910nd=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-p910nd=y' >> .config

# 确认USB存储包
echo 'CONFIG_PACKAGE_kmod-usb-storage=y' >> .config
echo 'CONFIG_PACKAGE_kmod-scsi-core=y' >> .config
echo 'CONFIG_PACKAGE_kmod-fs-vfat=y' >> .config
echo 'CONFIG_PACKAGE_kmod-fs-ext4=y' >> .config
echo 'CONFIG_PACKAGE_kmod-nls-cp437=y' >> .config
echo 'CONFIG_PACKAGE_kmod-nls-iso8859-1=y' >> .config
echo 'CONFIG_PACKAGE_kmod-nls-utf8=y' >> .config

# 工具
echo 'CONFIG_PACKAGE_usbutils=y' >> .config
echo 'CONFIG_PACKAGE_blkid=y' >> .config

# 刷新配置
make defconfig

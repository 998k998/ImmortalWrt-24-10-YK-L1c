#!/bin/bash
#=================================================
# diy-part1.sh - 更新 feeds 之前执行
# 作用：修改 YK-L1c DTS 适配 16M Flash
#=================================================

# 修改 youku_yk-l1c 的 DTS，适配 16M Flash
DTS_FILE="target/linux/ramips/dts/youku_yk-l1c.dts"

if [ -f "$DTS_FILE" ]; then
    echo "===== 修改 YK-L1c DTS 适配 16M Flash ====="
    
    # 备份原文件
    cp "$DTS_FILE" "${DTS_FILE}.bak"
    
    # 用 sed 替换 flash 节点的 reg 和分区
    # 16M Flash: 0x1000000
    # 分区布局：
    #   uboot:     0x000000 - 0x030000  (192KB)
    #   uboot-env: 0x030000 - 0x040000  (64KB)
    #   firmware:  0x040000 - 0x7F0000 (7.75MB)
    #   art:       0x7F0000 - 0x800000  (64KB, 只读)
    #   overlay:   0x800000 - 0x1000000 (8MB, 新增)
    
    cat > "$DTS_FILE" << 'DTS_EOF'
/dts-v1/;

#include "mt7620a.dtsi"

#include <dt-bindings/gpio/gpio.h>
#include <dt-bindings/input/input.h>

/ {
	compatible = "youku,yk-l1c", "mediatek,mt7620a";

	chosen {
		bootargs = "console=ttyS0,115200";
	};

	memory@0 {
		device_type = "memory";
		reg = <0x0 0x8000000>;
	};

	gpio-keys-polled {
		compatible = "gpio-keys-polled";
		#address-cells = <1>;
		#size-cells = <0>;
		poll-interval = <20>;
		reset {
			label = "reset";
			gpios = <&gpio0 1 GPIO_ACTIVE_LOW>;
			linux,code = <KEY_RESTART>;
		};
	};
};

&spi0 {
	status = "okay";

	flash@0 {
		compatible = "jedec,spi-nor";
		reg = <0>;
		spi-max-frequency = <10000000>;

		m25p,fast-read;

		partitions {
			compatible = "fixed-partitions";
			#address-cells = <1>;
			#size-cells = <1>;

			partition@0 {
				label = "u-boot";
				reg = <0x0 0x30000>;
				read-only;
			};

			partition@30000 {
				label = "u-boot-env";
				reg = <0x30000 0x10000>;
				read-only;
			};

			factory: partition@40000 {
				label = "factory";
				reg = <0x40000 0x10000>;
				read-only;
			};

			partition@50000 {
				label = "cfe";
				reg = <0x50000 0x10000>;
				read-only;
			};

			partition@60000 {
				label = "firmware";
				compatible = "denx,uimage";
				reg = <0x60000 0x790000>;
			};

			partition@7f0000 {
				label = "art";
				reg = <0x7f0000 0x10000>;
				read-only;
			};

			partition@800000 {
				label = "overlay";
				reg = <0x800000 0x800000>;
			};
		};
	};
};

&ehci {
	status = "okay";
};

&ohci {
	status = "okay";
};

&wmac {
	status = "okay";
	ralink,mtd-eeprom = <&art 0x0>;
};
DTS_EOF
    
    echo "DTS 修改完成"
else
    echo "警告：找不到 $DTS_FILE"
fi

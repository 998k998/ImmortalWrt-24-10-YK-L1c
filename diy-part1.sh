#!/bin/bash
#=================================================
# diy-part1.sh - ImmortalWrt 24.10 YK-L1c 16M硬改 DTS补丁
# 注意：ImmortalWrt 设备dts名字是 youku_yk_l1c.dts
#=================================================

DTS_FILE="target/linux/ramips/dts/youku_yk_l1c.dts"

if [ -f "$DTS_FILE" ]; then
    echo "===== 找到DTS文件，开始修改 YK-L1c 适配16M Flash ====="
    cp "$DTS_FILE" "${DTS_FILE}.bak"

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

    echo "✅ DTS 修改完成 youku_yk_l1c.dts"
else
    echo "❌ 错误：$DTS_FILE 不存在！"
    ls target/linux/ramips/dts/ | grep yk
    exit 1
fi

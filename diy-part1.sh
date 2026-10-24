#!/bin/bash
#=================================================
# diy-part1.sh - ImmortalWrt 24.10 YK-L1c 16M硬改
# 关键点：保留 art: phandle标签，给wmac引用，不重复节点
# DTS：target/linux/ramips/dts/mt7620a_youku_yk-l1c.dts
#=================================================

DTS_FILE="target/linux/ramips/dts/mt7620a_youku_yk-l1c.dts"

if [ -f "$DTS_FILE" ]; then
    echo "===== 找到DTS文件，修改分区适配16M Flash ====="
    cp "$DTS_FILE" "${DTS_FILE}.bak"

    sed -i '/flash@0 {/,/};/c\
	flash@0 {\
		compatible = "jedec,spi-nor";\
		reg = <0>;\
		spi-max-frequency = <10000000>;\
		m25p,fast-read;\
\
		partitions {\
			compatible = "fixed-partitions";\
			#address-cells = <1>;\
			#size-cells = <1>;\
\
			partition@0 {\
				label = "u-boot";\
				reg = <0x0 0x30000>;\
				read-only;\
			};\
\
			partition@30000 {\
				label = "u-boot-env";\
				reg = <0x30000 0x10000>;\
			};\
\
			art: partition@40000 {\
				label = "art";\
				reg = <0x40000 0x10000>;\
				read-only;\
			};\
\
			partition@50000 {\
				label = "cfe";\
				reg = <0x50000 0x10000>;\
				read-only;\
			};\
\
			partition@60000 {\
				label = "firmware";\
				compatible = "denx,uimage";\
				reg = <0x60000 0x790000>;\
			};\
\
			partition@7f0000 {\
				label = "art_backup";\
				reg = <0x7f0000 0x10000>;\
				read-only;\
			};\
\
			partition@800000 {\
				label = "overlay";\
				reg = <0x800000 0x800000>;\
			};\
		};\
	};' "$DTS_FILE"

    echo "✅ DTS分区修改完成，art标签保留"
else
    echo "❌ 错误：$DTS_FILE 不存在！"
    ls target/linux/ramips/dts/ | grep yk
    exit 1
fi

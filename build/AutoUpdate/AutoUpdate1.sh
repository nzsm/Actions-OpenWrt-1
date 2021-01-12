#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoBuild Actions

GET_TARGET_INFO() {
Author=danshui
AutoUpdate_Version=$(awk 'NR==6' package/base-files/files/bin/AutoUpdate.sh | awk -F '[="]+' '/Version/{print $2}')
TARGET_PROFILE=$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/')
TARGET_BOARD=$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' .config)
TARGET_SUBTARGET=$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' .config)
if [ $TARGET_BOARD-64 == x86-64 ];then
Openwrt_Device="$TARGET_BOARD-$TARGET_SUBTARGET"
else  
Openwrt_Device="$TARGET_PROFILE"
fi
Compile_Date=$(date +%Y%m%d-%H%M)
Openwrt_Version="$Compile_Date"
}

AutoUpdate1() {
GET_TARGET_INFO
echo "Author: $Author"
echo "Openwrt Version: $Openwrt_Version"
echo "AutoUpdate Version: $AutoUpdate_Version"
echo "Router: $Openwrt_Device"
echo "$Openwrt_Version" > package/base-files/files/etc/openwrt_info
echo "$Openwrt_Device" > package/base-files/files/etc/openwrt_device
}

AutoUpdate2() {
GET_TARGET_INFO
Device=$TARGET_BOARD-$TARGET_SUBTARGET
case "$Device" in
    "bcm53xx-generic")
    Default_Firmware=openwrt-$TARGET_BOARD-$TARGET_PROFILE-squashfs.trx
    AutoBuild_Firmware=openwrt-$TARGET_PROFILE-${Openwrt_Version}.trx
    ;;
    "ramips-mt7621")
    Default_Firmware=openwrt-$TARGET_BOARD-$TARGET_SUBTARGET-$TARGET_PROFILE-squashfs-sysupgrade.bin
    AutoBuild_Firmware=openwrt-$TARGET_PROFILE-${Openwrt_Version}.bin
    ;;
    "x86-64")
    Default_Firmware=openwrt-$TARGET_BOARD-$TARGET_PROFILE-combined.img.gz
    AutoBuild_Firmware=openwrt-$TARGET_BOARD-$TARGET_PROFILE-${Openwrt_Version}.img.gz
    ;;
esac

AutoBuild_Detail=openwrt-$TARGET_PROFILE-${Openwrt_Version}.detail
mv bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$Default_Firmware bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$AutoBuild_Firmware
echo "Firmware: $AutoBuild_Firmware"
echo "[$(date "+%H:%M:%S")] Calculating MD5 and SHA256 ..."
Firmware_MD5=$(md5sum bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$AutoBuild_Firmware | cut -d ' ' -f1)
Firmware_SHA256=$(sha256sum bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$AutoBuild_Firmware | cut -d ' ' -f1)
echo -e "MD5: $Firmware_MD5\nSHA256: $Firmware_SHA256"
touch bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$AutoBuild_Detail
echo -e "\nMD5:$Firmware_MD5\nSHA256:$Firmware_SHA256" >> bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$AutoBuild_Detail
}

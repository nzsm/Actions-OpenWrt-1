#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001

[ -f /tmp/cloud_version ] && rm -f /tmp/cloud_version
if [ ! -f /bin/AutoUpdate.sh ];then
	echo "不受支持的固件" > /tmp/cloud_version
	exit
fi
Github=`awk -F '[=]' '/Github/{print $2}' /bin/AutoUpdate.sh | awk 'NR==1'`
[[ -z "$Github" ]] && exit
Author=${Github##*com/}
CURRENT_Version=$(awk 'NR==1' /etc/openwrt_info)
CURRENT_DEVICE=$(awk 'NR==1' /etc/openwrt_device)
Github_Tags=https://api.github.com/repos/$Author/releases/latest
wget -q ${Github_Tags} -O - > /tmp/Github_Tags
if [[ $CURRENT_DEVICE-1 == x86-64-1 ]];then
GET_FullVersion=$(cat /tmp/Github_Tags | egrep -o "openwrt-$CURRENT_DEVICE-[0-9]+.[0-9]+.[0-9]+.[0-9]+.[a-z]+.[a-z]+" | awk 'END {print}')
GET_Version="${GET_FullVersion:0-21:14}"
else
GET_FullVersion=$(cat /tmp/Github_Tags | egrep -o "openwrt-$CURRENT_DEVICE-[0-9]+.[0-9]+.[0-9]+.[0-9]+.[a-z]+.[a-z]+" | awk 'END {print}')
GET_Version="${GET_FullVersion:0-17:13}"
fi

if [[ -z "$GET_Version" ]];then
	echo "未知" > /tmp/cloud_version
	exit
else
	if [[ "$CURRENT_Version" == "$GET_Version" ]];then
		echo "$GET_Version [最新]" > /tmp/cloud_version
	else
		echo "$GET_Version [可更新]" > /tmp/cloud_version
	fi
fi
exit

#!/bin/bash
#
# Modify default IP
sed -i 's/192.168.1.1/10.10.10.2/g' package/base-files/files/bin/config_generate
sed -i "s/ImmortalWrt/OpenWrt/g" package/base-files/files/bin/config_generate

echo -e "\n开始修改netdata配置，添加12.12.*网段访问权限..."

# 定义netdata配置文件路径（ImmortalWrt中netdata的默认配置模板路径）
NETDATA_CONF_PATH="./package/feeds/packages/netdata/files/etc/netdata/netdata.conf"

# 1. 检查配置文件是否存在，避免报错
if [ -f "$NETDATA_CONF_PATH" ]; then
    # 2. 给allow connections from行添加12.12.*（如果还没添加）
    sed -i '/allow connections from =/ {
        /12.12.\*/! s/$/ 12.12.\*/
    }' "$NETDATA_CONF_PATH"

    # 3. 给allow dashboard from行添加12.12.*（如果还没添加）
    sed -i '/allow dashboard from =/ {
        /12.12.\*/! s/$/ 12.12.\*/
    }' "$NETDATA_CONF_PATH"

    echo -e "✅ netdata配置修改完成，已添加12.12.*网段到访问白名单！"
    # 可选：打印修改后的配置，验证是否生效
    # cat "$NETDATA_CONF_PATH" | grep -E "allow connections from|allow dashboard from"
else
    echo -e "⚠️ 未找到netdata配置文件，跳过修改（可能netdata包未安装）"
fi

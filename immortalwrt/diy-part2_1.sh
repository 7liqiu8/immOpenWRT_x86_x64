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

# ======================================
# 新增：替换Netdata Web文件为汉化版
# ======================================
echo -e "\n开始集成Netdata汉化补丁到源码..."
# Netdata Web文件的目标路径（ImmortalWRT 23.05标准路径）
NETDATA_WEB_PATH="./package/feeds/packages/netdata/files/usr/share/netdata/web"
# 创建目标目录（防止不存在）
mkdir -p $NETDATA_WEB_PATH

# 备份原始文件（可选，方便回滚）
cp -f $NETDATA_WEB_PATH/dashboard.js $NETDATA_WEB_PATH/dashboard.js.bak 2>/dev/null || true
cp -f $NETDATA_WEB_PATH/dashboard_info.js $NETDATA_WEB_PATH/dashboard_info.js.bak 2>/dev/null || true
cp -f $NETDATA_WEB_PATH/main.js $NETDATA_WEB_PATH/main.js.bak 2>/dev/null || true
cp -f $NETDATA_WEB_PATH/index.html $NETDATA_WEB_PATH/index.html.bak 2>/dev/null || true

# 复制汉化补丁到目标路径（覆盖原文件）
cp -f ./tmp/netdata-chinese/* $NETDATA_WEB_PATH/

# 检查替换是否成功
if [ -f "$NETDATA_WEB_PATH/dashboard.js" ]; then
  echo -e "✅ Netdata汉化补丁替换完成！"
else
  echo -e "❌ Netdata汉化补丁替换失败，终止编译！"
  exit 1
fi

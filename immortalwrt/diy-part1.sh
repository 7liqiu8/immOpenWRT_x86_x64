#!/bin/bash

# Merge_package
function merge_package(){
    repo=`echo $1 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $2 | rev | cut -d'/' -f 1 | rev`
    # find package/ -follow -name $pkg -not -path "package/openwrt-packages/*" | xargs -rt rm -rf
    git clone --depth=1 --single-branch $1
    [ -d package/openwrt-packages ] || mkdir -p package/openwrt-packages
    mv $2 package/openwrt-packages/
    rm -rf $repo
}

rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config

# Clone community packages to package/community
mkdir package/community
pushd package/community
git clone --depth=1 https://github.com/fw876/helloworld
# git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2
git clone --depth=1 https://github.com/nikkinikki-org/OpenWrt-nikki
git clone --depth=1 https://github.com/DHDAXCW/dhdaxcw-app
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config
git clone --depth=1 https://github.com/DHDAXCW/istore
git clone --depth=1 https://github.com/Siriling/5G-Modem-Support && rm -rf 5G-Modem-Support/rooter
git clone --depth=1 https://github.com/gdy666/luci-app-lucky
popd

# add luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# ======================================
# 新增：Netdata汉化补丁下载 + 强制启用Netdata包
# ======================================
echo -e "\n开始下载Netdata社区汉化补丁..."
# 创建临时目录存放汉化补丁（openwrt目录下的tmp，避免路径混乱）
mkdir -p tmp/netdata-chinese
cd tmp/netdata-chinese

# 下载核心汉化文件（兼容wget/curl，增加容错）
DOWNLOAD_FILES=(
  "dashboard.js"
  "dashboard_info.js"
  "main.js"
  "index.html"
)
for file in "${DOWNLOAD_FILES[@]}"; do
  # 优先wget，失败则用curl；国内可替换为Gitee镜像：https://gitee.com/mirrors/Netdata-chinese-patch/raw/main/$file
  wget --no-check-certificate -qO $file "https://raw.githubusercontent.com/DX-Kevin/Netdata-chinese-patch/main/$file" || \
  curl --insecure -sSLo $file "https://raw.githubusercontent.com/DX-Kevin/Netdata-chinese-patch/main/$file"
  
  # 检查文件下载是否成功，失败则终止编译（避免无汉化的固件）
  if [ ! -f "$file" ]; then
    echo -e "❌ 汉化文件 $file 下载失败，终止编译！"
    exit 1
  fi
done
echo -e "✅ Netdata汉化补丁下载完成！"

# 回到openwrt根目录，强制启用Netdata编译选项（避免config漏选）
cd ../..
if ! grep -q "CONFIG_PACKAGE_netdata=y" .config; then
  echo "CONFIG_PACKAGE_netdata=y" >> .config
  echo -e "✅ 已自动启用Netdata编译选项！"
fi

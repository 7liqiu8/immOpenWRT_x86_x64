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
# git clone --depth=1 https://github.com/fw876/helloworld
# git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2
# git clone --depth=1 https://github.com/nikkinikki-org/OpenWrt-nikki
git clone --depth=1 https://github.com/DHDAXCW/dhdaxcw-app
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config
git clone --depth=1 https://github.com/DHDAXCW/istore
# git clone --depth=1 https://github.com/Siriling/5G-Modem-Support && rm -rf 5G-Modem-Support/rooter
git clone --depth=1 https://github.com/gdy666/luci-app-lucky
# git clone --depth=1 https://github.com/sbwml/luci-app-openlist2
popd

# add luci-app-mosdns
# rm -rf feeds/packages/net/v2ray-geodata
# git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
# git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone --depth=1 https://github.com/7liqiu8/mwan3nft package/mwan3nft


grep "download-ci-llvm" "$RUST_MAKEFILE" || echo "Pattern not found, but will attempt replacement anyway."

RUST_MAKEFILE="feeds/packages/lang/rust/Makefile"
if [ -f "$RUST_MAKEFILE" ]; then
    echo "Modifying Rust Makefile to disable download-ci-llvm for ImmortalWrt 24.10..."
    # 方案1: 修改 --set llvm.download-ci-llvm=true 为 false
    sed -i 's/--set llvm.download-ci-llvm=true/--set llvm.download-ci-llvm=false/' "$RUST_MAKEFILE"
    # 方案2: 修改 --set=llvm.download-ci-llvm=true 为 false (论坛讨论中提到的格式[citation:2])
    sed -i 's/--set=llvm.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' "$RUST_MAKEFILE"
else
    echo "Warning: Rust Makefile not found at $RUST_MAKEFILE"
fi

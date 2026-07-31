#!/usr/bin/env bash
set -ex

# QQ Linux 下载地址（x86_64/amd64 deb 包）
QQ_DEB_URL="https://qqdl.gtimg.cn/qqfile/QQNT/9.9.32/release/c390e792/QQ_3.2.31_260710_amd64_01.deb"

echo "Downloading QQ from: ${QQ_DEB_URL}"

# 下载并安装 QQ
mkdir -p /tmp/qq
cd /tmp/qq
curl -L "${QQ_DEB_URL}" -o qq.deb

# 安装（自动处理依赖）
apt-get update
apt-get install -y ./qq.deb || {
    echo "Trying to fix dependencies..."
    apt-get install -f -y
    apt-get install -y ./qq.deb
}

# 清理
rm -rf /tmp/qq

# 创建桌面快捷方式（若未提供）
if [ ! -f /usr/share/applications/qq.desktop ]; then
    cat > /usr/share/applications/qq.desktop << 'EOF'
[Desktop Entry]
Name=QQ
Comment=QQ Linux Client
Exec=/opt/QQ/qq --no-sandbox %U
Icon=qq
Type=Application
Categories=Network;InstantMessaging;
MimeType=x-scheme-handler/qq;x-scheme-handler/tencent;
StartupWMClass=QQ
EOF
fi

# 命令行访问软链
ln -sf /opt/QQ/qq /usr/local/bin/qq || true

echo "QQ installation completed successfully!"

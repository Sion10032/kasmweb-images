#!/usr/bin/env bash
set -ex
# 微信 Linux 下载地址（x86_64/amd64 deb 包）
WECHAT_DEB_URL="https://web.archive.org/web/20260505055009if_/https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb"

echo "Downloading WeChat from: ${WECHAT_DEB_URL}"

# 下载并安装微信
mkdir -p /tmp/wechat
cd /tmp/wechat
curl -L "${WECHAT_DEB_URL}" -o wechat.deb

# 安装（自动处理依赖）
apt-get update
apt-get install -y ./wechat.deb || {
    echo "Trying to fix dependencies..."
    apt-get install -f -y
    apt-get install -y ./wechat.deb
}

# 清理
rm -rf /tmp/wechat

# 创建桌面快捷方式（若未提供）
if [ ! -f /usr/share/applications/wechat.desktop ]; then
    cat > /usr/share/applications/wechat.desktop << 'EOF'
[Desktop Entry]
Name=WeChat
Comment=WeChat Linux Client
Exec=/opt/wechat/wechat --no-sandbox %U
Icon=wechat
Type=Application
Categories=Network;InstantMessaging;
MimeType=x-scheme-handler/weixin;
StartupWMClass=wechat
EOF
fi

# 命令行访问软链
ln -sf /opt/wechat/wechat /usr/local/bin/wechat || true

echo "WeChat installation completed successfully!"

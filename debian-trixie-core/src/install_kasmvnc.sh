#!/usr/bin/env bash
set -e

echo "Install KasmVNC server"
cd /tmp

BUILD_ARCH=$(uname -m)
COMMIT_ID="17265facc40ab50db5740cdf0d12c61173edafc9"
KASMVNC_VER="1.5.0"
KASM_VER_NAME_PART="${KASMVNC_VER}"

# 选择架构对应的安装包
if [[ "${BUILD_ARCH}" =~ ^aarch64$ ]] ; then
    ARCH_PKG="arm64"
else
    ARCH_PKG="amd64"
fi

# debian 13 (trixie) 预编译包
BUILD_URL="https://kasmweb-build-artifacts.s3.amazonaws.com/kasmvnc/${COMMIT_ID}/kasmvncserver_trixie_${KASM_VER_NAME_PART}_${ARCH_PKG}.deb"

echo "Downloading KasmVNC from: ${BUILD_URL}"
wget "${BUILD_URL}" -O kasmvncserver.deb

apt-get update
apt-get install -y gettext ssl-cert libxfont2
apt-get install -y /tmp/kasmvncserver.deb
rm -f /tmp/kasmvncserver.deb

# 配置 KasmVNC web 资源目录与下载软链
mkdir -p ${KASM_VNC_PATH}/www/Downloads
chown -R 0:0 ${KASM_VNC_PATH}
chmod -R og-w ${KASM_VNC_PATH}
ln -sf /home/kasm-user/Downloads ${KASM_VNC_PATH}/www/Downloads/Downloads
chown -R 1000:0 ${KASM_VNC_PATH}/www/Downloads

echo "KasmVNC installation completed."

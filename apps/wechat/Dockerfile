# 微信应用镜像（基于 debian-trixie-core 通用层）
ARG BASE_IMAGE=ghcr.io/sion10032/kasmweb/debian-trixie-core:0.1.1
FROM ${BASE_IMAGE}

ARG VERSION=0.1.0
ARG COMMIT=unknown
LABEL org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${COMMIT}"

USER root

### 镜像源（可选：设置 APT_MIRROR 才启用，如 APT_MIRROR=mirrors.ustc.edu.cn）
# base 镜像可能用官方源构建（如 GHCR），wechat 本地构建时可重新指定
ARG APT_MIRROR=
RUN if [ -n "$APT_MIRROR" ]; then \
      sed -i "s|deb.debian.org|$APT_MIRROR|g" /etc/apt/sources.list.d/debian.sources && \
      sed -i "s|security.debian.org/debian-security|$APT_MIRROR/debian-security|g" /etc/apt/sources.list.d/debian.sources; \
    fi

### 安装微信
COPY install_wechat.sh /tmp/install_wechat.sh
RUN bash /tmp/install_wechat.sh && rm /tmp/install_wechat.sh && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libasound2t64 \
        libpulse0 \
        libnss3 \
        libxkbcommon-x11-0 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-shape0 \
        libxcb-render-util0 \
        libxcb-keysyms1 && \
    rm -rf /var/lib/apt/lists/*

### 应用自启钩子（openbox 开机调用）
COPY app_autostart.sh /dockerstartup/app_autostart.sh
RUN chmod +x /dockerstartup/app_autostart.sh

### 覆盖右键菜单（加入「启动微信」）
COPY menu.xml /etc/xdg/openbox/menu.xml

USER 1000

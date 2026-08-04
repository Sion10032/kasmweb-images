# Linux QQ 应用镜像（基于 debian-trixie-core 通用层）
ARG BASE_IMAGE=ghcr.io/sion10032/kasmweb/debian-trixie-core:0.1.1
FROM ${BASE_IMAGE}

ARG VERSION=dev
ARG COMMIT=unknown
LABEL org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${COMMIT}"

USER root

### 镜像源（可选：设置 APT_MIRROR 才启用，如 APT_MIRROR=mirrors.ustc.edu.cn）
# base 镜像可能用官方源构建（如 GHCR），qq 本地构建时可重新指定
ARG APT_MIRROR=
RUN if [ -n "$APT_MIRROR" ]; then \
      sed -i "s|deb.debian.org|$APT_MIRROR|g" /etc/apt/sources.list.d/debian.sources && \
      sed -i "s|security.debian.org/debian-security|$APT_MIRROR/debian-security|g" /etc/apt/sources.list.d/debian.sources; \
    fi

### 安装 QQ
COPY install_qq.sh /tmp/install_qq.sh
RUN bash /tmp/install_qq.sh && rm /tmp/install_qq.sh && rm -rf /var/lib/apt/lists/*

### 修复 trixie t64 依赖：QQ 需要 libasound.so.2（由 libasound2t64 提供）
# qq.deb 声明的是旧包名 libasound2，在 trixie 中不会自动装上，需显式安装
RUN apt-get update && \
    apt-get install -y --no-install-recommends libasound2t64 && \
    rm -rf /var/lib/apt/lists/*

### 应用自启钩子（openbox 开机调用）
COPY app_autostart.sh /dockerstartup/app_autostart.sh
RUN chmod +x /dockerstartup/app_autostart.sh

### 覆盖右键菜单（加入「启动 QQ」）
COPY menu.xml /etc/xdg/openbox/menu.xml

USER 1000

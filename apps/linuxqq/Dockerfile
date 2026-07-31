# Linux QQ 应用镜像（基于 kasm-base 通用层）
ARG BASE_IMAGE=sion10032/kasm-base:trixie
FROM ${BASE_IMAGE}

USER root

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

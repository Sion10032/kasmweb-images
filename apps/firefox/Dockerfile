# Firefox 应用镜像（基于 debian-trixie-core 通用层）
ARG BASE_IMAGE=ghcr.io/sion10032/kasmweb/debian-trixie-core:0.2.0
FROM ${BASE_IMAGE}

ARG VERSION=dev
ARG COMMIT=unknown
LABEL org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${COMMIT}"

USER root

### 镜像源（可选：设置 APT_MIRROR 才启用，如 APT_MIRROR=mirrors.ustc.edu.cn）
ARG APT_MIRROR=
RUN if [ -n "$APT_MIRROR" ]; then \
      sed -i "s|deb.debian.org|$APT_MIRROR|g" /etc/apt/sources.list.d/debian.sources && \
      sed -i "s|security.debian.org/debian-security|$APT_MIRROR/debian-security|g" /etc/apt/sources.list.d/debian.sources; \
    fi

### 安装 Firefox（Mozilla 官方 apt 仓库）
COPY install_firefox.sh /tmp/install_firefox.sh
RUN bash /tmp/install_firefox.sh && rm /tmp/install_firefox.sh && rm -rf /var/lib/apt/lists/*

### Enterprise Policies：禁用遥测与自动更新（系统级，所有 profile 生效）
COPY policies.json /etc/firefox/policies/policies.json

### 应用自启钩子（icewm 开机调用）
COPY app_autostart.sh /dockerstartup/app_autostart.sh
RUN chmod +x /dockerstartup/app_autostart.sh

### IceWM：禁用 Firefox 窗口装饰（去标题栏/边框）+ 启动即最大化 + 置顶
# 对等原 openbox rc.xml <application class="firefox">；改用 icewm winoptions
# 按 WM_CLASS class 匹配（firefox），字段语义见 https://ice-wm.org/man/icewm-winoptions
COPY winoptions /etc/X11/icewm/winoptions

USER 1000

# Firefox 应用镜像（基于 debian-trixie-core 通用层）
ARG BASE_IMAGE=ghcr.io/sion10032/kasmweb/debian-trixie-core:0.1.1
FROM ${BASE_IMAGE}

ARG VERSION=0.1.0
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

### 应用自启钩子（openbox 开机调用）
COPY app_autostart.sh /dockerstartup/app_autostart.sh
RUN chmod +x /dockerstartup/app_autostart.sh

### 覆盖右键菜单（加入「启动 Firefox」）
COPY menu.xml /etc/xdg/openbox/menu.xml

### Openbox：禁用 Firefox 系统窗口装饰（去掉标题栏/边框）+ 启动即最大化
# openbox 下 Firefox 不使用客户端装饰（CSD），改为由 openbox 对 Firefox 窗口
# 关闭 decor 并最大化，获得更干净的无边框全屏外观（单应用容器场景更合适）
# 注意：WM_CLASS 的 class 字段是小写 "firefox"，openbox 匹配大小写敏感
RUN sed -i '/<\/applications>/i \
  <application class="firefox">\n    <layer>above</layer>\n    <decor>no</decor>\n    <maximized>true</maximized>\n  </application>' \
    /etc/xdg/openbox/rc.xml

USER 1000

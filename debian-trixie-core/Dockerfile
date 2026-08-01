# KasmVNC + Openbox 通用基础镜像（debian 13 trixie）
# 应用镜像基于此构建，只需提供 /dockerstartup/app_autostart.sh
FROM debian:trixie-slim

ARG VERSION=0.1.0
ARG COMMIT=unknown
LABEL org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${COMMIT}"

### 环境配置
ARG LANG='en_US.UTF-8'
ARG LC_ALL='en_US.UTF-8'
ARG TZ='Asia/Shanghai'
ENV DEBIAN_FRONTEND=noninteractive \
    DISTRO=debian \
    DISPLAY=:1 \
    HOME=/home/kasm-default-profile \
    STARTUPDIR=/dockerstartup \
    KASM_VNC_PATH=/usr/share/kasmvnc \
    NO_VNC_PORT=6901 \
    VNC_PORT=5901 \
    VNC_PW=password \
    VNC_RESOLUTION=1280x720 \
    VNC_COL_DEPTH=24 \
    MAX_FRAME_RATE=24 \
    LANG=$LANG \
    LANGUAGE=$LANG \
    LC_ALL=$LC_ALL \
    TZ=$TZ

WORKDIR /home/kasm-default-profile

### 切换 USTC 镜像源（trixie 使用 debian.sources）
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources && \
    sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' \
        /etc/apt/sources.list.d/debian.sources

### 基础工具 + locale + 时区
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        curl \
        bzip2 \
        locales \
        tzdata \
        openssl \
        dbus-x11 \
        sudo \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

### X11 + Openbox（轻量窗口管理器）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openbox \
        xterm \
        x11-xserver-utils \
        xclip \
        xauth \
        autocutsel \
        tint2 \
    && rm -rf /var/lib/apt/lists/*

### 中文字体（应用通用，放基础层）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fonts-noto-color-emoji \
        unzip \
    && rm -rf /var/lib/apt/lists/*

### MiSans VF 字体（小米官方，可变字体）
RUN mkdir -p /usr/share/fonts/truetype/misans && \
    curl -fL "https://hyperos.mi.com/font-download/MiSans.zip" -o /tmp/MiSans.zip && \
    unzip -o /tmp/MiSans.zip -d /tmp/misans && \
    find /tmp/misans -name "MiSansVF.ttf" -exec cp {} /usr/share/fonts/truetype/misans/ \; && \
    rm -rf /tmp/MiSans.zip /tmp/misans && \
    fc-cache -f

### 安装 KasmVNC（提供 web VNC 访问）
# 先装 deb 再覆盖 kasmvnc.yaml：该文件是 dpkg conffile，
# 若安装前已存在会触发交互式 conffile 冲突导致非交互 build 失败
COPY src/install_kasmvnc.sh /tmp/install_kasmvnc.sh
RUN bash /tmp/install_kasmvnc.sh && rm /tmp/install_kasmvnc.sh
COPY src/kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml

### 启动脚本
COPY src/dockerstartup/ /dockerstartup/
RUN chmod +x /dockerstartup/*.sh /dockerstartup/generate_container_user

### Openbox 配置
COPY src/openbox/autostart /etc/xdg/openbox/autostart
COPY src/openbox/menu.xml /etc/xdg/openbox/menu.xml
# 调优：关闭新建窗口时的鼠标交互限制；虚拟桌面减为 1（单应用场景）
RUN sed -i 's/NLIMC/NLMC/g' /etc/xdg/openbox/rc.xml 2>/dev/null || true && \
    sed -i 's/<numWorkspaces>4<\/numWorkspaces>/<numWorkspaces>1<\/numWorkspaces>/' /etc/xdg/openbox/rc.xml

### Tint2 topbar 配置（任务栏 + 系统托盘 + 时钟）
COPY src/tint2/tint2rc /etc/xdg/tint2/tint2rc

### 默认用户 profile（首次启动复制到运行期 HOME）
RUN mkdir -p /home/kasm-default-profile/.config/openbox && \
    echo 'source $STARTUPDIR/generate_container_user' >> /home/kasm-default-profile/.bashrc

### 创建运行期用户 kasm-user (uid 1000)
RUN groupadd -g 1000 kasm-user && \
    useradd -m -u 1000 -g 1000 -s /bin/bash kasm-user

ENV HOME=/home/kasm-user
RUN mkdir -p /home/kasm-user && chown -R 1000:0 /home/kasm-user
WORKDIR /home/kasm-user

### 端口与用户
EXPOSE $NO_VNC_PORT $VNC_PORT
USER 1000

ENTRYPOINT ["/dockerstartup/kasm_default_profile.sh", "/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]

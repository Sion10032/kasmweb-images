# syntax=docker/dockerfile:1.4
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
    VNC_USER=kasm_user \
    VNC_RESOLUTION=1280x720 \
    VNC_COL_DEPTH=24 \
    MAX_FRAME_RATE=24 \
    VNC_BLACKLIST_THRESHOLD=0 \
    LANG=$LANG \
    LANGUAGE=$LANG \
    LC_ALL=$LC_ALL \
    TZ=$TZ \
    # 输入法（fcitx5）：GTK/Qt IM 模块接入 + 部署决策点
    GTK_IM_MODULE=fcitx \
    QT_IM_MODULE=fcitx \
    XMODIFIERS=@im=fcitx \
    DEPLOY_IME_SCRIPT=/opt/rime/deploy_rime_ice.sh

WORKDIR /home/kasm-default-profile

### 镜像源（可选：设置 APT_MIRROR 才启用，如 APT_MIRROR=mirrors.ustc.edu.cn）
ARG APT_MIRROR=
RUN if [ -n "$APT_MIRROR" ]; then \
      sed -i "s|deb.debian.org|$APT_MIRROR|g" /etc/apt/sources.list.d/debian.sources && \
      sed -i "s|security.debian.org/debian-security|$APT_MIRROR/debian-security|g" /etc/apt/sources.list.d/debian.sources; \
    fi

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
# cache mount 缓存 217M zip：首次下载慢，后续构建命中缓存秒过
# --http1.1 避免 HTTP/2 PROTOCOL_ERROR；--retry 抗中断；unzip -t 防损坏缓存
RUN --mount=type=cache,target=/tmp/misans-cache \
    mkdir -p /usr/share/fonts/truetype/misans && \
    if [ ! -s /tmp/misans-cache/MiSans.zip ] || ! unzip -tq /tmp/misans-cache/MiSans.zip >/dev/null 2>&1; then \
      curl -fL --http1.1 --retry 5 --retry-delay 5 --retry-all-errors \
        "https://hyperos.mi.com/font-download/MiSans.zip" \
        -o /tmp/misans-cache/MiSans.zip; \
    fi && \
    unzip -o /tmp/misans-cache/MiSans.zip -d /tmp/misans-extract && \
    find /tmp/misans-extract -name "MiSansVF.ttf" -exec cp {} /usr/share/fonts/truetype/misans/ \; && \
    rm -rf /tmp/misans-extract && \
    fc-cache -f

### 输入法框架：fcitx5 + Rime 引擎（应用通用，放基础层）
# 框架装系统层（不随用户目录/挂载卷丢失）；引擎方案数据由 DEPLOY_IME_SCRIPT 部署
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fcitx5 \
        fcitx5-rime \
        fcitx5-frontend-all \
        fcitx5-modules \
        fcitx5-configtool \
        librime-bin \
        librime-plugin-lua \
    && rm -rf /var/lib/apt/lists/*

### 雾凇拼音（rime-ice）模板 + 部署脚本：打包到 /opt/rime，不预部署到任何用户目录
# 官方 release full.zip（完整方案 + 词典，未编译），钉在 2026.06.30 tag，构建可复现
# 出厂即已剔除 .github/build/others/README 等无关文件，解压直接就是模板
# 用户 Rime 目录位于挂载卷内，模板随镜像层存活；启动时由 deploy_rime_ice.sh
# 执行“缺失才补齐、已有不覆盖”，旧卷/新挂载卷都能获得雾凇且不动用户词库。
# cache mount 缓存 zip：首次慢，后续构建命中缓存秒过
RUN --mount=type=cache,target=/tmp/rime-cache \
    mkdir -p /tmp/rime-extract /opt/rime/rime-ice && \
    if [ ! -s /tmp/rime-cache/full.zip ] || ! unzip -tq /tmp/rime-cache/full.zip >/dev/null 2>&1; then \
      curl -fL --http1.1 --retry 5 --retry-delay 5 --retry-all-errors \
        "https://github.com/iDvel/rime-ice/releases/download/2026.06.30/full.zip" \
        -o /tmp/rime-cache/full.zip; \
    fi && \
    unzip -q /tmp/rime-cache/full.zip -d /tmp/rime-extract && \
    cp -r /tmp/rime-extract/. /opt/rime/rime-ice/ && \
    rm -rf /tmp/rime-extract

# 部署脚本 + fcitx5 配置模板（源码在 src/rime/，随镜像层打包）
COPY src/rime/deploy_rime_ice.sh /opt/rime/deploy_rime_ice.sh
COPY src/rime/fcitx5/ /opt/rime/fcitx5/
RUN chmod +x /opt/rime/deploy_rime_ice.sh

### 安装 KasmVNC（提供 web VNC 访问；cache mount 缓存 deb，一次 RUN 内下载+安装）
# TARGETARCH 由 buildx 注入（amd64/arm64）；非 buildx 构建回退 uname 推断
# deb 首次拉取后永久缓存，后续构建秒过；cache mount 不进镜像层
# 先装 deb 再覆盖 kasmvnc.yaml：该文件是 dpkg conffile，
# 若安装前已存在会触发交互式 conffile 冲突导致非交互 build 失败
ARG TARGETARCH
RUN --mount=type=cache,target=/tmp/kasmvnc-cache \
    set -e && \
    ARCH_PKG="${TARGETARCH:-$(case "$(uname -m)" in aarch64) echo arm64 ;; *) echo amd64 ;; esac)}" && \
    DEB="/tmp/kasmvnc-cache/kasmvncserver_${ARCH_PKG}.deb" && \
    echo "KasmVNC arch: ${ARCH_PKG}" && \
    if [ ! -s "$DEB" ]; then \
      curl -fL --http1.1 --retry 5 --retry-delay 5 --retry-all-errors \
        "https://kasmweb-build-artifacts.s3.amazonaws.com/kasmvnc/17265facc40ab50db5740cdf0d12c61173edafc9/kasmvncserver_trixie_1.5.0_${ARCH_PKG}.deb" \
        -o "$DEB"; \
    fi && \
    apt-get update && \
    apt-get install -y gettext ssl-cert libxfont2 && \
    apt-get install -y "$DEB" && \
    mkdir -p ${KASM_VNC_PATH}/www/Downloads && \
    chown -R 0:0 ${KASM_VNC_PATH} && \
    chmod -R og-w ${KASM_VNC_PATH} && \
    ln -sf /home/kasm-user/Downloads ${KASM_VNC_PATH}/www/Downloads/Downloads && \
    chown -R 1000:0 ${KASM_VNC_PATH}/www/Downloads && \
    rm -rf /var/lib/apt/lists/*

# KasmVNC 安装完成后覆盖配置（conffile 若提前存在会触发交互式冲突）
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

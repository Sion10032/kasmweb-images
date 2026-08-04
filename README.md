# kasmweb-images

把 Linux 桌面应用装进容器，**通过浏览器访问**的轻量方案（基于 KasmVNC）。

无需在本机安装任何客户端——打开 `https://<host>:6901`，输入账号密码，就是一个完整的桌面环境。

## 用途

- **远程运行桌面应用**：在没有图形界面的服务器、云主机、NAS 上跑 GUI 应用（如 QQ），通过浏览器远程使用
- **隔离与即用即弃**：每个应用一个容器，环境互相隔离，用完可销毁，配置在命名卷里持久化
- **统一基础镜像**：`debian-trixie-core` 提供一套通用桌面（KasmVNC + openbox + tint2 + 中文字体），应用镜像只需 `FROM` 它并安装应用——**几分钟就能构建一个新的桌面应用容器**

## 镜像

| 镜像                 | 说明                                                                          |
| -------------------- | ----------------------------------------------------------------------------- |
| `debian-trixie-core` | 通用基础镜像：Debian 13 trixie + KasmVNC + openbox + tint2 + MiSans/Noto 字体 |
| `qq`                 | Linux QQ 桌面版，容器启动后自动打开 QQ                                        |
| `firefox`            | Mozilla Firefox，已禁用遥测与自动更新，启动即用                               |

镜像地址：`ghcr.io/sion10032/kasmweb/<镜像名>`，采用语义化版本号（当前 `0.1.0`），均有 `:latest` 标签。

## 快速开始（以 QQ 为例）

### Docker

```bash
docker run -d \
  --name qq \
  -p 6901:6901 \
  -e VNC_PW=password \
  -v qq-data:/home/kasm-user \
  --shm-size 2g \
  --restart unless-stopped \
  ghcr.io/sion10032/kasmweb/qq:latest
```

### Docker Compose

新建 `docker-compose.yml`：

```yaml
services:
  qq:
    image: ghcr.io/sion10032/kasmweb/qq:latest
    container_name: qq
    ports:
      - "6901:6901"
    environment:
      - VNC_USER=kasm_user
      - VNC_PW=password
      - VNC_RESOLUTION=1280x720
    volumes:
      - qq-data:/home/kasm-user
    shm_size: '2gb'
    restart: unless-stopped

volumes:
  qq-data:
```

启动：

```bash
docker compose up -d
```

---

浏览器访问 `https://localhost:6901`（自签证书，首次需确认），输入账号密码（默认 `kasm_user` / `password`），即可看到桌面，QQ 已自动启动。

## 配置

运行时环境变量（`docker run -e` 或 compose `environment`）：

| 变量             | 默认        | 说明                               |
| ---------------- | ----------- | ---------------------------------- |
| `VNC_USER`       | `kasm_user` | web 登录用户名                     |
| `VNC_PW`         | `password`  | web 登录密码（生产环境请改强密码） |
| `VNC_RESOLUTION` | `1280x720`  | 桌面分辨率                         |
| `NO_VNC_PORT`    | `6901`      | web 访问端口（需映射到宿主）       |

## 本地构建

分层架构：先构建 base，再构建依赖它的应用镜像。

```bash
# 1. 构建 base
cd debian-trixie-core && docker compose build

# 2. 构建 qq（默认 FROM GHCR 上的 base；本地联调可加 --build-arg BASE_IMAGE=debian-trixie-core:latest）
cd ../apps/qq && docker compose build
```

## 项目结构

```
kasmweb-images/
├── debian-trixie-core/      # 通用基础镜像
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── src/                 # KasmVNC 配置 / 启动脚本 / openbox+tint2 配置 / 字体
├── apps/
│   ├── qq/                  # Linux QQ 应用镜像
│   └── firefox/             # Mozilla Firefox 应用镜像
└── .github/workflows/       # CI：GHCR 发版 + 自动 Release
```

**分层复用机制**：`debian-trixie-core` 提供通用桌面，并在 openbox 启动时检查 `/dockerstartup/app_autostart.sh`——存在则运行（启动应用），否则启动 xterm 占位。新应用镜像只需提供这个脚本，即可复用整套桌面环境，无需重复搭建 KasmVNC/WM/字体。

## 技术栈

- **OS**：Debian 13 (trixie-slim)
- **远程桌面**：[KasmVNC](https://github.com/kasmtech/KasmVNC)（浏览器直连，无需 VNC 客户端）
- **窗口管理器**：Openbox（轻量）+ tint2（topbar：任务栏 / 系统托盘 / 时钟，支持自动隐藏）
- **字体**：MiSans VF（中文）+ Noto Color Emoji
- **Locale**：默认 `en_US.UTF-8`（同时生成 `zh_CN.UTF-8`，可按需切换）

## 许可（License）

本项目（Dockerfile / 脚本 / 配置）以 [MIT](LICENSE.md) 协议发布。

## 第三方组件

容器镜像内含的第三方软件保留各自原始协议与版权，**本项目的 MIT 许可不覆盖它们**：

- **KasmVNC** — GPLv2，© Kasm Technologies
- **Openbox / tint2** — GPLv2
- **MiSans** — SIL Open Font License，© Xiaomi
- **Noto Color Emoji** — SIL Open Font License，© Google
- **Linux QQ** — 闭源专有，© Tencent。本项目仅自动化安装腾讯官方安装包，不持有 QQ 的任何权利
- **Mozilla Firefox** — MPL 2.0，© Mozilla Foundation。本项目仅自动化安装官方发行版，不持有 Firefox 的任何权利

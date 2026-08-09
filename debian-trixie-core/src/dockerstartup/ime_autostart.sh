#!/bin/sh
# Openbox 自启：启动 fcitx5 输入法框架
# Rime 引擎数据由 DEPLOY_IME_SCRIPT 在 entrypoint 阶段部署到用户目录；
# 框架与部署解耦：无引擎数据时 fcitx5 兜底为英文键盘，不阻塞桌面。

# 已在运行则跳过 —— 切勿 --replace 顶掉运行中的 fcitx5：
# fcitx5 重启时其窗口销毁/重建过程会让 openbox 事件处理阻塞（整个 openbox 卡死，
# 需 kill openbox 由 vnc_startup 重启才能恢复）。openbox 重跑本脚本时尤其要避免。
pgrep -x fcitx5 >/dev/null 2>&1 && exit 0

fcitx5 -d >/tmp/fcitx5.log 2>&1 &

#!/bin/sh
# Openbox 应用自启钩子：启动 QQ
# 使用 pgrep 防止 openbox 重启导致 QQ 重复启动

# 匹配 /opt/QQ 下的进程（无论从哪个软链启动都稳定）
if ! pgrep -f '/opt/QQ' > /dev/null 2>&1; then
    /usr/local/bin/qq --no-sandbox >/dev/null 2>&1 &
fi

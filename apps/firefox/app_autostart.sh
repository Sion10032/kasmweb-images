#!/bin/sh
# IceWM 应用自启钩子：启动 Firefox
# 使用 pgrep 防止 icewm 重启导致 Firefox 重复启动
if ! pgrep -x firefox > /dev/null 2>&1; then
    firefox >/dev/null 2>&1 &
fi

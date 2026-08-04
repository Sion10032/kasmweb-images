#!/bin/sh
# Openbox 应用自启钩子：启动微信
# 使用 pgrep 防止 openbox 重启导致微信重复启动

# 匹配 /opt/wechat 下的进程（无论从哪个软链启动都稳定）
if ! pgrep -f '/opt/wechat' > /dev/null 2>&1; then
    /usr/local/bin/wechat --no-sandbox >/dev/null 2>&1 &
fi

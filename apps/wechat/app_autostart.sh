#!/bin/sh
# IceWM 应用自启钩子：启动微信
# 使用 pgrep 防止 icewm 重启导致微信重复启动

# 匹配 /opt/wechat 下的进程（无论从哪个软链启动都稳定）
if ! pgrep -f '/opt/wechat' > /dev/null 2>&1; then
    /usr/local/bin/wechat --no-sandbox >/dev/null 2>&1 &
fi

(
    while true; do
        echo "$(date '+%F %T') trying maximize Weixin"

        icesh -c 'wechat.wechat' -n 'Weixin' maximize

        resolution=$(xrandr | awk '/ connected/{print $3}')
        if icesh -c 'wechat.wechat' list | grep -Fq "${resolution}"; then
            echo "$(date '+%F %T') window position matched, exit"
            break
        fi

        echo "$(date '+%F %T') not matched, retry"
        sleep 1
    done
) &

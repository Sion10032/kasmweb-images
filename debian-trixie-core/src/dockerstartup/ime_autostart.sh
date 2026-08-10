#!/bin/sh

pgrep -x fcitx5 >/dev/null 2>&1 && exit 0
fcitx5 -d >/tmp/fcitx5.log 2>&1 &

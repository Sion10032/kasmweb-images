#!/usr/bin/env bash
set -e

DEFAULT_PROFILE_HOME=/home/kasm-default-profile

function copy_default_profile_to_home {
    echo "Copying default profile to home directory"
    cp -rp $DEFAULT_PROFILE_HOME/. $HOME/ 2>/dev/null || true
}

# 首次启动时复制默认 profile
if [ -f "$HOME/.bashrc" ]; then
    echo "Profile already exists. Will not copy default contents"
else
    copy_default_profile_to_home
fi

# 创建常用目录
mkdir -p $HOME/Downloads

echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
echo "Executing command: '$@'"
exec "$@"

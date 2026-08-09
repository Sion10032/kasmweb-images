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

# 输入法部署钩子：DEPLOY_IME_SCRIPT 非空且可执行才执行（默认部署雾凇拼音模板）
# 置空 = 不部署；指向自定义脚本 = 部署其他输入法。失败静默跳过不阻塞启动
if [ -n "${DEPLOY_IME_SCRIPT:-}" ] && [ -x "$DEPLOY_IME_SCRIPT" ]; then
    echo "Executing IME deploy script: ${DEPLOY_IME_SCRIPT}"
    "$DEPLOY_IME_SCRIPT" || true
fi

echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
echo "Executing command: '$@'"
exec "$@"

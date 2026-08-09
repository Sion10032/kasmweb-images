#!/bin/sh
# 部署雾凇拼音（rime-ice）到当前用户 Rime 目录（幂等）
#
# 设计要点：
#   - 模板在镜像层 /opt/rime/rime-ice（不随用户目录挂载卷丢失）
#   - 用户 Rime 目录 ~/.local/share/fcitx5/rime 位于运行期 HOME（挂载卷内），词库持久化
#   - 规则：缺失才补齐、已有不覆盖（cp -n）。因此挂载新卷 / 旧卷 / 不挂载
#     三种场景都能"有就保留，没有就安装"，且不会覆盖用户词条与自定义方案
#   - 自定义输入法：参考本脚本写一份部署脚本，再把 DEPLOY_IME_SCRIPT 指向它；
#     置空字符串 = 完全不部署
#
# 由 /dockerstartup/kasm_default_profile.sh 在 entrypoint 阶段调用（USER 1000, HOME 就绪）

RIME_DIR="${HOME:-/home/kasm-user}/.local/share/fcitx5/rime"
FCITX5_DIR="${HOME:-/home/kasm-user}/.config/fcitx5"
RIME_TEMPLATE=/opt/rime/rime-ice
FCITX5_TEMPLATE=/opt/rime/fcitx5

# 1) Rime 用户数据：目录缺失或缺失方案标志文件（rime_ice.schema.yaml）时从模板补齐
#    存在即跳过——保留下来的就是用户自己的词库 / 自定义方案
if [ -d "$RIME_TEMPLATE" ] && \
   { [ ! -d "$RIME_DIR" ] || [ ! -f "$RIME_DIR/rime_ice.schema.yaml" ]; }; then
    mkdir -p "$RIME_DIR"
    cp -rn "$RIME_TEMPLATE"/. "$RIME_DIR"/ 2>/dev/null || true
fi

# 2) fcitx5 配置：profile 缺失才放入模板，否则 fcitx5 输入法列表为空、中文不可用
#     已有 profile 不动（保留用户自行配置的输入法方案）
if [ -d "$FCITX5_TEMPLATE" ] && [ ! -f "$FCITX5_DIR/profile" ]; then
    mkdir -p "$FCITX5_DIR"
    cp -rn "$FCITX5_TEMPLATE"/. "$FCITX5_DIR"/ 2>/dev/null || true
fi

exit 0
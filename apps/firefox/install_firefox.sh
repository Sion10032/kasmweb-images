#!/usr/bin/env bash
# 参考 kasmweb 官方 install_firefox.sh，在 Debian trixie (amd64) 上通过
# Mozilla 官方 apt 仓库安装最新 Firefox，并预置系统级 Enterprise Policies。
set -ex

# Mozilla 官方 apt 仓库（amd64）
# 提供 Mozilla 持续更新的原生 deb 包，避免依赖 snap/flatpak
install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- > /etc/apt/keyrings/packages.mozilla.org.asc
cat > /etc/apt/sources.list.d/mozilla.list <<'EOF'
deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main
EOF

# 提高 mozilla 仓库优先级，确保 firefox 来自官方源而非 debian/snap
cat > /etc/apt/preferences.d/mozilla <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

# 安装 firefox + p11-kit（让 firefox 复用系统证书库）
apt-get update
apt-get install -y --no-install-recommends firefox p11-kit-modules

# 让 firefox 使用系统证书库（NSS）替代内置的
if [ -f /usr/lib/firefox/libnssckbi.so ]; then
    rm -f /usr/lib/firefox/libnssckbi.so
    ln -s /usr/lib/$(dpkg --print-architecture)-linux-gnu/pkcs11/p11-kit-trust.so \
        /usr/lib/firefox/libnssckbi.so
fi

# 命令行软链
ln -sf /usr/lib/firefox/firefox /usr/local/bin/firefox || true

# 关闭首次运行数据上报提示（Firefox <147 读取 defaults/pref，新版本亦可兼容）
PREF_FILE=/usr/lib/firefox/defaults/pref/firefox.js
if [ -f "$PREF_FILE" ]; then
    sed -i -e '/datareporting.policy.firstRunURL/d' "$PREF_FILE" || true
else
    mkdir -p "$(dirname "$PREF_FILE")"
    : > "$PREF_FILE"
fi
cat >>"$PREF_FILE" <<'EOF'
pref("datareporting.policy.firstRunURL", "");
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("datareporting.healthreport.service.enabled", false);
pref("datareporting.healthreport.uploadEnabled", false);
pref("trailhead.firstrun.branches", "nofirstrun-empty");
pref("browser.aboutwelcome.enabled", false);
EOF

echo "Firefox installation completed successfully!"

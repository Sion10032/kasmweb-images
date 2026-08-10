#!/bin/bash
### every exit != 0 fails the script
set -e

APP_NAME=$(basename "$0")

log () {
    if [ -n "${1}" ]; then
        INGEST_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "${INGEST_DATE} ${2:-INFO} (${APP_NAME}): $1"
    fi
}

no_proxy="localhost,127.0.0.1"

# Start DBus session
eval "$(dbus-launch --sh-syntax)"

# dict to store processes
declare -A KASM_PROCS

DISPLAY_NUM=$(echo $DISPLAY | grep -Po ':\d+')

trap 'for p in "${KASM_PROCS[@]}"; do kill -s SIGTERM $p 2>/dev/null; done; exit 0' SIGINT SIGTERM

######## FUNCTION DECLARATIONS ##########

function start_kasmvnc (){
	log "Starting KasmVNC"

	# 清理旧的 X 锁和进程
	vncserver -kill $DISPLAY 2>/dev/null || true
	rm -rf /tmp/.X*-lock /tmp/.X11-unix 2>/dev/null || true
	rm -rf $HOME/.vnc/*.pid
	echo "exit 0" > $HOME/.vnc/xstartup
	chmod +x $HOME/.vnc/xstartup

	VNCOPTIONS="${VNCOPTIONS:-} -select-de manual"

	vncserver $DISPLAY \
		-depth $VNC_COL_DEPTH \
		-geometry $VNC_RESOLUTION \
		-websocketPort $NO_VNC_PORT \
		-httpd ${KASM_VNC_PATH}/www \
		-sslOnly \
		-FrameRate $MAX_FRAME_RATE \
		-BlacklistThreshold $VNC_BLACKLIST_THRESHOLD \
		-interface 0.0.0.0 \
		$VNCOPTIONS

	KASM_PROCS['kasmvnc']=$(cat $HOME/.vnc/*${DISPLAY_NUM}.pid 2>/dev/null)

	# 关闭 X 屏保
	xset -dpms 2>/dev/null || true
	xset s off 2>/dev/null || true
}

function start_window_manager (){
	echo -e "\n------------------ IceWM window manager startup ------------------"
	/usr/bin/icewm-session &
	KASM_PROCS['window_manager']=$!
}

function start_fcitx (){
    # 应用镜像不需要输入法时：覆盖 /dockerstartup/ime_autostart.sh 或置空 DEPLOY_IME_SCRIPT
    if [ -x /dockerstartup/ime_autostart.sh ]; then
        /dockerstartup/ime_autostart.sh
    fi
}

function custom_startup (){
	custom_startup_script=/dockerstartup/custom_startup.sh
	if [ -f "$custom_startup_script" ]; then
		if [ ! -x "$custom_startup_script" ]; then
			echo "${custom_startup_script}: not executable, exiting"
			exit 1
		fi
		"$custom_startup_script" &
		KASM_PROCS['custom_startup']=$!
		log "Executed custom startup script."
	fi
}

############ END FUNCTION DECLARATIONS ###########

# 创建自签证书（KasmVNC HTTPS 需要）
mkdir -p ${HOME}/.vnc
if [ ! -f ${HOME}/.vnc/self.pem ]; then
	openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
		-keyout ${HOME}/.vnc/self.pem -out ${HOME}/.vnc/self.pem \
		-subj "/C=US/ST=VA/L=None/O=None/OU=DoFu/CN=kasm/emailAddress=none@none.none"
fi

# 设置 VNC 密码
PASSWD_PATH="$HOME/.kasmpasswd"
if [[ -f $PASSWD_PATH ]]; then
	rm -f $PASSWD_PATH
fi
echo -e "${VNC_PW}\n${VNC_PW}\n" | kasmvncpasswd -u "${VNC_USER:-kasm_user}" -wo
chmod 600 $PASSWD_PATH

# source bashrc（含 generate_container_user）
if [ -f $HOME/.bashrc ]; then
    source $HOME/.bashrc
fi

# 启动进程
start_kasmvnc
start_fcitx
start_window_manager

log "KasmVNC environment started"

# tail vncserver 日志
tail -f $HOME/.vnc/*$DISPLAY.log &

# 可选的自定义启动钩子
custom_startup

# 监控进程：VNC/icewm 崩溃自动重启；应用崩溃由 icewm 桌面承托
sleep 3
while :
do
	for process in "${!KASM_PROCS[@]}"; do
		if ! kill -0 "${KASM_PROCS[$process]}" 2>/dev/null; then
			case $process in
				kasmvnc)
					log "KasmVNC crashed, restarting" "WARNING"
					start_kasmvnc
					;;
				window_manager)
					log "Window manager crashed, restarting" "WARNING"
					start_window_manager
					;;
				custom_startup)
					echo "The custom startup script exited."
					custom_startup
					;;
				*)
					echo "Unknown Service: $process"
					;;
			esac
		fi
	done

	sleep 3
done

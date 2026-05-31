#!/system/bin/sh
export ANDROID_DATA="/data"
export ANDROID_ROOT="/system"
export HOME="/data/data/com.termux/files/home"
export LANG="en_US.UTF-8"
export PATH="/data/data/com.termux/files/usr/bin:/system/bin"
export PREFIX="/data/data/com.termux/files/usr"
export TMPDIR="/data/data/com.termux/files/usr/tmp"
export TZ="UTC"
export TERM="xterm"

if [ ! -f "/welcome-full.txt" ]; then
cat > "/welcome-full.txt" <<'EOF'
Welcome to Termux!

Docs:       https://termux.dev/docs
Donate:     https://termux.dev/donate
Community:  https://termux.dev/community

Working with packages:

 - Search:  pkg search <query>
 - Install: pkg install <package>
 - Upgrade: pkg upgrade

Subscribing to additional repositories:

 - Root:    pkg install root-repo
 - X11:     pkg install x11-repo

For fixing any repository issues,
try 'termux-change-repo' command.

Report issues at https://termux.dev/issues
Starting fallback run of termux bootstrap second stage
[*] Running termux bootstrap second stage
[*] Running postinst maintainer scripts
[*] Running 'coreutils' package postinst
[*] Running 'less' package postinst
[*] Running 'nano' package postinst
update-alternatives: using /data/data/com.termux/files/usr/bin/nano to provide /data/data/com.termux/files/usr/bin/editor (editor) in auto mode
update-alternatives: warning: skipping updating manpage database as 'makewhatis' command from 'mandoc' package is not installed
[*] Running 'termux-exec' package postinst
termux-exec.postinst: Start
/usr/bin/getprop: 3: exec: /system/bin/getprop: not found
termux-exec.postinst: Failed to get android_build_version_sdk value from 'getprop': ''
termux-exec.postinst: Skipping setting primary Termux '$LD_PRELOAD' library as android_build_version_sdk value is not available
termux-exec.postinst: End
[*] Running 'util-linux' package postinst
[*] The termux bootstrap second stage completed successfully
EOF
fi

if [ ! -f "/welcome.txt" ]; then
cat > "/welcome.txt" <<'EOF'
Welcome to Termux!

Docs:       https://termux.dev/docs
Donate:     https://termux.dev/donate
Community:  https://termux.dev/community

Working with packages:

 - Search:  pkg search <query>
 - Install: pkg install <package>
 - Upgrade: pkg upgrade

Subscribing to additional repositories:

 - Root:    pkg install root-repo
 - X11:     pkg install x11-repo

For fixing any repository issues,
try 'termux-change-repo' command.

Report issues at https://termux.dev/issues
EOF
fi

if [ $# -lt 1 ]; then
	set -- login
fi

if [ "$(id -u)" != "0" ]; then
	echo "Failure: /entrypoint_root.sh must be started as root." >&2
	exit 1
fi

if [ -z "$(pidof dnsmasq)" ]; then
	/system/bin/sh -T /dev/ptmx -c "dnsmasq -u root -g root --pid-file=/dnsmasq.pid" >/dev/null 2>&1
	sleep 1
	if [ -z "$(pidof dnsmasq)" ]; then
		echo "[!] Failed to start dnsmasq, host name resolution may fail." >&2
	fi
fi

if [ ! -e "/usr/bin" ]; then
/data/data/com.termux/files/usr/bin/ln -s /data/data/com.termux/files/usr/bin /usr/bin
fi

exec /system/bin/su -s "/data/data/com.termux/files/usr/bin/env" system -- \
	-i \
	ANDROID_DATA="/data" \
	ANDROID_ROOT="/system" \
	HOME="/data/data/com.termux/files/home" \
	LANG="en_US.UTF-8" \
	PATH="/data/data/com.termux/files/usr/bin:/system/bin" \
	PREFIX="/data/data/com.termux/files/usr" \
	TMPDIR="/data/data/com.termux/files/usr/tmp" \
	TZ="UTC" \
	TERM="xterm" \
    bash -c 'cat "/welcome.txt" && cd "$HOME" && exec bash'

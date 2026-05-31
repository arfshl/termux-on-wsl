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

if [ ! -e "/usr/bin" ]; then
/data/data/com.termux/files/usr/bin/ln -s /data/data/com.termux/files/usr/bin /usr/bin
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

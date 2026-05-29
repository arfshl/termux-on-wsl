#!/bin/sh
mount --bind /dev /termuxwsl/dev
mount --bind /dev/pts /termuxwsl/dev/pts
mount --bind /proc /termuxwsl/proc
mount --bind /sys /termuxwsl/sys
chroot --userspec=system /termuxwsl /data/data/com.termux/files/usr/bin/env HOME=/data/data/com.termux/files/home /bin/bash --login -c "cd /data/data/com.termux/files/home && exec /bin/bash"
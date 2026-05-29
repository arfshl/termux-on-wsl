#!/bin/sh
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) ARCH=amd64 ;;
    aarch64|arm64) ARCH=arm64 ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac
echo "ARCH=$ARCH" >> "$GITHUB_OUTPUT"

# start build
# Fetch image manifest
manifest=$(docker manifest inspect debian:stable)
# Fetch image digest
digest=$(echo "$manifest" | jq -r ".manifests[] | select(.platform.architecture == \"$ARCH\") | .digest")
# Pull and Export image
docker pull "debian:stable@${digest}"
docker export $(docker create "debian:stable@${digest}") --output $GITHUB_WORKSPACE/debian.tar
mkdir -p ./termuxwsl/termuxwsl
sudo tar -xf debian.tar -C ./termuxwsl
# Fetch image manifest
manifest=$(docker manifest inspect termux/termux-docker:latest)
# Fetch image digest
digest=$(echo "$manifest" | jq -r ".manifests[] | select(.platform.architecture == \"$ARCH\") | .digest")
# Pull and Export image
docker pull "termux/termux-docker:latest@${digest}"
docker export $(docker create "termux/termux-docker:latest@${digest}") --output $GITHUB_WORKSPACE/termux.tar
sudo cp termux.tar ./termuxwsl/termuxwsl
sudo tar -xf ./termuxwsl/termuxwsl/termux.tar
sudo rm ./termuxwsl/termuxwsl/termux.tar
mkdir -p ./termuxwsl/termuxwsl/usr
mkdir -p ./termuxwsl/termuxwsl/dev
mkdir -p ./termuxwsl/termuxwsl/dev/pts
mkdir -p ./termuxwsl/termuxwsl/proc
mkdir -p ./termuxwsl/termuxwsl/sys

sudo ln -s ./termuxwsl/termuxwsl/data/data/com.termux/files/usr/bin ./termuxwsl/termuxwsl/bin
sudo ln -s ./termuxwsl/termuxwsl/data/data/com.termux/files/usr/bin ./termuxwsl/termuxwsl/usr/bin
sudo ln -s ./termuxwsl/termuxwsl/data/data/com.termux/files/usr/lib ./termuxwsl/termuxwsl/lib
sudo ln -s ./termuxwsl/termuxwsl/data/data/com.termux/files/usr/lib ./termuxwsl/termuxwsl/usr/lib
sudo ln -s ./termuxwsl/termuxwsl/data/data/com.termux/files/usr/etc ./termuxwsl/termuxwsl/etc
sudo ln -s ./termuxwsl/termuxwsl/data/data/com.termux/files/usr/var ./termuxwsl/termuxwsl/var
sudo ln -s ./termuxwsl/termuxwsl/data/data/com.termux/files/usr/tmp ./termuxwsl/termuxwsl/tmp
sudo ln -s ./termuxwsl/termuxwsl/data/data/com.termux/files/usr/opt ./termuxwsl/termuxwsl/opt

cat <<-EOF | sudo unshare -mpf bash -e -
sudo mount --bind /dev ./termuxwsl/dev
sudo mount --bind /proc ./termuxwsl/proc
sudo mount --bind /sys ./termuxwsl/sys
sudo mount --bind /dev/pts ./termuxwsl/dev/pts
sudo echo 'nameserver 1.1.1.1' >> ./termuxwsl/etc/resolv.conf

sudo chroot ./termuxwsl apt update
sudo chroot ./termuxwsl apt upgrade -y
EOF

cat <<-EOF | sudo unshare -mpf bash -e -
sudo mount --bind /dev ./termuxwsl/termuxwsl/dev
sudo mount --bind /proc ./termuxwsl/termuxwsl/proc
sudo mount --bind /sys ./termuxwsl/termuxwsl/sys
sudo mount --bind /dev/pts ./termuxwsl/termuxwsl/dev/pts
sudo chroot --userspec=1000:1000 ./termuxwsl /bin/bash --login -c "apt update"
sudo chroot --userspec=1000:1000 ./termuxwsl /bin/bash --login -c "apt upgrade -y -o Dpkg::Options::='--force-confold'"
EOF



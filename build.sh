#!/bin/sh
export RELEASE=$(date +"%Y%m%d")
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) ARCH=amd64 ;;
    aarch64|arm64) ARCH=arm64 ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac
ech0 "RELEASE=$RELEASE" >> "$GITHUB_OUTPUT"
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
sudo tar -xvpf debian.tar -C ./termuxwsl
# Fetch image manifest
manifest=$(docker manifest inspect termux/termux-docker:latest)
# Fetch image digest
digest=$(echo "$manifest" | jq -r ".manifests[] | select(.platform.architecture == \"$ARCH\") | .digest")
# Pull and Export image
docker pull "termux/termux-docker:latest@${digest}"
docker export $(docker create "termux/termux-docker:latest@${digest}") --output $GITHUB_WORKSPACE/termux.tar
sudo cp termux.tar ./termuxwsl/termuxwsl
sudo tar -xvpf ./termuxwsl/termuxwsl/termux.tar
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

sudo cp ./wslconf/wsl-entrypoint.sh ./termuxwsl/wsl-entrypoint.sh
sudo cp ./wslconf/wsl-entrypoint.sh ./termuxwsl/root/wsl-entrypoint.sh
sudo cp ./wslconf/wsl.conf ./termuxwsl/etc/wsl.conf
sudo cp ./wslconf/wsl-distribution.conf ./termuxwsl/etc/wsl-distribution.conf
sudo chmod 644 ./termuxwsl/etc/wsl-distribution.conf
sudo mkdir -p ./termuxwsl/usr/lib/wsl/
sudo cp ./wslconf/icon.png ./termuxwsl/usr/lib/wsl/icon.png

cd ./termuxwsl
sudo tar --numeric-owner --absolute-names -c  * | gzip --best > ../install.tar.gz
mv ../install.tar.gz ../termux-wsl-$ARCH.wsl
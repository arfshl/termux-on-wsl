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
docker export $(docker create "debian:stable@${digest}") | xz -T 0 > "$GITHUB_WORKSPACE/debian.tar.xz"
mkdir -p ./termuxwsl/termuxwsl
sudo tar -xJpf debian.tar.xz -C ./termuxwsl
# Fetch image manifest
manifest=$(docker manifest inspect termux/termux-docker:latest)
# Fetch image digest
digest=$(echo "$manifest" | jq -r ".manifests[] | select(.platform.architecture == \"$ARCH\") | .digest")
# Pull and Export image
docker pull "termux/termux-docker:latest@${digest}"
docker export $(docker create "termux/termux-docker:latest@${digest}") | xz -T 0 > "$GITHUB_WORKSPACE/termux.tar.xz"
sudo cp termux.tar.xz ./termuxwsl/termuxwsl
sudo tar -xJpf ./termuxwsl/termuxwsl/termux.tar.xz
sudo rm ./termuxwsl/termuxwsl/termux.tar.xz
mkdir ./termuxwsl/termuxwsl/usr
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
sudo echo 'nameserver 1.1.1.1' >> ./termuxwsl/etc/resolv.conf



sudo chroot ./termuxwsl apk update
sudo chroot ./termuxwsl apk upgrade
sudo chroot ./termuxwsl apk add bash sudo shadow shadow-login
EOF

sudo cp ./wslconf/oobe.sh ./termuxwsl/etc/oobe.sh
sudo chmod 644 ./termuxwsl/etc/oobe.sh
sudo chmod +x ./termuxwsl/etc/oobe.sh
sudo cp ./wslconf/wsl-distribution-edge.conf ./termuxwsl/etc/wsl-distribution.conf
sudo chmod 644 ./termuxwsl/etc/wsl-distribution.conf
sudo mkdir -p ./termuxwsl/usr/lib/wsl/
sudo cp ./wslconf/icon.ico ./termuxwsl/usr/lib/wsl/icon.ico


cd ./termuxwsl
sudo tar --numeric-owner --absolute-names -c  * | gzip --best > ../install.tar.gz
mv ../install.tar.gz ../alpine-edge-$ARCH.wsl

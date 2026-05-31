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
echo "RELEASE=$RELEASE" >> "$GITHUB_OUTPUT"
echo "ARCH=$ARCH" >> "$GITHUB_OUTPUT"

# start build
# Fetch image manifest
manifest=$(docker manifest inspect termux/termux-docker-pacman:latest)
# Fetch image digest
digest=$(echo "$manifest" | jq -r ".manifests[] | select(.platform.architecture == \"$ARCH\") | .digest")
# Pull and Export image
docker pull "termux/termux-docker-pacman:latest@${digest}"
docker export $(docker create "termux/termux-docker-pacman:latest@${digest}") --output $GITHUB_WORKSPACE/termux.tar
cd ./dump
sudo cp termux.tar ./dump
sudo tar -xpf ./dump/termux.tar -C ./dump
sudo rm ./dump/termux.tar

sudo cp ./wslconf/wsl.sh ./dump/wsl.sh
sudo cp ./wslconf/wsl-distribution-pacman.conf ./dump/etc/wsl-distribution.conf
sudo chmod 644 ./dump/etc/wsl-distribution.conf
sudo mkdir -p ./dump/usr/lib/wsl/
sudo cp ./wslconf/icon.ico ./dump/usr/lib/wsl/icon.ico

cd ./dump
sudo tar --numeric-owner --absolute-names -c  * | gzip --best > ../install.tar.gz
mv ../install.tar.gz ../termux-pacman-wsl-$ARCH.wsl
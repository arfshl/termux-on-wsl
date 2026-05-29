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
manifest=$(docker manifest inspect termux/termux-docker:latest)
# Fetch image digest
digest=$(echo "$manifest" | jq -r ".manifests[] | select(.platform.architecture == \"$ARCH\") | .digest")
# Pull and Export image
docker pull "termux/termux-docker:latest@${digest}"
docker export $(docker create "termux/termux-docker:latest@${digest}") | xz -T 0 > "$GITHUB_WORKSPACE/termux.tar.xz"
mkdir -p ./termuxwsl
sudo tar -xJpf termux.tar.xz -C ./termuxwsl
sudo cp ./wslconf/oobe.sh ./termuxwsl/etc/oobe.sh
sudo chmod 644 ./termuxwsl/etc/oobe.sh
sudo chmod +x ./termuxwsl/etc/oobe.sh
sudo cp ./wslconf/wsl-distribution-edge.conf ./termuxwsl/etc/wsl-distribution.conf
sudo chmod 644 ./termuxwsl/etc/wsl-distribution.conf
sudo mkdir -p ./termuxwsl/usr/lib/wsl/
sudo cp ./wslconf/icon.ico ./termuxwsl/usr/lib/wsl/icon.ico

cat <<-EOF | sudo unshare -mpf bash -e -
sudo mount --bind /dev ./termuxwsl/dev
sudo mount --bind /proc ./termuxwsl/proc
sudo mount --bind /sys ./termuxwsl/sys
sudo echo 'nameserver 1.1.1.1' >> ./termuxwsl/etc/resolv.conf

sudo chroot ./termuxwsl apk update
sudo chroot ./termuxwsl apk upgrade
sudo chroot ./termuxwsl apk add bash sudo shadow shadow-login
EOF

cd ./termuxwsl
sudo tar --numeric-owner --absolute-names -c  * | gzip --best > ../install.tar.gz
mv ../install.tar.gz ../alpine-edge-$ARCH.wsl
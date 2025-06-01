#!/usr/bin/bash
#
# Copyright (c) 2025 Arkria. All Rights Reserved.
# WARN: USE AT YOUR OWN RISK. THIS SHOULD WORK, BUT I'M NOT RESPONSIBLE FOR ANY DANGER TO YOUR DEVICE.

DEPS="wget tar make filesystem glibc sed util-linux po4a automake autoconf acl po4a git libtool clang"
WORKDIR="$(mktemp -d --suffix _ACF)"
ZSH_COMFIGURE_REPO="https://github.com/AkinaLTS/zsh.git"

# Ensure that we are rooted.
if [[ $(id -u) -ne 0 ]]; then
    echo "Run this with root user."
    exit 128
fi

# Change /etc/resolv.conf
# To solve the proble that we cant reach the internet
rm -rf /etc/resolv.conf
echo "nameserver 223.5.5.5
nameserver 1.1.1.1" >/etc/resolv.conf

# Re-compile fakeroot with tcp ipc
# So that we can usr AUR mormally.

pacman -Syu
pacman -Sy ${DEPS} --needed --noconfirm --overwrite "*"

# Download the code source
sudo mkdir ${WORKDIR} -p || exit 1	
sudo chown $(whoami):$(whoami) ${WORKDIR} -R
wget ${DOWNURL} -O ${WORKDIR}/fr.tgz || exit 1
cd ${WORKDIR} || exit 1
tar xvf fr.tgz || exit 1

# Compile temp fakeroot exectuble
cd ${WORKDIR}/fakeroot*/
./bootstrap
./configure --prefix=${WORKDIR} --libdir=${WORKDIR}/fakeroot/libs --disable-static --with-ipc=tcp
make -j$(nproc)
sudo make install

# create temporary soft link.
sudo rm /usr/bin/faked
sudo rm /usr/bin/fakeroot
sudo ln -s ${WORKDIR}/bin/fakeroot /usr/bin/
sudo ln -s ${WORKDIR}/bin/faked /usr/bin/

# clone fakeroot-tcp source code
git clone https://aur.archlinux.org/fakeroot-tcp.git

# makepkg 
cd fakeroot-tcp || exit 1
makepkg

# Install fakeroot-tcp
echo "安装fakeroot-tcp"
sudo pacman -U --overwrite "*" fakeroot*.pkg.tar.xz --noconfirm
sudo rm -rf ${WORKDIR}

# Install zsh
git clone ${ZSH_COMFIGURE_REPO}
./zsh/zsh.sh --auto
hash -r
zshtheme pure

# Add archlinuxcn repo, mirrored by BFSU
cat << 'EOF' >> /etc/pacman.conf
[archlinuxcn]
Server = https://mirrors.bfsu.edu.cn/archlinuxcn/$arch/
EOF
pacman -Syyu archlinuxcn-keyring

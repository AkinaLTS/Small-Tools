#!/usr/bin/env bash
#Started at 2023-12-09 01:29:04
#Finished at 2023-12-09 02:00:59
#by nya
#自动处理chroot容器的fakeroot问题
#
#################################
#       BEGIN OF SCRIPT         #
#################################


DOWNURL="https://ftp.debian.org/debian/pool/main/f/fakeroot/fakeroot_1.31.orig.tar.gz"
SOLVERTMP="/opt/FRF"
sudo rm -rf ${SOLVERTMP}

#检测命令
sudo pacman -Syu
sudo pacman -Sy wget tar make filesystem glibc sed util-linux po4a automake autoconf acl po4a git libtool clang --needed --noconfirm

if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
	echo -e "简单的./运行就可以了！"
	exit 0
fi

#获取源码
echo "获取源码"
sudo mkdir ${SOLVERTMP} -p || exit 1	
sudo chown $(whoami):$(whoami) ${SOLVERTMP} -R
wget ${DOWNURL} -O ${SOLVERTMP}/fr.tgz || exit 1
cd ${SOLVERTMP} || exit 1
tar xvf fr.tgz || exit 1

#编译临时fakeroot
echo "编译临时fakeroot"
cd ${SOLVERTMP}/fakeroot*/
./bootstrap
./configure --prefix=${SOLVERTMP} --libdir=${SOLVERTMP}/fakeroot/libs --disable-static --with-ipc=tcp
make -j$(nproc)
sudo make install

#创建临时软链接
echo "创建临时软链接"
sudo rm /usr/bin/faked
sudo rm /usr/bin/fakeroot
sudo ln -s ${SOLVERTMP}/bin/fakeroot /usr/bin/
sudo ln -s ${SOLVERTMP}/bin/faked /usr/bin/

#克隆fakeroot-tcp源码
echo "克隆fakeroot-tcp源码"
git clone https://aur.archlinux.org/fakeroot-tcp.git

#构建PKG
echo "构建PKG"
cd fakeroot-tcp || exit 1
makepkg

#安装fakeroot-tcp
echo "安装fakeroot-tcp"
sudo pacman -U --overwrite "*" fakeroot*.pkg.tar.xz --noconfirm
sudo rm -rf ${SOLVERTMP}

#################################
#         END OF SCRIPT         #
#################################

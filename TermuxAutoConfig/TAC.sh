#!/usr/bin/bash
#by AtopesSayuri

set -x

# 部分准备
termux-setup-storage
termux-wake-lock
CWD="$(pwd)"
TMPDIR="$(mktemp -d --suffix=_TAC)"
cd ${TMP}

# 字体替换
## 下载Jetbrain Nerdfont
wget https://github.com/subframe7536/maple-font/releases/latest/MapleMonoNL-NF-CN-unhinted.zip -O maple.zip
## 解压
unzip Maple.zip
## 替换字体
mv MapleMonoNL-NF-CN-Regular.ttf ${HOME}/.termux/font.ttf
rm *.ttf*

# 复位
termux-wake-unlock
cd ${CWD}
rm -rf ${TMPDIR}

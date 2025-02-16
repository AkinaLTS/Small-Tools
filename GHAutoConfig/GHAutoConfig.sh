#!/bin/bash
#By nya
#2023.6.12,23:00.
set -e
set -x
# 配置默认初始仓库分支为main
git config --global init.defaultBranch "main"
# 配置username(可改为你自己的GitHub用户名)
git config --global user.name "AkinaLTS"
# 配置用户邮箱(可改为你自己注册GitHub邮箱)
git config --global user.email "108107785+AkinaLTS@users.noreply.github.com"
# 配置最大缓冲区大小为10G(防止推送/拉取失败)
git config --global http.postBuffer 10737418240
git config --global https.postBuffer 10737418240
# 使用gpg签名提交
git config --global commit.gpgsign true
git config --global user.signingkey E089711B4C7C2FA1
##########

#!/bin/bash

# reference
# https://github.com/dandavison/delta
# https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Pagers.md

get_latest_ver() {
    local target_repo=$2
    local latest_ver=$(curl -s "https://api.github.com/repos/${target_repo}/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
    eval "$1=${latest_ver}"
}

check_url() {
    curl -f --head -s $1 > /dev/null
}

# jnvのインストール
TARGET_REPO="ynqa/jnv"
TARGET_NAME="jnv"
EXT_DIR="jnv_temp"
get_latest_ver LATEST_VER "${TARGET_REPO}"
TARGET_URL="https://github.com/${TARGET_REPO}/releases/download/v${LATEST_VER}/${TARGET_NAME}-x86_64-unknown-linux-musl.tar.xz"
if $(check_url "${TARGET_URL}"); then
    curl -s "${TARGET_URL}" -Lo ~/Downloads/${TARGET_NAME}.tar.xz
    pushd ~/Downloads
    mkdir ./${EXT_DIR}
    tar -xvf ./${TARGET_NAME}.tar.xz --strip-components=1 -C ./${EXT_DIR} > /dev/null
    mv ./${EXT_DIR}/jnv ~/.local/bin/
    rm -rf ./${TARGET_NAME}.tar.xz
    rm -rf ./${EXT_DIR}
    popd
else
    echo "Error: ${TARGET_NAME} download URL does not exist: ${TARGET_URL}"
    exit 1
fi

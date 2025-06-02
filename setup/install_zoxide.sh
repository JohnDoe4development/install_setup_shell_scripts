#!/bin/bash

check_url() {
    curl -f --head -s $1 > /dev/null
}

# zoxideのインストール
LATEST_ZOXIDE_VER=$(curl -s "https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
ZOXIDE_URL="https://github.com/ajeetdsouza/zoxide/releases/download/v${LATEST_ZOXIDE_VER}/zoxide_${LATEST_ZOXIDE_VER}-1_amd64.deb"
if $(check_url "${ZOXIDE_URL}"); then
    curl -s "${ZOXIDE_URL}" -Lo ~/Downloads/zoxide.deb
    pushd ~/Downloads
    sudo apt install -y ./zoxide.deb
    rm -rf ./zoxide.deb
    echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
    echo >> ~/.bashrc
    popd
else
    echo "Error: zoxide download URL does not exist: ${ZOXIDE_URL}"
    exit 1
fi
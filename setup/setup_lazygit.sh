#!/bin/bash

check_url() {
    curl -f --head -s $1 > /dev/null
}

apt-get update
apt-get install -q -y curl git

mkdir -p ~/Downloads
mkdir -p ~/.local/bin
mkdir -p ~/.config/lazygit

LATEST_LAZYGIT_VER=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LATEST_LAZYGIT_VER}/lazygit_${LATEST_LAZYGIT_VER}_Linux_x86_64.tar.gz"
if $(check_url "${LAZYGIT_URL}"); then
    curl -s "${LAZYGIT_URL}" -Lo ~/Downloads/lazygit.tar.gz
    pushd ~/Downloads
    mkdir ./lazygit_temp
    tar -xzf ./lazygit.tar.gz -C ./lazygit_temp
    mv ./lazygit_temp/lazygit ~/.local/bin/
    rm -rf ./lazygit.tar.gz
    rm -rf ./lazygit_temp
    popd
else
    echo "Error: lazygit download URL does not exist: ${LAZYGIT_URL}"
    exit 1
fi

tee ~/.config/lazygit/config.yml << EOF > /dev/null
gui:
  language: 'ja'
EOF

echo 'export PATH=${PATH}:~/.local/bin' >> ~/.bashrc
echo >> ~/.bashrc

#!/usr/bin/env bash

mkdir -p ~/bin
mkdir -p ~/Downloads
cd ~/Downloads

mkdir -p ~/Downloads/tmp_lazygit
pushd ~/Downloads/tmp_lazygit

# lazygit
LAZYGIT_VER=0.48.0
mkdir -p ./tmp_lazygit
pushd ./tmp_lazygit
wget --quiet -O lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VER}/lazygit_${LAZYGIT_VER}_Linux_x86_64.tar.gz
tar -xzf lazygit.tar.gz
chmod +x lazygit
mv ./lazygit ~/bin/

popd
rm -rf ~/Downloads/tmp_lazygit

mkdir -p ~/.config/lazygit
tee ~/.config/lazygit/config.yml << EOF > /dev/null
gui:
  language: 'ja'
EOF

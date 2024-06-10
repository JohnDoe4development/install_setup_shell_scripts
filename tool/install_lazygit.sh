#!/usr/bin/env bash

mkdir -p ~/Downloads
cd ~/Downloads

# lazygit
wget -O lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v0.41.0/lazygit_0.41.0_Linux_x86_64.tar.gz
tar -xzf lazygit.tar.gz
chmod +x lazygit
mv ./lazygit ~/bin/

mkdir -p ~/.config/lazygit
tee ~/.config/lazygit/config.yml << EOF > /dev/null
gui:
  language: 'ja'
EOF

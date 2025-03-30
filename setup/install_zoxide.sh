#!/bin/bash

# zoxide
wget --quiet -O ./zoxide.tar.gz https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.7/zoxide-0.9.7-x86_64-unknown-linux-musl.tar.gz
mkdir ./zoxide && tar -xzf zoxide.tar.gz -C ./zoxide
mv ./zoxide ~/bin/
echo 'export PATH=${PATH}:~/bin/zoxide' >> ~/.bashrc
echo 'eval "$(zoxide init bash)"' >> ~/.bashrc

rm -rf ./zoxide.tar.gz

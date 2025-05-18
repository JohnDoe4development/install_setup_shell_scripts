#!/bin/bash

# reference
# https://github.com/dandavison/delta
# https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Pagers.md

get_latest_ver() {
    local target_repo=$2
    local latest_ver=$(curl -s "https://api.github.com/repos/${target_repo}/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+')
    eval "$1=${latest_ver}"
}

check_url() {
    curl -f --head -s $1 > /dev/null
}

# deltaのインストール
TARGET_REPO="dandavison/delta"
TARGET_NAME="git-delta"
get_latest_ver LATEST_VER "${TARGET_REPO}"
TARGET_URL="https://github.com/${TARGET_REPO}/releases/download/${LATEST_VER}/${TARGET_NAME}_${LATEST_VER}_amd64.deb"
if $(check_url "${TARGET_URL}"); then
    curl -s "${TARGET_URL}" -Lo ~/Downloads/${TARGET_NAME}.deb
    pushd ~/Downloads
    apt install -y ./${TARGET_NAME}.deb
    rm -rf ./${TARGET_NAME}.deb
    popd
else
    echo "Error: ${TARGET_NAME} download URL does not exist: ${TARGET_URL}"
    exit 1
fi

# gitのdiffツールとして使用するためのセットアップ
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3

git config --global delta.line-numbers true
git config --global delta.side-by-side true
git config --global delta.syntax-theme  'Monokai Extended'

# lazygitでdeltaを使うためのセットアップ
mkdir -p ~/.config/lazygit
tee -a ~/.config/lazygit/config.yml << "EOF" > /dev/null

git:
  paging:
    colorArg: always
    pager: delta --paging=never --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"
EOF

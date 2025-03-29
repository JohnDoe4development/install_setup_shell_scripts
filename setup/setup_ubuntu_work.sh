#!/usr/bin/env bash

# init
sudo apt-get update && sudo apt-get upgrade

# work
mkdir -p ~/work
mkdir -p ~/work/dev
mkdir -p ~/work/dev/github_pj
mkdir -p ~/work/dev/other_pj
mkdir -p ~/bin
mkdir -p ~/.local/bin
mkdir ~/Downloads

# ~/.bashrc
echo 'export PATH=$PATH:~/bin:~/.local/bin' >> ~/.bashrc
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' ~/.bashrc
# ~/.bash_aliases
echo "alias ls='ls -la'" >> ~/.bash_aliases

# set title for windows terminal
tee -a ~/.bashrc << "EOF" > /dev/null
settitle () {
  # export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  echo -ne '\033]0;'"$1"'\a'
}
settitle ${USER}@${NAME}

EOF

# git settings for WSL
tee -a ~/.bashrc << "EOF" > /dev/null
PS1=${PS1::-3}'$(\__git_ps1)\$ '
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUPSTREAM=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWSTASHSTATE=1
EOF

# ホームディレクトリの日本語フォルダを強制的に英語名フォルダに変更
sudo -u ${USER} LANG=C xdg-user-dirs-update --force

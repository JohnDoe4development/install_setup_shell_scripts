#!/bin/bash
# https://github.com/b-ryan/powerline-shell

FG_NUM=53
BG_NUM=172

case $1 in
  1)
  NAME=Ubuntu
  FG_NUM=53
  BG_NUM=172
  ;;
  2)
  NAME=WSL
  FG_NUM=53
  BG_NUM=172
  ;;
  3)
  NAME=Docker
  FG_NUM=53
  BG_NUM=111
  ;;
  4)
  NAME=EC2
  FG_NUM=15
  BG_NUM=172
  ;;
  5)
  NAME=Cloud9
  FG_NUM=15
  BG_NUM=57
  ;;
  *)
  NAME=Ubuntu
  FG_NUM=53
  BG_NUM=172
esac

sudo apt-get install -y python3-pip
pip install powerline-shell

tee -a ~/.bashrc << "EOF" > /dev/null
# powerline-shell
function _update_ps1() {
    PS1="$(~/.local/bin/powerline-shell $?)"
}

if [ "$TERM" != "linux" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
EOF

mkdir -p ~/.config/powerline-shell
# powerline-shell --generate-config > ~/.config/powerline-shell/config.json
tee ~/.config/powerline-shell/config.json << EOF > /dev/null
{
  "segments": [
    {
      "type": "stdout",
      "command": ["echo", "${NAME}"],
      "fg_color": ${FG_NUM},
      "bg_color": ${BG_NUM}
    },
    "virtual_env",
    "username",
    "ssh",
    "cwd",
    "newline",
    "git",
    "hg",
    "jobs",
    "root"
  ],
  "cwd": {
    "max_depth": 10,
    "max_dir_size": 30,
    "full_cwd": true
  }
}
EOF

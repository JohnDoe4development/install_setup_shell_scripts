#!/usr/bin/env bash

mkdir -p ~/bin
mkdir -p ~/Downloads
cd ~/Downloads

# fzf
sudo apt install -y fzf
echo 'source /usr/share/doc/fzf/examples/key-bindings.bash' >> ~/.bashrc

tee -a ~/.bashrc << EOF > /dev/null
export FZF_DEFAULT_OPTS="--ansi -e --prompt='QUERY> ' --layout=reverse --border=rounded --height 100%"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=header,grid --line-range :100 {}'"
export FZF_ALT_C_OPTS="--preview 'exa {} -h -T -F  --no-user --no-time --no-filesize --no-permissions --long | head -200'"
export FZF_DEFAULT_COMMAND="fd -H -E .git --color=always"
export FZF_CTRL_T_COMMAND="fd --type f -H -E .git"
export FZF_ALT_C_COMMAND="fd --type d -H -E .git"

EOF

# ---

# fd
sudo apt install -y fd-find
ln -s $(which fdfind) /home/${USER}/.local/bin/fd

# ---

# bat
BAT_VER=0.24.0
wget --quiet https://github.com/sharkdp/bat/releases/download/v${BAT_VER}/bat_${BAT_VER}_amd64.deb
sudo dpkg -i bat_${BAT_VER}_amd64.deb
rm -rf bat_${BAT_VER}_amd64.deb

# ---

# exa
EXA_VER=0.10.1
wget --quiet https://github.com/ogham/exa/releases/download/v${EXA_VER}/exa-linux-x86_64-v${EXA_VER}.zip
unzip exa-linux-x86_64-v${EXA_VER}.zip
sudo cp bin/exa /usr/local/bin/
rm -rf exa-linux-x86_64-v${EXA_VER}.zip bin completions man

# ---

# tfz
tee ~/bin/tfz << "EOF" > /dev/null
#!/bin/bash

grep_cmd="grep --recursive --line-number --invert-match --regexp '^\s*$' * 2>/dev/null"

if type "rg" >/dev/null 2>&1; then
    grep_cmd="rg --hidden --no-ignore --line-number --no-heading --invert-match '^\s*$' 2>/dev/null"
fi

read -r file line <<<"$(eval $grep_cmd | fzf --select-1 --exit-0 | awk -F: '{print $1, $2}')"
( [[ -z "$file" ]] || [[ -z "$line" ]] ) && exit
$EDITOR $file +$line
EOF

chmod 755 ~/bin/tfz
echo "export EDITOR=vim" >> ~/.bashrc
echo "bind '\"\C-f\":\"tfz\C-m\"'" >> ~/.bashrc


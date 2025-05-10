#!/bin/bash

check_url() {
    curl -f --head -s $1 > /dev/null
}

apt-get update
apt-get install -q -y curl

mkdir -p ~/Downloads
mkdir -p ~/.local/bin

# fzf
LATEST_FZF_VER=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
FZF_URL="https://github.com/junegunn/fzf/releases/download/v${LATEST_FZF_VER}/fzf-${LATEST_FZF_VER}-linux_amd64.tar.gz"
if $(check_url "${FZF_URL}"); then
    curl -s "${FZF_URL}" -Lo ~/Downloads/fzf.tar.gz
    pushd ~/Downloads
    tar -xzf ./fzf.tar.gz
    mv ./fzf ~/.local/bin/
    rm -rf ./fzf.tar.gz
    FZF_KEYBINDINGS_URL="https://raw.githubusercontent.com/junegunn/fzf/refs/tags/v${LATEST_FZF_VER}/shell/key-bindings.bash"
    if $(check_url "${FZF_KEYBINDINGS_URL}"); then
        curl -s "${FZF_KEYBINDINGS_URL}" -Lo ~/.local/bin/fzf-key-bindings.bash
        echo >> ~/.bashrc
        echo 'source ~/.local/bin/fzf-key-bindings.bash' >> ~/.bashrc
        echo >> ~/.bashrc
    else
        echo "Error: fzf key-bindings download URL does not exist: ${FZF_KEYBINDINGS_URL}"
        exit 1
    fi
    popd
else
    echo "Error: fzf download URL does not exist: ${FZF_URL}"
    exit 1
fi

tee -a ~/.bashrc << EOF > /dev/null
export FZF_DEFAULT_OPTS="--ansi -e --prompt='QUERY> ' --layout=reverse --border=rounded --height 100%"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=header,grid --line-range :100 {}'"
export FZF_ALT_C_OPTS="--preview 'eza {} -h -T -F  --no-user --no-time --no-filesize --no-permissions --long | head -200'"
export FZF_DEFAULT_COMMAND="fd -H -E .git --color=always"
export FZF_CTRL_T_COMMAND="fd --type f -H -E .git"
export FZF_ALT_C_COMMAND="fd --type d -H -E .git"
EOF

# ---

# fd-find
LATEST_FD_VER=$(curl -s "https://api.github.com/repos/sharkdp/fd/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
FD_URL="https://github.com/sharkdp/fd/releases/download/v${LATEST_FD_VER}/fd-v${LATEST_FD_VER}-x86_64-unknown-linux-musl.tar.gz"
if $(check_url "${FD_URL}"); then
    curl -s "${FD_URL}" -Lo ~/Downloads/fd.tar.gz
    pushd ~/Downloads
    mkdir ./fd_temp
    tar -xzf ./fd.tar.gz --strip-components=1 -C ./fd_temp
    mv ./fd_temp/fd ~/.local/bin/
    rm -rf ./fd.tar.gz
    rm -rf ./fd_temp
    popd
else
    echo "Error: fd download URL does not exist: ${FD_URL}"
    exit 1
fi

# ---

# bat
LATEST_BAT_VER=$(curl -s "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
BAT_URL="https://github.com/sharkdp/bat/releases/download/v${LATEST_BAT_VER}/bat_${LATEST_BAT_VER}_amd64.deb"
if $(check_url "${BAT_URL}"); then
    curl -s "${BAT_URL}" -Lo ~/Downloads/bat.deb
    pushd ~/Downloads
    apt install -y ./bat.deb
    rm -rf ./bat.deb
    echo >> ~/.bashrc
    popd
else
    echo "Error: bat download URL does not exist: ${BAT_URL}"
    exit 1
fi

# ---

# eza
LATEST_EZA_VER=$(curl -s "https://api.github.com/repos/eza-community/eza/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
EZA_URL="https://github.com/eza-community/eza/releases/download/v${LATEST_EZA_VER}/eza_x86_64-unknown-linux-musl.tar.gz"
if $(check_url "${EZA_URL}"); then
    curl -s "${EZA_URL}" -Lo ~/Downloads/eza.tar.gz
    pushd ~/Downloads
    tar -xzf ./eza.tar.gz
    mv ./eza ~/.local/bin/
    rm -rf ./eza.tar.gz
    popd
else
    echo "Error: eza download URL does not exist: ${EZA_URL}"
    exit 1
fi

# ---

# tfz
tee ~/.local/bin/tfz << "EOF" > /dev/null
#!/bin/bash

grep_cmd="grep --recursive --line-number --invert-match --regexp '^\s*$' * 2>/dev/null"

if type "rg" >/dev/null 2>&1; then
    grep_cmd="rg --hidden --no-ignore --line-number --no-heading --invert-match '^\s*$' 2>/dev/null"
fi

read -r file line <<<"$(eval $grep_cmd | fzf --select-1 --exit-0 | awk -F: '{print $1, $2}')"
( [[ -z "$file" ]] || [[ -z "$line" ]] ) && exit
$EDITOR $file +$line
EOF

chmod 755 ~/.local/bin/tfz
echo 'export PATH=${PATH}:~/.local/bin' >> ~/.bashrc
echo "export EDITOR=vim" >> ~/.bashrc
echo "bind '\"\C-f\":\"tfz\C-m\"'" >> ~/.bashrc
echo >> ~/.bashrc

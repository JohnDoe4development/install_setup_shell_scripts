#!/bin/bash

SKEL_DIR=/etc/skel

rc_files=(
    ".bashrc"
    ".bashrc_add"
)

# ---

check_url() {
    curl -f --head -s $1 > /dev/null
}

setup_fzf_bashrc() {
    for rc_file in "${rc_files[@]}"; do
        tee -a ${SKEL_DIR}/${rc_file} <<- "EOF" > /dev/null

		# fzf settings
		source /etc/fzf/conf/fzf-key-bindings.bash
		source /etc/fzf/conf/fzf-completion.bash
		export FZF_TMUX_OPTS="-p 80%"
		export FZF_DEFAULT_OPTS="--ansi -e --prompt='QUERY> ' --layout=reverse --border=rounded --height 100%"
		export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=header,grid --line-range :100 {}'"
		export FZF_ALT_C_OPTS="--preview 'eza {} -h -T -F  --no-user --no-time --no-filesize --no-permissions --long | head -200'"
		export FZF_DEFAULT_COMMAND="fd -H -E .git --color=always"
		export FZF_CTRL_T_COMMAND="fd --type f -H -E .git"
		export FZF_ALT_C_COMMAND="fd --type d -H -E .git"

		export EDITOR=vim
		bind '"\C-f":"tfz\C-m"'

		EOF
    done
}

add_vimrc() {
    tee ${SKEL_DIR}/.vimrc <<- EOF > /dev/null
	set nu
	" set nonu
	set autoread
	colorscheme monokai

	" ctrl +s: save file
	nnoremap <C-s> :w<CR>
	inoremap <C-s> <ESC>:w<CR>
	set mouse=a
	set paste
	EOF

    git clone https://github.com/sickill/vim-monokai.git
    mkdir -p ${SKEL_DIR}/.vim/colors
    mv vim-monokai/colors/monokai.vim ${SKEL_DIR}/.vim/colors/
    rm -rf vim-monokai

    mkdir -p ~/.vim
    rsync -av ${SKEL_DIR}/.vim ~/
    cp ${SKEL_DIR}/.vimrc ~/
}

# ---

sudo apt-get update
sudo apt-get install -q -y curl
mkdir -p ~/Downloads

# fzfのインストール
LATEST_FZF_VER=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
FZF_URL="https://github.com/junegunn/fzf/releases/download/v${LATEST_FZF_VER}/fzf-${LATEST_FZF_VER}-linux_amd64.tar.gz"
if $(check_url "${FZF_URL}"); then
    curl -s "${FZF_URL}" -Lo ~/Downloads/fzf.tar.gz
    pushd ~/Downloads
    tar -xzf ./fzf.tar.gz
    mv ./fzf /usr/local/bin/
    rm -rf ./fzf.tar.gz
    sudo mkdir -p /etc/fzf/conf
    FZF_KEYBINDINGS_URL="https://raw.githubusercontent.com/junegunn/fzf/refs/tags/v${LATEST_FZF_VER}/shell/key-bindings.bash"
    if $(check_url "${FZF_KEYBINDINGS_URL}"); then
        sudo curl -s "${FZF_KEYBINDINGS_URL}" -Lo /etc/fzf/conf/fzf-key-bindings.bash
    else
        echo "Error: fzf key-bindings download URL does not exist: ${FZF_KEYBINDINGS_URL}"
        exit 1
    fi
    FZF_COMPLETION_BASH_URL="https://raw.githubusercontent.com/junegunn/fzf/refs/tags/v${LATEST_FZF_VER}/shell/completion.bash"
    if $(check_url "${FZF_COMPLETION_BASH_URL}"); then
        sudo curl -s "${FZF_COMPLETION_BASH_URL}" -Lo /etc/fzf/conf/fzf-completion.bash
    else
        echo "Error: fzf completion.bash download URL does not exist: ${FZF_COMPLETION_BASH_URL}"
        exit 1
    fi
    FZF_TMUX_URL="https://raw.githubusercontent.com/junegunn/fzf/refs/tags/v${LATEST_FZF_VER}/bin/fzf-tmux"
    if $(check_url "${FZF_TMUX_URL}"); then
        sudo curl -s "${FZF_TMUX_URL}" -Lo /usr/local/bin/fzf-tmux
        sudo chmod +x /usr/local/bin/fzf-tmux
    else
        echo "Error: fzf-tmux download URL does not exist: ${FZF_COMPLETION_BASH_URL}"
          exit 1
    fi
    popd
else
    echo "Error: fzf download URL does not exist: ${FZF_URL}"
    exit 1
fi

# ---

# fd-find
LATEST_FD_VER=$(curl -s "https://api.github.com/repos/sharkdp/fd/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
FD_URL="https://github.com/sharkdp/fd/releases/download/v${LATEST_FD_VER}/fd-v${LATEST_FD_VER}-x86_64-unknown-linux-musl.tar.gz"
if $(check_url "${FD_URL}"); then
    curl -s "${FD_URL}" -Lo ~/Downloads/fd.tar.gz
    pushd ~/Downloads
    mkdir ./fd_temp
    tar -xzf ./fd.tar.gz --strip-components=1 -C ./fd_temp
    mv ./fd_temp/fd /usr/local/bin/
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
    sudo apt install -y ./bat.deb
    rm -rf ./bat.deb
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
    mv ./eza /usr/local/bin/
    rm -rf ./eza.tar.gz
    popd
else
    echo "Error: eza download URL does not exist: ${EZA_URL}"
    exit 1
fi

# ---

# tfz
tee /usr/local/bin/tfz << "EOF" > /dev/null
#!/bin/bash

grep_cmd="grep --recursive --line-number --invert-match --regexp '^\s*$' * 2>/dev/null"

if type "rg" >/dev/null 2>&1; then
    grep_cmd="rg --hidden --no-ignore --line-number --no-heading --invert-match '^\s*$' 2>/dev/null"
fi

read -r file line <<<"$(eval $grep_cmd | fzf --select-1 --exit-0 | awk -F: '{print $1, $2}')"
( [[ -z "$file" ]] || [[ -z "$line" ]] ) && exit
$EDITOR $file +$line
EOF

chmod 755 /usr/local/bin/tfz
setup_fzf_bashrc
add_vimrc

for username in $(ls /home); do
    mkdir -p /home/${username}/.vim
    rsync -av ${SKEL_DIR}/.vim /home/${username}/
    chown -R ${username}:${username} /home/${username}/.vim
    cp ${SKEL_DIR}/.vimrc /home/${username}/
    chown -R ${username}:${username} /home/${username}/.vimrc

    mv /home/${username}/.bashrc /home/${username}/.bashrc.bak
    cat /home/${username}/.bashrc.bak ${SKEL_DIR}/.bashrc_add >> /home/${username}/.bashrc
    chown -R ${username}:${username} /home/${username}/.bashrc
    rm -rf /home/${username}/.bashrc.bak
done
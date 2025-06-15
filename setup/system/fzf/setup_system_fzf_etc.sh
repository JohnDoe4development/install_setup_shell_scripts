#!/bin/bash

echo ">>> DEBUG"

<< COMMENT
AIによる要約
■ インストールされるツール:
   1. fzf:
       * 最新版のfzfバイナリ (fzf) をダウンロードし、/usr/local/bin/ に配置します。
       * fzfのキーバインディング (fzf-key-bindings.bash) と補完スクリプト (fzf-completion.bash) をGitHubからダウンロードし、/etc/fzf/conf/
         に保存します。
       * fzf-tmux (fzf-tmux) とfzfプレビュースクリプト (fzf-preview.sh) をダウンロードし、/usr/local/bin/ に配置し、実行権限を付与します。
       * カスタム設定ファイル (.fzfrc) を/etc/fzf/conf/ にコピーします。
       * fzfのbash補完スクリプト (fzf-bash-completion.sh) を/usr/local/bin/ にコピーし、実行権限を付与します。
       * fzfのセットアップフックスクリプト (fzf-sethook.bash) を/etc/skel/.config/bash/completion.d/ にコピーし、実行権限を付与します。
   2. fd-find:
       * 最新版のfdバイナリをダウンロードし、/usr/local/bin/ に配置します。
   3. bat:
       * 最新版のbatの.debパッケージをダウンロードし、apt install を使用してインストールします。
   4. eza:
       * 最新版のezaバイナリをダウンロードし、/usr/local/bin/ に配置します。
   5. tfz:
       * /usr/local/bin/tfz に、grep (またはripgrep)
         とfzfを組み合わせてファイル内のテキストを検索し、エディタで開くためのカスタムスクリプトを作成し、実行権限を付与します。

  FZF関連の設定:
   * /etc/skel/.bashrc および /etc/skel/.bashrc_add
     にFZFの設定を追加します。これには、fzfの補完とキーバインディングのソース指定、FZF関連の環境変数（FZF_DEFAULT_OPTS_FILE, FZF_TMUX_OPTS,
     FZF_DEFAULT_COMMAND, FZF_CTRL_T_COMMAND, FZF_ALT_C_COMMAND）の設定、およびfzfタブ補完に関する設定が含まれます。
   * FZF_CTRL_R_OPTS (履歴検索), FZF_CTRL_T_OPTS (ファイル検索), FZF_ALT_C_OPTS (ディレクトリ移動)
     のプロンプトやプレビューなどの詳細なオプションを設定します。
   * C-f に tfz コマンドをバインドします。
   * 既存のユーザー (/home ディレクトリ内のユーザーとrootユーザー) のホームディレクトリに対して、.bashrc
     ファイルを更新し、FZF関連の設定を適用します。また、fzf-sethook.bashをユーザーの.config/bash/completion.dにコピーします。

  このスクリプトは、これらのツールをシステム全体で利用できるようにするための設定とインストールを自動化するものです。
COMMENT

echo "<<< DEBUG"

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
		source /etc/fzf/conf/fzf-completion.bash
		source /etc/fzf/conf/fzf-key-bindings.bash

		export FZF_DEFAULT_OPTS_FILE=/etc/fzf/conf/.fzfrc
		export FZF_TMUX_OPTS="-p 80%"

		export FZF_DEFAULT_COMMAND="fd -H -E .git --color=always"
		export FZF_CTRL_T_COMMAND="fd --type f -H -E .git"
		export FZF_ALT_C_COMMAND="fd --type d -H -E .git"

		export FZF_CTRL_R_OPTS="--prompt='CMD> ' --border-label ' History Search ' \
		                        --header '実行したいコマンドを選択してください.'"
		export FZF_CTRL_T_OPTS="--prompt='FILE> ' --border-label ' File Search ' \
		                        --header-label ' File Type ' \
		                        --preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}'"
		export FZF_ALT_C_OPTS="--prompt='DIR> ' --border-label ' Move to Dir ' \
		                        --header '移動先のディレクトリを選択してください.' \
		                        --preview 'eza {} -T -a -F | head -200'"

		FZF_TAB_COMPLETIONS="$(
		  if [ -d ~/.config/bash/completion.d ]; then
		    run-parts --list --regex '\.bash$' ~/.config/bash/completion.d
		  fi
		)"
		for FZF_TAB_COMPLETION in ${FZF_TAB_COMPLETIONS}; do
		    . ${FZF_TAB_COMPLETION}
		done

		# txt fzf
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
    FZF_PREVIEW_URL="https://raw.githubusercontent.com/junegunn/fzf/refs/tags/v${LATEST_FZF_VER}/bin/fzf-preview.sh"
    if $(check_url "${FZF_PREVIEW_URL}"); then
        sudo curl -s "${FZF_PREVIEW_URL}" -Lo /usr/local/bin/fzf-preview.sh
        sudo chmod +x /usr/local/bin/fzf-preview.sh
    else
        echo "Error: fzf-preview.sh download URL does not exist: ${FZF_COMPLETION_BASH_URL}"
          exit 1
    fi
    popd
else
    echo "Error: fzf download URL does not exist: ${FZF_URL}"
    exit 1
fi

git clone https://github.com/lincheney/fzf-tab-completion.git ~/Downloads/fzf-tab-completion
mkdir -p ${SKEL_DIR}/.config/bash/scripts
cp ~/Downloads/fzf-tab-completion/bash/fzf-bash-completion.sh ${SKEL_DIR}/.config/bash/scripts/
chmod +x ${SKEL_DIR}/.config/bash/scripts/fzf-bash-completion.sh
rm -rf ~/Downloads/fzf-tab-completion

mkdir -p ${SKEL_DIR}/.config/bash/completion.d
tee ${SKEL_DIR}/.config/bash/completion.d/fzf-sethook.bash << EOF > /dev/null
# @(#) fzf completion with bash cli

function fzf-sethook() {
  export FZF_DEFAULT_OPTS="--height 40% --border"
  . "/usr/local/bin/fzf-bash-completion.sh"
  bind -x '"\e[Z": fzf_bash_completion'
}

fzf --version >/dev/null 2>&1 && fzf-sethook
unset fzf-sethook

EOF

rsync -av templates/.fzfrc /etc/fzf/conf/

rsync -av templates/fzf-bash-completion.sh /usr/local/bin/
chmod +x /usr/local/bin/fzf-bash-completion.sh

mkdir -p ${skel_dir}/.config/bash/completion.d
rsync -av templates/fzf-sethook.bash ${skel_dir}/.config/bash/completion.d/
chmod +x ${skel_dir}/.config/bash/completion.d/fzf-sethook.bash

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

for username in $(ls /home) root; do
    if [ "$username" = "root" ]; then
        home_dir="/root"
    else
        home_dir="/home/${username}"
    fi

    if [ -d "${SKEL_DIR}/.config/bash/completion.d" ]; then
        mkdir -p ${home_dir}/.config/bash/completion.d
        rsync -av ${SKEL_DIR}/.config/bash/completion.d/fzf-sethook.bash ${home_dir}/.config/bash/completion.d
        chown -R ${username}:${username} ${home_dir}/.config/bash
    fi

    mkdir -p ${home_dir}/.vim
    rsync -av ${SKEL_DIR}/.vim ${home_dir}/
    chown -R ${username}:${username} ${home_dir}/.vim
    cp ${SKEL_DIR}/.vimrc ${home_dir}/
    chown -R ${username}:${username} ${home_dir}/.vimrc

    mv ${home_dir}/.bashrc ${home_dir}/.bashrc.bak
    cat ${home_dir}/.bashrc.bak ${SKEL_DIR}/.bashrc_add >> ${home_dir}/.bashrc
    chown -R ${username}:${username} ${home_dir}/.bashrc
    rm -rf ${home_dir}/.bashrc.bak
done

#!/bin/bash

SKEL_DIR=/etc/skel

rc_files=(
    ".bashrc"
    ".bashrc_add"
)

plugins=(
    "yazi-rs/plugins:full-border"
    "yazi-rs/plugins:smart-enter"
    "yazi-rs/plugins:toggle-pane"
    "yazi-rs/plugins:chmod"
    "dedukun/bookmarks"
    "yazi-rs/plugins:git"
    "yazi-rs/plugins:jump-to-char"
    "yazi-rs/plugins:smart-filter"
)

# ---

check_url() {
    curl -f --head -s $1 > /dev/null
}

setup_fzf_bashrc() {
    for rc_file in "${rc_files[@]}"; do
        sudo tee -a ${SKEL_DIR}/${rc_file} <<- "EOF" > /dev/null

		# fzf settings
		source /etc/fzf/conf/fzf-key-bindings.bash
		source /etc/fzf/conf/fzf-completion.bash

		EOF
    done
}

setup_zoxide_bashrc() {
    for rc_file in "${rc_files[@]}"; do
        sudo tee -a ${SKEL_DIR}/${rc_file} <<- "EOF" > /dev/null
		# zoxide settings
		eval "$(zoxide init bash)"

		EOF
    done
}

setup_yazi_bashrc() {
    for rc_file in "${rc_files[@]}"; do
        sudo tee -a ${SKEL_DIR}/${rc_file} <<- "EOF" > /dev/null
		# yazi settings
		export SHELL=/bin/bash
		export EDITOR=vim

		function yazi_cd() {
		    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
		    yazi "$@" --cwd-file="$tmp"
		    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		        builtin cd -- "$cwd"
		    fi
		    rm -f -- "$tmp"
		}
		if which yazi >& /dev/null && [[ -t 1 ]]; then
		    bind '"\C-o":"yazi_cd\C-m"'
		fi

		function _update_ps1() {
		    if (which powerline-shell >& /dev/null); then
		        PS1="$(/usr/local/bin/powerline-shell $?)"
		    fi
		    if (which yazi >& /dev/null); then
		        [ -n "$YAZI_LEVEL" ] && PS1="$PS1"'(in yazi[$YAZI_LEVEL]) '
		    fi
		}
		if [ "$TERM" != "linux" ]; then
		    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
		fi
		EOF
        echo >> ${SKEL_DIR}/${rc_file}
    done
}

setup_ya_bashrc() {
    for rc_file in "${rc_files[@]}"; do
        sudo tee -a ${SKEL_DIR}/${rc_file} <<- EOF > /dev/null
		plugin_dir="\${HOME}/.config/yazi/plugins"
		if [ ! -d "\${plugin_dir}" ]; then
		    mkdir -p \${plugin_dir}
		$(
		for plugin in "${plugins[@]}"; do
		    echo "    ya pkg add ${plugin}"
		done
		)
		fi
		EOF
        echo >> ${SKEL_DIR}/${rc_file}
    done
}

add_vimrc() {
    sudo tee ${SKEL_DIR}/.vimrc <<- EOF > /dev/null
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

add_tmuxconf() {
    cp ${SKEL_DIR}/.tmux.conf ${HOME}/
}

add_bashrc() {
    mv ${HOME}/.bashrc ${HOME}/.bashrc.bak
    cat ${HOME}/.bashrc.bak ${SKEL_DIR}/.bashrc_add >> ${HOME}/.bashrc
    rm -rf ${HOME}/.bashrc.bak
}

# ---

sudo apt-get update
sudo apt-get install -q -y sudo unzip curl git vim rsync
sudo apt-get install -q -y ffmpeg 7zip poppler-utils imagemagick
mkdir -p ~/Downloads

# ---

# jqのインストール
LATEST_JQ_VER=$(curl -s "https://api.github.com/repos/jqlang/jq/releases/latest" | grep -Po '"tag_name": "jq-\K[0-9.]+')
JQ_URL="https://github.com/jqlang/jq/releases/download/jq-${LATEST_JQ_VER}/jq-linux-amd64"
if $(check_url "${JQ_URL}"); then
    curl -s "${JQ_URL}" -Lo ~/Downloads/jq
    pushd ~/Downloads
    chmod +x ./jq
    mv ./jq /usr/local/bin/
    popd
else
    echo "Error: jq download URL does not exist: $JQ_URL"
    exit 1
fi

# ---

# fd-findのインストール
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

# ripgrepのインストール
LATEST_RG_VER=$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+')
RG_URL="https://github.com/BurntSushi/ripgrep/releases/download/${LATEST_RG_VER}/ripgrep-${LATEST_RG_VER}-x86_64-unknown-linux-musl.tar.gz"
if $(check_url "${RG_URL}"); then
    curl -s "${RG_URL}" -Lo ~/Downloads/rg.tar.gz
    pushd ~/Downloads
    mkdir ./rg_temp
    tar -xzf ./rg.tar.gz --strip-components=1 -C ./rg_temp
    mv ./rg_temp/rg /usr/local/bin/
    rm -rf ./rg.tar.gz
    rm -rf ./rg_temp
    popd
else
    echo "Error: ripgrep download URL does not exist: ${RG_URL}"
    exit 1
fi

# ---

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
        curl -s "${FZF_COMPLETION_BASH_URL}" -Lo /etc/fzf/conf/fzf-completion.bash
    else
        echo "Error: fzf completion.bash download URL does not exist: ${FZF_COMPLETION_BASH_URL}"
        exit 1
    fi
    setup_fzf_bashrc
    popd
else
    echo "Error: fzf download URL does not exist: ${FZF_URL}"
    exit 1
fi

# ---

# zoxideのインストール
LATEST_ZOXIDE_VER=$(curl -s "https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
ZOXIDE_URL="https://github.com/ajeetdsouza/zoxide/releases/download/v${LATEST_ZOXIDE_VER}/zoxide_${LATEST_ZOXIDE_VER}-1_amd64.deb"
if $(check_url "${ZOXIDE_URL}"); then
    curl -s "${ZOXIDE_URL}" -Lo ~/Downloads/zoxide.deb
    pushd ~/Downloads
    sudo apt install -y ./zoxide.deb
    rm -rf ./zoxide.deb
    setup_zoxide_bashrc
    popd
else
    echo "Error: zoxide download URL does not exist: ${ZOXIDE_URL}"
    exit 1
fi

# ---

# yaziのインストール
LATEST_YAZI_VER=$(curl -s "https://api.github.com/repos/sxyazi/yazi/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
YAZI_URL="https://github.com/sxyazi/yazi/releases/download/v${LATEST_YAZI_VER}/yazi-x86_64-unknown-linux-musl.zip"
if $(check_url "${YAZI_URL}"); then
    curl -s "${YAZI_URL}" -Lo ~/Downloads/yazi.zip
    pushd ~/Downloads
    unzip ./yazi.zip -d ./
    rm -rf ./yazi.zip
    mv ./yazi-x86_64-unknown-linux-musl/ ./yazi/
    mv ./yazi/yazi /usr/local/bin/
    mv ./yazi/ya /usr/local/bin/
    rm -rf ./yazi
    popd
else
    echo "Error: yazi download URL does not exist: ${YAZI_URL}"
    exit 1
fi

sudo mkdir -p /etc/yazi/config
YAZI_CONFIG_HOME=/etc/yazi/config

# 設定ファイルとテーマをダウンロード
git clone https://github.com/sxyazi/yazi.git ${YAZI_CONFIG_HOME}/yazi
git clone https://github.com/yazi-rs/flavors.git ${YAZI_CONFIG_HOME}/flavors

pushd ${YAZI_CONFIG_HOME}

# edit yazi.toml
cp yazi/yazi-config/preset/yazi-default.toml ./yazi.toml
sed -i 's/^linemode.*$/linemode       = "size"/g' ./yazi.toml
sed -i "s/^show_hidden.*$/show_hidden    = true/g" ./yazi.toml

# edit keymap.toml
cp yazi/yazi-config/preset/keymap-default.toml ./keymap.toml
sed -i "s/arrow prev/arrow -1/g" ./keymap.toml
sed -i "s/arrow next/arrow 1/g" ./keymap.toml

# create theme.toml
sudo tee ./theme.toml << "EOF" > /dev/null
# If the user's terminal is in dark mode, Yazi will load `theme-dark.toml` on startup; otherwise, `theme-light.toml`.
# You can override any parts of them that are not related to the dark/light mode in your own `theme.toml`.

# If you want to dynamically override their content based on dark/light mode, you can specify two different flavors
# for dark and light modes under `[flavor]`, and do so in those flavors instead.
"$schema" = "https://yazi-rs.github.io/schemas/theme.json"

# vim:fileencoding=utf-8:foldmethod=marker

# : Flavor {{{

[flavor]
dark  = "dracula"
light = "catppuccin-latte"

# : }}}

EOF

# plugins
for plugin in "${plugins[@]}"; do
    /usr/local/bin/ya pkg add ${plugin}
done

sudo tee ./init.lua <<- "EOF" > /dev/null
require("full-border"):setup()

require("smart-enter"):setup {
	open_multi = true,
}

require("bookmarks"):setup({
	last_directory = { enable = false, persist = false, mode="dir" },
	persist = "none",
	desc_format = "full",
	file_pick_mode = "hover",
	custom_desc_input = false,
	notify = {
		enable = false,
		timeout = 1,
		message = {
			new = "New bookmark '<key>' -> '<folder>'",
			delete = "Deleted bookmark in '<key>'",
			delete_all = "Deleted all bookmarks",
		},
	},
})

require("git"):setup()

Status:children_add(function(self)
	local h = self._current.hovered
    local symlink = ""
    if h and h.link_to then
		symlink = " -> " .. tostring(h.link_to)
	else
		symlink =  ""
	end
    return ui.Line {
        ui.Span(symlink):fg("#af87ff"),
        " [",
        ui.Span(os.date("%Y-%m-%d %H:%M", tostring(h.cha.mtime):sub(1, 10))):fg("#af87ff"),
        "] ",
	}
end, 3300, Status.LEFT)

Status:children_add(function()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ""
	end

	return ui.Line {
		"[",
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("#af87ff"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("#af87ff"),
		"]",
		" ",
	}
end, 500, Status.RIGHT)

EOF

sudo tee -a ./keymap.toml << "EOF" > /dev/null
[[mgr.prepend_keymap]]
on   = "!"
run  = 'shell "$SHELL" --block'
desc = "Open shell here"

[[mgr.prepend_keymap]]
on   = "<Enter>"
run  = "plugin smart-enter"
desc = "Enter the child directory, or open the file"

[[mgr.prepend_keymap]]
on   = "T"
run  = "plugin toggle-pane min-preview"
desc = "Show or hide the preview pane"

[[mgr.prepend_keymap]]
on   = "i"
run  = "plugin toggle-pane max-preview"
desc = "Maximize or restore the preview pane"

[[mgr.prepend_keymap]]
on   = [ "c", "m" ]
run  = "plugin chmod"
desc = "Chmod on selected files"

[[mgr.prepend_keymap]]
on = [ "B", "S" ]
run = "plugin bookmarks save"
desc = "Save current position as a bookmark"

[[mgr.prepend_keymap]]
on = [ "B", "J" ]
run = "plugin bookmarks jump"
desc = "Jump to a bookmark"

[[mgr.prepend_keymap]]
on = [ "b", "d" ]
run = "plugin bookmarks delete"
desc = "Delete a bookmark"

[[mgr.prepend_keymap]]
on = [ "b", "D" ]
run = "plugin bookmarks delete_all"
desc = "Delete all bookmarks"

[[mgr.prepend_keymap]]
on   = "f"
run  = "plugin jump-to-char"
desc = "Jump to char"

[[mgr.prepend_keymap]]
on   = "F"
run  = "plugin smart-filter"
desc = "Smart filter"

EOF

sudo tee -a ./yazi.toml << EOF > /dev/null

[[plugin.prepend_fetchers]]
id   = "git"
name = "*"
run  = "git"

[[plugin.prepend_fetchers]]
id   = "git"
name = "*/"
run  = "git"

EOF

# ---

mkdir -p ./plugins/smart-tab.yazi
sudo tee ./plugins/smart-tab.yazi/main.lua << EOF > /dev/null
--- @sync entry
return {
	entry = function()
		local h = cx.active.current.hovered
		ya.mgr_emit("tab_create", h and h.cha.is_dir and { h.url } or { current = true })
	end,
}
EOF

sudo tee -a ./keymap.toml << "EOF" > /dev/null
[[mgr.prepend_keymap]]
on   = "t"
run  = "plugin smart-tab"
desc = "Create a tab and enter the hovered directory"
EOF

# ---

mkdir -p ./plugins/smart-switch.yazi
sudo tee ./plugins/smart-switch.yazi/main.lua << EOF > /dev/null
--- @sync entry
local function entry(_, job)
	local cur = cx.active.current
	for _ = #cx.tabs, job.args[1] do
		ya.mgr_emit("tab_create", { cur.cwd })
		if cur.hovered then
			ya.mgr_emit("reveal", { cur.hovered.url })
		end
	end
	ya.mgr_emit("tab_switch", { job.args[1] })
end

return { entry = entry }
EOF

sudo tee -a ./keymap.toml << "EOF" > /dev/null
[[mgr.prepend_keymap]]
on   = "2"
run  = "plugin smart-switch 1"
desc = "Switch or create tab 2"

[[mgr.prepend_keymap]]
on   = "3"
run  = "plugin smart-switch 2"
desc = "Switch or create tab 3"
EOF

rm -rf ./yazi
popd

# ---

# edit ~/.tmux.conf
sudo tee -a ${SKEL_DIR}/.tmux.conf << EOF > /dev/null

set -g allow-passthrough on
set -ga update-environment TERM
set -ga update-environment TERM_PROGRAM

EOF

# ---

setup_yazi_bashrc
setup_ya_bashrc
rsync -av /etc/yazi/config/ ${HOME}/.config/yazi
chown -R $(whoami):$(whoami) ${HOME}/.config

add_vimrc
add_tmuxconf
add_bashrc

for username in $(ls /home); do
    mkdir -p /home/${username}/.config
    rsync -av /etc/yazi/config/ /home/${username}/.config/yazi
    rsync -av ~/.config/yazi/plugins /home/${username}/.config/yazi
    chown -R ${username}:${username} /home/${username}/.config

    mkdir -p /home/${username}/.vim
    rsync -av ${SKEL_DIR}/.vim /home/${username}/
    chown -R ${username}:${username} /home/${username}/.vim
    cp ${SKEL_DIR}/.vimrc /home/${username}/
    chown -R ${username}:${username} /home/${username}/.vimrc

    cp ${SKEL_DIR}/.tmux.conf /home/${username}/
    chown -R ${username}:${username} /home/${username}/.tmux.conf

    mv /home/${username}/.bashrc /home/${username}/.bashrc.bak
    cat /home/${username}/.bashrc.bak ${SKEL_DIR}/.bashrc_add >> /home/${username}/.bashrc
    chown -R ${username}:${username} /home/${username}/.bashrc
    rm -rf /home/${username}/.bashrc.bak
done

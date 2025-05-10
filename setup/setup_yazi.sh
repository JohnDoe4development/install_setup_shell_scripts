#!/bin/bash

check_url() {
    curl -f --head -s $1 > /dev/null
}

apt-get update
apt-get install -q -y unzip curl git
apt-get install -q -y ffmpeg 7zip poppler-utils imagemagick

mkdir -p ~/.config
mkdir -p ~/.local/bin
mkdir -p ~/.config/yazi/
mkdir -p ~/Downloads
echo 'export PATH=${PATH}:~/.local/bin' >> ~/.bashrc
echo >> ~/.bashrc

# ---

# jqのインストール
LATEST_JQ_VER=$(curl -s "https://api.github.com/repos/jqlang/jq/releases/latest" | grep -Po '"tag_name": "jq-\K[0-9.]+')
JQ_URL="https://github.com/jqlang/jq/releases/download/jq-${LATEST_JQ_VER}/jq-linux-amd64"
if $(check_url "${JQ_URL}"); then
    curl -s "${JQ_URL}" -Lo ~/Downloads/jq
    pushd ~/Downloads
    chmod +x ./jq
    mv ./jq ~/.local/bin/
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
    mv ./fd_temp/fd ~/.local/bin/
    rm -rf ./fd.tar.gz
    rm -rf ./fd_temp
    popd
else
    echo "Error: fd download URL does not exist: ${FD_URL}"
    # exit 1
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
    mv ./rg_temp/rg ~/.local/bin/
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
    mv ./fzf ~/.local/bin/
    rm -rf ./fzf.tar.gz
    FZF_KEYBINDINGS_URL="https://raw.githubusercontent.com/junegunn/fzf/refs/tags/v${LATEST_FZF_VER}/shell/key-bindings.bash"
    if $(check_url "${FZF_KEYBINDINGS_URL}"); then
        curl -s "${FZF_KEYBINDINGS_URL}" -Lo ~/.local/bin/fzf-key-bindings.bash
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

# ---

# zoxideのインストール
LATEST_ZOXIDE_VER=$(curl -s "https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
ZOXIDE_URL="https://github.com/ajeetdsouza/zoxide/releases/download/v${LATEST_ZOXIDE_VER}/zoxide_${LATEST_ZOXIDE_VER}-1_amd64.deb"
if $(check_url "${ZOXIDE_URL}"); then
    curl -s "${ZOXIDE_URL}" -Lo ~/Downloads/zoxide.deb
    pushd ~/Downloads
    apt install -y ./zoxide.deb
    rm -rf ./zoxide.deb
    echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
    echo >> ~/.bashrc
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
    mv ./yazi/ ~/.local/bin/
    echo 'export PATH=${PATH}:~/.local/bin/yazi' >> ~/.bashrc
    popd
else
    echo "Error: yazi download URL does not exist: ${YAZI_URL}"
    exit 1
fi

# 設定ファイルとテーマをダウンロード
git clone https://github.com/sxyazi/yazi.git ~/.config/yazi/yazi
git clone https://github.com/yazi-rs/flavors.git ~/.config/yazi/flavors

pushd ~/.config/yazi

# edit yazi.toml
cp yazi/yazi-config/preset/yazi-default.toml ./yazi.toml
sed -i 's/^linemode.*$/linemode       = "size"/g' ./yazi.toml
sed -i "s/^show_hidden.*$/show_hidden    = true/g" ./yazi.toml

# edit keymap.toml
cp yazi/yazi-config/preset/keymap-default.toml ./keymap.toml
sed -i "s/arrow prev/arrow -1/g" ./keymap.toml
sed -i "s/arrow next/arrow 1/g" ./keymap.toml

# create theme.toml
tee ./theme.toml << "EOF" > /dev/null
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
~/.local/bin/yazi/ya pack -a yazi-rs/plugins:full-border
~/.local/bin/yazi/ya pack -a yazi-rs/plugins:smart-enter
~/.local/bin/yazi/ya pack -a yazi-rs/plugins:toggle-pane
~/.local/bin/yazi/ya pack -a yazi-rs/plugins:chmod
~/.local/bin/yazi/ya pack -a dedukun/bookmarks
~/.local/bin/yazi/ya pack -a yazi-rs/plugins:git
~/.local/bin/yazi/ya pack -a yazi-rs/plugins:jump-to-char
~/.local/bin/yazi/ya pack -a yazi-rs/plugins:smart-filter

tee ./init.lua <<- "EOF" > /dev/null
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

tee -a ./keymap.toml << "EOF" > /dev/null
[[manager.prepend_keymap]]
on   = "!"
run  = 'shell "$SHELL" --block'
desc = "Open shell here"

[[manager.prepend_keymap]]
on   = "<Enter>"
run  = "plugin smart-enter"
desc = "Enter the child directory, or open the file"

[[manager.prepend_keymap]]
on   = "T"
run  = "plugin toggle-pane min-preview"
desc = "Show or hide the preview pane"

[[manager.prepend_keymap]]
on   = "i"
run  = "plugin toggle-pane max-preview"
desc = "Maximize or restore the preview pane"

[[manager.prepend_keymap]]
on   = [ "c", "m" ]
run  = "plugin chmod"
desc = "Chmod on selected files"

[[manager.prepend_keymap]]
on = [ "B", "S" ]
run = "plugin bookmarks save"
desc = "Save current position as a bookmark"

[[manager.prepend_keymap]]
on = [ "B", "J" ]
run = "plugin bookmarks jump"
desc = "Jump to a bookmark"

[[manager.prepend_keymap]]
on = [ "b", "d" ]
run = "plugin bookmarks delete"
desc = "Delete a bookmark"

[[manager.prepend_keymap]]
on = [ "b", "D" ]
run = "plugin bookmarks delete_all"
desc = "Delete all bookmarks"

[[manager.prepend_keymap]]
on   = "f"
run  = "plugin jump-to-char"
desc = "Jump to char"

[[manager.prepend_keymap]]
on   = "F"
run  = "plugin smart-filter"
desc = "Smart filter"

EOF

tee -a ./yazi.toml << EOF > /dev/null

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

mkdir -p ~/.config/yazi/plugins/smart-tab.yazi
tee ~/.config/yazi/plugins/smart-tab.yazi/main.lua << EOF > /dev/null
--- @sync entry
return {
	entry = function()
		local h = cx.active.current.hovered
		ya.mgr_emit("tab_create", h and h.cha.is_dir and { h.url } or { current = true })
	end,
}
EOF

tee -a ./keymap.toml << "EOF" > /dev/null
[[manager.prepend_keymap]]
on   = "t"
run  = "plugin smart-tab"
desc = "Create a tab and enter the hovered directory"
EOF

# ---

mkdir -p ./plugins/smart-switch.yazi
tee ~/.config/yazi/plugins/smart-switch.yazi/main.lua << EOF > /dev/null
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

tee -a ./keymap.toml << "EOF" > /dev/null
[[manager.prepend_keymap]]
on   = "2"
run  = "plugin smart-switch 1"
desc = "Switch or create tab 2"

[[manager.prepend_keymap]]
on   = "3"
run  = "plugin smart-switch 2"
desc = "Switch or create tab 3"
EOF

rm -rf ./yazi
popd

# ---

# edit ~/.tmux.conf
tee ~/.tmux.conf << EOF > /dev/null
set -g allow-passthrough on
set -ga update-environment TERM
set -ga update-environment TERM_PROGRAM

EOF

# ---

# edit ~/.bashrc
tee -a ~/.bashrc <<- "EOF" > /dev/null

# yazi settings
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
        PS1="$(~/.local/bin/powerline-shell $?)"
    fi
    if (which yazi >& /dev/null); then
        [ -n "$YAZI_LEVEL" ] && PS1="$PS1"'(in yazi[$YAZI_LEVEL]) '
    fi
}
if [ "$TERM" != "linux" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
EOF

echo "export SHELL=/bin/bash" >> ~/.bashrc
echo "export EDITOR=vim" >> ~/.bashrc
echo >> ~/.bashrc

#!/bin/bash

apt-get install -y ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick

mkdir -p ~/.config
mkdir -p ~/.config/yazi/
mkdir -p ~/Downloads

# yaziのインストール
YAZI_VER="25.3.2"
wget -q -O ~/Downloads/yazi.zip https://github.com/sxyazi/yazi/releases/download/v${YAZI_VER}/yazi-x86_64-unknown-linux-musl.zip
cd ~/Downloads
unzip yazi.zip
rm -rf yazi.zip
mv yazi-x86_64-unknown-linux-musl/ yazi/
mv yazi/ ~/bin/
echo 'export PATH=${PATH}:~/bin/yazi' >> ~/.bashrc

# 設定ファイルとテーマをダウンロード
git clone https://github.com/sxyazi/yazi.git ~/.config/yazi/yazi
git clone https://github.com/yazi-rs/flavors.git ~/.config/yazi/flavors

pushd ~/.config/yazi

# edit yazi.toml
cp yazi/yazi-config/preset/yazi-default.toml ./yazi.toml
sed -i "s/show_hidden    = false/show_hidden    = true/g" ./yazi.toml

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
~/bin/yazi/ya pack -a yazi-rs/plugins:full-border
~/bin/yazi/ya pack -a yazi-rs/plugins:smart-enter
~/bin/yazi/ya pack -a yazi-rs/plugins:toggle-pane
~/bin/yazi/ya pack -a yazi-rs/plugins:chmod
~/bin/yazi/ya pack -a dedukun/bookmarks
cp -r ~/.config/yazi/plugins ./ 
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
on   = "T"
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
on = [ "B", "L" ]
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

EOF
rm -rf ./yazi
popd

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
EOF

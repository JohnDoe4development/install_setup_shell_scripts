#!/usr/bin/env bash

# ranger
sudo apt install -y ranger w3m lynx highlight atool mediainfo xpdf caca-utils

ranger --copy-config=all
sed -i 's/set show_hidden false/set show_hidden true/' ~/.config/ranger/rc.conf
sed -i 's/set draw_borders none/set draw_borders both/' ~/.config/ranger/rc.conf
sed -i 's/set preview_directories true/set preview_directories false/' ~/.config/ranger/rc.conf
sed -i 's/set line_numbers false/set line_numbers true/' ~/.config/ranger/rc.conf
sed -i 's/set dirname_in_tabs false/set dirname_in_tabs true/' ~/.config/ranger/rc.conf
sed -i 's/set one_indexed false/set one_indexed true/' ~/.config/ranger/rc.conf

tee -a ~/.bashrc << EOF > /dev/null
# ranger settings
[ -n "$RANGER_LEVEL" ] && PS1="$PS1"'(in ranger) '

# ranger_cd
ranger_cd() {
    temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
    ranger --choosedir="$temp_file" -- "${@:-$PWD}"
    if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
        cd -- "$chosen_dir"
    fi
    rm -f -- "$temp_file"
}

# This binds Ctrl-O to ranger_cd:
if which ranger >& /dev/null && [[ -t 1 ]]; then
    bind '"\C-o":"ranger_cd\C-m"'
fi
EOF

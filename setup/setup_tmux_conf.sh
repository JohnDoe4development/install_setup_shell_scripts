#!/usr/bin/env bash

sudo apt install -y tmux ansifilter

# tmux conf
if [ ! -e ~/.tmux.conf ]; then
    tee ~/.tmux.conf <<- "EOF" > /dev/null
	# マウスでウィンドウ・ペインの切り替えやリサイズを可能にする
	set-option -g mouse on

	# コピーモードのキー操作をviライクにする
	set-window-option -g mode-keys vi

	# ウィンドウ履歴の最大行数
	set-option -g history-limit 50000

	# 新規ウィンドウを同じディレクトリで起動
	bind c new-window -c "#{pane_current_path}"
	bind '"' split-window -c "#{pane_current_path}" -v
	bind '%' split-window -c "#{pane_current_path}" -h

	# ---

	# ウィンドウの作成・移動・入れ替えのキーバインド
	bind -n S-left prev
	bind -n S-right next
	bind -n C-S-left swap-window -t -1
	bind -n C-S-right swap-window -t +1

	# セッション移動のキーバインド
	bind -n S-down switch-client -n
	bind -n S-up switch-client -p

	# ---

	# 境界線の表示を点線に変更
	set -g pane-border-lines simple

	# true colorを表示できるようにする
	set-option -g default-terminal "tmux-256color"

	# アクティブなペインの色
	set -g pane-active-border-style fg=blue
	# set -g pane-active-border-style fg=red
	# 非アクティブなペインの色
	set -g pane-border-style fg=yellow
	# set -g pane-border-style fg=green

	# アクティブなウィンドウの色
	set -g window-active-style 'bg=#1c1c1c'
	# 非アクティブなウィンドウの色
	set -g window-style 'bg=#262626'

	# ---

	# カスタムフォントを設定
	set -g @custom-style '#[fg=white,bg=black]'
	set -g @custom-reverse-style '#[fg=black,bg=white]'

	# ステータスラインを2行に設定
	set-option -g status 2

	# １行目の設定
	# 左寄せ
	set -g status-format[0] '#{?pane_in_mode,#[bg=yellow] COPY ,#{@custom-reverse-style}#{?client_prefix,#[reverse],} TMUX }'
	set -ag status-format[0] '#[align=left]#{@custom-style} USER: #(echo $USER) #{@custom-reverse-style}#{@custom-reverse-style} DISPLAY#(echo $DISPLAY) #[default]#[fg=white]'
	# 右寄せ
	set -ag status-format[0] '#[align=right]#[fg=black]#{@custom-style} up #(~/bin/pc-running-time) #[fg=white]#{@custom-reverse-style} load_average(#(~/bin/loadaverage)) #[fg=black]#{@custom-style} Mem #(~/bin/used-mem)%% #[fg=white]#{@custom-reverse-style} disk:(#(~/bin/disk-info))'

	# 2行目の設定
	# status-left
	set -g status-format[1] '#[align=left range=left #{status-left-style}]#[push-default]#{T;=/#{status-left-length}:status-left}#[pop-default]#[norange default]#'
	# window-status
	set -ag status-format[1] '[list=on align=#{status-justify}]#[list=left-marker]<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index} #{window-status-style}#{?#{&&:#{window_last_flag},#{!=:#{window-status-last-style},default}}, #{window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{window-status-bell-style},default}}, #{window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{window-status-activity-style},default}}, #{window-status-activity-style},}}]#[push-default]#{T:window-status-format}#[pop-default]#[norange default]'
	set -ag status-format[1] '#{?window_end_flag,,#{window-status-separator}},#[range=window|#{window_index} list=focus #{?#{!=:#{window-status-current-style},default},#{window-status-current-style},#{window-status-style}}#{?#{&&:#{window_last_flag},#{!=:#{window-status-last-style},default}}, #{window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{window-status-bell-style},default}}, #{window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{window-status-activity-style},default}}, #{window-status-activity-style},}}]#[push-default]#{T:window-status-current-format}#[pop-default]#[norange list=on default]#{?window_end_flag,,#{window-status-separator}}}#[pop-default]#[norange default]'
	# status-right
	# status-right の設定
	set-option -g status-right-length 200
	set -g status-right '#{cpu_bg_color} CPU: #{cpu_percentage} #[fg=black]#{@custom-style} LANG: #(echo $LANG) #[fg=white]#{@custom-reverse-style} host: #(~/bin/gip) #[fg=black]#{@custom-style} %Y-%m-%d (%a) %H:%M:%S '
	set -ag status-format[1] '#[nolist align=right range=right #{status-right-style}]#{T;=/#{status-right-length}:status-right}#[pop-default]#[norange default]'

	# ---

	# ポップアップウィンドウの表示設定
	bind C-p popup -xC -yC -w95% -h95% -E -d "#{pane_current_path}" '\
	  if [ popup = $(tmux display -p -F "#{session_name}") ]; then \
	    tmux detach-client ; \
	  else \
	    tmux attach -c $(tmux display -p -F "#{pane_current_path}") -t popup || tmux new -s popup ; \
	  fi \
	'

	# ---

	# List of plugins
	set -g @plugin 'tmux-plugins/tpm'
	set -g @plugin 'tmux-plugins/tmux-sensible'
	set -g @plugin 'tmux-plugins/tmux-cpu'
	set -g @plugin 'tmux-plugins/tmux-resurrect'
	set -g @plugin 'tmux-plugins/tmux-continuum'
	set -g @continuum-restore 'on'
	set -g @continuum-save-interval '1'
	set -g @plugin 'tmux-plugins/tmux-logging'

	if "test ! -d ~/.tmux/plugins/tpm" \
	"run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

	# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
	run '~/.tmux/plugins/tpm/tpm'

	EOF
fi

# ---

mkdir -p ~/bin

# used-mem
tee ~/bin/used-mem << "EOF" > /dev/null
#!/bin/bash
#
# Print memory status.
#
#  Usage:
#    used-mem [Output format]
#
#  Default format:
#    #.1u%(#.2UG/#.2TG)
#
#  Format string:
#    #f : Free memory(%).
#    #u : Used memory(%).
#    #F : Free memory(GB).
#    #U : Used memory(GB).
#    #T : Total memory(GB).
#
#  Example:
#    $ used-mem
#    77.5%(6.20G/8.00G)
#
#    $ used-mem '#f%(#FG/#TG)'
#    25%(2G/8G)
#
#    $ used-mem 'Free: #.2f % (#.3F GB) | Used: #.2u % (#.3U GB) | Total: #.3T GB'
#    Free: 38.32 % (3.065 GB) | Used: 61.68 % (4.933 GB) | Total: 7.998 GB
#
#  About vm_stat:
#    Page size: 4096 bytes
#    http://qz.tsugumi.org/man_vm_stat.html
#    http://d.hatena.ne.jp/zariganitosh/20110617/free_memory
#    https://discussionsjapan.apple.com/thread/10093439?start=0&tstart=0
#    http://support.apple.com/kb/HT1342?viewlocale=ja_JP&locale=ja_JP
#    http://www.badrit.com/blog/2014/5/1/how-to-calc-memory-usage-in-mavericks-programmatically#.VXKo2lyqpBc
#    http://www.songmu.jp/riji/entry/2015-05-08-mac-memory.html

DEFAULT_SCALE=${DEFAULT_SCALE:-'.0'}
MAX_SCALE=${MAX_SCALE:-3}


# To round off.
MAX_SCALE=$(($MAX_SCALE + 1))

# This script name.
PROG=$(basename "$0")

# Usage.
USAGE=`cat << __EOF__
Usage:
  $PROG [Output format]
Format string:
  #f : Free memory(%).
  #u : Used memory(%).
  #F : Free memory(GB).
  #U : Used memory(GB).
  #T : Total memory(GB).
__EOF__
`

# Set format.
if [ -z "$1" ]; then
    FORMAT='#.1u%(#.2UG/#.2TG)'
else
    FORMAT=$1
fi

# Cache data.
FREE_MEM=
USED_MEM=
TOTAL_MEM=


# Usage.
exit_usage() {
    echo "$USAGE" 1>&2
    exit 1
}

round_off() {
    local num=$1
    local result

    result=$((($num + 5) / 10))
    result=$(printf "%0${MAX_SCALE}d" $result)
    echo "$result" | sed -e "s/\(.*\)\([0-9]\{$MAX_SCALE\}\)/\1.\2/" -e 's/^\./0./'
}

# Calculate $1/$2(%) to $3 decimal place.
calculate_percent() {
    local num1=$1
    local num2=$2
    local scale=$3
    local result

    if type bc > /dev/null 2>&1; then
        result=$(echo "scale=$MAX_SCALE; 100 * $num1 / $num2" | bc)
    else
        result=$(round_off $(($num1 * 1000 * 10 ** $MAX_SCALE / $num2)))
    fi
    printf "%${scale}f" $result
}

# Convert $1 KB to GB ($2 decimal place).
convert_kb_to_gb() {
    local num=$1
    local scale=$2
    local result

    if type bc > /dev/null 2>&1; then
        result=$(echo "scale=$MAX_SCALE; $num / 1024 / 1024" | bc)
    else
        result=$(round_off $(($num * 10 * 10 ** $MAX_SCALE / 1024 / 1024)))
    fi
    printf "%${scale}f" $result
}

# Conert $1 pages to KB.
convert_pages_to_kb() {
    echo "$(($1 * 4096 / 1024))"
}

# Calculate used memory(KB) and total memory(KB).
calculate_memory() {
    local free_mem
    local used_mem
    local total_mem

    if type vm_stat > /dev/null 2>&1; then
        local vm_stat
        vm_stat=$(vm_stat) || return 1
        local pages_free=$(echo "$vm_stat" | awk '/Pages free/ {print $3}' | tr -d '.')
        local pages_active=$(echo "$vm_stat" | awk '/Pages active/ {print $3}' | tr -d '.')
        local pages_inactive=$(echo "$vm_stat" | awk '/Pages inactive/ {print $3}' | tr -d '.')
        local pages_speculative=$(echo "$vm_stat" | awk '/Pages speculative/ {print $3}' | tr -d '.')
        local pages_wired=$(echo "$vm_stat" | awk '/Pages wired down/ {print $4}' | tr -d '.')
        local pages_compressed=$(echo "$vm_stat" | awk '/Pages stored in compressor/ {print $5}' | tr -d '.')
        local pages_purgeable=$(echo "$vm_stat" | awk '/Pages purgeable/ {print $3}' | tr -d '.')
        local pages_file=$(echo "$vm_stat" | awk '/File-backed pages/ {print $3}' | tr -d '.')
        local pages_app=$(echo "$vm_stat" | awk '/Anonymous pages/ {print $3}' | tr -d '.')

        local used_and_cached_mem=$(($pages_active + $pages_inactive + $pages_speculative + $pages_wired + $pages_compressed))
        local cached_mem=$(($pages_purgeable + $pages_file))

        if type sysctl > /dev/null 2>&1; then
            total_mem=$(sysctl -n 'hw.memsize')
            total_mem=$(($total_mem / 4096))
        else
            total_mem=$(($used_and_cached_mem + $pages_free))
        fi
        used_mem=$(($used_and_cached_mem - $cached_mem))
        free_mem=$(($total_mem - $used_mem))

        used_and_cached_mem=$(convert_pages_to_kb $used_and_cached_mem)
        cached_mem=$(convert_pages_to_kb $cached_mem)
        used_mem=$(convert_pages_to_kb $used_mem)
        free_mem=$(convert_pages_to_kb $free_mem)
        total_mem=$(convert_pages_to_kb $total_mem)

        if [ -n "$DEBUG" ]; then
            {
                echo "Page size: 4096bytes"
                echo "pages_free: $pages_free pages"
                echo "pages_active: $pages_active pages"
                echo "pages_inactive: $pages_Inactive pages"
                echo "pages_speculative: $pages_speculative pages"
                echo "pages_wired: $pages_wired pages"
                echo "pages_compressed: $pages_compressed pages"
                echo "pages_purgeable: $pages_purgeable pages"
                echo "pages_file: $pages_file pages"
                echo "pages_app: $pages_app pages"
                echo
                echo "pages_free: $(convert_pages_to_kb $pages_free) KB"
                echo "pages_active: $(convert_pages_to_kb $pages_active) KB"
                echo "pages_inactive: $(convert_pages_to_kb $pages_inactive) KB"
                echo "pages_speculative: $(convert_pages_to_kb $pages_speculative) KB"
                echo "pages_wired: $(convert_pages_to_kb $pages_wired) KB"
                echo "pages_compressed: $(convert_pages_to_kb $pages_compressed) KB"
                echo "pages_purgeable: $(convert_pages_to_kb $pages_purgeable) KB"
                echo "pages_file: $(convert_pages_to_kb $pages_file) KB"
                echo "pages_app: $(convert_pages_to_kb $pages_app) KB"
                echo
                echo "used_and_cached_mem: $used_and_cached_mem KB"
                echo "cached_mem: $cached_mem KB"
                echo "free_mem: $free_mem KB"
                echo "used_mem: $used_mem KB"
                echo "total_mem: $total_mem KB"
                echo
            } 1>&2
        fi
    elif type free > /dev/null 2>&1; then
        local free
        free=$(free) || return 1
        # free_mem=$(echo "$free" | awk '/-\/\+ buffers\/cache/ {print $4}')
        # used_mem=$(echo "$free" | awk '/-\/\+ buffers\/cache/ {print $3}')
        # total_mem=$(($used_mem + $free_mem))
        free_mem=$(echo "$free" | awk '2==NR {print $4}')
        used_mem=$(echo "$free" | awk '2==NR {print $3}')
        total_mem=$(echo "$free" | awk '2==NR {print $2}')
    else
        echo 'Error: Requires the command free(Linux) or vm_stat(OSX).' 1>&2
        exit 1
    fi

    if [ -n "$DEBUG" ]; then
        {
            echo "free_mem: $(($free_mem / 1024)) MB"
            echo "used_mem: $(($used_mem / 1024)) MB"
            echo "free_mem(%): $(calculate_percent "$free_mem" "$total_mem" '.3')%"
            echo "used_mem(%): $(calculate_percent "$used_mem" "$total_mem" '.3')%"
            echo "total_mem: $(($total_mem / 1024)) MB"
            echo
        } 1>&2
    fi
    # Caching data.
    FREE_MEM=$free_mem
    USED_MEM=$used_mem
    TOTAL_MEM=$total_mem
}

set_up_format() {
    local sigil=$1
    local format=$2

    local -a list
    list=($(echo "$format" | GREP_OPTIONS= grep -o "#[^#${sigil}]*${sigil}"))

    if [ -n "$DEBUG" ]; then
        {
            echo "sigil=$sigil"
            echo "format=$format"
            echo "list=${list[@]}"
        } 1>&2
    fi

    local item
    local scale
    local num
    for item in "${list[@]}"; do
        scale=$(echo "$item" | sed 's/^#\(.*\).$/\1/')
        if [ -z "$scale" ]; then
            scale=$DEFAULT_SCALE
        fi

        # Check scale.
        if [ $(echo "$scale" | sed 's/.*\.//') -ge $MAX_SCALE ]; then
            echo "Error: Illegal scale: $item" 1>&2
            echo "Specify the value less than ${MAX_SCALE}." 1>&2
            exit 1
        fi

        if [ -n "$DEBUG" ]; then
            {
                echo "item=$item"
                echo "scale=$scale"
            } 1>&2
        fi

        case $sigil in
            f)
                num=$(calculate_percent "$FREE_MEM" "$TOTAL_MEM" "$scale") || return 1
                ;;
            u)
                num=$(calculate_percent "$USED_MEM" "$TOTAL_MEM" "$scale") || return 1
                ;;
            F)
                num=$(convert_kb_to_gb "$FREE_MEM" "$scale") || return 1
                ;;
            U)
                num=$(convert_kb_to_gb "$USED_MEM" "$scale") || return 1
                ;;
            T)
                num=$(convert_kb_to_gb "$TOTAL_MEM" "$scale") || return 1
                ;;
            *)
                echo "Error: Illegal sigil: $sigil" 1>&2
                return 1
                ;;
        esac
        item=$(echo "$item" | sed 's/\./\\./')
        format=$(echo "$format" | sed "s/$item/$num/g")

        if [ -n "$DEBUG" ]; then
            {
                echo "num=$num" 1>&2
                echo "item=$item" 1>&2
                echo "format=$format" 1>&2
            } 1>&2
        fi
    done
    echo "$format"
}

# Main
main() {
    calculate_memory || return 1

    local format=$FORMAT
    local sigil
    for sigil in f u F U T; do
        format=$(set_up_format "$sigil" "$format") || return 1
    done

    echo "$format"

    if [ -n "$DEBUG" ]; then
        echo '========== ========== ========== =========' 1>&2
        local debug_format='Free: #.3f % (#.3F GB) | Used: #.3u % (#.3U GB) | Total: #.3T GB'
        for sigil in f u F U T; do
            debug_format=$(set_up_format "$sigil" "$debug_format") || return 1
            echo
        done
        echo "$debug_format" 1>&2
        echo '========== ========== ========== =========' 1>&2
    fi
}

main || exit_usage

EOF
chmod +x ~/bin/used-mem

# ---

# my scripts
# loadaverage
tee ~/bin/loadaverage << "EOF" > /dev/null
#!/bin/sh
uptime | awk -F\  '{print $(NF - 2),$(NF - 1),$NF}'

EOF
chmod +x ~/bin/loadaverage

# pc-running-time
tee ~/bin/pc-running-time << "EOF" > /dev/null
#!/bin/sh
uptime | sed -e 's/.* up *\(.*\)/\1/' -e 's/\(.*\),.* user.*/\1/' | awk -F, '{print $1 $2}' | tr -s ' '

EOF
chmod +x ~/bin/pc-running-time

# disk-info
tee ~/bin/disk-info << "EOF" > /dev/null
#!/bin/bash

df -h | awk '$6 ~ /^\/$/ {print $4 "/" $2}'

EOF
chmod +x ~/bin/disk-info

# get ip address
tee ~/bin/gip << "EOF" > /dev/null
#!/bin/bash

ip route get 8.8.8.8 | head -1 | awk '{print $7}'

EOF
chmod +x ~/bin/gip

# ---

# edit ~/.bashrc
# tmux session select
tee -a ~/.bashrc << "EOF" > /dev/null

# tmux session select
PERCOL=fzf
CMDLINE=$(cat /proc/$$/cmdline | xargs --null)
if [[ ! -n $TMUX && "-bash" = ${CMDLINE} ]]; then
  # get the IDs
  ID="`tmux list-sessions`"
  if [[ -z "$ID" ]]; then
    tmux new-session
  fi
  create_new_session="Create New Session"
  ID="$ID\n${create_new_session}:"
  ID="`echo -e "$ID" | $PERCOL | cut -d: -f1`"
  if [[ "$ID" = "${create_new_session}" ]]; then
    tmux new-session
  elif [[ -n "$ID" ]]; then
    tmux attach-session -t "$ID"
  else
    :  # Start terminal normally
  fi
fi

EOF

# tmux auto logging
tee -a ~/.bashrc << "EOF" > /dev/null

# tmux auto logging
if [ -n "$TMUX_PANE" ] && [ "$TMUX_PANE_AUTORUN" != "0" ]; then
    # set TMUX_LOGGING to the path of your tmux-logging installation.
    TMUX_LOGGING="$HOME/.tmux/plugins/tmux-logging"
    log_file="$HOME/$(date +%Y%m%d-%H%M%S)-$(hostname)-tmux.log"
    $TMUX_LOGGING/scripts/start_logging.sh "${log_file}" "${TMUX_PANE}"

    # Prevent autocommand in subshells. We only want the top shell within a
    # tmux pane to run these commands.
    export TMUX_PANE_AUTORUN=0
fi

EOF

# ---

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

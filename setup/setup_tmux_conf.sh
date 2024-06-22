#!/usr/bin/env bash

# tmux
tee ~/.tmux.conf << EOF > /dev/null
# マウスでウィンドウ・ペインの切り替えやリサイズを可能にする
set-option -g mouse on

# 右クリックでのコンテキストメニューの表示機能を無効化
unbind -n MouseDown3Pane

# コピーモードのキー操作をviライクにする
set-window-option -g mode-keys vi

# ウィンドウ履歴の最大行数
set-option -g history-limit 5000

# 新規ウィンドウを同じディレクトリで起動
bind c new-window -c "#{pane_current_path}"
bind '"' split-window -c "#{pane_current_path}" -v
bind '%' split-window -c "#{pane_current_path}" -h

# ウィンドウの作成・移動・入れ替えのキーバインド
bind -n S-left prev
bind -n S-right next
bind -n C-S-left swap-window -t -1
bind -n C-S-right swap-window -t +1

# セッション移動のキーバインド
bind -n S-down switch-client -n
bind -n S-up switch-client -p

# status
set -g pane-border-status bottom
set -g pane-border-format " [#S-#W] pane: #{pane_index} "

# 非アクティブなペインの色
set -g pane-border-style fg=green
set -g pane-border-style bg="colour235"
# アクティブなペインの色
set -g pane-active-border-style fg=yellow
set -g pane-active-border-style bg="#272822"
EOF

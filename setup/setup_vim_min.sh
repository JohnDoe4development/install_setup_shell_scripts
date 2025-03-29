#!/usr/bin/env bash

mkdir -p ~/bin
mkdir -p ~/Downloads
cd ~/Downloads

# vim
sudo apt-get install -y vim
git clone https://github.com/sickill/vim-monokai.git
mkdir -p ~/.vim/colors
mv vim-monokai/colors/monokai.vim ~/.vim/colors/
rm -rf vim-monokai

# edit ~/.vimrc
tee ~/.vimrc << EOF > /dev/null
set nu
" set nonu
set autoread
set paste
set mouse=a
colorscheme monokai

:nmap <c-s> :w<CR>
:imap <c-s> <Esc>:w<CR>a
EOF

# edit ~/.bashrc
tee -a ~/.bashrc << EOF > /dev/null
bind -r '\C-s'
stty -ixon

EOF
# echo "bind -r '\C-s'" >> ~/.bashrc
# echo "stty -ixon" >> ~/.bashrc

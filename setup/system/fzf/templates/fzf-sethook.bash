# @(#) fzf completion with bash cli

function fzf-sethook() {
  export FZF_DEFAULT_OPTS="--height 40% --border"
  . "/usr/local/bin/fzf-bash-completion.sh"
  bind -x '"\e[Z": fzf_bash_completion'
}

fzf --version >/dev/null 2>&1 && fzf-sethook
unset fzf-sethook

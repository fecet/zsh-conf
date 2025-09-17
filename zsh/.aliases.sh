#!/usr/bin/env zsh
c() {
  if alias clear &>/dev/null; then
    clear "$@"
  elif functions clear &>/dev/null; then
    clear "$@"
  elif [ -x /usr/bin/clear ]; then
    /usr/bin/clear "$@"
  else
    clear "$@"
  fi
}
alias tf=terraform
alias j=just
alias f=fzf
alias s=neofetch
alias ss="kitty +kitten ssh"
alias v="nvim"
alias b="btop"
# alias nv="~/scripts/start_neovide.sh"
alias refresh="exec -l \$SHELL"
alias mm="micromamba"
alias mmac="micromamba activate"
alias sudop="sudo -E env PATH=\$PATH"

alias update-keys="cat ~/.ssh/ssh_keys/* > ~/.ssh/authorized_keys"
alias update-etc="sudo rsync -vrP ~/scripts/etc/ /etc/"
alias zz=__zoxide_zi

# alias det="~/.conda/envs/dl/bin/det"

alias check_mimetype="xdg-mime query filetype"
## modern alternative
# alias ps=procs
# alias ping=gping

alias timevim="vim-startuptime --vimpath=nvim -count 10 -warmup 5 | grep Total"

alias checkmod='stat -c "%a %n"'

function killx() {
  kill -9 $(xprop | grep PID | awk '{print $3}')
}
#alias man=tldr

alias lg=lazygit
alias ra=yy

raa() {
  if [ -z "$RANGER_LEVEL" ]; then
    ranger --choosedir="$HOME/.rangerdir"
    LASTDIR=$(cat "$HOME/.rangerdir")
    cd "$LASTDIR"
  else
    exit
  fi
}

alias wp="zsh ~/scripts/wp-change.sh"

# alias dg="(sudo surface dgpu set on
# sudo surface profile set performance
# sudo iw dev mlan0 set power_save off)"

set_proxy() {
  local url="$1"
  if [[ -z "$url" ]]; then
    echo "用法: set_proxy http://HOST:PORT" >&2
    return 1
  fi
  export http_proxy="$url"
  export https_proxy="$url"
  export HTTP_PROXY="$url"
  export HTTPS_PROXY="$url"
  export no_proxy='localhost,127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.svc,.cluster.local,.bk8s,.lionrock.com'
  export NO_PROXY="$no_proxy"
}

alias prefix-prx="set_proxy http://127.0.0.1:7890"
alias upr='''unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY'''

# alias save-energe="sudo surface profile set low-power"

alias setm=xfce4-settings-manager

if [ "$(command -v exa)" ]; then
  # unalias -m 'll'
  unalias -m 'l'
  # unalias -m 'la'
  # unalias -m 'ls'
  # alias ls='exa -G  --color auto --icons -a -s type'
  # alias ls='exa -G  --color auto --icons -s type'
  alias l='exa -l --color always --icons -a -s type'
fi
if [ "$(command -v eza)" ]; then
  unalias -m 'll'
  unalias -m 'l'
  unalias -m 'la'
  # unalias -m 'ls'
  # alias ls='exa -G  --color auto --icons -a -s type'
  # alias ls='exa -G  --color auto --icons -s type'
  alias l='eza -l --color always --icons -a -s type'
fi

if [ "$(command -v bat)" ]; then
  unalias -m 'cat'
  alias cat='bat -pp --theme="Dracula"'
fi

if [ "$(command -v yay)" ]; then
  # alias yay='pacstall'
  alias Syu='yay -Sy archlinux-keyring archlinuxcn-keyring'
  alias Syd='yay -Qtdq | grep -E -- '-debug$' | yay -Rns -'
fi
if [ "$(command -v nvim)" ]; then
  # alias yay='pacstall'
  alias vim='nvim --clean'
fi
if [ "$(command -v fastfetch)" ]; then
  # alias yay='pacstall'
  alias s=fastfetch
fi

if [ "$(command -v helix)" ]; then
  # alias yay='pacstall'
  alias vim=helix
fi

if [ "$(command -v kitten)" ]; then
  alias e="kitten edit-in-kitty"
else
  alias e="nvim"
fi

function add-kernel() {
  # bash ~/scripts/setup/install_basics.sh
  python -m ipykernel install --user --name $CONDA_DEFAULT_ENV --display-name "Python $(python-version) ($CONDA_DEFAULT_ENV)"
  json_file="$HOME/.local/share/jupyter/kernels/$CONDA_DEFAULT_ENV/kernel.json"
  # jq '. + {env: {PATH: env.PATH}}' $json_file > $json_file
  # cat <<< $(jq '. + {env: {PATH: env.PATH}}' $json_file) > $json_file
  cat <<<$(jq --argjson env "$(< <(env | jq -R 'split("=") | {(.[0]): .[1]}' | jq -s '. | add' | jq '{PATH, CONDA_PREFIX, LD_LIBRARY_PATH}'))" '. + {env: $env}' $json_file) >$json_file
}

alias remove-kernel="rm -rf ~/.local/share/jupyter/kernels/\$CONDA_DEFAULT_ENV"

function mount-ssh() {
  sshfs $1:/ /mnt/sshfs
}

function python-version() { #statements
  python3 -c 'import sys; ver=sys.version_info; print(f"{ver.major}.{ver.minor}")'
}

# function _test(){ #statements
#     echo "$(get_python_version)"
# }
# Install packages using yay (change to pacman/AUR helper of your choice)
function in() {
  yay -Slq | fzf -q "$1" -m --preview 'yay -Si {1}' | xargs -ro yay -S
}
# Remove installed packages (change to pacman/AUR helper of your choice)
function re() {
  yay -Qq | fzf -q "$1" -m --preview 'yay -Qi {1}' | xargs -ro yay -Rns
}

function sshtunnel() {
  # ssh -L \*:"$1":localhost:$1 -N -T $2
  ssh -L "${1}":localhost:"${2}" -N -T "${3}"
}
function sync-from() {
  rsync -avP "$1:$2" $2 "${3}"
}

function sync-to() {
  rsync -avP $2 "$1:$2" "${3}"
}
# unzip -P "$(echo -n 中文密码|iconv -f utf-8 -t gbk)"  文件名.zip
# wget google.com && rm index.html
## fzf-locate
# for i in $(ls);do x $i; rm $i;done

reboot_to_windows() {
  # windows_title=$(grep -i windows /boot/grub/grub.cfg | cut -d "'" -f 2)
  # sudo grub-reboot "$windows_title" && sudo reboot
  systemctl reboot --boot-loader-entry=auto-windows
}
# alias reboot-to-windows='reboot_to_windows'

alias unrar-all='''for i in $(find -name "*.rar");do x $i;rm $i;done'''

function topy() {
  # FILE=$1
  # FILENAME="${FILE%.*}"
  # mv "$1" "${FILENAME}.sync.ipynb"
  # jupytext "${FILENAME}.sync.ipynb" --to py:percent
  ipynb2jupytext $1
}

fix_history() {
  mv ~/.histfile ~/.histfile_bad
  strings -eS ~/.histfile_bad >~/.histfile
  #R in capital gives an error so the solution
  fc -r ~/.histfile
  rm ~/.histfile_bad
}

t() {
  tmux -u attach || tmux -u
}

# yay -S --editmenu lean-community-bin --mflags --skipinteg
#
#

# rm -f ~/.zsh_history && kill -9 $$
#
function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

gr() {
  cd $(git rev-parse --show-toplevel)
}

fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

code() {
  if [ "$(command -v code-insiders)" ]; then
    code-insiders "$@"
  else
    command code "$@"
  fi
}

alias cnpm="npm --registry=https://registry.npmmirror.com --cache=$HOME/.npm/.cache/cnpm --disturl=https://npmmirror.com/mirrors/node --userconfig=$HOME/.cnpmrc"

alias dmg="cd && yadm enter lazygit; cd -"

alias se="source_env"
alias kctx="kubectx"
alias kns="kubens"
alias krrd="kubectl rollout restart deployment"
alias krrss="kubectl rollout restart statefulset"
alias krr="kubectl rollout restart"
if [ "$(command -v pixi)" ]; then
  pxe() {
    # pixi shell-hook -e $(pixi info --json | jq -r '.environments_info[].name' | fzf) | source /dev/stdin
    local env_names
    local line_count
    local env_name="${1}" # 如果有传参，env_name为参数

    if [ -z "$env_name" ]; then # 如果没有传参
      env_names=$(pixi info --json | jq -r '.environments_info[].name')
      line_count=$(echo "$env_names" | wc -l)
      if [ "$line_count" -eq 1 ]; then
        env_name="$env_names"
      else
        env_name=$(echo "$env_names" | fzf)
      fi
    fi

    eval "$(pixi shell-hook -e "$env_name")"
  }
  alias px="pixi"
  alias pxa="pixi a"
  alias pxrm="pixi rm"
  alias pxi="ulimit -n 65536 && pixi i"
  alias pxr="pixi run"
  alias pxx="pixi x"
  alias pxs="pixi s"
  alias pxls="pixi ls"
  alias pxt="pixi t"
  alias pxg="pixi g"
  alias pxee="pixi shell-hook | source /dev/stdin"
fi
alias kxx="killall xinit"

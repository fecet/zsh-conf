#!/bin/sh

# source ~/.bashrc
export PATH=$HOME/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/.TinyTeX/bin/x86_64-linux/:$PATH
export PATH=$HOME/.local/share/bob/nvim-bin:$PATH
export PATH=$PATH:"$HOME/.local/share/nvim/mason/bin"
# pnpm
export PNPM_HOME="/home/rok/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
export XDG_CONFIG_HOME=$HOME/.config
export PIXI_HOME="$HOME/.pixi"
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
export ZSH_CACHE_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
export PATH="$PATH:$PIXI_HOME/bin"
export PATH="$PATH:$PIXI_HOME/envs/pnpm/bin"
export PATH="$PATH:${KREW_ROOT:-$HOME/.krew}/bin:"
if [ -n "$JUPYTER_SERVER_URL" ]; then
  unset TMUX_PANE
fi
if [ -n "$CUDA_PATH" ]; then
  unset CUDA_PATH
fi

if [[ "$(command -v nvim)" ]]; then
    if [ -n "$NVIM" ]; then
        export NVIM_LISTEN_ADDRESS=$NVIM
        # export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
        # export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
        # export VISUAL="nvr --remote-wait +'set bufhidden=wipe'"
        # export EDITOR="nvr --remote-wait +'set bufhidden=wipe'"
        export VISUAL="$(which nvr) --remote -l"
    else
        export VISUAL="$(which nvim)"
    fi
else export VISUAL="vim"
fi
if [ "$CHROME_DESKTOP" = "code.desktop" ]; then
  export VISUAL="code"
elif [ "$CHROME_DESKTOP" = "cursor.desktop" ]; then
  export VISUAL="cursor"
fi
export EDITOR=$VISUAL
export MANPAGER='nvim +Man!'
# if [[ "$(command -v nvimpager)" ]]; then
#     export PAGER="nvimpager"
#     export NVIMPAGER_NVIM="$MAMBA_ROOT_PREFIX/bin/nvim"
# fi
#export http_proxy="127.0.0.1:7890"
#export https_proxy="127.0.0.1:7890"

###
###FZF
###

#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# export FZF_DEFAULT_COMMAND='fd --hidden --follow -E ".git" -E "/run/timeshift" -E "/mnt" -E "/proc" -E "/var/run/" '
#export FZF_DEFAULT_OPTS='--height 90% --layout=reverse --bind=alt-j:down,alt-k:up,alt-i:toggle+down --border --preview "echo {} | ~/scripts/fzf_preview.py" --preview-window=right --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
# export FZF_DEFAULT_OPTS='--height 90% --layout=reverse --preview "echo {} | ~/scripts/fzf_preview.py" --preview-window=right,border-none'

export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --preview='~/scripts/fzf_preview.sh {}' --preview-window=right,border-none"
# use fzf in bash and zsh
# Use ~~ as the trigger sequence instead of the default **
#export FZF_COMPLETION_TRIGGER='~~'

#export FZF_DEFAULT_OPTS=''
# Options to fzf command
#export FZF_COMPLETION_OPTS='--height 90% --layout=reverse --preview "echo {} | ~/scripts/fzf_preview.py" --preview-window=right'

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fdfind --hidden --follow -E ".git" -E "node_modules" . /etc /home
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fdfind --type d --hidden --follow -E ".git" -E "node_modules" . /etc /home
}



skip_global_compinit=1


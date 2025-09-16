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
export PNPM_HOME="$HOME/.local/share/pnpm"
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
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --preview='pistol {}' --preview-window=right,border-none"

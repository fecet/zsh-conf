### Deps: git zsh unzip curl wget
# ==== p10k instant prompt ====
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
# HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=1000000
SAVEHIST=100000
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
ZVM_LINE_INIT_MODE=$ZVM_MODE_NORMAL
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
bindkey -M vicmd "H" vi-beginning-of-line
bindkey -M vicmd "L" vi-end-of-line


if [ "$TERM" = "linux" ]; then
	printf %b '\e[40m' '\e[8]' # set default background to color 0 'dracula-bg'
	printf %b '\e[37m' '\e[8]' # set default foreground to color 7 'dracula-fg'
	printf %b '\e]P0282a36'    # redefine 'black'          as 'dracula-bg'
	printf %b '\e]P86272a4'    # redefine 'bright-black'   as 'dracula-comment'
	printf %b '\e]P1ff5555'    # redefine 'red'            as 'dracula-red'
	printf %b '\e]P9ff7777'    # redefine 'bright-red'     as '#ff7777'
	printf %b '\e]P250fa7b'    # redefine 'green'          as 'dracula-green'
	printf %b '\e]PA70fa9b'    # redefine 'bright-green'   as '#70fa9b'
	printf %b '\e]P3f1fa8c'    # redefine 'brown'          as 'dracula-yellow'
	printf %b '\e]PBffb86c'    # redefine 'bright-brown'   as 'dracula-orange'
	printf %b '\e]P4bd93f9'    # redefine 'blue'           as 'dracula-purple'
	printf %b '\e]PCcfa9ff'    # redefine 'bright-blue'    as '#cfa9ff'
	printf %b '\e]P5ff79c6'    # redefine 'magenta'        as 'dracula-pink'
	printf %b '\e]PDff88e8'    # redefine 'bright-magenta' as '#ff88e8'
	printf %b '\e]P68be9fd'    # redefine 'cyan'           as 'dracula-cyan'
	printf %b '\e]PE97e2ff'    # redefine 'bright-cyan'    as '#97e2ff'
	printf %b '\e]P7f8f8f2'    # redefine 'white'          as 'dracula-fg'
	printf %b '\e]PFffffff'    # redefine 'bright-white'   as '#ffffff'
	clear
fi

### Added by Zinit's installer
source ~/.aliases.sh
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && source "${ZINIT_HOME}/zinit.zsh"
source "${ZINIT_HOME}/zinit.zsh"

# Workaround for zinit issue#504: remove subversion dependency. Function clones all files in plugin
# directory (on github) that might be useful to zinit snippet directory. Should only be invoked
# via zinit atclone"_fix-omz-plugin"
_fix-omz-plugin() {
    [[ -f ./._zinit/teleid ]] || return 1
    local teleid="$(<./._zinit/teleid)"
    local pluginid
    for pluginid (${teleid#OMZ::plugins/} ${teleid#OMZP::}) {
        [[ $pluginid != $teleid ]] && break
    }
    (($?)) && return 1
    print "Fixing $teleid..."
    git clone --quiet --no-checkout --depth=1 --filter=tree:0 https://github.com/ohmyzsh/ohmyzsh
    cd ./ohmyzsh
    git sparse-checkout set --no-cone /plugins/$pluginid
    git checkout --quiet
    cd ..
    local file
    for file (./ohmyzsh/plugins/$pluginid/*~(.gitignore|*.plugin.zsh)(D)) {
        print "Copying ${file:t}..."
        cp -R $file ./${file:t}
    }
    rm -rf ./ohmyzsh
}

# Optimized version with shared clone cache for better performance
_fix-omz-plugin-cached() {
    [[ -f ./._zinit/teleid ]] || return 1
    local teleid="$(<./._zinit/teleid)"
    local pluginid
    for pluginid (${teleid#OMZ::plugins/} ${teleid#OMZP::}) {
        [[ $pluginid != $teleid ]] && break
    }
    (($?)) && return 1

    # Use a shared cache directory for the current zinit update cycle
    local cache_dir="${TMPDIR:-/tmp}/omz-cache-$$"
    local omz_dir="${cache_dir}/ohmyzsh"

    # Clone only if not already cached
    if [[ ! -d "${omz_dir}/.git" ]]; then
        print "Cloning Oh My Zsh to cache..."
        mkdir -p "${cache_dir}"
        git clone --quiet --no-checkout --depth=1 --filter=tree:0 \
            https://github.com/ohmyzsh/ohmyzsh "${omz_dir}"
    fi

    print "Fixing $teleid from cache..."

    # Configure sparse-checkout for this specific plugin
    (
        cd "${omz_dir}"
        git sparse-checkout add /plugins/$pluginid 2>/dev/null || \
            git sparse-checkout set --no-cone /plugins/$pluginid
        git checkout --quiet
    )

    # Copy plugin files
    local file
    for file ("${omz_dir}"/plugins/$pluginid/*~(.gitignore|*.plugin.zsh)(D)) {
        print "Copying ${file:t}..."
        cp -R $file ./${file:t}
    }

    # Clean up cache after all plugins are processed (deferred via trap)
    # This allows multiple plugin loads to share the same cache
    trap "rm -rf '${cache_dir}' 2>/dev/null" EXIT
}
# == zsh-zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_COMPLETION_IGNORE='( |man |pikaur -S )*'
ZSH_AUTOSUGGEST_HISTORY_IGNORE='?(#c50,)'

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=103'

GENCOMP_DIR=$XDG_CONFIG_HOME/zsh/completions

zstyle ':zce:*' keys 'asdghklqwertyuiopzxcvbnmfj;23456789'
zstyle ':fzf-tab:complete:_zlua:*' query-string input
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'
zstyle ':fzf-tab:complete:kill:*' popup-pad 0 3
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0
# zstyle ":fzf-tab:*" fzf-flags --color=bg+:23
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*' file-sort modification
zstyle ':completion:*:exa' sort false
zstyle ':completion:files' sort false
zstyle ':fzf-tab:complete:*' fzf-preview 'echo $realpath | ~/scripts/fzf_preview.py'

zi ice as"program" from"gh-r" \
  atpull"%atclone" \
  mv'pixi* > pixi' \
  bpick"pixi-*"; zi load fecet/pixi

if [[ $- == *i* ]]; then
  for _f in $PIXI_HOME/hooks/zsh/*.sh(N); do
    [[ -r $_f ]] && source $_f > /dev/null
  done
  unset _f
fi

zinit ice as"program" \
  atclone'ln -sf completion/_kubectx.zsh _kubectx; ln -sf completion/_kubens.zsh _kubens' \
  atpull'%atclone' \
  sbin'kubectx;kubens'; zi load ahmetb/kubectx

zinit wait="0" lucid light-mode for \
    hlissner/zsh-autopair \
    Aloxaf/gencomp \
    OMZL::completion.zsh \
    OMZL::clipboard.zsh \
    has'fzf' OMZP::fzf \
    blockf \
    zsh-users/zsh-completions \
    zdharma-continuum/zinit-annex-bin-gem-node \
    Aloxaf/fzf-tab \
    Freed-Wu/fzf-tab-source

zinit wait="1" lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
  atclone"_fix-omz-plugin-cached" atpull"%atclone" OMZP::extract \
  atclone"_fix-omz-plugin-cached" atpull"%atclone" OMZP::pip \
  atclone"_fix-omz-plugin-cached" atpull"%atclone" OMZP::kubectl \
  atclone"_fix-omz-plugin-cached" atpull"%atclone" OMZP::podman \
  atclone"_fix-omz-plugin-cached" atpull"%atclone" OMZP::kitty \
  atclone"_fix-omz-plugin-cached" atpull"%atclone" OMZP::sudo \
  atclone"_fix-omz-plugin-cached" atpull"%atclone" OMZP::dotenv \
  atclone"_fix-omz-plugin-cached" atpull"%atclone" OMZP::direnv \
  atclone"_fix-omz-plugin-cached" atpull"%atclone" OMZP::systemd
zi ice as"completion"
zi snippet OMZP::docker/completions/_docker

zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
 blockf \
    zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

zinit ice depth=1; zinit light romkatv/powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi
fpath+=($PIXI_HOME/completions/zsh)
autoload -Uz compinit
compinit

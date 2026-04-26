#!/usr/bin/env bash
set -euo pipefail
shopt -s dotglob nullglob

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
zsh_dir="$repo_dir/zsh"
data_dir="$HOME/.local/share/zsh-conf"

link_path() {
  local src="$1"
  local dest="$2"
  rm -rf -- "$dest"
  ln -s -- "$src" "$dest"
  printf 'Linked %s -> %s\n' "$dest" "$src"
}

install_zsh_files() {
  local src
  for src in "$zsh_dir"/*; do
    [[ -f "$src" ]] || continue
    link_path "$src" "$HOME/$(basename "$src")"
  done
}

install_local_plugins() {
  [[ -d "$zsh_dir/plugins" ]] || return 0
  mkdir -p "$data_dir"
  link_path "$zsh_dir/plugins" "$data_dir/plugins"
}

prime_shell() {
  local elapsed_file elapsed_ms
  elapsed_file="$(mktemp)"

  if ! ZSH_CONF_REPO_DIR="$repo_dir" ZINIT_STARTUP_FILE="$elapsed_file" zsh -c '
    start_time=$(date +%s%N)
    source "$HOME/.zshrc"
    if command -v @zinit-scheduler >/dev/null 2>&1; then
      @zinit-scheduler burst
    fi
    "$ZSH_CONF_REPO_DIR/pixi-setup.sh"
    end_time=$(date +%s%N)
    elapsed=$(( (end_time - start_time) / 1000000 ))
    printf "%s" "$elapsed" > "$ZINIT_STARTUP_FILE"
  '; then
    rm -f "$elapsed_file"
    return 1
  fi

  elapsed_ms="$(cat "$elapsed_file")"
  rm -f "$elapsed_file"
  printf '=== Shell startup time: %sms ===\n' "$elapsed_ms"
}

main() {
  install_zsh_files
  install_local_plugins
  prime_shell

  if [[ -z "${INSTALL_SH_SKIP_SHELL:-}" ]]; then
    exec zsh
  fi
}

main "$@"

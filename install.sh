#!/usr/bin/env bash
set -e
shopt -s dotglob nullglob

script_dir="$(cd "$(dirname "$0")" && pwd)"

for src in "$script_dir"/zsh/*; do
  [[ -f "$src" ]] || continue
  dest="$HOME/$(basename "$src")"
  rm -rf -- "$dest"
  ln -s -- "$src" "$dest"
  echo "Linked $dest -> $src"
done
# 先启动 zsh 触发 zinit 安装，然后执行命令
exec zsh -c '
  source ~/.zshrc
  ./pixi-setup.sh
  exec zsh
'

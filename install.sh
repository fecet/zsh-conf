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
  # 测量加载时间
  start_time=$(date +%s%N)
  source ~/.zshrc
  end_time=$(date +%s%N)
  elapsed=$((($end_time - $start_time) / 1000000))
  echo "=== Shell startup time: ${elapsed}ms ==="

  # ./pixi-setup.sh
  exec zsh
'

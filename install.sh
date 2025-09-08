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

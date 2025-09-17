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
# Prime zinit install and record startup time
elapsed_file="$(mktemp)"
cleanup() {
  rm -f "$elapsed_file"
}
trap cleanup EXIT
ZINIT_STARTUP_FILE="$elapsed_file" zsh -c "
  start_time=\$(date +%s%N)
  source ~/.zshrc
  if command -v @zinit-scheduler >/dev/null 2>&1; then
    @zinit-scheduler burst
  fi
  ./pixi-setup.sh
  end_time=\$(date +%s%N)
  elapsed=\$(( (end_time - start_time) / 1000000 ))
  printf \"%s\" \"\$elapsed\" > \"\$ZINIT_STARTUP_FILE\"
"
elapsed_ms="$(cat "$elapsed_file")"
cleanup
trap - EXIT
echo "=== Shell startup time: ${elapsed_ms}ms ==="

# ./pixi-setup.sh
if [[ -z "${INSTALL_SH_SKIP_SHELL:-}" ]]; then
  exec zsh
fi

#!/usr/bin/env zsh

pixi config set --global detached-environments $PIXI_HOME/envs
pixi config set --global pinning-strategy no-pin
pixi config set --global default-channels
pixi config append --global default-channels "https://repo.prefix.dev/meta-forge"
pixi config append --global default-channels "conda-forge"
pixi config set --global repodata-config.disable-sharded true
# pixi run pixi-global.py shell
export DBUS_SESSION_BUS_ADDRESS=""
pixi global sync
touch $PIXI_HOME/envs/shell/etc/pixi/global-ignore-conda-prefix
pixi global sync
mkdir -p "$PIXI_HOME/completions/zsh"
typeset -A comps
comps=(
  pixi    "pixi completion --shell zsh"
  rattler "rattler-build completion --shell zsh"
  gh      "gh completion --shell zsh"
  just    "just --completions zsh"
  buf     "buf completion zsh"
  pnpm    "pnpm completion zsh"
  dagger "dagger completion zsh"
  codex "codex completion zsh"
)

echo "Installing completions to $PIXI_HOME/completions/zsh"
for name in "${(@k)comps}"; do
  cmdline="${comps[$name]}"
  parts=(${(z)cmdline})
  cmd=${parts[1]}

  if command -v "$cmd" &>/dev/null; then
    eval "$cmdline > '$PIXI_HOME/completions/zsh/_$name'"
  else
    echo "⚠️ 跳过补全 $name：未找到命令 '$cmd'" >&2
  fi
done
compinit

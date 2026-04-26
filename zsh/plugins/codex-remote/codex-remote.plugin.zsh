# Codex remote integration.

typeset -g _CODEX_REMOTE_CONFIG="${CODEX_HOME:-$HOME/.codex}/codex_remote.json"
typeset -g _CODEX_REMOTE_ADDR=""

_codex_remote_ensure_config() {
  local config_file="$_CODEX_REMOTE_CONFIG"
  [[ -f "$config_file" ]] && return 0

  mkdir -p "$(dirname "$config_file")"
  command jq -n \
    --arg scheme "ws" \
    --arg host "127.0.0.1" \
    --argjson port 4222 \
    '{codexAppServer:{scheme:$scheme,host:$host,port:$port}}' >| "$config_file"
}

_codex_remote_load_config() {
  _codex_remote_ensure_config || return

  local config_file="$_CODEX_REMOTE_CONFIG"
  local scheme host port
  scheme="$(command jq -r '.codexAppServer.scheme // "ws"' "$config_file" 2>/dev/null)"
  host="$(command jq -r '.codexAppServer.host // "127.0.0.1"' "$config_file" 2>/dev/null)"
  port="$(command jq -r '.codexAppServer.port // 4222 | tostring' "$config_file" 2>/dev/null)"
  if [[ -z "$scheme" || -z "$host" || -z "$port" || "$scheme" == "null" || "$host" == "null" || "$port" == "null" ]]; then
    echo "invalid codex remote config: $config_file" >&2
    return 1
  fi

  _CODEX_REMOTE_ADDR="${scheme}://${host}:${port}"
}

codex() {
  local trust="projects={$(printf '%s' "$PWD" | jq -Rs .)={trust_level=\"trusted\"}}"
  local common_args=(--dangerously-bypass-approvals-and-sandbox -c "$trust")
  if _codex_remote_should_use_remote "$@"; then
    _codex_remote_load_config || return
    _codex_remote_start_app_server || return
    command codex "${common_args[@]}" --remote "$_CODEX_REMOTE_ADDR" "$@"
  else
    command codex "${common_args[@]}" "$@"
  fi
}

_codex_remote_app_server_ready() {
  local addr="${1:-$_CODEX_REMOTE_ADDR}"
  local base="${addr%/}"
  local health="${base/#ws:\/\//http://}"
  health="${health/#wss:\/\//https://}"
  command curl -fsS --max-time 0.2 "$health/readyz" >/dev/null 2>&1
}

_codex_remote_start_app_server() {
  [[ -n "$_CODEX_REMOTE_ADDR" ]] || _codex_remote_load_config || return

  local addr="$_CODEX_REMOTE_ADDR"
  local listen="${addr%/}"
  local log_dir="${XDG_CACHE_HOME:-$HOME/.cache}/codex-app-server"
  local log_file="$log_dir/app-server.log"

  _codex_remote_app_server_ready "$addr" && return
  mkdir -p "$log_dir"
  command codex app-server --listen "$listen" >>"$log_file" 2>&1 &!

  local i
  for i in {1..30}; do
    sleep 0.1
    _codex_remote_app_server_ready "$addr" && return
  done

  echo "codex app-server did not become ready at $addr; see $log_file" >&2
  return 1
}

_codex_remote_first_command() {
  local arg skip_next=0
  for arg in "$@"; do
    if (( skip_next )); then
      skip_next=0
      continue
    fi

    case "$arg" in
      -c|--config|--enable|--disable|--remote|--remote-auth-token-env|-i|--image|-m|--model|--local-provider|-p|--profile|-s|--sandbox|-C|--cd|--add-dir|-a|--ask-for-approval)
        skip_next=1
        continue
        ;;
      --*=*)
        continue
        ;;
      -*)
        continue
        ;;
      *)
        print -r -- "$arg"
        return
        ;;
    esac
  done
}

_codex_remote_should_use_remote() {
  [[ "${CODEX_SHARED_APP_SERVER:-1}" == "0" ]] && return 1

  local arg
  for arg in "$@"; do
    case "$arg" in
      --remote|--remote=*|--remote-auth-token-env|--remote-auth-token-env=*)
        return 1
        ;;
      -h|--help|-V|--version)
        return 1
        ;;
    esac
  done

  local cmd="$(_codex_remote_first_command "$@")"
  case "$cmd" in
    ""|resume|fork)
      return 0
      ;;
    exec|e|review|login|logout|mcp|mcp-server|plugin|app-server|completion|sandbox|debug|apply|a|cloud|exec-server|features|help)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

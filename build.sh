#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="$script_dir/.env"

verbose=false
for arg in "$@"; do
  case "$arg" in
    --verbose) verbose=true ;;
    *)
      echo "Error: unknown option '$arg'" >&2
      exit 1
      ;;
  esac
done

log() { echo "$@"; }
log_verbose() { [[ "$verbose" == true ]] && echo "$@"; return 0; }

if [[ ! -f "$env_file" ]]; then
  echo "Error: $env_file not found" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$env_file"
set +a

if ! luabundler bundle "src/reason/codecs/novation/LCXL3.lua" -p "?.lua" -o "dist/REASON_REMOTE_CODECS_NOVATION/LCXL3.lua"; then
    log "Error: bundling the Lua script failed — did you install luabundler?"
    exit 1
fi

log_verbose "Build: success"
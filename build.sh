#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
codecs_src_dir="src/reason/codecs/novation"
codecs_dist_dir="dist/REASON_REMOTE_CODECS_NOVATION"
maps_src_dir="src/reason/maps/novation"
maps_dist_dir="dist/REASON_REMOTE_MAPS_NOVATION"

env_file="$script_dir/.env"

verbose=false
dev=false

for arg in "$@"; do
  case "$arg" in
    --verbose) verbose=true ;;
    --dev) dev=true ;;
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

log_verbose "Preparing dist dirs"
rm -rf "${codecs_dist_dir}"
rm -rf "${maps_dist_dir}"
mkdir "${codecs_dist_dir}"
mkdir "${maps_dist_dir}"

log_verbose "Building remote codec"
if ! luabundler bundle "${codecs_src_dir}/LCXL3.lua" -p "?.lua" -o "${codecs_dist_dir}/LCXL3.lua"; then
    log "Error: bundling the Lua script failed"
    exit 1
fi

if $dev; then
  log_verbose "Copying dev version files"
  cp "${codecs_src_dir}/LCXL3.dev.luacodec" "${codecs_dist_dir}/LCXL3.luacodec"
  cp "${codecs_src_dir}/LCXL3.dev.png" "${codecs_dist_dir}/LCXL3.png"
  cp "${maps_src_dir}/LCXL3.dev.remotemap" "${maps_dist_dir}/LCXL3.remotemap"
else
  log_verbose "Copying prod version files"
  cp "${codecs_src_dir}/LCXL3.luacodec" "${codecs_src_dir}/LCXL3.png" "${codecs_dist_dir}/"
  cp "${maps_src_dir}/LCXL3.remotemap" "${maps_dist_dir}/"
fi

log_verbose "Build: success"
#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
codecs_src_dir="src/reason/codecs/novation"
codecs_dist_dir="dist/REASON_REMOTE_CODECS_NOVATION"
maps_src_dir="src/reason/maps/novation"
maps_dist_dir="dist/REASON_REMOTE_MAPS_NOVATION"

env_file="$script_dir/.env"

usage() {
  echo "Usage: $(basename "$0") <controller> [--dev] [--verbose]" >&2
  echo "" >&2
  echo "  controller   the controller to build for, one of:" >&2
  echo "                 LCXL3   Novation Launch Control XL3" >&2
  echo "                 LPPMK3  Novation Launchpad Pro [MK3]" >&2
  echo "  --dev        build the dev version" >&2
  echo "  --verbose    print more output" >&2
}

verbose=false
dev=false
controller=""

for arg in "$@"; do
  case "$arg" in
    --verbose) verbose=true ;;
    --dev) dev=true ;;
    -*)
      echo "Error: unknown option '$arg'" >&2
      usage
      exit 1
      ;;
    *)
      if [[ -n "$controller" ]]; then
        echo "Error: only one controller may be specified (got '$controller' and '$arg')" >&2
        usage
        exit 1
      fi
      controller="$(echo "$arg" | tr '[:lower:]' '[:upper:]')"
      ;;
  esac
done

if [[ -z "$controller" ]]; then
  echo "Error: missing required argument 'controller'" >&2
  usage
  exit 1
fi

case "$controller" in
  LCXL3|LPPMK3) ;;
  *)
    echo "Error: unsupported controller '$controller'" >&2
    usage
    exit 1
    ;;
esac

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

log_verbose "Building for controller ${controller}"

# The dist dirs are shared by all controllers, so only replace this controller's files
log_verbose "Preparing dist dirs"
mkdir -p "${codecs_dist_dir}" "${maps_dist_dir}"
rm -f "${codecs_dist_dir}/${controller}.lua" \
      "${codecs_dist_dir}/${controller}.luacodec" \
      "${codecs_dist_dir}/${controller}.png" \
      "${maps_dist_dir}/${controller}.remotemap"

log_verbose "Building remote codec"
if ! luabundler bundle "${codecs_src_dir}/${controller}.lua" -p "?.lua" -o "${codecs_dist_dir}/${controller}.lua"; then
    log "Error: bundling the Lua script failed"
    exit 1
fi

if $dev; then
  log_verbose "Copying dev version files"
  cp "${codecs_src_dir}/${controller}.dev.luacodec" "${codecs_dist_dir}/${controller}.luacodec"
  cp "${codecs_src_dir}/${controller}.dev.png" "${codecs_dist_dir}/${controller}.png"
  cp "${maps_src_dir}/${controller}.dev.remotemap" "${maps_dist_dir}/${controller}.remotemap"
else
  log_verbose "Copying prod version files"
  cp "${codecs_src_dir}/${controller}.luacodec" "${codecs_src_dir}/${controller}.png" "${codecs_dist_dir}/"
  cp "${maps_src_dir}/${controller}.remotemap" "${maps_dist_dir}/"
fi

log "Build: success (${controller}$($dev && echo ", dev"))"

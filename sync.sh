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

while IFS='=' read -r name _; do
  [[ $name == PATH_* ]] || continue
  path="${!name}"
  if [[ -d "$path" ]]; then
    log_verbose "Exists: $name -> $path"
  else
    log "Creating: $name -> $path"
    mkdir -p "$path"
  fi
done < <(grep -E '^PATH_[A-Za-z0-9_]*=' "$env_file")

shopt -s nullglob

find_by_basename() {
  local bn="$1"; shift
  local f
  for f in "$@"; do
    [[ "$(basename "$f")" == "$bn" ]] && { echo "$f"; return 0; }
  done
  return 1
}

if stat -c %Y . >/dev/null 2>&1; then
  file_mtime() { stat -c %Y "$1"; }   # GNU stat (Linux)
else
  file_mtime() { stat -f %m "$1"; }   # BSD stat (macOS)
fi

while IFS='=' read -r name _; do
  [[ $name == FILES_* ]] || continue
  suffix="${name#FILES_}"
  path_var="PATH_$suffix"
  path="${!path_var:-}"
  pattern="${!name}"

  if [[ -z "$path" ]]; then
    echo "Warning: $path_var is not defined, skipping $name" >&2
    continue
  fi

  eval "expanded=(\"\$path\"/$pattern)"
  matches=()
  for f in "${expanded[@]+"${expanded[@]}"}"; do
    [[ -f "$f" ]] && matches+=("$f")
  done
  count=${#matches[@]}
  log_verbose "Found: $name -> $count file(s) matching '$pattern' in $path"

  dist_dir="$script_dir/dist/$suffix"
  if [[ -d "$dist_dir" ]]; then
    log_verbose "Exists: $dist_dir"
  else
    log "Creating: $dist_dir"
    mkdir -p "$dist_dir"
  fi

  eval "dist_expanded=(\"\$dist_dir\"/$pattern)"
  dist_matches=()
  for f in "${dist_expanded[@]+"${dist_expanded[@]}"}"; do
    [[ -f "$f" ]] && dist_matches+=("$f")
  done
  dist_count=${#dist_matches[@]}
  log_verbose "Dist: $name -> $dist_count file(s) in $dist_dir"

  all_names=$(printf '%s\n' "${matches[@]+"${matches[@]##*/}"}" "${dist_matches[@]+"${dist_matches[@]##*/}"}" | sort -u)

  while IFS= read -r bn; do
    [[ -z "$bn" ]] && continue
    t="$(find_by_basename "$bn" "${matches[@]+"${matches[@]}"}" || true)"
    d="$(find_by_basename "$bn" "${dist_matches[@]+"${dist_matches[@]}"}" || true)"

    if [[ -n "$t" && -z "$d" ]]; then
      log "Sync: $bn -> missing in dist, copying target to dist"
      cp -p "$t" "$dist_dir/$bn"
    elif [[ -z "$t" && -n "$d" ]]; then
      log "Sync: $bn -> missing in target, copying dist to target"
      cp -p "$d" "$path/$bn"
    else
      t_mtime=$(file_mtime "$t")
      d_mtime=$(file_mtime "$d")
      if (( t_mtime > d_mtime )); then
        log "Sync: $bn -> target is newer, copying target to dist"
        cp -p "$t" "$d"
      elif (( d_mtime > t_mtime )); then
        log "Sync: $bn -> dist is newer, copying dist to target"
        cp -p "$d" "$t"
      else
        log_verbose "Sync: $bn -> up to date"
      fi
    fi
  done <<< "$all_names"
done < <(grep -E '^FILES_[A-Za-z0-9_]*=' "$env_file")

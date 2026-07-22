#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="$script_dir/.env"

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
    echo "Exists: $name -> $path"
  else
    echo "Creating: $name -> $path"
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
  echo "Found: $name -> $count file(s) matching '$pattern' in $path"

  src_dir="$script_dir/src/$suffix"
  mkdir -p "$src_dir"

  eval "src_expanded=(\"\$src_dir\"/$pattern)"
  src_matches=()
  for f in "${src_expanded[@]+"${src_expanded[@]}"}"; do
    [[ -f "$f" ]] && src_matches+=("$f")
  done
  src_count=${#src_matches[@]}
  echo "Src: $name -> $src_count file(s) in $src_dir"

  all_names=$(printf '%s\n' "${matches[@]+"${matches[@]##*/}"}" "${src_matches[@]+"${src_matches[@]##*/}"}" | sort -u)

  while IFS= read -r bn; do
    [[ -z "$bn" ]] && continue
    t="$(find_by_basename "$bn" "${matches[@]+"${matches[@]}"}" || true)"
    s="$(find_by_basename "$bn" "${src_matches[@]+"${src_matches[@]}"}" || true)"

    if [[ -n "$t" && -z "$s" ]]; then
      echo "Sync: $bn -> missing in source, copying target to source"
      cp -p "$t" "$src_dir/$bn"
    elif [[ -z "$t" && -n "$s" ]]; then
      echo "Sync: $bn -> missing in target, copying source to target"
      cp -p "$s" "$path/$bn"
    else
      t_mtime=$(file_mtime "$t")
      s_mtime=$(file_mtime "$s")
      if (( t_mtime > s_mtime )); then
        echo "Sync: $bn -> target is newer, copying target to source"
        cp -p "$t" "$s"
      elif (( s_mtime > t_mtime )); then
        echo "Sync: $bn -> source is newer, copying source to target"
        cp -p "$s" "$t"
      else
        echo "Sync: $bn -> up to date"
      fi
    fi
  done <<< "$all_names"
done < <(grep -E '^FILES_[A-Za-z0-9_]*=' "$env_file")

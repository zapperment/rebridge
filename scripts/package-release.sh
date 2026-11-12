#!/usr/bin/env bash
# Builds the production version of a controller's codec and map and packs
# them, with installation instructions, into a zip for anyone to download.
# The files sit in the zip as they do in Reason's Remote folder.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd "$script_dir/.." && pwd)"
cd "$root_dir"

usage() {
  echo "Usage: $(basename "$0") <controller>" >&2
  echo "" >&2
  echo "  controller   the controller to package, one of:" >&2
  echo "                 LPP     Novation Launchpad Pro" >&2
  echo "                 LPPMK3  Novation Launchpad Pro [MK3]" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

controller="$(echo "$1" | tr '[:lower:]' '[:upper:]')"
case "$controller" in
  LPP)
    zip_name="Launchpad-Pro-remote-codec-for-Launchnik.zip"
    constants="src/lpp/config/constants.lua"
    ;;
  LPPMK3)
    zip_name="Launchpad-Pro-MK3-remote-codec-for-Launchnik.zip"
    constants="src/lppmk3/config/constants.lua"
    ;;
  *)
    echo "Error: unsupported controller '$1'" >&2
    usage
    exit 1
    ;;
esac

readme_template="src/reason/release/${controller}.readme.txt"
codecs_dist_dir="dist/REASON_REMOTE_CODECS_NOVATION"
maps_dist_dir="dist/REASON_REMOTE_MAPS_NOVATION"
release_dir="temp/release"
stage_dir="$release_dir/$controller"
zip_path="$release_dir/$zip_name"

version="$(sed -n 's/^ *softwareVersion *= *"\(.*\)".*/\1/p' "$constants")"
if [[ -z "$version" ]]; then
  echo "Error: no softwareVersion in $constants" >&2
  exit 1
fi
build_date="$(date -u +%Y-%m-%d)"
commit="$(git rev-parse --short HEAD)"

./build.sh "$controller"

rm -rf "$stage_dir" "$zip_path"
codecs_dir="$stage_dir/Remote/Codecs/Lua Codecs/Novation"
maps_dir="$stage_dir/Remote/Maps/Novation"
mkdir -p "$codecs_dir" "$maps_dir"
cp "$codecs_dist_dir/$controller.lua" \
   "$codecs_dist_dir/$controller.luacodec" \
   "$codecs_dist_dir/$controller.png" \
   "$codecs_dir/"
cp "$maps_dist_dir/$controller.remotemap" "$maps_dir/"

# Windows line endings, so that any text editor shows the lines
sed -e "s/@VERSION@/$version/" \
    -e "s/@BUILD_DATE@/$build_date/" \
    -e "s/@COMMIT@/$commit/" \
    "$readme_template" |
  awk '{ printf "%s\r\n", $0 }' > "$stage_dir/readme.txt"

if grep -q '@[A-Z_]*@' "$stage_dir/readme.txt"; then
  echo "Error: readme.txt still has placeholders:" >&2
  grep '@[A-Z_]*@' "$stage_dir/readme.txt" >&2
  exit 1
fi

# zip reads the variables ZIP and ZIPOPT as extra command-line arguments
(cd "$stage_dir" &&
  env -u ZIP -u ZIPOPT zip -q -r -X "$root_dir/$zip_path" readme.txt Remote)

# The zip must hold exactly these files, in these places
expected="$(printf '%s\n' \
  "Remote/Codecs/Lua Codecs/Novation/$controller.lua" \
  "Remote/Codecs/Lua Codecs/Novation/$controller.luacodec" \
  "Remote/Codecs/Lua Codecs/Novation/$controller.png" \
  "Remote/Maps/Novation/$controller.remotemap" \
  "readme.txt" | sort)"
actual="$(zipinfo -1 "$zip_path" | grep -v '/$' | sort)"
if [[ "$actual" != "$expected" ]]; then
  echo "Error: the zip holds the wrong files" >&2
  echo "Expected:" >&2
  echo "$expected" >&2
  echo "Actual:" >&2
  echo "$actual" >&2
  exit 1
fi

# The production codec, not the dev one with its log port
if grep -q 'developer version' "$codecs_dir/$controller.luacodec"; then
  echo "Error: $controller.luacodec is the dev version" >&2
  exit 1
fi

echo "Package: success ($zip_path, version $version, commit $commit)"

#!/usr/bin/env bash

# Automates pulling Combinator patches out of Reason's Factory Sound Bank.
#
# The Factory Sound Bank ships as an encrypted ReFill, so its Combinator
# patches only exist as files once Reason itself has saved them to disk —
# there is no way to extract them without going through the app. Reason's
# own UI is custom-rendered and ignores synthetic mouse clicks, but it does
# respond to synthetic keystrokes and to its native (AppKit) menu bar, which
# is enough to drive the load/save/remove cycle below without a human
# clicking through it hundreds of times.
#
# macOS only. Requires Accessibility permission for whatever runs this
# script (System Settings > Privacy & Security > Accessibility).
#
# Before running:
#   - Open Reason, open the Browser, and navigate to the folder of
#     Combinator patches to extract (e.g. the Factory Sound Bank, filtered
#     to Instrument Patches > Combinator).
#   - Move the Browser's selection to the first patch to process.
#   - Save one patch by hand first (File > Save Device Patch As...) into the
#     target folder, so the save dialog remembers that folder as its default
#     — after that, every save from this script lands in the same place.
#   - Leave Reason alone while the script runs: it drives the frontmost app
#     via keystrokes, so anything that steals focus (including clicking
#     back into this terminal) will misdirect a keystroke.
#
# Usage:
#   scripts/extract-reason-factory-combinators.sh [count]
#
#   count   how many patches to process in this run (default 1)
#
# Each patch is driven by a single osascript call (rather than one call per
# step) to avoid paying process-startup overhead eight times over, and the
# delays between steps are tuned to the minimum that held up in testing. The
# one exception is the delay after loading a patch: how long that takes
# depends on the patch's own sample content, so it keeps a bigger margin. If
# runs start failing partway through (typically on the save-menu step, which
# means the patch hadn't finished loading yet), raise LOAD_DELAY below.

set -euo pipefail

count="${1:-1}"

if ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -lt 1 ]; then
  echo "Usage: $0 [count]" >&2
  echo "count must be a positive integer" >&2
  exit 1
fi

if ! osascript -e 'application "Reason" is running' | grep -q true; then
  echo "Reason is not running." >&2
  exit 1
fi

LOAD_DELAY="${LOAD_DELAY:-1}"

start_time="$SECONDS"

report_elapsed() {
  local elapsed=$((SECONDS - start_time))
  printf 'Elapsed time: %02dh %02dm %02ds\n' \
    $((elapsed / 3600)) $((elapsed % 3600 / 60)) $((elapsed % 60))
}
trap report_elapsed EXIT

for ((i = 1; i <= count; i++)); do
  echo "[$i/$count] processing selected patch..."

  if ! osascript <<EOF
tell application "Reason" to activate
delay 0.15

tell application "System Events"
	-- load the Browser's current selection into the rack
	key code 36 -- Return
	delay $LOAD_DELAY

	-- close the Browser; focus moves to the rack device
	key code 101 -- F9
	delay 0.1

	tell process "Reason"
		click menu item "Combinator-Patch sichern unter…" of menu "Ablage" of menu bar item "Ablage" of menu bar 1
	end tell
	delay 0.7

	-- confirm the save dialog (folder/filename default to last-used)
	key code 36 -- Return
	delay 0.2

	-- remove the Combinator from the rack again
	key code 51 using command down -- Cmd+Backspace
	delay 0.1

	-- reopen the Browser
	key code 101 -- F9
	delay 0.1

	-- move the selection down to the next patch
	key code 125 -- Down arrow
	delay 0.05
	key code 125 -- Down arrow
	delay 0.05
end tell
EOF
  then
    echo "Failed while processing patch $i (see error above)." >&2
    exit 1
  fi
done

echo "Done: processed $count patch(es)."

-- What pressing a button of Launchnik changes; the same rules the device's own
-- panel follows (Press.cpp in the Launchnik repository, see its ADR 0002), so
-- the cases of test/lppmk3/TestPress.lua mirror the device's tests.
--
-- Tracks and rows are numbered from 1. A launch button's index is 0..63,
-- counted down track 1 first. A change names one property and its new value:
--   { kind = "selection", track = 1..8, value = 0..8 }
--   { kind = "setup", value = 0..65 }
--   { kind = "present" | "pattern" | "colour", index = 0..63, value = ... }

local selectionStop = 0

local setupLaunchMode = 0
local setupClipPicking = 1
local setupFirstClipEditing = 2

-- where the controls of clip editing sit on the grid
local toggle = { track = 8, row = 1 }
local back = { track = 8, row = 8 }
local firstColourRow = 2
local coloursPerRow = 7
local patternRow = 5

local function buttonIndex(track, row)
  return (track - 1) * 8 + (row - 1)
end

-- pressedHoldsClip says whether the pressed launch button holds a clip;
-- pickedHoldsClip says the same of the launch button that is being edited and
-- only matters in clip editing; returns nil if the press changes nothing
local function launchButton(setup, track, row, pressedHoldsClip, pickedHoldsClip)
  if setup == setupLaunchMode then
    -- an empty launch button stands in for the stop button
    return { kind = "selection", track = track, value = pressedHoldsClip and row or selectionStop }
  end
  if setup == setupClipPicking then
    return { kind = "setup", value = setupFirstClipEditing + buttonIndex(track, row) }
  end

  local picked = setup - setupFirstClipEditing
  if track == toggle.track and row == toggle.row then
    return { kind = "present", index = picked, value = pickedHoldsClip and 0 or 1 }
  end
  if track == back.track and row == back.row then
    return { kind = "setup", value = setupClipPicking }
  end
  -- the colour and pattern controls are not there without a clip
  if not pickedHoldsClip then
    return nil
  end
  local isColourRow = row == firstColourRow or row == firstColourRow + 1
  if isColourRow and track <= coloursPerRow then
    return { kind = "colour", index = picked, value = (row - firstColourRow) * coloursPerRow + track - 1 }
  end
  if row == patternRow then
    return { kind = "pattern", index = picked, value = track - 1 }
  end
  return nil
end

local function stopButton(track)
  return { kind = "selection", track = track, value = selectionStop }
end

local function setupButton(setup)
  local inSetupMode = setup ~= setupLaunchMode
  return { kind = "setup", value = inSetupMode and setupLaunchMode or setupClipPicking }
end

return {
  setupLaunchMode = setupLaunchMode,
  setupClipPicking = setupClipPicking,
  setupFirstClipEditing = setupFirstClipEditing,
  buttonIndex = buttonIndex,
  launchButton = launchButton,
  stopButton = stopButton,
  setupButton = setupButton,
}

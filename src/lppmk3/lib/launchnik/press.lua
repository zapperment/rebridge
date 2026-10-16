-- What pressing a button of Launchnik changes; the same rules the device's own
-- panel follows (Press.cpp in the Launchnik repository, see its ADR 0002), so
-- the cases of test/lppmk3/TestPress.lua mirror the device's tests.
--
-- Tracks and rows are numbered from 1. A launch button's index is 0..63,
-- counted down track 1 first. A change names one property and its new value:
--   { kind = "selection", track = 1..8, value = 0..8 }
--   { kind = "setup", value = 0..129 }
--   { kind = "length", value = 0..7 }
--   { kind = "present" | "pattern" | "colour", index = 0..63, value = ... }
--   { kind = "fillinpresent" | "fillinpattern" | "fillincolour", index = 0..63, value = ... }
--   { kind = "fillin", value = 0..1 }
--   { kind = "function", value = 0..2 }
--   { kind = "mute" | "solo", track = 1..8, value = 0..1 }
-- A press of a launch button outside fill-in editing, a function button, a
-- function select button, the setup button, the back button, the set fill-in
-- button or the fill-in button changes one property at most; a press of a scene button, or of a launch
-- button in fill-in editing, yields a list of changes.

local selectionStop = 0

-- what the function buttons do
local functionStop = 0
local functionMute = 1
local functionSolo = 2
local functionCount = 3

local setupLaunchMode = 0
local setupClipPicking = 1
local setupFirstClipEditing = 2
local setupFirstFillInEditing = 66
local setupCount = 130

local colourWhite = 0

-- where the controls of clip editing sit on the grid
local toggle = { track = 8, row = 1 }
local firstColourRow = 2
local coloursPerRow = 7
local patternRow = 5

local function buttonIndex(track, row)
  return (track - 1) * 8 + (row - 1)
end

local function isClipEditing(setup)
  return setup >= setupFirstClipEditing and setup < setupFirstFillInEditing
end

local function isFillInEditing(setup)
  return setup >= setupFirstFillInEditing and setup < setupCount
end

-- the index of the launch button being edited in clip editing or fill-in
-- editing, or nil in launch mode and clip picking
local function pickedButton(setup)
  if isClipEditing(setup) then
    return setup - setupFirstClipEditing
  end
  if isFillInEditing(setup) then
    return setup - setupFirstFillInEditing
  end
  return nil
end

-- pressedHoldsClip says whether the pressed launch button holds a clip;
-- pickedHoldsClip says the same of the launch button that is being edited and
-- only matters in clip editing; returns nil if the press changes nothing, as in
-- fill-in editing, which fillInEditingLaunchButton handles
local function launchButton(setup, track, row, pressedHoldsClip, pickedHoldsClip)
  if setup == setupLaunchMode then
    -- an empty launch button stands in for the stop button
    return { kind = "selection", track = track, value = pressedHoldsClip and row or selectionStop }
  end
  if setup == setupClipPicking then
    return { kind = "setup", value = setupFirstClipEditing + buttonIndex(track, row) }
  end

  if not isClipEditing(setup) then
    return nil
  end

  local picked = pickedButton(setup)
  if track == toggle.track and row == toggle.row then
    return { kind = "present", index = picked, value = pickedHoldsClip and 0 or 1 }
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

-- a press of a launch button in fill-in editing, where the grid stands for the
-- fill-in of the picked launch button as it stands for its clip in clip
-- editing; pickedHoldsFillIn says whether the picked launch button holds a
-- fill-in, pickedPattern is the pattern of its clip, which a new fill-in starts
-- with, in white; returns a list of changes, empty outside fill-in editing
local function fillInEditingLaunchButton(setup, track, row, pickedHoldsFillIn, pickedPattern)
  if not isFillInEditing(setup) then
    return {}
  end
  local picked = pickedButton(setup)
  if track == toggle.track and row == toggle.row then
    if pickedHoldsFillIn then
      return { { kind = "fillinpresent", index = picked, value = 0 } }
    end
    return {
      { kind = "fillinpresent", index = picked, value = 1 },
      { kind = "fillinpattern", index = picked, value = pickedPattern },
      { kind = "fillincolour", index = picked, value = colourWhite },
    }
  end
  -- the colour and pattern controls are not there without a fill-in
  if not pickedHoldsFillIn then
    return {}
  end
  local isColourRow = row == firstColourRow or row == firstColourRow + 1
  if isColourRow and track <= coloursPerRow then
    return { { kind = "fillincolour", index = picked, value = (row - firstColourRow) * coloursPerRow + track - 1 } }
  end
  if row == patternRow then
    return { { kind = "fillinpattern", index = picked, value = track - 1 } }
  end
  return {}
end

local function stopButton(track)
  return { kind = "selection", track = track, value = selectionStop }
end

-- holding down a function button and letting it go: in stop function a press
-- chooses stop and letting go does nothing; in mute and solo function the
-- button is held down, as the mute or solo button of its track, for as long as
-- it is, and whether a press mutes or solos is up to Launchnik; trackHasClips
-- says whether the track holds any clip: without one, a press does nothing;
-- letting go is always passed on, so that a button that is held down can be
-- let go of; returns nil if nothing changes
local function functionButton(func, track, trackHasClips, pressed)
  if track < 1 or track > 8 then
    return nil
  end
  if pressed and not trackHasClips then
    return nil
  end
  if func == functionMute then
    return { kind = "mute", track = track, value = pressed and 1 or 0 }
  end
  if func == functionSolo then
    return { kind = "solo", track = track, value = pressed and 1 or 0 }
  end
  if pressed then
    return stopButton(track)
  end
  return nil
end

-- chooses the function of a function select button
local function functionSelectButton(func)
  if func < 0 or func >= functionCount then
    return nil
  end
  return { kind = "function", value = func }
end

-- in launch mode, a scene button means what the eight launch buttons of its
-- scene mean, track by track; in clip picking it chooses the length of the
-- switch interval it stands for, immediate at the bottom and sixteen bars at
-- the top, and returns to launch mode; in clip editing it does nothing (see
-- ADR 0004 of the Launchnik repository); holdsClip says of each track, 1..8,
-- whether its launch button in the scene holds a clip; returns a list of
-- changes
local function sceneButton(setup, scene, holdsClip)
  local changes = {}
  if setup == setupClipPicking then
    return {
      { kind = "length", value = 8 - scene },
      { kind = "setup", value = setupLaunchMode },
    }
  end
  if setup ~= setupLaunchMode then
    return changes
  end
  for track = 1, 8 do
    table.insert(changes, launchButton(setup, track, scene, holdsClip[track], false))
  end
  return changes
end

local function setupButton(setup)
  local inSetupMode = setup ~= setupLaunchMode
  return { kind = "setup", value = inSetupMode and setupLaunchMode or setupClipPicking }
end

-- goes back one step of setup mode: from fill-in editing to clip editing of
-- the same launch button, from clip editing to clip picking, from clip picking
-- to launch mode; in launch mode it does nothing, so returns nil
local function backButton(setup)
  if setup == setupLaunchMode then
    return nil
  end
  if isFillInEditing(setup) then
    return { kind = "setup", value = setupFirstClipEditing + pickedButton(setup) }
  end
  return { kind = "setup", value = setup == setupClipPicking and setupLaunchMode or setupClipPicking }
end

-- goes on from clip editing to fill-in editing of the same launch button, but
-- only if it holds a clip; anywhere else it does nothing, so returns nil
local function setFillInButton(setup, pickedHoldsClip)
  if not isClipEditing(setup) or not pickedHoldsClip then
    return nil
  end
  return { kind = "setup", value = setupFirstFillInEditing + pickedButton(setup) }
end

-- holding down the fill-in button and letting it go; whether a press triggers
-- a fill-in is up to Launchnik
local function fillInButton(pressed)
  return { kind = "fillin", value = pressed and 1 or 0 }
end

return {
  setupLaunchMode = setupLaunchMode,
  setupClipPicking = setupClipPicking,
  setupFirstClipEditing = setupFirstClipEditing,
  setupFirstFillInEditing = setupFirstFillInEditing,
  functionStop = functionStop,
  functionMute = functionMute,
  functionSolo = functionSolo,
  buttonIndex = buttonIndex,
  isClipEditing = isClipEditing,
  isFillInEditing = isFillInEditing,
  pickedButton = pickedButton,
  launchButton = launchButton,
  fillInEditingLaunchButton = fillInEditingLaunchButton,
  stopButton = stopButton,
  functionButton = functionButton,
  functionSelectButton = functionSelectButton,
  sceneButton = sceneButton,
  setupButton = setupButton,
  backButton = backButton,
  setFillInButton = setFillInButton,
  fillInButton = fillInButton,
}

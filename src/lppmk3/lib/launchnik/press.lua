-- What pressing a button of Launchnik changes; the same rules the device's own
-- panel follows (Press.cpp in the Launchnik repository, see its ADR 0002), so
-- the cases of test/lppmk3/TestPress.lua mirror the device's tests.
--
-- Tracks and rows are numbered from 1. A launch button's index is 0..63,
-- counted down track 1 first. A change names one property and its new value:
--   { kind = "selection", track = 1..8, value = 0..8 }
--   { kind = "setup", value = 0..193 }
--   { kind = "length", value = 0..7 }
--   { kind = "present" | "colour", index = 0..63, value = ... }
--   { kind = "pattern" | "unipolar" | "bipolar" | "transition", index = 0..63, output = 1..6, value = ... }
--   { kind = "fillinpresent" | "fillincolour", index = 0..63, value = ... }
--   { kind = "fillinpattern" | "fillinunipolar" | "fillinbipolar" | "fillintransition", index = 0..63, output = 1..6, value = ... }
--   { kind = "landingpresent" | "landingcolour", index = 0..63, value = ... }
--   { kind = "landingpattern" | "landingunipolar" | "landingbipolar" | "landingtransition", index = 0..63, output = 1..6, value = ... }
--   { kind = "fillin", value = 0..1 }
--   { kind = "function", value = 0..2 }
--   { kind = "mute" | "solo", track = 1..8, value = 0..1 }
-- A press of a launch button outside fill-in editing and landing editing, a
-- function button, a function select button, the setup button, the back
-- button, the forward button or the fill-in button changes one property at
-- most; a press of a scene button, or of a launch button in fill-in editing or
-- landing editing, yields a list of changes.

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
local setupFirstLandingEditing = 130
local setupCount = 194

local colourWhite = 0

-- each track has six CV outputs, A to F, numbered from 1 here; a CV mode is
-- 0 = bipolar, 1 = unipolar, 2 = pattern, and a new device has output A in
-- pattern mode and the others in unipolar mode
local outputCount = 6
local cvModeBipolar = 0
local cvModeUnipolar = 1
local cvModePattern = 2
-- transitions: 0 = off, then A, B, C and D
local transitionOff = 0
local transitionCount = 5

-- where the controls of clip editing sit on the grid: the colours fill the
-- first seven tracks of rows 1 and 2, and rows 3 to 8 stand for the CV outputs
-- A to F, with the transition in the last track
local toggle = { track = 8, row = 1 }
local firstColourRow = 1
local coloursPerRow = 7
local firstOutputRow = 3
local transitionTrack = 8

local function defaultCVMode(output)
  return output == 1 and cvModePattern or cvModeUnipolar
end

-- what a press in clip editing, fill-in editing or landing editing needs to
-- know of the settings being edited: whether there are any, the CV modes of the picked
-- launch button's track and the transitions, by output; with present alone,
-- the CV modes of a new device and every transition off
local function edited(present, cvModes, transitions)
  local result = { present = present, cvModes = {}, transitions = {} }
  for output = 1, outputCount do
    result.cvModes[output] = cvModes and cvModes[output] or defaultCVMode(output)
    result.transitions[output] = transitions and transitions[output] or transitionOff
  end
  return result
end

-- what a press changes among the colours and the CV outputs of the settings
-- being edited, the clip's or, with prefix "fillin" or "landing", the
-- fill-in's or the landing's, which must be there; nil if nothing
local function editSetting(prefix, picked, track, row, settings)
  local isColourRow = row == firstColourRow or row == firstColourRow + 1
  if isColourRow and track <= coloursPerRow then
    return { kind = prefix .. "colour", index = picked, value = (row - firstColourRow) * coloursPerRow + track - 1 }
  end
  local output = row - firstOutputRow + 1
  if output < 1 or output > outputCount or track < 1 or track > 8 then
    return nil
  end
  local cvMode = settings.cvModes[output]
  if cvMode == cvModePattern then
    return { kind = prefix .. "pattern", index = picked, output = output, value = track - 1 }
  end
  -- the transition button goes round from off through A to D
  if track == transitionTrack then
    return { kind = prefix .. "transition", index = picked, output = output, value = (settings.transitions[output] + 1) % transitionCount }
  end
  local kind = cvMode == cvModeUnipolar and "unipolar" or "bipolar"
  return { kind = prefix .. kind, index = picked, output = output, value = track - 1 }
end

local function buttonIndex(track, row)
  return (track - 1) * 8 + (row - 1)
end

local function isClipEditing(setup)
  return setup >= setupFirstClipEditing and setup < setupFirstFillInEditing
end

local function isFillInEditing(setup)
  return setup >= setupFirstFillInEditing and setup < setupFirstLandingEditing
end

local function isLandingEditing(setup)
  return setup >= setupFirstLandingEditing and setup < setupCount
end

-- the index of the launch button being edited in clip editing, fill-in
-- editing or landing editing, or nil in launch mode and clip picking
local function pickedButton(setup)
  if isClipEditing(setup) then
    return setup - setupFirstClipEditing
  end
  if isFillInEditing(setup) then
    return setup - setupFirstFillInEditing
  end
  if isLandingEditing(setup) then
    return setup - setupFirstLandingEditing
  end
  return nil
end

-- pressedHoldsClip says whether the pressed launch button holds a clip;
-- pickedClip, made by edited(), describes the clip being edited and only
-- matters in clip editing; returns nil if the press changes nothing, as in
-- fill-in editing and landing editing, which fillInEditingLaunchButton and
-- landingEditingLaunchButton handle
local function launchButton(setup, track, row, pressedHoldsClip, pickedClip)
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
    return { kind = "present", index = picked, value = pickedClip.present and 0 or 1 }
  end
  -- the colour and CV controls are not there without a clip
  if not pickedClip.present then
    return nil
  end
  return editSetting("", picked, track, row, pickedClip)
end

-- a press of a launch button in fill-in editing or landing editing, with
-- prefix "fillin" or "landing", where the grid stands for the fill-in or the
-- landing of the picked launch button as it stands for its clip in clip
-- editing; settings, made by edited(), describes the fill-in or landing,
-- clipValues the values of its clip by output, { patterns = {}, unipolar =
-- {}, bipolar = {} }, which a new one starts as a copy of, with every
-- transition off, in white; returns a list of changes
local function editOverlay(prefix, setup, track, row, settings, clipValues)
  local picked = pickedButton(setup)
  if track == toggle.track and row == toggle.row then
    if settings.present then
      return { { kind = prefix .. "present", index = picked, value = 0 } }
    end
    local changes = {
      { kind = prefix .. "present", index = picked, value = 1 },
      { kind = prefix .. "colour", index = picked, value = colourWhite },
    }
    for output = 1, outputCount do
      table.insert(changes, { kind = prefix .. "pattern", index = picked, output = output, value = clipValues.patterns[output] })
      table.insert(changes, { kind = prefix .. "unipolar", index = picked, output = output, value = clipValues.unipolar[output] })
      table.insert(changes, { kind = prefix .. "bipolar", index = picked, output = output, value = clipValues.bipolar[output] })
      table.insert(changes, { kind = prefix .. "transition", index = picked, output = output, value = transitionOff })
    end
    return changes
  end
  -- the colour and CV controls are not there without a fill-in or landing
  if not settings.present then
    return {}
  end
  local change = editSetting(prefix, picked, track, row, settings)
  return change and { change } or {}
end

-- a press of a launch button in fill-in editing; returns a list of changes,
-- empty outside fill-in editing
local function fillInEditingLaunchButton(setup, track, row, fillIn, clipValues)
  if not isFillInEditing(setup) then
    return {}
  end
  return editOverlay("fillin", setup, track, row, fillIn, clipValues)
end

-- the same in landing editing, for the landing
local function landingEditingLaunchButton(setup, track, row, landing, clipValues)
  if not isLandingEditing(setup) then
    return {}
  end
  return editOverlay("landing", setup, track, row, landing, clipValues)
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
    table.insert(changes, launchButton(setup, track, scene, holdsClip[track], edited(false)))
  end
  return changes
end

local function setupButton(setup)
  local inSetupMode = setup ~= setupLaunchMode
  return { kind = "setup", value = inSetupMode and setupLaunchMode or setupClipPicking }
end

-- goes back one step of setup mode: from landing editing to fill-in editing
-- and from fill-in editing to clip editing of the same launch button, from
-- clip editing to clip picking, from clip picking to launch mode; in launch
-- mode it does nothing, so returns nil
local function backButton(setup)
  if setup == setupLaunchMode then
    return nil
  end
  if isLandingEditing(setup) then
    return { kind = "setup", value = setupFirstFillInEditing + pickedButton(setup) }
  end
  if isFillInEditing(setup) then
    return { kind = "setup", value = setupFirstClipEditing + pickedButton(setup) }
  end
  return { kind = "setup", value = setup == setupClipPicking and setupLaunchMode or setupClipPicking }
end

-- goes forward one step of setup mode: from clip editing to fill-in editing
-- and from fill-in editing to landing editing of the same launch button, but
-- only if it holds a clip; anywhere else it does nothing, so returns nil
local function forwardButton(setup, pickedHoldsClip)
  if not pickedHoldsClip then
    return nil
  end
  if isClipEditing(setup) then
    return { kind = "setup", value = setupFirstFillInEditing + pickedButton(setup) }
  end
  if isFillInEditing(setup) then
    return { kind = "setup", value = setupFirstLandingEditing + pickedButton(setup) }
  end
  return nil
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
  setupFirstLandingEditing = setupFirstLandingEditing,
  functionStop = functionStop,
  functionMute = functionMute,
  functionSolo = functionSolo,
  outputCount = outputCount,
  cvModeBipolar = cvModeBipolar,
  cvModeUnipolar = cvModeUnipolar,
  cvModePattern = cvModePattern,
  defaultCVMode = defaultCVMode,
  edited = edited,
  buttonIndex = buttonIndex,
  isClipEditing = isClipEditing,
  isFillInEditing = isFillInEditing,
  isLandingEditing = isLandingEditing,
  pickedButton = pickedButton,
  launchButton = launchButton,
  fillInEditingLaunchButton = fillInEditingLaunchButton,
  landingEditingLaunchButton = landingEditingLaunchButton,
  stopButton = stopButton,
  functionButton = functionButton,
  functionSelectButton = functionSelectButton,
  sceneButton = sceneButton,
  setupButton = setupButton,
  backButton = backButton,
  forwardButton = forwardButton,
  fillInButton = fillInButton,
}

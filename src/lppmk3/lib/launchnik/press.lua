-- What pressing a button of Launchnik changes; the same rules the device's own
-- panel follows (Press.cpp in the Launchnik repository, see its ADR 0002), so
-- the cases of test/lppmk3/TestPress.lua mirror the device's tests.
--
-- Tracks and rows are numbered from 1. A launch button's index is 0..63,
-- counted down track 1 first. A change names one property and its new value:
--   { kind = "selection", track = 1..8, value = 0..8 }
--   { kind = "setup", value = 0..395 }
--   { kind = "length", value = 0..7 }
--   { kind = "switches", index = 0..63, value = 0..55 }
--   { kind = "output", index = 0..63, output = 1..6, value = 0..1959 }
--   { kind = "fillinswitches", index = 0..63, value = 0..55 }
--   { kind = "fillinoutput", index = 0..63, output = 1..6, value = 0..1959 }
--   { kind = "landingswitches", index = 0..63, value = 0..55 }
--   { kind = "landingoutput", index = 0..63, output = 1..6, value = 0..1959 }
--   and the same with "intro" and "outro" in place of "landing"
-- The value of an output is all four of its settings in one number, see
-- packOutputSettings; that of the switches is whether there is a clip,
-- fill-in, landing, intro or outro, its colour and one-bar pattern, see
-- packSwitches.
--   { kind = "fillin", value = 0..1 }
--   { kind = "function", value = 0..2 }
--   { kind = "mute" | "solo" | "relaunch", track = 1..8, value = 0..1 }
-- A press of a launch button outside fill-in editing, landing editing, intro
-- editing, outro editing, clear mode and duplicate mode, a function button, a function select button, the
-- setup button, the clear button, the duplicate button, the back button, the
-- forward button or the fill-in button changes one property at most; a press
-- of a scene button, or of a launch button in fill-in editing, landing
-- editing, intro editing, outro editing, clear mode or duplicate mode, yields
-- a list of changes.

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
local setupFirstIntroEditing = 194
local setupFirstOutroEditing = 258
-- clear mode and duplicate mode are not part of setup mode; duplicate mode is
-- source picking, then destination picking for a launch button or a scene as
-- the source
local setupClearMode = 322
local setupSourcePicking = 323
local setupFirstClipDestinationPicking = 324
local setupFirstSceneDestinationPicking = 388
local setupCount = 396

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
local patternCount = 8
local valueCount = 7
local bipolarZero = 3

-- the four settings of a CV output as one number, as Launchnik keeps them
-- (see its ADR 0008): the pattern, plus 8 times the unipolar value, plus 56
-- times the bipolar value, plus 392 times the transition
local function packOutputSettings(pattern, unipolar, bipolar, transition)
  return pattern + patternCount * (unipolar + valueCount * (bipolar + valueCount * transition))
end

-- whether there is a clip, fill-in, landing, intro or outro, its colour, its
-- one-bar pattern and whether it has been set up before as one number, as
-- Launchnik keeps them (see its ADR 0008): 1 if it is there, plus 2 times
-- the colour, plus 28 if one-bar pattern is on, plus 56 if it has been set
-- up
local function packSwitches(present, colour, oneBarPattern, setUp)
  return (present and 1 or 0) + 2 * colour + (oneBarPattern and 28 or 0) + (setUp and 56 or 0)
end

-- the other way round: present, colour, oneBarPattern, setUp
local function unpackSwitches(packed)
  return packed % 2 == 1, math.floor(packed / 2) % 14, math.floor(packed / 28) % 2 == 1, packed >= 56
end

-- the other way round: pattern, unipolar, bipolar, transition
local function unpackOutputSettings(packed)
  local pattern = packed % patternCount
  packed = math.floor(packed / patternCount)
  local unipolar = packed % valueCount
  packed = math.floor(packed / valueCount)
  return pattern, unipolar, packed % valueCount, math.floor(packed / valueCount)
end

-- where the controls of clip editing sit on the grid: the colours fill the
-- first seven tracks of rows 1 and 2, and rows 3 to 8 stand for the CV outputs
-- A to F, with the transition in the last track
local toggle = { track = 8, row = 1 }
local firstColourRow = 1
local coloursPerRow = 7
local firstOutputRow = 3
local transitionTrack = 8
-- in fill-in editing, landing editing, intro editing and outro editing only,
-- the one-bar pattern switch
-- sits in the last track of the second colour row
local oneBarPattern = { track = 8, row = 2 }

local function defaultCVMode(output)
  return output == 1 and cvModePattern or cvModeUnipolar
end

-- what a press in clip editing, fill-in editing, landing editing, intro
-- editing or outro editing needs to know of the settings being edited: whether there are any, the CV modes of the picked
-- launch button's track and the transitions, by output; with present alone,
-- the CV modes of a new device and every transition off; oneBarPattern says
-- of a fill-in, a landing, an intro or an outro whether one-bar pattern is on;
-- values holds the colour, whether a fill-in, landing, intro or outro has
-- been set up before, and the other settings by output, { colour = ...,
-- setUp = ..., patterns = {}, unipolar = {}, bipolar = {} }, which a press
-- keeps, since the switches are one item, and all four settings of an output
-- another; without it, white, never set up, pattern 1 and unipolar and
-- bipolar 0
local function edited(present, cvModes, transitions, oneBarPattern, values)
  local result = { present = present, colour = values and values.colour or colourWhite, setUp = values and values.setUp or false, cvModes = {}, transitions = {}, patterns = {}, unipolar = {}, bipolar = {}, oneBarPattern = oneBarPattern or false }
  for output = 1, outputCount do
    result.cvModes[output] = cvModes and cvModes[output] or defaultCVMode(output)
    result.transitions[output] = transitions and transitions[output] or transitionOff
    result.patterns[output] = values and values.patterns[output] or 0
    result.unipolar[output] = values and values.unipolar[output] or 0
    result.bipolar[output] = values and values.bipolar[output] or bipolarZero
  end
  return result
end

-- what a press changes among the colours and the CV outputs of the settings
-- being edited, the clip's or, with prefix "fillin", "landing", "intro" or
-- "outro", the fill-in's, the landing's, the intro's or the outro's, which
-- must be there; nil if nothing
local function editSetting(prefix, picked, track, row, settings)
  local isColourRow = row == firstColourRow or row == firstColourRow + 1
  if isColourRow and track <= coloursPerRow then
    local colour = (row - firstColourRow) * coloursPerRow + track - 1
    return { kind = prefix .. "switches", index = picked, value = packSwitches(settings.present, colour, settings.oneBarPattern, settings.setUp) }
  end
  if prefix ~= "" and track == oneBarPattern.track and row == oneBarPattern.row then
    return { kind = prefix .. "switches", index = picked, value = packSwitches(settings.present, settings.colour, not settings.oneBarPattern, settings.setUp) }
  end
  local output = row - firstOutputRow + 1
  if output < 1 or output > outputCount or track < 1 or track > 8 then
    return nil
  end
  -- a press changes one of the output's settings and keeps the others
  local pattern, unipolar, bipolar, transition = settings.patterns[output], settings.unipolar[output], settings.bipolar[output], settings.transitions[output]
  local cvMode = settings.cvModes[output]
  if cvMode == cvModePattern then
    pattern = track - 1
  -- the transition button goes round from off through A to D
  elseif track == transitionTrack then
    transition = (transition + 1) % transitionCount
  elseif cvMode == cvModeUnipolar then
    unipolar = track - 1
  else
    bipolar = track - 1
  end
  return { kind = prefix .. "output", index = picked, output = output, value = packOutputSettings(pattern, unipolar, bipolar, transition) }
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
  return setup >= setupFirstLandingEditing and setup < setupFirstIntroEditing
end

local function isIntroEditing(setup)
  return setup >= setupFirstIntroEditing and setup < setupFirstOutroEditing
end

local function isOutroEditing(setup)
  return setup >= setupFirstOutroEditing and setup < setupClearMode
end

-- whether a setup state is one of duplicate mode: source picking or
-- destination picking
local function isDuplicateMode(setup)
  return setup >= setupSourcePicking and setup < setupCount
end

-- the index of the launch button that is the source in destination picking,
-- or nil if there is none
local function sourceButton(setup)
  if setup >= setupFirstClipDestinationPicking and setup < setupFirstSceneDestinationPicking then
    return setup - setupFirstClipDestinationPicking
  end
  return nil
end

-- the scene that is the source in destination picking, or nil if there is
-- none
local function sourceScene(setup)
  if setup >= setupFirstSceneDestinationPicking and setup < setupCount then
    return setup - setupFirstSceneDestinationPicking + 1
  end
  return nil
end

-- the index of the launch button being edited in clip editing, fill-in
-- editing, landing editing, intro editing or outro editing, or nil in launch
-- mode, clip picking, clear mode and duplicate mode; the editing steps follow
-- one another, each with every launch button in turn
local function pickedButton(setup)
  if setup >= setupFirstClipEditing and setup < setupClearMode then
    return (setup - setupFirstClipEditing) % 64
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
    return { kind = "switches", index = picked, value = packSwitches(not pickedClip.present, pickedClip.colour, false, false) }
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
-- {}, bipolar = {} }, which one that has never been set up starts as a copy
-- of, with every transition off and one-bar pattern off, in white; returns a
-- list of changes
local function editOverlay(prefix, setup, track, row, settings, clipValues)
  local picked = pickedButton(setup)
  if track == toggle.track and row == toggle.row then
    -- switched off and on again, it keeps its settings, like a clip
    if settings.present or settings.setUp then
      return { { kind = prefix .. "switches", index = picked, value = packSwitches(not settings.present, settings.colour, settings.oneBarPattern, true) } }
    end
    -- the first time, it starts as a copy of its clip
    local changes = {
      { kind = prefix .. "switches", index = picked, value = packSwitches(true, colourWhite, false, true) },
    }
    for output = 1, outputCount do
      local value = packOutputSettings(clipValues.patterns[output], clipValues.unipolar[output], clipValues.bipolar[output], transitionOff)
      table.insert(changes, { kind = prefix .. "output", index = picked, output = output, value = value })
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

-- the same in intro editing, for the intro
local function introEditingLaunchButton(setup, track, row, intro, clipValues)
  if not isIntroEditing(setup) then
    return {}
  end
  return editOverlay("intro", setup, track, row, intro, clipValues)
end

-- the same in outro editing, for the outro
local function outroEditingLaunchButton(setup, track, row, outro, clipValues)
  if not isOutroEditing(setup) then
    return {}
  end
  return editOverlay("outro", setup, track, row, outro, clipValues)
end

-- a press of a launch button in clear mode empties it, if it holds a clip, as
-- SET/CLEAR does in clip editing, keeping its colour, pressedColour, and
-- returns to launch mode; returns a list of changes, empty outside clear mode
local function clearModeLaunchButton(setup, track, row, pressedHoldsClip, pressedColour)
  if setup ~= setupClearMode then
    return {}
  end
  local changes = {}
  if pressedHoldsClip then
    table.insert(changes, { kind = "switches", index = buttonIndex(track, row), value = packSwitches(false, pressedColour, false, false) })
  end
  table.insert(changes, { kind = "setup", value = setupLaunchMode })
  return changes
end

-- the kinds of change for the settings of a clip, a fill-in, a landing, an
-- intro and an outro, by the field of the settings they come from
local settingsPrefixes = { clip = "", fillIn = "fillin", landing = "landing", intro = "intro", outro = "outro" }

-- what makes a launch button, destination, exactly like source, which holds
-- for each of clip, fillIn, landing, intro and outro: present, colour, and
-- patterns, unipolar, bipolar and transitions by output; of all but clip also
-- oneBarPattern; returns a list of changes
local function copyButton(source, destination)
  local changes = {}
  for _, field in ipairs({ "clip", "fillIn", "landing", "intro", "outro" }) do
    local prefix = settingsPrefixes[field]
    local settings = source[field]
    local oneBar = prefix ~= "" and settings.oneBarPattern
    local setUp = prefix ~= "" and settings.setUp
    table.insert(changes, { kind = prefix .. "switches", index = destination, value = packSwitches(settings.present, settings.colour, oneBar, setUp) })
    for output = 1, outputCount do
      local value = packOutputSettings(settings.patterns[output], settings.unipolar[output], settings.bipolar[output], settings.transitions[output])
      table.insert(changes, { kind = prefix .. "output", index = destination, output = output, value = value })
    end
  end
  return changes
end

-- a press of a launch button in duplicate mode: in source picking it picks
-- the launch button as the source, if it holds a clip; in destination picking
-- for a launch button it makes the pressed one exactly like the source,
-- source, as copyButton describes it, and returns to launch mode; a press of
-- the source itself does nothing, as does a press with a scene as the source
-- or outside duplicate mode; returns a list of changes
local function duplicateModeLaunchButton(setup, track, row, pressedHoldsClip, source)
  if setup == setupSourcePicking then
    if pressedHoldsClip then
      return { { kind = "setup", value = setupFirstClipDestinationPicking + buttonIndex(track, row) } }
    end
    return {}
  end
  local sourceIndex = sourceButton(setup)
  local pressed = buttonIndex(track, row)
  if sourceIndex == nil or pressed == sourceIndex then
    return {}
  end
  local changes = copyButton(source, pressed)
  table.insert(changes, { kind = "setup", value = setupLaunchMode })
  return changes
end

-- a press of a scene button in duplicate mode: in source picking it picks the
-- scene as the source, if it holds a clip; in destination picking for a scene
-- it makes every launch button of the pressed scene exactly like the one of
-- the same track in the source scene, sources by track, 1..8, empty ones
-- included, and returns to launch mode; a press of the source itself does
-- nothing, as does a press with a launch button as the source or outside
-- duplicate mode; returns a list of changes
local function duplicateModeSceneButton(setup, scene, sceneHoldsClip, sources)
  if setup == setupSourcePicking then
    if sceneHoldsClip then
      return { { kind = "setup", value = setupFirstSceneDestinationPicking + scene - 1 } }
    end
    return {}
  end
  local source = sourceScene(setup)
  if source == nil or scene == source then
    return {}
  end
  local changes = {}
  for track = 1, 8 do
    for _, change in ipairs(copyButton(sources[track], buttonIndex(track, scene))) do
      table.insert(changes, change)
    end
  end
  table.insert(changes, { kind = "setup", value = setupLaunchMode })
  return changes
end

-- holding down a launch button and letting it go, or a scene button for each
-- track: in launch mode a press holds the track's relaunch press down as well
-- as choosing the selection; whether it relaunches is up to Launchnik;
-- elsewhere a press changes nothing, so returns nil; letting go is always
-- passed on
local function relaunchButton(setup, track, pressed)
  if track < 1 or track > 8 or (pressed and setup ~= setupLaunchMode) then
    return nil
  end
  return { kind = "relaunch", track = track, value = pressed and 1 or 0 }
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
-- scene mean, track by track: the selections, then the relaunch presses; in clip picking it chooses the length of the
-- switch interval it stands for, immediate at the bottom and sixteen bars at
-- the top, and returns to launch mode; in clear mode it empties every launch
-- button of its scene that holds a clip and returns to launch mode; in clip
-- editing it does nothing, and in duplicate mode nothing here, see
-- duplicateModeSceneButton (see
-- ADR 0004 of the Launchnik repository); holdsClip says of each track, 1..8,
-- whether its launch button in the scene holds a clip, and colours its clip's
-- colour, which clearing keeps; returns a list of changes
local function sceneButton(setup, scene, holdsClip, colours)
  local changes = {}
  if setup == setupClipPicking then
    return {
      { kind = "length", value = 8 - scene },
      { kind = "setup", value = setupLaunchMode },
    }
  end
  if setup == setupClearMode then
    for track = 1, 8 do
      if holdsClip[track] then
        table.insert(changes, { kind = "switches", index = buttonIndex(track, scene), value = packSwitches(false, colours[track], false, false) })
      end
    end
    table.insert(changes, { kind = "setup", value = setupLaunchMode })
    return changes
  end
  if setup ~= setupLaunchMode then
    return changes
  end
  for track = 1, 8 do
    table.insert(changes, launchButton(setup, track, scene, holdsClip[track], edited(false)))
  end
  for track = 1, 8 do
    table.insert(changes, relaunchButton(setup, track, true))
  end
  return changes
end

-- from launch mode to clip picking, and from any step of setup mode, from
-- clear mode or from duplicate mode back to launch mode
local function setupButton(setup)
  local inSetupMode = setup ~= setupLaunchMode
  return { kind = "setup", value = inSetupMode and setupLaunchMode or setupClipPicking }
end

-- from launch mode to clear mode and back; in setup mode and duplicate mode it
-- does nothing, so returns nil
local function clearButton(setup)
  if setup == setupLaunchMode then
    return { kind = "setup", value = setupClearMode }
  end
  if setup == setupClearMode then
    return { kind = "setup", value = setupLaunchMode }
  end
  return nil
end

-- from launch mode to duplicate mode, and from either step of it back; in
-- setup mode and clear mode it does nothing, so returns nil
local function duplicateButton(setup)
  if setup == setupLaunchMode then
    return { kind = "setup", value = setupSourcePicking }
  end
  if isDuplicateMode(setup) then
    return { kind = "setup", value = setupLaunchMode }
  end
  return nil
end

-- goes back one step of setup mode: from outro editing to intro editing, from
-- intro editing to landing editing, from landing editing to fill-in editing
-- and from fill-in editing to clip editing of the same launch button, from
-- clip editing to clip picking, from clip picking, from clear mode and from
-- duplicate mode to launch mode; in launch mode it does nothing, so returns
-- nil
local function backButton(setup)
  if setup == setupLaunchMode then
    return nil
  end
  if setup == setupClearMode or isDuplicateMode(setup) then
    return { kind = "setup", value = setupLaunchMode }
  end
  if isOutroEditing(setup) then
    return { kind = "setup", value = setupFirstIntroEditing + pickedButton(setup) }
  end
  if isIntroEditing(setup) then
    return { kind = "setup", value = setupFirstLandingEditing + pickedButton(setup) }
  end
  if isLandingEditing(setup) then
    return { kind = "setup", value = setupFirstFillInEditing + pickedButton(setup) }
  end
  if isFillInEditing(setup) then
    return { kind = "setup", value = setupFirstClipEditing + pickedButton(setup) }
  end
  return { kind = "setup", value = setup == setupClipPicking and setupLaunchMode or setupClipPicking }
end

-- holding the back button, that is letting it go after keeping it down for
-- holdMilliseconds or more: from fill-in editing, landing editing, intro
-- editing and outro editing it goes straight back to clip picking, so that the
-- user can pick another launch button; anywhere else it does what backButton
-- does
local holdMilliseconds = 200

local function heldBackButton(setup)
  if isFillInEditing(setup) or isLandingEditing(setup) or isIntroEditing(setup) or isOutroEditing(setup) then
    return { kind = "setup", value = setupClipPicking }
  end
  return backButton(setup)
end

-- goes forward one step of setup mode: from clip editing to fill-in editing,
-- from fill-in editing to landing editing, from landing editing to intro
-- editing and from intro editing to outro editing of the same launch button,
-- but only if it holds a clip; anywhere else it does nothing, so returns nil
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
  if isLandingEditing(setup) then
    return { kind = "setup", value = setupFirstIntroEditing + pickedButton(setup) }
  end
  if isIntroEditing(setup) then
    return { kind = "setup", value = setupFirstOutroEditing + pickedButton(setup) }
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
  setupFirstIntroEditing = setupFirstIntroEditing,
  setupFirstOutroEditing = setupFirstOutroEditing,
  setupClearMode = setupClearMode,
  setupSourcePicking = setupSourcePicking,
  setupFirstClipDestinationPicking = setupFirstClipDestinationPicking,
  setupFirstSceneDestinationPicking = setupFirstSceneDestinationPicking,
  setupCount = setupCount,
  functionStop = functionStop,
  functionMute = functionMute,
  functionSolo = functionSolo,
  outputCount = outputCount,
  cvModeBipolar = cvModeBipolar,
  cvModeUnipolar = cvModeUnipolar,
  cvModePattern = cvModePattern,
  defaultCVMode = defaultCVMode,
  packOutputSettings = packOutputSettings,
  packSwitches = packSwitches,
  unpackSwitches = unpackSwitches,
  unpackOutputSettings = unpackOutputSettings,
  edited = edited,
  buttonIndex = buttonIndex,
  isClipEditing = isClipEditing,
  isFillInEditing = isFillInEditing,
  isLandingEditing = isLandingEditing,
  isIntroEditing = isIntroEditing,
  isOutroEditing = isOutroEditing,
  pickedButton = pickedButton,
  isDuplicateMode = isDuplicateMode,
  sourceButton = sourceButton,
  sourceScene = sourceScene,
  copyButton = copyButton,
  duplicateModeLaunchButton = duplicateModeLaunchButton,
  duplicateModeSceneButton = duplicateModeSceneButton,
  launchButton = launchButton,
  fillInEditingLaunchButton = fillInEditingLaunchButton,
  landingEditingLaunchButton = landingEditingLaunchButton,
  introEditingLaunchButton = introEditingLaunchButton,
  outroEditingLaunchButton = outroEditingLaunchButton,
  clearModeLaunchButton = clearModeLaunchButton,
  relaunchButton = relaunchButton,
  stopButton = stopButton,
  functionButton = functionButton,
  functionSelectButton = functionSelectButton,
  sceneButton = sceneButton,
  setupButton = setupButton,
  clearButton = clearButton,
  duplicateButton = duplicateButton,
  backButton = backButton,
  heldBackButton = heldBackButton,
  holdMilliseconds = holdMilliseconds,
  forwardButton = forwardButton,
  fillInButton = fillInButton,
}

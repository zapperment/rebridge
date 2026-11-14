local launchnik = require "src.lpcommon.lib.launchnik._"
local write = require "src.lpcommon.remote.processMidi.write"

local press = launchnik.press
local state = launchnik.state

-- the scene buttons send the control change that continues the numbering of
-- the pads in their row: 19 at the bottom to 89 at the top
local firstSceneButton = 19
local lastSceneButton = 89

-- what a press in clip editing, fill-in editing, landing editing, intro
-- editing or outro editing needs to know of what is being edited
local function editedSettings(picked)
  local track = math.floor(picked / 8) + 1
  -- what is being edited, as state.button has it
  local field = "clip"
  if press.isFillInEditing(state.setup) then
    field = "fillIn"
  elseif press.isLandingEditing(state.setup) then
    field = "landing"
  elseif press.isIntroEditing(state.setup) then
    field = "intro"
  elseif press.isOutroEditing(state.setup) then
    field = "outro"
  end
  local settings = state.button(picked)[field]
  return press.edited(settings.present, state.cvModes[track], settings.transitions, settings.oneBarPattern, settings)
end

-- whether any launch button of a track holds a clip
local function trackHoldsClips(track)
  for row = 1, 8 do
    if state.present[press.buttonIndex(track, row)] then
      return true
    end
  end
  return false
end

-- a press of a function button means what a click on the function button of
-- its track means in the current function; a mute or solo button is held down
-- for as long as the button on the surface is, and letting go lets go of the
-- same one, whatever the function is by then
local function processFunctionButton(event, track, pressed)
  if pressed then
    local change = press.functionButton(state["function"], track, trackHoldsClips(track), true)
    if change and (change.kind == "mute" or change.kind == "solo") then
      state.heldFunctionButtons[track] = change.kind
    end
    write(event, change)
    return
  end
  local held = state.heldFunctionButtons[track]
  if held then
    state.heldFunctionButtons[track] = nil
    write(event, { kind = held, track = track, value = 0 })
  end
end

-- writes a change, and remembers a relaunch press held down, so that letting
-- go of the pad or scene button lets go of it
local function writeHeld(event, change)
  if change and change.kind == "relaunch" then
    state.heldRelaunches[change.track] = true
  end
  write(event, change)
end

-- lets go of the relaunch presses of the given tracks that are held down;
-- returns whether there were any
local function releaseRelaunches(event, tracks)
  local released = false
  for _, track in ipairs(tracks) do
    if state.heldRelaunches[track] then
      state.heldRelaunches[track] = nil
      write(event, press.relaunchButton(state.setup, track, false))
      released = true
    end
  end
  return released
end

local allTracks = { 1, 2, 3, 4, 5, 6, 7, 8 }

-- makes the handler of the presses of the pads, the function buttons, the
-- function select buttons, the scene buttons, the setup button (if it sends
-- MIDI), the back button, the forward button, the clear button, the duplicate
-- button and the fill-in button of the device given (see
-- src/lppmk3/device.lua): a pad means what a click on the launch button in
-- its place means, a scene button what a click on the scene button of its row
-- means, the other buttons what a click on the button of the same name on
-- Launchnik means; the fill-in button is held down for as long as its button
-- on the surface is, and so are the function buttons in mute and solo
-- function
--
-- The handler gets an input, as remote/processMidi/surface.lua makes it,
-- rather than a MIDI event.
return function(device)
  local controls = device.controls
  local backButton = controls.back
  local forwardButton = controls.forward
  local fillInButton = controls.fillIn
  local clearButton = controls.clear
  local duplicateButton = controls.duplicate
  local setupButton = controls.setup
  local firstFunctionButton = controls.firstFunctionButton
  local lastFunctionButton = firstFunctionButton + 7
  local functionSelectButtons = controls.functionSelectButtons

  local function processPadsAndTrackButtons(input)
    local control, value = input.control, input.value
    local isButton = not input.pad
    -- the setup button acts when it is let go, as the surface's own Setup
    -- button does on the Launchpad Pro [MK3]
    if setupButton and isButton and control == setupButton then
      if value == 0 then
        write(input, press.setupButton(state.setup))
      end
      return true
    end
    if isButton and control == fillInButton then
      write(input, press.fillInButton(value > 0))
      return true
    end
    -- the back button and the forward button act when they are let go, so
    -- that a hold of the back button can be told from a click
    if isButton and control == backButton then
      if value > 0 then
        state.backPressedAt = remote.get_time_ms()
        return true
      end
      local held = state.backPressedAt ~= nil and remote.get_time_ms() - state.backPressedAt >= press.holdMilliseconds
      state.backPressedAt = nil
      write(input, held and press.heldBackButton(state.setup) or press.backButton(state.setup))
      return true
    end
    if isButton and control == forwardButton then
      if value == 0 then
        local picked = press.pickedButton(state.setup)
        write(input, press.forwardButton(state.setup, picked ~= nil and state.present[picked]))
      end
      return true
    end
    if isButton and control >= firstFunctionButton and control <= lastFunctionButton then
      processFunctionButton(input, control - firstFunctionButton + 1, value > 0)
      return true
    end
    local isSceneButton = control >= firstSceneButton and control <= lastSceneButton and control % 10 == 9
    -- letting go of a pad lets go of its track's relaunch press, letting go of
    -- a scene button those of every track
    if value == 0 then
      if input.pad then
        return releaseRelaunches(input, { control % 10 })
      end
      if isButton and isSceneButton then
        return releaseRelaunches(input, allTracks)
      end
      return false
    end
    if input.pad then
      -- the pads send note 11 at the bottom left to 88 at the top right
      local track = control % 10
      local row = 9 - ((control - track) / 10)
      if state.setup == press.setupClearMode then
        for _, change in ipairs(press.clearModeLaunchButton(state.setup, track, row, state.present[press.buttonIndex(track, row)], state.colours[press.buttonIndex(track, row)])) do
          write(input, change)
        end
        return true
      end
      if press.isDuplicateMode(state.setup) then
        local pressed = press.buttonIndex(track, row)
        local source = state.button(press.sourceButton(state.setup) or pressed)
        for _, change in ipairs(press.duplicateModeLaunchButton(state.setup, track, row, state.present[pressed], source)) do
          write(input, change)
        end
        return true
      end
      local picked = press.pickedButton(state.setup)
      if picked ~= nil and not press.isClipEditing(state.setup) then
        local clipValues = { patterns = state.patterns[picked], unipolar = state.unipolar[picked], bipolar = state.bipolar[picked] }
        local editLaunchButton = press.outroEditingLaunchButton
        if press.isFillInEditing(state.setup) then
          editLaunchButton = press.fillInEditingLaunchButton
        elseif press.isLandingEditing(state.setup) then
          editLaunchButton = press.landingEditingLaunchButton
        elseif press.isIntroEditing(state.setup) then
          editLaunchButton = press.introEditingLaunchButton
        end
        for _, change in ipairs(editLaunchButton(state.setup, track, row, editedSettings(picked), clipValues)) do
          write(input, change)
        end
        return true
      end
      local pressedHoldsClip = state.present[press.buttonIndex(track, row)]
      local pickedClip = picked ~= nil and editedSettings(picked) or press.edited(false)
      -- in launch mode the relaunch press follows the selection, which
      -- Launchnik compares it with
      write(input, press.launchButton(state.setup, track, row, pressedHoldsClip, pickedClip))
      writeHeld(input, press.relaunchButton(state.setup, track, true))
      return true
    end
    if isButton and functionSelectButtons[control] then
      write(input, press.functionSelectButton(functionSelectButtons[control]))
      return true
    end
    if isButton and control == clearButton then
      write(input, press.clearButton(state.setup))
      return true
    end
    if isButton and control == duplicateButton then
      write(input, press.duplicateButton(state.setup))
      return true
    end
    if isButton and isSceneButton then
      local scene = 9 - (control - 9) / 10
      local holdsClip = {}
      local colours = {}
      local sceneHoldsClip = false
      for track = 1, 8 do
        holdsClip[track] = state.present[press.buttonIndex(track, scene)]
        colours[track] = state.colours[press.buttonIndex(track, scene)]
        sceneHoldsClip = sceneHoldsClip or holdsClip[track]
      end
      if press.isDuplicateMode(state.setup) then
        local source = press.sourceScene(state.setup) or scene
        local sources = {}
        for track = 1, 8 do
          sources[track] = state.button(press.buttonIndex(track, source))
        end
        for _, change in ipairs(press.duplicateModeSceneButton(state.setup, scene, sceneHoldsClip, sources)) do
          write(input, change)
        end
        return true
      end
      for _, change in ipairs(press.sceneButton(state.setup, scene, holdsClip, colours)) do
        writeHeld(input, change)
      end
      return true
    end
    return false
  end

  return {
    processPadsAndTrackButtons = processPadsAndTrackButtons,
  }
end

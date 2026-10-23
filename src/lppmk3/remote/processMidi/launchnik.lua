local items = require "src.lppmk3.config.items"
local deb = require "src.lib.debug._"
local launchnik = require "src.lppmk3.lib.launchnik._"

local press = launchnik.press
local state = launchnik.state

local noteOn = 144
local controlChange = 176
-- the function buttons, in the upper of the two rows beneath the grid
local firstFunctionButton = 101
local lastFunctionButton = 108
-- the function select buttons, in the lower row: mute, solo and stop
local functionSelectButtons = { [2] = press.functionMute, [3] = press.functionSolo, [8] = press.functionStop }
-- the scene buttons send the control change that continues the numbering of
-- the pads in their row: 19 at the bottom to 89 at the top
local firstSceneButton = 19
local lastSceneButton = 89
-- the button with the arrow pointing left, beside Shift
local backButton = 91
-- the button in the top row above the second column of pads
local forwardButton = 92
-- the button to the left of the sixth row of pads from the top
local fillInButton = 30

-- the name of the item that carries a change to the host
local function itemName(change)
  if change.kind == "selection" then
    return "track" .. change.track .. "selection"
  end
  if change.kind == "setup" then
    return "setup"
  end
  if change.kind == "length" then
    return "switchinterval"
  end
  if change.kind == "fillin" then
    return "fillin"
  end
  if change.kind == "function" then
    return "function"
  end
  if change.kind == "mute" or change.kind == "solo" then
    return "track" .. change.track .. change.kind
  end
  local track = math.floor(change.index / 8) + 1
  local row = change.index % 8 + 1
  local clip = "track" .. track .. "clip" .. row
  -- a setting of a CV output, such as track1clip1apattern,
  -- track1clip1fillinapattern or track1clip1landingapattern
  if change.output then
    local letter = string.char(string.byte("a") + change.output - 1)
    for _, prefix in ipairs({ "fillin", "landing" }) do
      local setting = string.match(change.kind, "^" .. prefix .. "(.+)$")
      if setting then
        return clip .. prefix .. letter .. setting
      end
    end
    return clip .. letter .. change.kind
  end
  return clip .. change.kind
end

-- hands a change to the host; nil stands for a press that changes nothing
local function write(event, change)
  if not change then
    return
  end
  local name = itemName(change)
  deb.log("[lppmk3:remote:processMidi:launchnik] " .. name .. " = " .. change.value)
  remote.handle_input({ time_stamp = event.time_stamp, item = items[name].index, value = change.value })
end

-- what a press in clip editing, fill-in editing or landing editing needs to
-- know of the clip, fill-in or landing being edited
local function editedSettings(picked)
  local track = math.floor(picked / 8) + 1
  if press.isFillInEditing(state.setup) then
    return press.edited(state.fillInPresent[picked], state.cvModes[track], state.fillInTransitions[picked])
  end
  if press.isLandingEditing(state.setup) then
    return press.edited(state.landingPresent[picked], state.cvModes[track], state.landingTransitions[picked], state.landingOneBarPattern[picked])
  end
  return press.edited(state.present[picked], state.cvModes[track], state.transitions[picked])
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

-- handles presses of the pads, the function buttons, the function select
-- buttons, the scene buttons, the back button, the forward button and the
-- fill-in button: a pad means what a click on the launch button in its place
-- means, a scene button what a click on the scene button of its row means, the
-- other buttons what a click on the button of the same name on Launchnik
-- means; the fill-in button is held down for as long as its button on the
-- surface is, and so are the function buttons in mute and solo function
local function processPadsAndTrackButtons(event)
  local ret = remote.match_midi("xx yy zz", event)
  if not ret then
    return false
  end
  if ret.x == controlChange and ret.y == fillInButton then
    write(event, press.fillInButton(ret.z > 0))
    return true
  end
  if ret.x == controlChange and ret.y >= firstFunctionButton and ret.y <= lastFunctionButton then
    processFunctionButton(event, ret.y - firstFunctionButton + 1, ret.z > 0)
    return true
  end
  if ret.z == 0 then
    return false
  end
  if ret.x == noteOn then
    -- the pads send note 11 at the bottom left to 88 at the top right
    local track = ret.y % 10
    local row = 9 - ((ret.y - track) / 10)
    local picked = press.pickedButton(state.setup)
    local fillInEditing = press.isFillInEditing(state.setup)
    if fillInEditing or press.isLandingEditing(state.setup) then
      local clipValues = { patterns = state.patterns[picked], unipolar = state.unipolar[picked], bipolar = state.bipolar[picked] }
      local editLaunchButton = fillInEditing and press.fillInEditingLaunchButton or press.landingEditingLaunchButton
      for _, change in ipairs(editLaunchButton(state.setup, track, row, editedSettings(picked), clipValues)) do
        write(event, change)
      end
      return true
    end
    local pressedHoldsClip = state.present[press.buttonIndex(track, row)]
    local pickedClip = picked ~= nil and editedSettings(picked) or press.edited(false)
    write(event, press.launchButton(state.setup, track, row, pressedHoldsClip, pickedClip))
    return true
  end
  if ret.x == controlChange and ret.y == forwardButton then
    local picked = press.pickedButton(state.setup)
    write(event, press.forwardButton(state.setup, picked ~= nil and state.present[picked]))
    return true
  end
  if ret.x == controlChange and functionSelectButtons[ret.y] then
    write(event, press.functionSelectButton(functionSelectButtons[ret.y]))
    return true
  end
  if ret.x == controlChange and ret.y == backButton then
    write(event, press.backButton(state.setup))
    return true
  end
  local isSceneButton = ret.y >= firstSceneButton and ret.y <= lastSceneButton and ret.y % 10 == 9
  if ret.x == controlChange and isSceneButton then
    local scene = 9 - (ret.y - 9) / 10
    local holdsClip = {}
    for track = 1, 8 do
      holdsClip[track] = state.present[press.buttonIndex(track, scene)]
    end
    for _, change in ipairs(press.sceneButton(state.setup, scene, holdsClip)) do
      write(event, change)
    end
    return true
  end
  return false
end

return {
  processPadsAndTrackButtons = processPadsAndTrackButtons,
  write = write,
}

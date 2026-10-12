local items = require "src.lppmk3.config.items"
local deb = require "src.lib.debug._"
local launchnik = require "src.lppmk3.lib.launchnik._"

local press = launchnik.press
local state = launchnik.state

local noteOn = 144
local controlChange = 176
local firstTrackButton = 101
local lastTrackButton = 108
-- the scene buttons send the control change that continues the numbering of
-- the pads in their row: 19 at the bottom to 89 at the top
local firstSceneButton = 19
local lastSceneButton = 89

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
  local track = math.floor(change.index / 8) + 1
  local row = change.index % 8 + 1
  return "track" .. track .. "clip" .. row .. change.kind
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

-- handles presses of the pads, the track buttons and the scene buttons: a pad
-- means what a click on the launch button in its place means, a track button
-- what a click on the stop button of its track means, a scene button what a
-- click on the scene button of its row means
local function processPadsAndTrackButtons(event)
  local ret = remote.match_midi("xx yy zz", event)
  if not ret or ret.z == 0 then
    return false
  end
  if ret.x == noteOn then
    -- the pads send note 11 at the bottom left to 88 at the top right
    local track = ret.y % 10
    local row = 9 - ((ret.y - track) / 10)
    local pressedHoldsClip = state.present[press.buttonIndex(track, row)]
    local isClipEditing = state.setup >= press.setupFirstClipEditing
    local pickedHoldsClip = isClipEditing and state.present[state.setup - press.setupFirstClipEditing]
    write(event, press.launchButton(state.setup, track, row, pressedHoldsClip, pickedHoldsClip))
    return true
  end
  if ret.x == controlChange and ret.y >= firstTrackButton and ret.y <= lastTrackButton then
    write(event, press.stopButton(ret.y - firstTrackButton + 1))
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

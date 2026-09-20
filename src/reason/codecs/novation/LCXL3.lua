local autoInputs = require "src.config.autoInputs"
local autoOutputs = require "src.config.autoOutputs"
local const = require "src.config.constants"
local deliverButtons = require "src.remote.deliverMidi.buttons"
local deliverDisplay = require "src.remote.deliverMidi.display"
local deliverEncoders = require "src.remote.deliverMidi.encoders"
local deliverFaders = require "src.remote.deliverMidi.faders"
local deliverInfo = require "src.remote.deliverMidi.info"
local deliverPages = require "src.remote.deliverMidi.pages"
local deliverSelection = require "src.remote.deliverMidi.selection"
local deliverTransport = require "src.remote.deliverMidi.transport"
local items = require "src.config.items"
local midi = require "src.lib.midi._"
local processButtons = require "src.remote.processMidi.buttons"
local processEncoders = require "src.remote.processMidi.encoders"
local processFaders = require "src.remote.processMidi.faders"
local processNavigation = require "src.remote.processMidi.navigation"
local processTransport = require "src.remote.processMidi.transport"
local processRackUI = require "src.remote.processMidi.rackUI"
local processSelection = require "src.remote.processMidi.selection"
local setButtons = require "src.remote.setState.buttons"
local setEncoders = require "src.remote.setState.encoders"
local setFaders = require "src.remote.setState.faders"
local setRackUI = require "src.remote.setState.rackUI"
local setInfo = require "src.remote.setState.info"
local setPages = require "src.remote.setState.pages"
local setSelection = require "src.remote.setState.selection"
local setTransport = require "src.remote.setState.transport"
local deb = require "src.lib.debug._"

---@diagnostic disable-next-line: lowercase-global
function remote_init()
  local itemsToDefine = {}
  for name, item in pairs(items) do
    table.insert(itemsToDefine, {
      name = name,
      input = item.input,
      output = item.output,
      min = item.min,
      max = item.max,
    })
    item.index = #itemsToDefine
  end
  remote.define_items(itemsToDefine)
  remote.define_auto_inputs(autoInputs)
  remote.define_auto_outputs(autoOutputs)
  if _ENV ~= "test" then
    deb.log(
      "[reason.codecs.novation.LCXL3] " ..
      "remote codec version " .. const.softwareVersion .. " " ..
      "initialised successfully!"
    )
  end
end

-- Remote surface (Launch Control) -> remote codec -> host (Reason)
---@diagnostic disable-next-line: lowercase-global
function remote_process_midi(event)
  return processRackUI(event)
      or processSelection(event)
      or processEncoders(event)
      or processFaders(event)
      or processButtons(event)
      or processTransport(event)
      or processNavigation(event)
end

-- Host (Reason) -> remote codec
---@diagnostic disable-next-line: lowercase-global
function remote_set_state(changedItems)
  setRackUI(changedItems)
  setInfo(changedItems)
  setPages(changedItems)
  setSelection(changedItems)
  setEncoders(changedItems)
  setFaders(changedItems)
  setButtons(changedItems)
  setTransport(changedItems)
end

-- Remote codec -> remote surface (Launch Control)
---@diagnostic disable-next-line: lowercase-global
function remote_deliver_midi(_, port)
  if port == 2 then
    return deb.dump()
  end

  local events = {}

  for _, event in ipairs(deliverInfo()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverPages()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverEncoders()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverFaders()) do
    table.insert(events, event)
  end
  -- before the buttons, which take back the selection buttons in the same
  -- delivery when a selecting device loses the target
  for _, event in ipairs(deliverSelection()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverButtons()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverTransport()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverDisplay()) do
    table.insert(events, event)
  end

  return events
end

---@diagnostic disable-next-line: lowercase-global
function remote_prepare_for_use()
  local events = {
    -- turn on DAW mode
    midi.makeSysexEvent "02 7f",
    remote.make_midi("b6 1e 02"),

    -- set encoder modes to absolute
    remote.make_midi("b6 45 00"),
    remote.make_midi("b6 48 00"),
    remote.make_midi("b6 49 00"),

    -- set the colours of navigation buttons to dim white
    midi.makeSysexEvent "01 53 6a 1f 1f 1f",
    midi.makeSysexEvent "01 53 6b 1f 1f 1f",
    midi.makeSysexEvent "01 53 67 1f 1f 1f",
    midi.makeSysexEvent "01 53 66 1f 1f 1f",

    -- turn off the play and record button LEDs
    midi.makeSysexEvent "01 53 74 00 00 00",
    midi.makeSysexEvent "01 53 76 00 00 00",

    -- set temporary display timeout to 1 sec
    remote.make_midi("b6 71 00"),
  }

  -- Stop the encoders and faders bringing up their displays until the host has
  -- assigned a parameter to them, as a control with nothing mapped to it would
  -- otherwise show the raw MIDI controller and value it is sending.
  for i = 1, 24 do
    table.insert(events, midi.makeParamDisplayConfigEvent(items["encoder" .. i].controller, false))
  end
  for i = 1, 8 do
    table.insert(events, midi.makeParamDisplayConfigEvent(items["fader" .. i].controller, false))
  end

  return events
end

---@diagnostic disable-next-line: lowercase-global
function remote_release_from_use()
  return {
    -- turn off DAW mode
    midi.makeSysexEvent "02 00",
  }
end

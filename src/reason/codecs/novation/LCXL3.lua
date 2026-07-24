local items = require("src.config.items")
local processEncoders = require("src.processMidi.encoders")
local processFaders = require("src.processMidi.faders")
local processButtons = require("src.processMidi.buttons")
local setEncoders = require("src.setState.encoders")
local setFaders = require("src.setState.faders")
local setInfo = require("src.setState.info")
local setButtons = require("src.setState.buttons")
local deliverEncoders = require("src.deliverMidi.encoders")
local deliverFaders = require("src.deliverMidi.faders")
local deliverButtons = require("src.deliverMidi.buttons")
local deliverDisplay = require("src.deliverMidi.display")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")
local debug = require("src.lib.debug._")
local autoInputs = require("src.config.autoInputs")

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
  debug.log("LCXL3 remote codec initialised successfully!")
end

-- Remote surface (Launch Control) -> remote codec -> host (Reason)
function remote_process_midi(event)
  return processEncoders(event) or processFaders(event) or processButtons(event)
end

-- Host (Reason) -> remote codec
function remote_set_state(changedItems)
  setInfo(changedItems)
  setEncoders(changedItems)
  setFaders(changedItems)
  setButtons(changedItems)
end

-- Remote codec -> remote surface (Launch Control)
function remote_deliver_midi(_, port)
  if port == 2 then
    return debug.dump()
  end

  local events = {}

  for _, event in ipairs(deliverEncoders()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverFaders()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverButtons()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverDisplay()) do
    table.insert(events, event)
  end

  return events
end

function remote_prepare_for_use()
  return {
    -- turn on DAW mode
    makeSysexEvent("02 7f"),
    remote.make_midi("b6 1e 02"),

    -- set encoder modes to absolute
    remote.make_midi("b6 45 00"),
    remote.make_midi("b6 48 00"),
    remote.make_midi("b6 49 00"),

    -- set the colours of navigation buttons to dim white
    makeSysexEvent("01 53 6a 1f 1f 1f"),
    makeSysexEvent("01 53 6b 1f 1f 1f"),
    makeSysexEvent("01 53 67 1f 1f 1f"),
    makeSysexEvent("01 53 66 1f 1f 1f"),

    -- set temporary display timeout to 1 sec
    remote.make_midi("b6 71 00"),
  }
end

function remote_release_from_use()
  return {
    -- turn off DAW mode
    makeSysexEvent("02 00"),
  }
end

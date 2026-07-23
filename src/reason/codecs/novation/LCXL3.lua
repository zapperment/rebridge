local items = require("src.config.items")
local processFaders = require("src.processMidi.faders")
local processEncoders = require("src.processMidi.encoders")
local setFaders = require("src.setState.faders")
local setEncoders = require("src.setState.encoders")
local deliverFaders = require("src.deliverMidi.faders")
local deliverEncoders = require("src.deliverMidi.encoders")

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
    item.lastInputTime = 0
    item.updateValue = false
    item.updateColour = false
  end
  remote.define_items(itemsToDefine)
end

-- Launch Control -> Remote
function remote_process_midi(event)
  return processFaders(event) or processEncoders(event)
end

-- Reason -> Remote
function remote_set_state(changedItems)
  setEncoders(changedItems)
  setFaders(changedItems)
end

-- Remote -> Launch Control
function remote_deliver_midi()
  local events = {}

  for _, event in ipairs(deliverEncoders()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverFaders()) do
    table.insert(events, event)
  end

  return events
end

function remote_prepare_for_use()
  return {
    -- turn on DAW mode
    remote.make_midi("f0 00 20 29 02 15 02 7f f7"),
    remote.make_midi("b6 45 00"),
    remote.make_midi("b6 48 00"),
    remote.make_midi("b6 49 00"),
  }
end

function remote_release_from_use()
  return {
    -- turn off DAW mode
    remote.make_midi("F0 00 20 29 02 15 02 00 F7"),
  }
end

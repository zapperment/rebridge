local items = require("src.config.items")
local processEncoders = require("src.processMidi.encoders")
local processFaders = require("src.processMidi.faders")
local processButtons = require("src.processMidi.buttons")
local processTransport = require("src.processMidi.transport")
local processNavigation = require("src.processMidi.navigation")
local setEncoders = require("src.setState.encoders")
local setFaders = require("src.setState.faders")
local setInfo = require("src.setState.info")
local setPages = require("src.setState.pages")
local setButtons = require("src.setState.buttons")
local setTransport = require("src.setState.transport")
local deliverEncoders = require("src.deliverMidi.encoders")
local deliverFaders = require("src.deliverMidi.faders")
local deliverInfo = require("src.deliverMidi.info")
local deliverButtons = require("src.deliverMidi.buttons")
local deliverPages = require("src.deliverMidi.pages")
local deliverTransport = require("src.deliverMidi.transport")
local deliverDisplay = require("src.deliverMidi.display")
local midi = require("src.lib.midi._")
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
  debug.log("[reason.codecs.novation.LCXL3] remote codec initialised successfully!")
end

-- Remote surface (Launch Control) -> remote codec -> host (Reason)
function remote_process_midi(event)
  return processEncoders(event)
      or processFaders(event)
      or processButtons(event)
      or processTransport(event)
      or processNavigation(event)
end

-- Host (Reason) -> remote codec
function remote_set_state(changedItems)
  setInfo(changedItems)
  setPages(changedItems)
  setEncoders(changedItems)
  setFaders(changedItems)
  setButtons(changedItems)
  setTransport(changedItems)
end

-- Remote codec -> remote surface (Launch Control)
function remote_deliver_midi(_, port)
  if port == 2 then
    return debug.dump()
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

function remote_prepare_for_use()
  local events = {
    -- turn on DAW mode
    midi.makeSysexEvent("02 7f"),
    remote.make_midi("b6 1e 02"),

    -- set encoder modes to absolute
    remote.make_midi("b6 45 00"),
    remote.make_midi("b6 48 00"),
    remote.make_midi("b6 49 00"),

    -- set the colours of navigation buttons to dim white
    midi.makeSysexEvent("01 53 6a 1f 1f 1f"),
    midi.makeSysexEvent("01 53 6b 1f 1f 1f"),
    midi.makeSysexEvent("01 53 67 1f 1f 1f"),
    midi.makeSysexEvent("01 53 66 1f 1f 1f"),

    -- turn off the play and record button LEDs
    midi.makeSysexEvent("01 53 74 00 00 00"),
    midi.makeSysexEvent("01 53 76 00 00 00"),

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

function remote_release_from_use()
  return {
    -- turn off DAW mode
    midi.makeSysexEvent("02 00"),
  }
end

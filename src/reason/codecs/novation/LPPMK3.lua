local const = require "src.lppmk3.config.constants"
local items = require "src.lppmk3.config.items"
local deb = require "src.lib.debug._"
local midi = require "src.lppmk3.lib.midi._"
local processPads = require "src.lppmk3.remote.processMidi.pads"
local processShift = require "src.lppmk3.remote.processMidi.shift"
local processTransport = require "src.lppmk3.remote.processMidi.transport"
local processStore = require "src.lppmk3.remote.processMidi.store"
local setPattern = require "src.lppmk3.remote.setState.patterns"
local setTransport = require "src.lppmk3.remote.setState.transport"
local setStore = require "src.lppmk3.remote.setState.store"
local deliverPadColours = require "src.lppmk3.remote.deliverMidi.padColours"
local deliverTransport = require "src.lppmk3.remote.deliverMidi.transport"
local deliverSwitchMeter = require "src.lppmk3.remote.deliverMidi.switchMeter"
local deliverStore = require "src.lppmk3.remote.deliverMidi.store"
local deliverPadsOff = require "src.lppmk3.remote.deliverMidi.padsOff"

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
  if _ENV ~= "test" then
    deb.log(
      "[reason.codecs.novation.LPPMK3] " ..
      "Novation Launchpad Pro [MK3] " ..
      "remote codec version " .. const.softwareVersion .. " " ..
      "initialised successfully!"
    )
  end
end

-- Remote surface (Launchpad) -> remote codec -> host (Reason)
---@diagnostic disable-next-line: lowercase-global
function remote_process_midi(event)
  return processStore(event) or processShift(event) or processTransport(event) or processPads(event)
end

-- Host (Reason) -> remote codec
---@diagnostic disable-next-line: lowercase-global
function remote_set_state(changedItems)
  setPattern(changedItems)
  setTransport(changedItems)
  setStore(changedItems)
end

-- Remote codec -> remote surface (Launchpad)
---@diagnostic disable-next-line: lowercase-global
function remote_deliver_midi(_, port)
  if port == const.ports.log then
    return deb.dump()
  end

  if port == const.ports.store then
    return deliverStore()
  end

  local events = {}

  -- the play button goes first, as the pad colours mark the transport state
  -- as delivered
  for _, event in ipairs(deliverTransport()) do
    table.insert(events, event)
  end

  for _, event in ipairs(deliverPadColours()) do
    table.insert(events, event)
  end

  for _, event in ipairs(deliverSwitchMeter()) do
    table.insert(events, event)
  end

  return events
end

---@diagnostic disable-next-line: lowercase-global
function remote_prepare_for_use()
  local events = {
    -- turn on programmer mode
    midi.makeSysexEvent "0e 01",
  }
  -- clear the pads the last session left lit
  for _, event in ipairs(deliverPadsOff()) do
    table.insert(events, event)
  end
  return events
end

---@diagnostic disable-next-line: lowercase-global
function remote_release_from_use()
  return {
    -- turn off programmer mode
    midi.makeSysexEvent "0e 00",
  }
end

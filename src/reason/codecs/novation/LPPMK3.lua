local const = require "src.lppmk3.config.constants"
local items = require "src.lppmk3.config.items"
local deb = require "src.lib.debug._"
local midi = require "src.lppmk3.lib.midi._"
local processPads = require "src.lppmk3.remote.processMidi.pads"
local processShift = require "src.lppmk3.remote.processMidi.shift"
local processTransport = require "src.lppmk3.remote.processMidi.transport"
local setPattern = require "src.lppmk3.remote.setState.patterns"
local setTransport = require "src.lppmk3.remote.setState.transport"
local deliverPadColours = require "src.lppmk3.remote.deliverMidi.padColours"
local deliverTransport = require "src.lppmk3.remote.deliverMidi.transport"

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
  return processShift(event) or processTransport(event) or processPads(event)
end

-- Host (Reason) -> remote codec
---@diagnostic disable-next-line: lowercase-global
function remote_set_state(changedItems)
  setPattern(changedItems)
  setTransport(changedItems)
end

-- Remote codec -> remote surface (Launchpad)
---@diagnostic disable-next-line: lowercase-global
function remote_deliver_midi(_, port)
  if port == 2 then
    return deb.dump()
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

  return events
end

---@diagnostic disable-next-line: lowercase-global
function remote_prepare_for_use()
  return {
    -- turn on programmer mode
    midi.makeSysexEvent "0e 01",
  }
end

---@diagnostic disable-next-line: lowercase-global
function remote_release_from_use()
  return {
    -- turn off programmer mode
    midi.makeSysexEvent "0e 00",
  }
end

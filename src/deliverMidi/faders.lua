local state = require("src.lib.state._")
local items = require("src.config.items")
local const = require("src.config.constants")
local makeParamNameDisplayEvent = require("src.lib.midi.makeParamNameDisplayEvent")
local makeParamDisplayConfigEvent = require("src.lib.midi.makeParamDisplayConfigEvent")

-- the LED display character set has no arrow glyphs (only ASCII 20h-7Eh),
-- so "^" and "v" indicate which way to move the fader to pick up the host value
local pickupPrefixes = {
  [const.fader.tooLow] = "^ ",
  [const.fader.tooHigh] = "v ",
}

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, 8 do
    local fader = "fader" .. i
    if state.hasChanged(fader) then
      local wasAssigned = state.get(fader) ~= const.fader.unassigned
      local status = state.update(fader)
      local isAssigned = status ~= const.fader.unassigned
      local item = items[fader]

      -- the parameter name stays on the fader's display until it is overwritten,
      -- so an unassigned fader must not bring that display up at all; otherwise
      -- moving it shows the previous name and a raw value
      if isAssigned ~= wasAssigned then
        table.insert(events, makeParamDisplayConfigEvent(item.controller, isAssigned))
      end

      if isAssigned then
        local prefix = pickupPrefixes[status] or ""
        table.insert(events, makeParamNameDisplayEvent(prefix .. remote.get_item_name(item.index), item.controller))
      end
    end
  end
  return events
end

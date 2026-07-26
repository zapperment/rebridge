local state = require("src.lib.state._")
local items = require("src.config.items")
local const = require("src.config.constants")
local makeParamNameDisplayEvent = require("src.lib.midi.makeParamNameDisplayEvent")

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
      local status = state.update(fader)
      local item = items[fader]
      if status == const.fader.unassigned then
        table.insert(events, makeParamNameDisplayEvent(" ", item.controller))
      else
        local prefix = pickupPrefixes[status] or ""
        table.insert(events, makeParamNameDisplayEvent(prefix .. remote.get_item_name(item.index), item.controller))
      end
    end
  end
  return events
end

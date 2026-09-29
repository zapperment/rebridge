local const = require "src.lppmk3.config.constants"
local ctrl = require "src.lppmk3.config.controls"
local state = require "src.lppmk3.lib.state._"
local patternColours = require "src.lppmk3.config.patternColours"

local count = const.counts.devices * const.counts.patternValues

-- the colour of each pattern, device by device, in the order the surface
-- store keeps them
local function get()
  local colours = {}
  for _, device in ipairs(ctrl.devices) do
    for value = 1, const.counts.patternValues do
      table.insert(colours, state.get(device .. ".colour" .. value))
    end
  end
  return colours
end

-- sets the colour of each pattern from the surface store; a list of the
-- wrong length is ignored
local function set(colours)
  if #colours ~= count then
    return
  end
  local index = 1
  for _, device in ipairs(ctrl.devices) do
    for value = 1, const.counts.patternValues do
      state.set(device .. ".colour" .. value, colours[index])
      index = index + 1
    end
  end
end

-- gives every pattern the colour it starts with
local function reset()
  for _, device in ipairs(ctrl.devices) do
    for value = 1, const.counts.patternValues do
      state.set(device .. ".colour" .. value, patternColours[1])
    end
  end
end

return {
  get = get,
  set = set,
  reset = reset,
}

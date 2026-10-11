local items = require "src.lppmk3.config.items"
local launchnik = require "src.lppmk3.lib.launchnik._"

-- the items of Launchnik by their index, which they only get when the codec
-- is initialised
local itemsByIndex = nil

local function findItem(index)
  if not itemsByIndex then
    itemsByIndex = {}
    for _, item in pairs(items) do
      if item.launchnik then
        itemsByIndex[item.index] = item
      end
    end
  end
  return itemsByIndex[index]
end

-- keeps a copy of what the host reports about Launchnik: the setup state,
-- which launch buttons hold a clip, and the light of every launch button and
-- stop button;
-- while no Launchnik is mapped, its items are disabled and count as a new
-- device, so that the pads go dark
local function setState(hostItems)
  local state = launchnik.state
  for _, hostItemIndex in ipairs(hostItems) do
    local item = findItem(hostItemIndex)
    if item then
      local changedItem = remote.get_item_state(hostItemIndex)
      local value = changedItem.is_enabled and changedItem.value or 0
      local kind = item.launchnik.kind
      if kind == "setup" then
        if value ~= state.setup then
          state.setup = value
          state.setupChanged = true
        end
      elseif kind == "present" then
        state.present[item.launchnik.index] = value > 0
      elseif kind == "stoplight" then
        if value ~= state.stopLights[item.launchnik.track] then
          state.stopLights[item.launchnik.track] = value
          state.changedStopLights[item.launchnik.track] = true
        end
      elseif kind == "light" then
        if value ~= state.lights[item.launchnik.index] then
          state.lights[item.launchnik.index] = value
          state.changedLights[item.launchnik.index] = true
        end
      end
    end
  end
end

return {
  setState = setState,
  -- for tests, which give the items new indices
  forgetItemIndices = function()
    itemsByIndex = nil
  end,
}

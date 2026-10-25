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

-- the settings of the CV outputs the codec keeps, by the kind of their items
local outputSettings = {
  pattern = "patterns",
  unipolar = "unipolar",
  bipolar = "bipolar",
  transition = "transitions",
  fillinpattern = "fillInPatterns",
  fillinunipolar = "fillInUnipolar",
  fillinbipolar = "fillInBipolar",
  fillintransition = "fillInTransitions",
  landingpattern = "landingPatterns",
  landingunipolar = "landingUnipolar",
  landingbipolar = "landingBipolar",
  landingtransition = "landingTransitions",
  intropattern = "introPatterns",
  introunipolar = "introUnipolar",
  introbipolar = "introBipolar",
  introtransition = "introTransitions",
  outropattern = "outroPatterns",
  outrounipolar = "outroUnipolar",
  outrobipolar = "outroBipolar",
  outrotransition = "outroTransitions",
}

-- the colours of the clips, fill-ins, landings, intros and outros, by the
-- kind of their items
local colourSettings = {
  colour = "colours",
  fillincolour = "fillInColours",
  landingcolour = "landingColours",
  introcolour = "introColours",
  outrocolour = "outroColours",
}

-- the switches of the fill-ins, landings, intros and outros: whether there is
-- one and its one-bar pattern, by the kind of their items
local switchSettings = {
  fillinpresent = "fillInPresent",
  landingpresent = "landingPresent",
  intropresent = "introPresent",
  outropresent = "outroPresent",
  fillinonebarpattern = "fillInOneBarPattern",
  landingonebarpattern = "landingOneBarPattern",
  introonebarpattern = "introOneBarPattern",
  outroonebarpattern = "outroOneBarPattern",
}

-- keeps a copy of what the host reports about Launchnik: whether it is mapped,
-- the setup state, the function, which launch buttons hold a clip, a fill-in,
-- a landing, an intro or an outro, the CV modes, the colours, values and
-- transitions of every clip, fill-in, landing, intro and outro, and the light of every launch
-- button, function button and scene button, of the fill-in button and of the
-- forward button;
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
        state.mapped = changedItem.is_enabled
      elseif kind == "function" then
        if value ~= state["function"] then
          state["function"] = value
          state.functionChanged = true
        end
      elseif kind == "present" then
        state.present[item.launchnik.index] = value > 0
      elseif colourSettings[kind] then
        state[colourSettings[kind]][item.launchnik.index] = value
      elseif outputSettings[kind] then
        state[outputSettings[kind]][item.launchnik.index][item.launchnik.output] = value
      elseif kind == "cvmode" then
        state.cvModes[item.launchnik.track][item.launchnik.output] = value
      elseif switchSettings[kind] then
        state[switchSettings[kind]][item.launchnik.index] = value > 0
      elseif kind == "fillinlight" then
        state.fillInLight = value
      elseif kind == "forwardlight" then
        state.forwardLight = value
      elseif kind == "functionlight" then
        if value ~= state.functionLights[item.launchnik.track] then
          state.functionLights[item.launchnik.track] = value
          state.changedFunctionLights[item.launchnik.track] = true
        end
      elseif kind == "scenelight" then
        if value ~= state.sceneLights[item.launchnik.scene] then
          state.sceneLights[item.launchnik.scene] = value
          state.changedSceneLights[item.launchnik.scene] = true
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

local cond = require("src.config.conditionals")
local tbl = require("src.lib.table._")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local str = require("src.lib.string._")
local deb = require("src.lib.debug._")

-- The label for a parameter whose display depends on the setting of another
-- parameter, e.g. SubTractor's LFO1 Rate showing note-length divisions while
-- LFO sync is enabled. Returns nil when nothing is configured for the
-- parameter or the parameter it depends on is off, leaving the caller to fall
-- back to the ordinary labels.
return function(deviceType, param, hostValue)
  local logMe = param == "Delay Time" or param == "Delay Synced Time"
  if logMe then
    deb.log(
      "[lib:display:getConditionalDisplayValue] " ..
      "**param=" .. str.serialise(param) .. "**"
    )
  end
  local conditional = tbl.getValueFromPath(
    deviceType .. "." .. param
  )
  if not conditional then
    return nil, nil
  end
  if conditional.useOtherParamWhenValue then
    if logMe then
      deb.log(
        "[lib:display:getConditionalDisplayValue] " ..
        "conditional has a property “getConditionalDisplayValue” — " ..
        "this is handled elsewhere, returning nil"
      )
    end
    return nil, nil
  end
  local dependsOnValue = state.getHostValue(conditional.dependsOn)
  if dependsOnValue == nil then
    return nil, nil
  end
  if logMe then
    deb.log(
      "[lib:display:getConditionalDisplayValue] " ..
      "dependsOn=" .. conditional.dependsOn
    )
  end
  if type(dependsOnValue) == "boolean" then
    dependsOnValue = dependsOnValue and 127 or 0
  end
  if logMe then
    deb.log(
      "[lib:display:getConditionalDisplayValue] " ..
      "dependsOnValue=" .. str.serialise(dependsOnValue)
    )
  end
  local label, paramNameVariant
  if conditional.labels and dependsOnValue > 0 then
    local bucket = math.floor(hostValue * #conditional.labels / 128) + 1
    label = conditional.labels[bucket]
  end
  if conditional.variations then
    paramNameVariant = conditional.variations[tostring(dependsOnValue)]
  end
  return label, paramNameVariant
end

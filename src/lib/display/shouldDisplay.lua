local condi = require "src.lcxl3.lib.conditional._"
local state = require "src.lib.state._"
local str = require "src.lib.string._"
local deb = require "src.lib.debug._"

-- Whether a control mapped to a parameter should show that parameter's value,
-- or stay blank because another parameter takes its place: while Ripley's Delay
-- Tempo Sync is on, its Delay Time is replaced by its Synced Time, so Delay Time
-- should not display.
--
-- A parameter is replaced as soon as one of its conditionals says so, so it only
-- displays while every conditional it has is happy with the current value of the
-- parameter it depends on. Ripley's Delay Time, for instance, displays only while
-- both Delay Tempo Sync and Dual Delay are off: the first turns it into Synced
-- Time, the second into Delay Time L and Delay Time R.
--
-- Conditionals that say nothing about which parameter to use — the ones that only
-- give labels or colours — never hide anything.
return function(deviceType, param)
  local logMe = false --param == "Delay Time" or param == "Synced Time"
  if not param then
    return true
  end
  for _, conditional in ipairs(condi.getConditionals(deviceType, param)) do
    local useOtherParam = conditional.useOtherParamWhenValue
    -- the host value is a boolean and may well be false, so it cannot be
    -- fetched with an and/or expression
    local dependsOnValue = nil
    if useOtherParam ~= nil then
      dependsOnValue = state.getHostValue(conditional.dependsOn)
    end
    if dependsOnValue ~= nil and dependsOnValue == useOtherParam then
      if logMe then
        deb.log(
          "[lib:display:shouldDisplay] " ..
          "param " .. str.serialise(param) .. " " ..
          "is replaced by another parameter while " ..
          str.serialise(conditional.dependsOn) .. " " ..
          "is " .. str.serialise(useOtherParam) .. "; " ..
          "returning false (should not display)"
        )
      end
      return false
    end
  end
  if logMe then
    deb.log(
      "[lib:display:shouldDisplay] " ..
      "no conditional replaces param " .. str.serialise(param) .. "; " ..
      "returning true (should display)"
    )
  end
  return true
end

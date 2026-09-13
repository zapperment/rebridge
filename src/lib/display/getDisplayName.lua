local combinatorLabels = require "src.config.combinatorLabels"
local displayNames = require "src.config.displayNames"
local state = require "src.lib.state._"
local str = require "src.lib.string._"
local deb = require "src.lib.debug._"

-- The only device whose parameters are named by the patch rather than by the
-- device: every other device reports a name that already says what the parameter
-- does, so there is nothing to look up for it.
local COMBINATOR = "combinator"

-- shortens the name as config/displayNames says for the device type, if at all
local function shorten(deviceType, name)
  for _, shortening in ipairs(displayNames[deviceType] or {}) do
    name = name:gsub(shortening.find, shortening.replace)
  end
  return name
end

-- The name to show on the control surface for the parameter a control is mapped
-- to. For all but a Combinator that is the name Reason reports, which is the
-- name of the parameter itself, shortened as config/displayNames says for the
-- device if the displays would otherwise cut it off.
--
-- A Combinator, though, reports "Rotary 1" ... "Button 16" whichever patch is
-- loaded, and the labels its front panel shows instead are kept in the patch
-- file, out of reach of a remote codec. config/combinatorLabels holds the ones
-- that scripts/extractCombinatorLabels.js has read out of the patch files, keyed
-- by the name Reason reports for the patch.
--
-- The device name is tried as well: a Combinator that Reason reports no patch
-- name for is still likely to carry the name of the patch it was built from.
return function(deviceType, param)
  local logMe = false --param == "Rotary 1"
  if not param then
    return param
  end
  if deviceType ~= COMBINATOR then
    return shorten(deviceType, param)
  end
  local patchName = str.trim(state.get "patchName" or "")
  local deviceName = str.trim(state.get "deviceName" or "")
  local labels = combinatorLabels[patchName] or combinatorLabels[deviceName]
  if not labels then
    if logMe then
      deb.log(
        "[lib:display:getDisplayName] " ..
        "no labels for patch " .. str.serialise(patchName) .. " " ..
        "or device " .. str.serialise(deviceName)
      )
    end
    return param
  end
  local label = labels[param]
  if logMe and label then
    deb.log(
      "[lib:display:getDisplayName] " ..
      "param " .. param .. " is labelled **" .. label .. "**"
    )
  end
  -- a patch only stores the slots it has renamed, so the rest keep the name
  -- Reason reports for them
  return label or param
end

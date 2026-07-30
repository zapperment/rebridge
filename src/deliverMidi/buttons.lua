local state = require("src.lib.state._")
local buttonStates = require("src.lib.state.buttons")
local items = require("src.config.items")
local const = require("src.config.constants")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")
local makeOverlayDisplayEvents = require("src.lib.midi.makeOverlayDisplayEvents")
local getLabel = require("src.lib.valueLabels.getLabel")
local cycleParams = require("src.config.cycleParams")
local debug = require("src.lib.debug._")

-- the host (Reason) reports an on/off button as "0" or "1", which reads poorly
-- on the display
local defaultValueLabels = {
  ["0"] = "Off",
  ["1"] = "On",
}

-- turns the value the host reports into what the display should show, honouring
-- the labels a device defines for buttons that are not simply on/off; a value
-- with no label is shown as the host provides it
local function getValueLabel(paramName, itemState)
  local deviceType = state.get("deviceType")
  local label = getLabel(deviceType, paramName, itemState)
  if label then
    return label
  end
  local textValue = itemState.text_value
  local deviceCycleParams = cycleParams[deviceType]
  if deviceCycleParams and deviceCycleParams[paramName] then
    -- a cycling parameter's values are not on/off, so without labels of its
    -- own it shows the plain value rather than the On/Off defaults
    return textValue
  end
  return defaultValueLabels[textValue] or textValue
end

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, const.counts.buttons do
    local path, enabled
    local enabledChanged = false
    local item = items["button" .. i]

    path = "button" .. i .. ".enabled"
    if state.hasChanged(path) then
      state.update(path)
      enabled = state.get(path)
      enabledChanged = true
      if not enabled then
        -- turn of button's LED
        table.insert(events, makeSysexEvent("01 53 xx 00 00 00", { x = item.controller }))
      end
    else
      enabled = state.get(path)
    end

    if enabled then
      path = "button" .. i .. ".value"
      if enabledChanged or state.hasChanged(path) then
        state.update(path)
        -- no MIDI command sent out for button change
      end
      path = "button" .. i .. ".colour"
      if enabledChanged or state.hasChanged(path) then
        local colour = state.update(path)
        table.insert(events, makeSysexEvent("01 53 xx " .. colour, { x = item.controller }))
      end
    end
  end

  -- The hardware only offers per-control displays for faders and encoders, so a
  -- button's parameter name goes on the shared overlay display. It is shown for
  -- presses on the remote surface only, matching how the hardware brings up the
  -- fader and encoder displays on movement but not on changes made in the host.
  local pressed = buttonStates.pressed
  buttonStates.pressed = nil
  if pressed then
    local paramName = remote.get_item_name(pressed.index)
    for _, event in ipairs(makeOverlayDisplayEvents(
      paramName,
      getValueLabel(paramName, remote.get_item_state(pressed.index))
    )) do
      table.insert(events, event)
    end
  end

  return events
end

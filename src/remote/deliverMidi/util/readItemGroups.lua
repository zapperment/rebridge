local disp = require "src.lib.display._"
local items = require "src.lcxl3.config.items"
local state = require "src.lib.state._"

-- Reads the state of one item of the control surface and reports what a delivery
-- needs to know about it: its values, which of them have changed since the last
-- delivery, and whether it is an item that displays at all. The state has to be
-- updated for every item on every delivery, whether it is the one on show or
-- not, or the changes of the items that are not would pile up until they are
-- (see lib/state/StateManager:update).
local function readItem(control, deviceType, readMore)
  local item = {
    control = control,
    controller = items[control].controller,
    midi = items[control].midi,
    colour = items[control].colour,
  }
  local _, controlSurfaceValueChanged = state.update(control .. ".controlSurfaceValue")
  local enabled = state.update(control .. ".enabled")
  local param, paramChanged = state.update(control .. ".param")
  local hostValue, hostValueChanged = state.update(control .. ".hostValue")
  local _, hostTextValueChanged = state.update(control .. ".hostTextValue")
  item.controlSurfaceValueChanged = controlSurfaceValueChanged
  item.param = param
  item.paramChanged = paramChanged
  item.hostValue = hostValue
  item.hostValueChanged = hostValueChanged
  item.hostTextValueChanged = hostTextValueChanged
  -- an item only displays while nothing has taken the place of the parameter it
  -- is mapped to: Ripley's Delay Time R gives way to Synced Time R as soon as
  -- Delay Tempo Sync comes on (see lib/display/shouldDisplay)
  local displaying = enabled and disp.shouldDisplay(deviceType, param)
  state.set(control .. ".displaying", displaying)
  local _, displayingChanged = state.update(control .. ".displaying")
  item.displaying = displaying
  item.displayingChanged = displayingChanged
  if readMore then
    readMore(item, control)
  end
  return item
end

-- Reads the given items of config/items and groups them by the control on the
-- surface they address: encoder2 and encoder2alt are two mappings of the same
-- encoder, only one of which is on show at a time. Each group reports the item
-- that is on show, if any, and whether an item has taken over or given up that
-- role since the last delivery. While no item is on show, the control belongs to
-- no parameter at all and neither lights up nor displays anything.
--
-- The groups come back in the order of the controls. Deliveries that keep more
-- state per item than the ones every control has can pass readMore, which is
-- called with the item read so far and its name.
return function(controls, deviceType, readMore)
  local groups = {}
  local groupsByController = {}
  for _, control in ipairs(controls) do
    local item = readItem(control, deviceType, readMore)
    local group = groupsByController[item.controller]
    if not group then
      group = { controller = item.controller, displayingChanged = false }
      groupsByController[item.controller] = group
      table.insert(groups, group)
    end
    group.displayingChanged = group.displayingChanged or item.displayingChanged
    if item.displaying and not group.displayedItem then
      group.displayedItem = item
    end
  end
  return groups
end

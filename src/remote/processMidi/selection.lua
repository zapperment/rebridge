local ctrl = require "src.config.controls"
local items = require "src.config.items"
local state = require "src.lib.state._"

-- the surface's reply to the query the delivery sends to get the codec here
-- when the mapping in force has to be switched (see deliverMidi/selection):
-- the surface mode select feature control, which answers on channel 7
local surfaceModeReplyMidi = "b6 1e xx"

local function getOptionSelect(option)
  return option == 0 and items.noOptionSelect or items["optionSelect" .. option]
end

-- Handles the selection of a selecting device.
--
-- The host only lets the codec switch the mapping in force while it handles
-- MIDI from the surface, so any event is taken as the chance to bring the
-- mapping in step with the option the host reports as selected, before the
-- event itself is handled with that mapping.
--
-- Pressing a selection button gives the selector parameter the value of the
-- button's option, or deselects it if it is the selected one; the codec does
-- not switch the mapping itself, but follows the host's report of the new value
-- (see ADR 0002). With Shift held down, the button only shows its display.
return function(event)
  local option = state.takeSelectionSwitch()
  if option then
    remote.handle_input({
      time_stamp = event.time_stamp,
      item = getOptionSelect(option).index,
      value = 1
    })
  end

  if remote.match_midi(surfaceModeReplyMidi, event) then
    return true
  end

  if not state.isSelecting() then
    return false
  end
  for buttonOption, control in ipairs(ctrl.selectionButtons) do
    local match = remote.match_midi(items[control].midi, event)
    if match then
      if match.x > 0 and buttonOption <= state.getOptionCount() then
        if state.isShifted() then
          state.forceDisplay(control)
        else
          remote.handle_input({
            time_stamp = event.time_stamp,
            item = items.selector.index,
            value = state.getSelectorValueFor(buttonOption)
          })
        end
      end
      return true
    end
  end
  return false
end

local items = require "src.config.items"
local state = require "src.lib.state._"
local deb = require "src.lib.debug._"

-- Shift is a feature control and reports on channel 7 rather than channel 1,
-- see "Launch Control XL 3 feature controls" in the programmer's reference
local shiftMidi = "b6 3f xx"

-- The physical page buttons have two functions, disambiguated by Shift: on
-- their own they step through the parameter pages of the target device, with
-- Shift held down they browse its patches (patchUp/DownButton).
local pageButtons = {
  { midi = items.pageUpButton.midi,   step = -1, shifted = "patchUpButton" },
  { midi = items.pageDownButton.midi, step = 1,  shifted = "patchDownButton" },
}

-- handles the Shift and page buttons of the remote surface (Launch Control)
return function(event)
  local processed = false
  local match = remote.match_midi(shiftMidi, event)
  if match then
    state.setShifted(match.x > 0)
    processed = true
  else
    for _, button in ipairs(pageButtons) do
      match = remote.match_midi(button.midi, event)
      if match then
        if match.x > 0 then
          if state.isShifted() then
            remote.handle_input({
              time_stamp = event.time_stamp,
              item = items[button.shifted].index,
              value = 1
            })
          else
            local target = state.selectPage(button.step)
            if target then
              remote.handle_input({
                time_stamp = event.time_stamp,
                item = items["pageSelect" .. target].index,
                value = 1
              })
            end
          end
        end
        processed = true
      end
    end
  end
  return processed
end

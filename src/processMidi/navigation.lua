local items = require("src.config.items")
local shiftState = require("src.lib.state.shift")

-- Shift is a feature control and reports on channel 7 rather than channel 1,
-- see "Launch Control XL 3 feature controls" in the programmer's reference
local shiftMidi = "b6 3f xx"

-- The physical page buttons have two functions, disambiguated by Shift: on
-- their own they select the parameter page of the target device (the remote
-- map binds pageUp/DownButton to the "Pages" group variations per device
-- scope), with Shift held down they browse the patches (patchUp/DownButton).
local pageButtons = {
  { midi = items.pageUpButton.midi, plain = "pageUpButton", shifted = "patchUpButton" },
  { midi = items.pageDownButton.midi, plain = "pageDownButton", shifted = "patchDownButton" },
}

-- handles the Shift and page buttons of the remote surface (Launch Control)
return function(event)
  local match = remote.match_midi(shiftMidi, event)
  if match then
    shiftState.held = match.x > 0
    return true
  end

  for _, button in ipairs(pageButtons) do
    match = remote.match_midi(button.midi, event)
    if match then
      if match.x > 0 then
        local item = items[shiftState.held and button.shifted or button.plain]
        remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = 1 })
      end
      return true
    end
  end

  return false
end

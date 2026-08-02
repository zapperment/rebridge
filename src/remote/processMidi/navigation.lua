local items = require("src.config.items")
local shiftState = require("src.lib.state.shift")
local pages = require("src.lib.state.pages")
local deb = require("src.lib.debug._")

-- Shift is a feature control and reports on channel 7 rather than channel 1,
-- see "Launch Control XL 3 feature controls" in the programmer's reference
local shiftMidi = "b6 3f xx"

-- selects the parameter page by pressing its pageSelect item, which the
-- target device's remote map binds to the page's group variation; does
-- nothing when the device has no pages
local function selectPage(target, timeStamp)
  if pages.count == 0 then
    return
  end
  if target < 1 then
    target = pages.count
  end
  if target > pages.count then
    target = 1
  end
  remote.handle_input({ time_stamp = timeStamp, item = items["pageSelect" .. target].index, value = 1 })
  -- the host reports the switch back via the selectors, but recording it now
  -- keeps rapid successive presses stepping from the right page
  pages.setActive(target)
end

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
    shiftState.held = match.x > 0
    processed = true
  else
    for _, button in ipairs(pageButtons) do
      match = remote.match_midi(button.midi, event)
      if match then
        if match.x > 0 then
          if shiftState.held then
            remote.handle_input({ time_stamp = event.time_stamp, item = items[button.shifted].index, value = 1 })
          else
            selectPage(pages.active + button.step, event.time_stamp)
          end
        end
        processed = true
      end
    end
  end
  return processed
end

-- What the codec knows about the Launchnik device the surface is mapped to.
-- The host owns all of it; the codec keeps copies only to decide what a press
-- means and to deliver the lights.

local buttonCount = 64

local state = {}

-- puts everything back to what a new device has, with nothing to deliver
function state.reset()
  -- 0 = launch mode, 1 = clip picking, 2..65 = clip editing
  state.setup = 0
  state.setupChanged = false
  -- by launch button index, 0..63
  state.present = {}
  state.lights = {}
  state.changedLights = {}
  for index = 0, buttonCount - 1 do
    state.present[index] = false
    state.lights[index] = 0
  end
  -- when the codec last switched the surface to programmer mode
  state.preparedAt = nil
end

state.reset()

return state

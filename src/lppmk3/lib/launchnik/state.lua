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
  -- whether a Launchnik is mapped, which the setup item tells
  state.mapped = false
  -- the colour last delivered to the logo, which is dark to begin with
  state.logoColour = 0
  -- by launch button index, 0..63
  state.present = {}
  state.lights = {}
  state.changedLights = {}
  -- the lights of the stop buttons, by track, 1..8
  state.stopLights = {}
  state.changedStopLights = {}
  -- the lights of the scene buttons, by scene, 1..8 from the top
  state.sceneLights = {}
  state.changedSceneLights = {}
  for track = 1, 8 do
    state.stopLights[track] = 0
  end
  for scene = 1, 8 do
    state.sceneLights[scene] = 0
  end
  for index = 0, buttonCount - 1 do
    state.present[index] = false
    state.lights[index] = 0
  end
  -- when the codec last switched the surface to programmer mode
  state.preparedAt = nil
end

state.reset()

return state

-- What the codec knows about the Launchnik device the surface is mapped to.
-- The host owns all of it; the codec keeps copies only to decide what a press
-- means and to deliver the lights.

local buttonCount = 64

local state = {}

-- puts everything back to what a new device has, with nothing to deliver
function state.reset()
  -- 0 = launch mode, 1 = clip picking, 2..65 = clip editing, 66..129 =
  -- fill-in editing
  state.setup = 0
  state.setupChanged = false
  -- whether a Launchnik is mapped, which the setup item tells
  state.mapped = false
  -- the colour last delivered to the logo, which is dark to begin with
  state.logoColour = 0
  -- the colour last delivered to the back button, which is dark to begin with
  state.backButtonColour = 0
  -- the colours last delivered to the fill-in button and the set fill-in
  -- button, which are dark to begin with
  state.fillInButtonColour = 0
  state.setFillInButtonColour = 0
  -- the lights of the fill-in button and the set fill-in button
  state.fillInLight = 0
  state.setFillInLight = 0
  -- by launch button index, 0..63
  state.present = {}
  state.patterns = {}
  state.fillInPresent = {}
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
    state.patterns[index] = 0
    state.fillInPresent[index] = false
    state.lights[index] = 0
  end
  -- when the codec last switched the surface to programmer mode
  state.preparedAt = nil
end

state.reset()

return state

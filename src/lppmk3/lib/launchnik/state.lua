-- What the codec knows about the Launchnik device the surface is mapped to.
-- The host owns all of it; the codec keeps copies only to decide what a press
-- means and to deliver the lights.

local buttonCount = 64
local outputCount = 6

local state = {}

-- puts everything back to what a new device has, with nothing to deliver
function state.reset()
  -- 0 = launch mode, 1 = clip picking, 2..65 = clip editing, 66..129 =
  -- fill-in editing
  state.setup = 0
  state.setupChanged = false
  -- 0 = stop, 1 = mute, 2 = solo
  state["function"] = 0
  state.functionChanged = false
  -- the colours last delivered to the function select buttons, by their
  -- control change, which are dark to begin with
  state.functionSelectColours = {}
  -- the kind of change, "mute" or "solo", that a function button held down on
  -- the surface has made, by track, so that letting go of it lets go of the
  -- same button of Launchnik
  state.heldFunctionButtons = {}
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
  -- by launch button index, 0..63; the settings of the CV outputs by index
  -- and then by output, 1..6
  state.present = {}
  state.patterns = {}
  state.unipolar = {}
  state.bipolar = {}
  state.transitions = {}
  state.fillInPresent = {}
  state.fillInTransitions = {}
  -- the CV modes by track, 1..8, and then by output: 0 = bipolar, 1 =
  -- unipolar, 2 = pattern
  state.cvModes = {}
  state.lights = {}
  state.changedLights = {}
  -- the lights of the function buttons, by track, 1..8
  state.functionLights = {}
  state.changedFunctionLights = {}
  -- the lights of the scene buttons, by scene, 1..8 from the top
  state.sceneLights = {}
  state.changedSceneLights = {}
  for track = 1, 8 do
    state.functionLights[track] = 0
    state.cvModes[track] = {}
    for output = 1, outputCount do
      state.cvModes[track][output] = output == 1 and 2 or 1
    end
  end
  for scene = 1, 8 do
    state.sceneLights[scene] = 0
  end
  for index = 0, buttonCount - 1 do
    state.present[index] = false
    state.patterns[index] = {}
    state.unipolar[index] = {}
    state.bipolar[index] = {}
    state.transitions[index] = {}
    state.fillInTransitions[index] = {}
    -- a new clip plays the pattern of its row, at unipolar and bipolar 0
    for output = 1, outputCount do
      state.patterns[index][output] = index % 8
      state.unipolar[index][output] = 0
      state.bipolar[index][output] = 3
      state.transitions[index][output] = 0
      state.fillInTransitions[index][output] = 0
    end
    state.fillInPresent[index] = false
    state.lights[index] = 0
  end
  -- when the codec last switched the surface to programmer mode
  state.preparedAt = nil
end

state.reset()

return state

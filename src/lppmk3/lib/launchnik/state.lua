-- What the codec knows about the Launchnik device the surface is mapped to.
-- The host owns all of it; the codec keeps copies only to decide what a press
-- means and to deliver the lights.

local buttonCount = 64
local outputCount = 6

local state = {}

-- puts everything back to what a new device has, with nothing to deliver
function state.reset()
  -- 0 = launch mode, 1 = clip picking, 2..65 = clip editing, 66..129 =
  -- fill-in editing, 130..193 = landing editing, 194..257 = intro editing,
  -- 258..321 = outro editing, 322 = clear mode, 323 = source picking,
  -- 324..387 and 388..395 = destination picking
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
  -- the tracks whose relaunch press a pad or scene button on the surface
  -- holds down, so that letting go of it lets go of the press
  state.heldRelaunches = {}
  -- whether a Launchnik is mapped, which the setup item tells
  state.mapped = false
  -- the colour last delivered to the logo, which is dark to begin with
  state.logoColour = 0
  -- the colours last delivered to the back button, the clear button and the
  -- duplicate button, which are dark to begin with
  state.backButtonColour = 0
  state.clearButtonColour = 0
  state.duplicateButtonColour = 0
  -- the colours last delivered to the fill-in button and the forward button,
  -- which are dark to begin with
  state.fillInButtonColour = 0
  state.forwardButtonColour = 0
  -- the lights of the fill-in button and the forward button
  state.fillInLight = 0
  state.forwardLight = 0
  -- by launch button index, 0..63; the settings of the CV outputs by index
  -- and then by output, 1..6
  state.present = {}
  state.colours = {}
  state.patterns = {}
  state.unipolar = {}
  state.bipolar = {}
  state.transitions = {}
  state.fillInPresent = {}
  state.fillInColours = {}
  state.fillInPatterns = {}
  state.fillInUnipolar = {}
  state.fillInBipolar = {}
  state.fillInTransitions = {}
  state.landingPresent = {}
  state.landingColours = {}
  state.landingPatterns = {}
  state.landingUnipolar = {}
  state.landingBipolar = {}
  state.landingTransitions = {}
  state.landingOneBarPattern = {}
  state.fillInOneBarPattern = {}
  for _, overlay in ipairs({ "intro", "outro" }) do
    state[overlay .. "Present"] = {}
    state[overlay .. "Colours"] = {}
    state[overlay .. "Patterns"] = {}
    state[overlay .. "Unipolar"] = {}
    state[overlay .. "Bipolar"] = {}
    state[overlay .. "Transitions"] = {}
    state[overlay .. "OneBarPattern"] = {}
  end
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
    state.fillInPatterns[index] = {}
    state.fillInUnipolar[index] = {}
    state.fillInBipolar[index] = {}
    state.fillInTransitions[index] = {}
    state.landingPatterns[index] = {}
    state.landingUnipolar[index] = {}
    state.landingBipolar[index] = {}
    state.landingTransitions[index] = {}
    for _, overlay in ipairs({ "intro", "outro" }) do
      state[overlay .. "Patterns"][index] = {}
      state[overlay .. "Unipolar"][index] = {}
      state[overlay .. "Bipolar"][index] = {}
      state[overlay .. "Transitions"][index] = {}
      state[overlay .. "Colours"][index] = 0
      state[overlay .. "Present"][index] = false
      state[overlay .. "OneBarPattern"][index] = false
      for output = 1, outputCount do
        state[overlay .. "Patterns"][index][output] = index % 8
        state[overlay .. "Unipolar"][index][output] = 0
        state[overlay .. "Bipolar"][index][output] = 3
        state[overlay .. "Transitions"][index][output] = 0
      end
    end
    -- a new clip plays the pattern of its row, at unipolar and bipolar 0, in
    -- the colour of its track; a new device's fill-ins, landings, intros and
    -- outros are the same, in white
    local trackColours = { 1, 2, 3, 5, 7, 9, 11, 13 }
    state.colours[index] = trackColours[math.floor(index / 8) + 1]
    state.fillInColours[index] = 0
    state.landingColours[index] = 0
    for output = 1, outputCount do
      state.patterns[index][output] = index % 8
      state.unipolar[index][output] = 0
      state.bipolar[index][output] = 3
      state.transitions[index][output] = 0
      state.fillInPatterns[index][output] = index % 8
      state.fillInUnipolar[index][output] = 0
      state.fillInBipolar[index][output] = 3
      state.fillInTransitions[index][output] = 0
      state.landingPatterns[index][output] = index % 8
      state.landingUnipolar[index][output] = 0
      state.landingBipolar[index][output] = 3
      state.landingTransitions[index][output] = 0
    end
    state.fillInPresent[index] = false
    state.landingPresent[index] = false
    state.landingOneBarPattern[index] = false
    state.fillInOneBarPattern[index] = false
    state.lights[index] = 0
  end
  -- when the codec last switched the surface to programmer mode
  state.preparedAt = nil
end

-- everything a launch button holds, as press.copyButton takes it
function state.button(index)
  return {
    clip = {
      present = state.present[index], colour = state.colours[index], patterns = state.patterns[index],
      unipolar = state.unipolar[index], bipolar = state.bipolar[index], transitions = state.transitions[index],
    },
    fillIn = {
      present = state.fillInPresent[index], colour = state.fillInColours[index], patterns = state.fillInPatterns[index],
      unipolar = state.fillInUnipolar[index], bipolar = state.fillInBipolar[index], transitions = state.fillInTransitions[index],
      oneBarPattern = state.fillInOneBarPattern[index],
    },
    landing = {
      present = state.landingPresent[index], colour = state.landingColours[index], patterns = state.landingPatterns[index],
      unipolar = state.landingUnipolar[index], bipolar = state.landingBipolar[index], transitions = state.landingTransitions[index],
      oneBarPattern = state.landingOneBarPattern[index],
    },
    intro = {
      present = state.introPresent[index], colour = state.introColours[index], patterns = state.introPatterns[index],
      unipolar = state.introUnipolar[index], bipolar = state.introBipolar[index], transitions = state.introTransitions[index],
      oneBarPattern = state.introOneBarPattern[index],
    },
    outro = {
      present = state.outroPresent[index], colour = state.outroColours[index], patterns = state.outroPatterns[index],
      unipolar = state.outroUnipolar[index], bipolar = state.outroBipolar[index], transitions = state.outroTransitions[index],
      oneBarPattern = state.outroOneBarPattern[index],
    },
  }
end

state.reset()

return state

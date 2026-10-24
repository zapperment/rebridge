local const = require "src.lppmk3.config.constants"
local midi = require "src.lppmk3.lib.midi._"
local col = require "src.lppmk3.lib.colour._"
local launchnik = require "src.lppmk3.lib.launchnik._"

-- the Novation logo at the top right shows Launchnik's mode colour, as the
-- Launchnik logo does on the panel, since the Setup button has no light the
-- codec could use; it is dark while no Launchnik is mapped
local logo = 99

local function logoColour(state)
  if not state.mapped then
    return col.config.off
  end
  if state.setup == launchnik.press.setupLaunchMode then
    return col.config.white.bright
  end
  if state.setup == launchnik.press.setupClipPicking then
    return col.config.green.vibrant
  end
  if state.setup == launchnik.press.setupClearMode then
    return col.config.red.vibrant
  end
  if launchnik.press.isDuplicateMode(state.setup) then
    return col.config.fuchsia.vibrant
  end
  if launchnik.press.isFillInEditing(state.setup) then
    return col.config.orange.vibrant
  end
  if launchnik.press.isLandingEditing(state.setup) then
    return col.config.blue.vibrant
  end
  return col.config.yellow.vibrant
end

-- the back button, with the arrow pointing left beside Shift, shows the light
-- of Launchnik's back button, which only depends on the setup state: dark in
-- launch mode, vibrant white in clip picking, clear mode and duplicate mode,
-- vibrant green in
-- clip editing, vibrant yellow in fill-in editing, vibrant orange in landing
-- editing; it is dark while no Launchnik is mapped
local backButton = 91

local function backButtonColour(state)
  if not state.mapped or state.setup == launchnik.press.setupLaunchMode then
    return col.config.off
  end
  if state.setup == launchnik.press.setupClipPicking or state.setup == launchnik.press.setupClearMode or launchnik.press.isDuplicateMode(state.setup) then
    return col.config.white.bright
  end
  if launchnik.press.isFillInEditing(state.setup) then
    return col.config.yellow.vibrant
  end
  if launchnik.press.isLandingEditing(state.setup) then
    return col.config.orange.vibrant
  end
  return col.config.green.vibrant
end

-- the button to the left of the third row of pads shows the light of
-- Launchnik's clear button, which only depends on the setup state: dim white
-- in launch mode, vibrant red in clear mode, dark in setup mode and duplicate
-- mode, where it does nothing; it is dark while no Launchnik is mapped
local clearButton = 60

local function clearButtonColour(state)
  if not state.mapped then
    return col.config.off
  end
  if state.setup == launchnik.press.setupLaunchMode then
    return col.config.white.dim
  end
  if state.setup == launchnik.press.setupClearMode then
    return col.config.red.vibrant
  end
  return col.config.off
end

-- the button to the left of the fourth row of pads shows the light of
-- Launchnik's duplicate button, which only depends on the setup state: dim
-- white in launch mode, vibrant fuchsia in duplicate mode, dark in setup mode
-- and clear mode, where it does nothing; it is dark while no Launchnik is
-- mapped
local duplicateButton = 50

local function duplicateButtonColour(state)
  if not state.mapped then
    return col.config.off
  end
  if state.setup == launchnik.press.setupLaunchMode then
    return col.config.white.dim
  end
  if launchnik.press.isDuplicateMode(state.setup) then
    return col.config.fuchsia.vibrant
  end
  return col.config.off
end

-- the button to the left of the sixth row of pads shows the light of
-- Launchnik's fill-in button, the button above the second column of pads that
-- of its forward button
local fillInButton = 30
local forwardButton = 92

-- Launchnik's colours in its order, each with the palette entries for dim and
-- vibrant; white has no entry called vibrant
local palette = {
  { dim = col.config.white.dim, vibrant = col.config.white.bright },
  col.config.red, col.config.orange, col.config.yellow, col.config.lime,
  col.config.green, col.config.turquoise, col.config.cyan,
  col.config.lightBlue, col.config.blue, col.config.darkBlue,
  col.config.purple, col.config.fuchsia, col.config.pink,
}

-- the function buttons send and take control changes 101 to 108
local firstFunctionButton = 101

-- the function select buttons, in the row below, take control changes 2
-- (mute), 3 (solo) and 8 (stop)
local functionSelectButtons = {
  [2] = launchnik.press.functionMute,
  [3] = launchnik.press.functionSolo,
  [8] = launchnik.press.functionStop,
}

-- the colour of each function: red for stop, yellow for mute, blue for solo
local functionColours = {
  [launchnik.press.functionStop] = col.config.red,
  [launchnik.press.functionMute] = col.config.yellow,
  [launchnik.press.functionSolo] = col.config.blue,
}

-- the scene buttons, to the right of the grid, send and take the control
-- change that continues the numbering of the pads in their row: 89 at the top
-- to 19 at the bottom
local function sceneButton(scene)
  return (9 - scene) * 10 + 9
end

local dim, vibrant = 0, 1

-- the events that make a pad or button show a colour dim, vibrant or
-- flashing; a flashing one alternates between its static colour and the
-- colour sent on the flashing channel, at the surface's own tempo
local function colourEvents(control, colour, brightness)
  if brightness == dim then
    return { midi.makeColourEvent(control, colour.dim) }
  end
  if brightness == vibrant then
    return { midi.makeColourEvent(control, colour.vibrant) }
  end
  return {
    midi.makeColourEvent(control, colour.dim),
    midi.makeColourEvent(control, colour.vibrant, const.colourBehaviour.flashing),
  }
end

-- a launch button's light is 0 for unlit, then dim, vibrant and flashing for
-- each colour
local function isVibrant(light)
  return light > 0 and (light - 1) % 3 == vibrant
end

-- pulses says that a vibrant light is to pulse instead of standing still
local function lightEvents(pad, light, pulses)
  if light == 0 then
    return { midi.makeColourEvent(pad, col.config.off) }
  end
  local colour = palette[math.floor((light - 1) / 3) + 1]
  if pulses and isVibrant(light) then
    return { midi.makeColourEvent(pad, colour.vibrant, const.colourBehaviour.pulsing) }
  end
  return colourEvents(pad, colour, (light - 1) % 3)
end

-- a function button's light is 0 for unlit, then dim, vibrant and flashing,
-- in the colour of the function
local function functionLightEvents(button, light, func)
  if light == 0 then
    return { midi.makeColourEvent(button, col.config.off) }
  end
  return colourEvents(button, functionColours[func] or col.config.red, light - 1)
end

-- a function select button is vibrant in the colour of its function while
-- that function is chosen, dim white otherwise, and dark while no Launchnik is
-- mapped
local function functionSelectColour(state, func)
  if not state.mapped then
    return col.config.off
  end
  if func == state["function"] then
    return functionColours[func].vibrant
  end
  return col.config.white.dim
end

-- the static colour a light of the fill-in button or the forward button
-- stands for; neither of them flashes
local function lightColour(light)
  if light == 0 then
    return col.config.off
  end
  local colour = palette[math.floor((light - 1) / 3) + 1]
  return isVibrant(light) and colour.vibrant or colour.dim
end

-- called regularly by the codec to make the pads show the lights of the launch
-- buttons in their place, the function buttons and the function select
-- buttons the lights of Launchnik's buttons of the same names,
-- the scene buttons the lights of the scene buttons, the logo the mode colour,
-- and the back button, the clear button, the duplicate button, the forward
-- button and the fill-in button the lights of Launchnik's buttons of the same
-- names; each change is
-- delivered once
--
-- In launch mode a vibrant launch button is one whose clip is playing, and its
-- pad pulses, which the panel of Launchnik does not do. In setup mode vibrant
-- marks a chosen setting and stands still, so a pad whose light is vibrant in
-- both is delivered again when the mode changes.
return function()
  local state = launchnik.state
  local events = {}
  local inLaunchMode = state.setup == launchnik.press.setupLaunchMode

  for index = 0, 63 do
    if state.changedLights[index] or (state.setupChanged and isVibrant(state.lights[index])) then
      local track = math.floor(index / 8) + 1
      local row = index % 8 + 1
      -- the pads are numbered 11 at the bottom left to 88 at the top right
      local pad = (9 - row) * 10 + track
      for _, event in ipairs(lightEvents(pad, state.lights[index], inLaunchMode)) do
        table.insert(events, event)
      end
    end
  end
  state.changedLights = {}

  -- a change of function changes the colour of every function button
  for track = 1, 8 do
    if state.changedFunctionLights[track] or state.functionChanged then
      for _, event in ipairs(functionLightEvents(firstFunctionButton + track - 1, state.functionLights[track], state["function"])) do
        table.insert(events, event)
      end
    end
  end
  state.changedFunctionLights = {}
  state.functionChanged = false

  for button = 1, 8 do
    local func = functionSelectButtons[button]
    if func then
      local colour = functionSelectColour(state, func)
      if colour ~= (state.functionSelectColours[button] or col.config.off) then
        state.functionSelectColours[button] = colour
        table.insert(events, midi.makeColourEvent(button, colour))
      end
    end
  end

  for scene = 1, 8 do
    if state.changedSceneLights[scene] then
      for _, event in ipairs(lightEvents(sceneButton(scene), state.sceneLights[scene])) do
        table.insert(events, event)
      end
    end
  end
  state.changedSceneLights = {}

  state.setupChanged = false

  local colour = logoColour(state)
  if colour ~= state.logoColour then
    state.logoColour = colour
    table.insert(events, midi.makeColourEvent(logo, colour))
  end

  colour = backButtonColour(state)
  if colour ~= state.backButtonColour then
    state.backButtonColour = colour
    table.insert(events, midi.makeColourEvent(backButton, colour))
  end

  colour = clearButtonColour(state)
  if colour ~= state.clearButtonColour then
    state.clearButtonColour = colour
    table.insert(events, midi.makeColourEvent(clearButton, colour))
  end

  colour = duplicateButtonColour(state)
  if colour ~= state.duplicateButtonColour then
    state.duplicateButtonColour = colour
    table.insert(events, midi.makeColourEvent(duplicateButton, colour))
  end

  colour = state.mapped and lightColour(state.fillInLight) or col.config.off
  if colour ~= state.fillInButtonColour then
    state.fillInButtonColour = colour
    table.insert(events, midi.makeColourEvent(fillInButton, colour))
  end

  colour = state.mapped and lightColour(state.forwardLight) or col.config.off
  if colour ~= state.forwardButtonColour then
    state.forwardButtonColour = colour
    table.insert(events, midi.makeColourEvent(forwardButton, colour))
  end

  return events
end

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
  return col.config.yellow.vibrant
end

-- the back button, with the arrow pointing left beside Shift, shows the light
-- of Launchnik's back button, which only depends on the setup state: dark in
-- launch mode, vibrant white in clip picking, vibrant green in clip editing;
-- it is dark while no Launchnik is mapped
local backButton = 91

local function backButtonColour(state)
  if not state.mapped or state.setup == launchnik.press.setupLaunchMode then
    return col.config.off
  end
  if state.setup == launchnik.press.setupClipPicking then
    return col.config.white.bright
  end
  return col.config.green.vibrant
end

-- Launchnik's colours in its order, each with the palette entries for dim and
-- vibrant; white has no entry called vibrant
local palette = {
  { dim = col.config.white.dim, vibrant = col.config.white.bright },
  col.config.red, col.config.orange, col.config.yellow, col.config.lime,
  col.config.green, col.config.turquoise, col.config.cyan,
  col.config.lightBlue, col.config.blue, col.config.darkBlue,
  col.config.purple, col.config.fuchsia, col.config.pink,
}

-- the track buttons send and take control changes 101 to 108
local firstTrackButton = 101

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

-- a stop button's light is 0 for unlit, then dim, vibrant and flashing, in red
local function stopLightEvents(button, light)
  if light == 0 then
    return { midi.makeColourEvent(button, col.config.off) }
  end
  return colourEvents(button, col.config.red, light - 1)
end

-- called regularly by the codec to make the pads show the lights of the launch
-- buttons in their place, the track buttons the lights of the stop buttons,
-- the scene buttons the lights of the scene buttons, the logo the mode colour
-- and the back button the light of Launchnik's back button; each change is
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

  for track = 1, 8 do
    if state.changedStopLights[track] then
      for _, event in ipairs(stopLightEvents(firstTrackButton + track - 1, state.stopLights[track])) do
        table.insert(events, event)
      end
    end
  end
  state.changedStopLights = {}

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

  return events
end

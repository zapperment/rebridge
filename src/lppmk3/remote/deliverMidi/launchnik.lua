local const = require "src.lppmk3.config.constants"
local midi = require "src.lppmk3.lib.midi._"
local col = require "src.lppmk3.lib.colour._"
local launchnik = require "src.lppmk3.lib.launchnik._"

-- the Novation logo at the top right shows that setup mode is on, since the
-- Setup button has no light the codec could use
local logo = 99

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
local function lightEvents(pad, light)
  if light == 0 then
    return { midi.makeColourEvent(pad, col.config.off) }
  end
  return colourEvents(pad, palette[math.floor((light - 1) / 3) + 1], (light - 1) % 3)
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
-- and the logo the setup mode; each change is delivered once
return function()
  local state = launchnik.state
  local events = {}

  for index = 0, 63 do
    if state.changedLights[index] then
      local track = math.floor(index / 8) + 1
      local row = index % 8 + 1
      -- the pads are numbered 11 at the bottom left to 88 at the top right
      local pad = (9 - row) * 10 + track
      for _, event in ipairs(lightEvents(pad, state.lights[index])) do
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

  if state.setupChanged then
    state.setupChanged = false
    local inSetupMode = state.setup ~= launchnik.press.setupLaunchMode
    table.insert(events, midi.makeColourEvent(logo, inSetupMode and col.config.green.vibrant or col.config.off))
  end

  return events
end

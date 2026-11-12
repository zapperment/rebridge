local const = require "src.lppcommon.config.constants"
local col = require "src.lppcommon.lib.colour._"
local launchnik = require "src.lppcommon.lib.launchnik._"
local shift = require "src.lppcommon.lib.state._"


-- the logo (the Novation logo of the Launchpad Pro [MK3], the LED on the
-- front edge of the Launchpad Pro) shows Launchnik's mode colour, as
-- the Launchnik logo does on the panel; it is dark while no Launchnik is
-- mapped
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
  if launchnik.press.isIntroEditing(state.setup) then
    return col.config.pink.vibrant
  end
  if launchnik.press.isOutroEditing(state.setup) then
    return col.config.turquoise.vibrant
  end
  return col.config.yellow.vibrant
end

-- the back button shows the light of Launchnik's back button, which only depends on the setup state: dark in
-- launch mode, vibrant white in clip picking, clear mode and duplicate mode,
-- vibrant green in
-- clip editing, vibrant yellow in fill-in editing, vibrant orange in landing
-- editing, vibrant blue in intro editing, vibrant pink in outro editing; it is
-- dark while no Launchnik is mapped

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
  if launchnik.press.isIntroEditing(state.setup) then
    return col.config.blue.vibrant
  end
  if launchnik.press.isOutroEditing(state.setup) then
    return col.config.pink.vibrant
  end
  return col.config.green.vibrant
end

-- the clear button shows the light of Launchnik's clear button, which only depends on the setup state: dim white
-- in launch mode, vibrant red in clear mode, dark in setup mode and duplicate
-- mode, where it does nothing; it is dark while no Launchnik is mapped

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

-- the duplicate button shows the light of Launchnik's duplicate button, which only depends on the setup state: dim
-- white in launch mode, vibrant fuchsia in duplicate mode, dark in setup mode
-- and clear mode, where it does nothing; it is dark while no Launchnik is
-- mapped

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


-- Launchnik's colours in its order, each with the palette entries for dim and
-- vibrant; white has no entry called vibrant
local palette = {
  { dim = col.config.white.dim, vibrant = col.config.white.bright },
  col.config.red, col.config.orange, col.config.yellow, col.config.lime,
  col.config.green, col.config.turquoise, col.config.cyan,
  col.config.lightBlue, col.config.blue, col.config.darkBlue,
  col.config.purple, col.config.fuchsia, col.config.pink,
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

-- a launch button's light is 0 for unlit, then dim, vibrant and flashing for
-- each colour
local function isVibrant(light)
  return light > 0 and (light - 1) % 3 == vibrant
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

-- makes what the codec calls regularly to make the pads of the device given
-- (see src/lppmk3/device.lua) show the lights of the launch buttons in their
-- place, the function buttons and the function select buttons the lights of
-- Launchnik's buttons of the same names, the scene buttons the lights of the
-- scene buttons, the logo the mode colour, and the back button, the clear
-- button, the duplicate button, the forward button and the fill-in button the
-- lights of Launchnik's buttons of the same names; each change is delivered
-- once
--
-- In launch mode a vibrant launch button is one whose clip is playing, and its
-- pad pulses, which the panel of Launchnik does not do. In setup mode vibrant
-- marks a chosen setting and stands still, so a pad whose light is vibrant in
-- both is delivered again when the mode changes.
--
-- Where the function select buttons are the function buttons with Shift held,
-- the row shows the function select buttons while Shift is held, the other
-- buttons of the row dark, and the function buttons otherwise; each time Shift
-- is pressed or let go, the whole row is delivered again.
return function(device)
  local controls = device.controls
  local makeColourEvent = device.midi.makeColourEvent
  local firstFunctionButton = controls.firstFunctionButton
  local functionSelectButtons = controls.functionSelectButtons

  -- the control changes of the function select buttons, in order
  local functionSelectControls = {}
  for button in pairs(functionSelectButtons) do
    table.insert(functionSelectControls, button)
  end
  table.sort(functionSelectControls)

  -- the events that make a pad or button show a colour dim, vibrant or
  -- flashing; a flashing one alternates between its static colour and the
  -- flashing colour, at the surface's own tempo
  local function colourEvents(control, colour, brightness)
    if brightness == dim then
      return { makeColourEvent(control, colour.dim) }
    end
    if brightness == vibrant then
      return { makeColourEvent(control, colour.vibrant) }
    end
    return {
      makeColourEvent(control, colour.dim),
      makeColourEvent(control, colour.vibrant, const.colourBehaviour.flashing),
    }
  end

  -- pulses says that a vibrant light is to pulse instead of standing still
  local function lightEvents(pad, light, pulses)
    if light == 0 then
      return { makeColourEvent(pad, col.config.off) }
    end
    local colour = palette[math.floor((light - 1) / 3) + 1]
    if pulses and isVibrant(light) then
      return { makeColourEvent(pad, colour.vibrant, const.colourBehaviour.pulsing) }
    end
    return colourEvents(pad, colour, (light - 1) % 3)
  end

  -- a function button's light is 0 for unlit, then dim, vibrant and flashing,
  -- in the colour of the function
  local function functionLightEvents(button, light, func)
    if light == 0 then
      return { makeColourEvent(button, col.config.off) }
    end
    return colourEvents(button, functionColours[func] or col.config.red, light - 1)
  end

  local function append(events, more)
    for _, event in ipairs(more) do
      table.insert(events, event)
    end
  end

  -- delivers the colour of a button, unless it already shows it
  local function deliverColour(events, button, colour, delivered)
    if colour ~= delivered then
      table.insert(events, makeColourEvent(button, colour))
    end
    return colour
  end

  -- the function buttons; a change of function changes the colour of every
  -- one of them
  local function deliverFunctionButtons(events, state, all)
    for track = 1, 8 do
      if all or state.changedFunctionLights[track] or state.functionChanged then
        append(events, functionLightEvents(firstFunctionButton + track - 1, state.functionLights[track], state["function"]))
      end
    end
    state.changedFunctionLights = {}
    state.functionChanged = false
  end

  -- the function select buttons of their own
  local function deliverFunctionSelectButtons(events, state)
    for _, button in ipairs(functionSelectControls) do
      state.functionSelectColours[button] = deliverColour(events, button,
        functionSelectColour(state, functionSelectButtons[button]), state.functionSelectColours[button] or col.config.off)
    end
  end

  -- the row of function buttons, which shows the function select buttons
  -- while Shift is held
  local function deliverSharedRow(events, state)
    local shown = shift.isShifted() == true
    local all = shown ~= state.functionSelectShown
    state.functionSelectShown = shown
    if not shown then
      deliverFunctionButtons(events, state, all)
      return
    end
    for button = firstFunctionButton, firstFunctionButton + 7 do
      local func = functionSelectButtons[button]
      local colour = func and functionSelectColour(state, func) or col.config.off
      if all or colour ~= state.functionSelectColours[button] then
        table.insert(events, makeColourEvent(button, colour))
      end
      state.functionSelectColours[button] = colour
    end
  end

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
        append(events, lightEvents(pad, state.lights[index], inLaunchMode))
      end
    end
    state.changedLights = {}

    if controls.functionSelectWithShift then
      deliverSharedRow(events, state)
    else
      deliverFunctionButtons(events, state, false)
      deliverFunctionSelectButtons(events, state)
    end

    for scene = 1, 8 do
      if state.changedSceneLights[scene] then
        append(events, lightEvents(sceneButton(scene), state.sceneLights[scene]))
      end
    end
    state.changedSceneLights = {}

    state.setupChanged = false

    state.logoColour = deliverColour(events, controls.logo, logoColour(state), state.logoColour)
    state.backButtonColour = deliverColour(events, controls.back, backButtonColour(state), state.backButtonColour)
    state.clearButtonColour = deliverColour(events, controls.clear, clearButtonColour(state), state.clearButtonColour)
    state.duplicateButtonColour = deliverColour(events, controls.duplicate, duplicateButtonColour(state), state.duplicateButtonColour)
    state.fillInButtonColour = deliverColour(events, controls.fillIn,
      state.mapped and lightColour(state.fillInLight) or col.config.off, state.fillInButtonColour)
    state.forwardButtonColour = deliverColour(events, controls.forward,
      state.mapped and lightColour(state.forwardLight) or col.config.off, state.forwardButtonColour)

    return events
  end
end

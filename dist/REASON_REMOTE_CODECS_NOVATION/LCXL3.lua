-- Bundled by luabundle {"version":"1.7.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("__root", function(require, _LOADED, __bundle_register, __bundle_modules)
local items = require("src.config.items")
local processFaders = require("src.processMidi.faders")
local processEncoders = require("src.processMidi.encoders")
local setFaders = require("src.setState.faders")
local setEncoders = require("src.setState.encoders")
local deliverFaders = require("src.deliverMidi.faders")
local deliverEncoders = require("src.deliverMidi.encoders")

function remote_init()
  local itemsToDefine = {}
  for name, item in pairs(items) do
    table.insert(itemsToDefine, {
      name = name,
      input = item.input,
      output = item.output,
      min = item.min,
      max = item.max,
    })
    item.index = #itemsToDefine
    item.lastInputTime = 0
    item.updateValue = false
    item.updateColour = false
  end
  remote.define_items(itemsToDefine)
end

-- Launch Control -> Remote
function remote_process_midi(event)
  return processFaders(event) or processEncoders(event)
end

-- Reason -> Remote
function remote_set_state(changedItems)
  setEncoders(changedItems)
  setFaders(changedItems)
end

-- Remote -> Launch Control
function remote_deliver_midi()
  local events = {}

  for _, event in ipairs(deliverEncoders()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverFaders()) do
    table.insert(events, event)
  end

  return events
end

function remote_prepare_for_use()
  return {
    -- turn on DAW mode
    remote.make_midi("f0 00 20 29 02 15 02 7f f7"),
    remote.make_midi("b6 45 00"),
    remote.make_midi("b6 48 00"),
    remote.make_midi("b6 49 00"),
  }
end

function remote_release_from_use()
  return {
    -- turn off DAW mode
    remote.make_midi("F0 00 20 29 02 15 02 00 F7"),
  }
end

end)
__bundle_register("src.deliverMidi.encoders", function(require, _LOADED, __bundle_register, __bundle_modules)
local stateUtils = require("src.lib.state.utils")
local items = require("src.config.items")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, 24 do
    local path, enabled, changed
    local item = items["encoder" .. i]

    path = "encoder" .. i .. ".enabled"
    if stateUtils.hasChanged(path) then
      stateUtils.update(path)
      enabled = stateUtils.get(path)
      changed = true
      if not enabled then
        -- turn of encoder's LED
        table.insert(events, remote.make_midi("f0 00 20 29 02 15 01 53 xx 00 00 00 f7", { x = item.controller }))
      end
    else
      enabled = stateUtils.get(path)
    end

    if enabled then
      path = "encoder" .. i .. ".value"
      if changed or stateUtils.hasChanged(path) then
        stateUtils.update(path)
        local value = stateUtils.get(path)
        table.insert(events, remote.make_midi(item.midi, { x = value }))
      end
      path = "encoder" .. i .. ".colour"
      if changed or stateUtils.hasChanged(path) then
        stateUtils.update(path)
        local colour = stateUtils.get(path)
        table.insert(events, remote.make_midi("f0 00 20 29 02 15 01 53 xx " .. colour .. " f7", { x = item.controller }))
      end
    end
  end
  return events
end

end)
__bundle_register("src.config.items", function(require, _LOADED, __bundle_register, __bundle_modules)
return {
  encoder1 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 0d xx", controller = 13, colour = "fhyd" },
  encoder2 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 0e xx", controller = 14, colour = "tang" },
  encoder3 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 0f xx", controller = 15, colour = "suns" },
  encoder4 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 10 xx", controller = 16, colour = "fore" },
  encoder5 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 11 xx", controller = 17, colour = "aqua" },
  encoder6 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 12 xx", controller = 18, colour = "coco" },
  encoder7 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 13 xx", controller = 19, colour = "plum" },
  encoder8 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 14 xx", controller = 20, colour = "flam" },
  encoder9 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 15 xx", controller = 21, colour = "fhyd" },
  encoder10 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 16 xx", controller = 22, colour = "tang" },
  encoder11 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 17 xx", controller = 23, colour = "suns" },
  encoder12 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 18 xx", controller = 24, colour = "fore" },
  encoder13 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 19 xx", controller = 25, colour = "aqua" },
  encoder14 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 1a xx", controller = 26, colour = "coco" },
  encoder15 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 1b xx", controller = 27, colour = "plum" },
  encoder16 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 1c xx", controller = 28, colour = "flam" },
  encoder17 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 1d xx", controller = 29, colour = "fhyd" },
  encoder18 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 1e xx", controller = 30, colour = "tang" },
  encoder19 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 1f xx", controller = 31, colour = "suns" },
  encoder20 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 20 xx", controller = 32, colour = "fore" },
  encoder21 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 21 xx", controller = 33, colour = "aqua" },
  encoder22 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 22 xx", controller = 34, colour = "coco" },
  encoder23 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 23 xx", controller = 35, colour = "plum" },
  encoder24 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 24 xx", controller = 36, colour = "flam" },
  fader1 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 05 xx", controller = 5 },
  fader2 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 06 xx", controller = 6 },
  fader3 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 07 xx", controller = 7 },
  fader4 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 08 xx", controller = 8 },
  fader5 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 09 xx", controller = 9 },
  fader6 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 0a xx", controller = 10 },
  fader7 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 0b xx", controller = 11 },
  fader8 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 0c xx", controller = 12 },
}

end)
__bundle_register("src.lib.state.utils", function(require, _LOADED, __bundle_register, __bundle_modules)
local StateManager = require("src.lib.state.StateManager")

local stateManager = StateManager:new()

return {
  hasChanged = function(path)
    return stateManager:hasChanged(path)
  end,
  update = function(path)
    return stateManager:update(path)
  end,
  updateAll = function()
    stateManager:updateAll()
  end,
  get = function(path)
    return stateManager:get(path)
  end,
  getNext = function(path)
    return stateManager:getNext(path)
  end,
  set = function(path, next)
    stateManager:set(path, next)
  end,
  add = function(path, delta, min, max)
    stateManager:add(path, delta, min, max)
  end,
  flip = function(path)
    return stateManager:flip(path)
  end,
  inc = function(path)
    stateManager:inc(path)
  end,
  dec = function(path)
    stateManager:dec(path)
  end
}

end)
__bundle_register("src.lib.state.StateManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local constants = require("src.config.constants")
local getValueFromPath = require("src.lib.table.getValueFromPath")

local StateManager = {}

function StateManager:new()
    local instance = {
        fader1 = {
            current = constants.fader.unassigned,
            next = constants.fader.unassigned
        },
        fader2 = {
            current = constants.fader.unassigned,
            next = constants.fader.unassigned
        },
        fader3 = {
            current = constants.fader.unassigned,
            next = constants.fader.unassigned
        },
        fader4 = {
            current = constants.fader.unassigned,
            next = constants.fader.unassigned
        },
        fader5 = {
            current = constants.fader.unassigned,
            next = constants.fader.unassigned
        },
        fader6 = {
            current = constants.fader.unassigned,
            next = constants.fader.unassigned
        },
        fader7 = {
            current = constants.fader.unassigned,
            next = constants.fader.unassigned
        },
        fader8 = {
            current = constants.fader.unassigned,
            next = constants.fader.unassigned
        },
        encoder1 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder2 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder3 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder4 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder5 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder6 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder7 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder8 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder9 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder10 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder11 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder12 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder13 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder14 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder15 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder16 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder17 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder18 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder19 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder20 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder21 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder22 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder23 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
        encoder24 = {
            value = {
                current = 0,
                next = 0,
            },
            colour = {
                current = "00 00 00",
                next = "00 00 00",
            },
            enabled = {
                current = false,
                next = false
            }
        },
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function StateManager:hasChanged(path)
    local item = getValueFromPath(self, path)
    if not item then
        return false
    end
    return item.next ~= item.current
end

function StateManager:update(path)
    local item = getValueFromPath(self, path)
    if not item then
        return
    end
    item.current = item.next
    return item.current
end

function StateManager:updateAll()
    for i = 1, 8 do
        self:update("fader" .. i)
    end
end

function StateManager:get(path)
    return getValueFromPath(self, path).current
end

function StateManager:getNext(path)
    return getValueFromPath(self, path).next
end

function StateManager:set(path, next)
    local item = getValueFromPath(self, path)
    if not item then
        return
    end
    item.next = next
end

function StateManager:inc(path)
    local item = getValueFromPath(self, path)
    if not item then
        return
    end
    local next = item.current + 1
    if next > 127 then
        next = 127
    end
    item.next = next
end

function StateManager:dec(path)
    local item = getValueFromPath(self, path)
    if not item then
        return
    end
    local next = item.current - 1
    if next < 0 then
        next = 0
    end
    item.next = next
end

function StateManager:add(path, delta, min, max)
    local item = getValueFromPath(self, path)
    if not item then
        return
    end
    local next = item.current + delta
    if min ~= nil and next < min then
        next = min
    end
    if max ~= nil and next > max then
        next = max
    end
    item.next = next
end

function StateManager:flip(path)
    local item = getValueFromPath(self, path)
    if not item then
        return
    end
    if item.current then
        item.next = false
    else
        item.next = true
    end
    return item.next
end

return StateManager

end)
__bundle_register("src.lib.table.getValueFromPath", function(require, _LOADED, __bundle_register, __bundle_modules)
return function(tbl, path)
  local current = tbl
  for token in string.gmatch(path, "([^%.]+)") do
    if current[token] then
      current = current[token]
    else
      return nil       -- This means the token/path doesn't exist in the table
    end
  end
  return current
end

end)
__bundle_register("src.config.constants", function(require, _LOADED, __bundle_register, __bundle_modules)
return {
  pickupTolerance = 10,
  fader = {
    unknown = 0,
    tooLow = 1,
    inSync = 2,
    tooHigh = 3,
    unassigned = 4
  }
}

end)
__bundle_register("src.deliverMidi.faders", function(require, _LOADED, __bundle_register, __bundle_modules)
local stateUtils = require("src.lib.state.utils")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, 8 do
    local fader = "fader" .. i
    if stateUtils.hasChanged(fader) then
      -- currently not sending any fader CCs to remote surface
      -- we may change this later
      stateUtils.update(fader)
    end
  end
  return events
end

end)
__bundle_register("src.setState.encoders", function(require, _LOADED, __bundle_register, __bundle_modules)
local items = require("src.config.items")
local stateUtils = require("src.lib.state.utils")
local getColour = require("src.lib.colour.getColour")

-- handles changes of the encoders from the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, 24 do
      local encoder = "encoder" .. i
      if changedItemIndex == items[encoder].index then
        if changedItem.is_enabled then
          local hostValue = changedItem.value
          stateUtils.set(encoder .. ".enabled", true)
          stateUtils.set(encoder .. ".value", hostValue)
          stateUtils.set(encoder .. ".colour", getColour(items[encoder].colour, hostValue))
        else
          stateUtils.set(encoder .. ".enabled", false)
        end
      end
    end
  end
end

end)
__bundle_register("src.lib.colour.getColour", function(require, _LOADED, __bundle_register, __bundle_modules)
local colours = require("src.config.colours")
local getColourForValue = require("src.lib.colour.getColourForValue");

return function(name, value)
  return getColourForValue(colours[name], value)
end

end)
__bundle_register("src.lib.colour.getColourForValue", function(require, _LOADED, __bundle_register, __bundle_modules)
local hexToRgb = require("src.lib.colour.hexToRgb")
local rgbToHsb = require("src.lib.colour.rgbToHsb")
local hsbToRgb = require("src.lib.colour.hsbToRgb")
local to7Bit = require("src.lib.colour.to7Bit")

return function(hex, value)
  local r, g, b = hexToRgb(hex)
  local h, s, brightness = rgbToHsb(r, g, b)

  local newS, newB = s, brightness

  if value <= 95 then
    local t = value / 95
    newB = brightness * (0.05 + 0.95 * t)
  else
    local t = (value - 95) / 32
    newS = s * (1 - 0.3 * t)
  end

  local nr, ng, nb = hsbToRgb(h, newS, newB)
  return string.format("%02x %02x %02x", to7Bit(nr), to7Bit(ng), to7Bit(nb))
end

end)
__bundle_register("src.lib.colour.to7Bit", function(require, _LOADED, __bundle_register, __bundle_modules)
return function(v)
  return math.floor((v * 127 / 255) + 0.5)
end

end)
__bundle_register("src.lib.colour.hsbToRgb", function(require, _LOADED, __bundle_register, __bundle_modules)
return function(h, s, b)
  local c = b * s
  local x = c * (1 - math.abs((h / 60) % 2 - 1))
  local m = b - c

  local r1, g1, b1
  if h < 60 then
    r1, g1, b1 = c, x, 0
  elseif h < 120 then
    r1, g1, b1 = x, c, 0
  elseif h < 180 then
    r1, g1, b1 = 0, c, x
  elseif h < 240 then
    r1, g1, b1 = 0, x, c
  elseif h < 300 then
    r1, g1, b1 = x, 0, c
  else
    r1, g1, b1 = c, 0, x
  end

  return
      math.floor((r1 + m) * 255 + 0.5),
      math.floor((g1 + m) * 255 + 0.5),
      math.floor((b1 + m) * 255 + 0.5)
end

end)
__bundle_register("src.lib.colour.rgbToHsb", function(require, _LOADED, __bundle_register, __bundle_modules)
return function(r, g, b)
  r = r / 255
  g = g / 255
  b = b / 255
  local max = math.max(r, g, b)
  local min = math.min(r, g, b)
  local delta = max - min

  local h = 0
  if delta ~= 0 then
    if max == r then
      h = 60 * (((g - b) / delta) % 6)
    elseif max == g then
      h = 60 * ((b - r) / delta + 2)
    else
      h = 60 * ((r - g) / delta + 4)
    end
  end
  if h < 0 then h = h + 360 end

  local s = 0
  if max ~= 0 then s = delta / max end

  return h, s, max
end

end)
__bundle_register("src.lib.colour.hexToRgb", function(require, _LOADED, __bundle_register, __bundle_modules)
return function(hex)
  local num = tonumber(hex, 16)
  local r = math.floor(num / 65536) % 256
  local g = math.floor(num / 256) % 256
  local b = num % 256
  return r, g, b
end

end)
__bundle_register("src.config.colours", function(require, _LOADED, __bundle_register, __bundle_modules)
return {
  fhyd = "fe3636",
  tang = "f66c02",
  duri = "dbc302",
  poml = "85961f",
  tiff = "14bfaf",
  coco = "1a2f96",
  plum = "624bad",
  flam = "fd39d4",
  ceru = "0ea4ee",
  suns = "fff034",
  aqua = "0f9c8e",
  fore = "3dc300"
}

end)
__bundle_register("src.setState.faders", function(require, _LOADED, __bundle_register, __bundle_modules)
local faderStates = require("src.lib.state.faders")
local items = require("src.config.items")
local constants = require("src.config.constants")
local stateUtils = require("src.lib.state.utils")

-- handles changes of the faders from the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, 8 do
      local fader = "fader" .. i
      if changedItemIndex == items[fader].index then
        if changedItem.is_enabled then
          local hostValue = changedItem.value
          local controlSurfaceValue = faderStates[fader].controlSurface
          local state
          if controlSurfaceValue == nil then
            -- it goes here when the codec is loaded
            -- because we do not know where the fader is at on the control surface
            state = constants.fader.unknown
          elseif hostValue >= controlSurfaceValue - constants.pickupTolerance and hostValue <= controlSurfaceValue + constants.pickupTolerance then
            --local xy = changedItem.IN_SYNC.value
            state = constants.fader.inSync
          elseif hostValue > controlSurfaceValue then
            --local xy = changedItem.TOO_LOW.value
            state = constants.fader.tooLow
          elseif hostValue < controlSurfaceValue then
            --local xy = changedItem.TOO_HIGH.value
            state = constants.fader.tooHigh
          end
          faderStates[fader].host = hostValue
          stateUtils.set(fader, state)
        else
          faderStates[fader] = {}
          stateUtils.set(fader, constants.fader.unassigned)
        end
      end
    end
  end
end

end)
__bundle_register("src.lib.state.faders", function(require, _LOADED, __bundle_register, __bundle_modules)
return {
  fader1 = {},
  fader2 = {},
  fader3 = {},
  fader4 = {},
  fader5 = {},
  fader6 = {},
  fader7 = {},
  fader8 = {},
}

end)
__bundle_register("src.processMidi.encoders", function(require, _LOADED, __bundle_register, __bundle_modules)
local items = require("src.config.items")
local stateUtils = require("src.lib.state.utils")
local getColour = require("src.lib.colour.getColour")

-- handles changes of the faders from the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, 24 do
    local encoder = "encoder" .. i
    local item = items[encoder]
    local match = remote.match_midi(item.midi, event)
    if match and stateUtils.get(encoder .. ".enabled") then
      local remoteSurfaceValue = match.x
      stateUtils.set(encoder .. ".value", remoteSurfaceValue)
      stateUtils.set(encoder .. ".colour", getColour(item.colour, remoteSurfaceValue))

      -- update host (Reason)
      remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = remoteSurfaceValue })
      processed = true
    end
  end
  return processed
end

end)
__bundle_register("src.processMidi.faders", function(require, _LOADED, __bundle_register, __bundle_modules)
local faderStates = require("src.lib.state.faders")
local items = require("src.config.items")
local constants = require("src.config.constants")
local stateUtils = require("src.lib.state.utils")

-- handles changes of the faders from the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, 8 do
    local fader = "fader" .. i
    local ret = remote.match_midi(items[fader].midi, event)
    if ret then
      local remoteSurfaceValue = ret.x
      local hostValue = faderStates[fader].host
      local state = stateUtils.get(fader)
      if state == constants.fader.unknown then
        -- it is goes here when the codec has just been loaded and
        -- we receive a CC from a fader for the first time
        if remoteSurfaceValue >= hostValue - constants.pickupTolerance and remoteSurfaceValue <= hostValue + constants.pickupTolerance then
          stateUtils.set(fader, constants.fader.inSync)
        elseif remoteSurfaceValue < hostValue then
          stateUtils.set(fader, constants.fader.tooLow)
        elseif remoteSurfaceValue > hostValue then
          stateUtils.set(fader, constants.fader.tooHigh)
        end
      elseif state == constants.fader.tooLow then
        if remoteSurfaceValue >= hostValue then
          stateUtils.set(fader, constants.fader.inSync)
        end
      elseif state == constants.fader.tooHigh then
        if remoteSurfaceValue <= hostValue then
          stateUtils.set(fader, constants.fader.inSync)
        end
      end
      faderStates[fader].remoteSurface = remoteSurfaceValue

      if stateUtils.getNext(fader) == constants.fader.inSync then
        faderStates[fader].host = remoteSurfaceValue

        -- CODEC => REASON
        remote.handle_input({
          item = items[fader].index,
          value = remoteSurfaceValue,
          time_stamp = event.time_stamp
        })
        processed = true
      end
    end
  end

  return processed
end

end)
return __bundle_require("__root")
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
local processEncoders = require("src.processMidi.encoders")
local processFaders = require("src.processMidi.faders")
local processButtons = require("src.processMidi.buttons")
local setEncoders = require("src.setState.encoders")
local setFaders = require("src.setState.faders")
local setInfo = require("src.setState.info")
local setButtons = require("src.setState.buttons")
local deliverEncoders = require("src.deliverMidi.encoders")
local deliverFaders = require("src.deliverMidi.faders")
local deliverButtons = require("src.deliverMidi.buttons")
local deliverDisplay = require("src.deliverMidi.display")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")
local debug = require("src.lib.debug._")
local autoInputs = require("src.config.autoInputs")

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
  end
  remote.define_items(itemsToDefine)
  remote.define_auto_inputs(autoInputs)
  debug.log("LCXL3 remote codec initialised successfully!")
end

-- Remote surface (Launch Control) -> remote codec -> host (Reason)
function remote_process_midi(event)
  return processEncoders(event) or processFaders(event) or processButtons(event)
end

-- Host (Reason) -> remote codec
function remote_set_state(changedItems)
  setInfo(changedItems)
  setEncoders(changedItems)
  setFaders(changedItems)
  setButtons(changedItems)
end

-- Remote codec -> remote surface (Launch Control)
function remote_deliver_midi(_, port)
  if port == 2 then
    return debug.dump()
  end

  local events = {}

  for _, event in ipairs(deliverEncoders()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverFaders()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverButtons()) do
    table.insert(events, event)
  end
  for _, event in ipairs(deliverDisplay()) do
    table.insert(events, event)
  end

  return events
end

function remote_prepare_for_use()
  return {
    -- turn on DAW mode
    makeSysexEvent("02 7f"),
    remote.make_midi("b6 1e 02"),

    -- set encoder modes to absolute
    remote.make_midi("b6 45 00"),
    remote.make_midi("b6 48 00"),
    remote.make_midi("b6 49 00"),

    -- set the colours of navigation buttons to dim white
    makeSysexEvent("01 53 6a 1f 1f 1f"),
    makeSysexEvent("01 53 6b 1f 1f 1f"),
    makeSysexEvent("01 53 67 1f 1f 1f"),
    makeSysexEvent("01 53 66 1f 1f 1f"),

    -- set temporary display timeout to 1 sec
    remote.make_midi("b6 71 00"),
  }
end

function remote_release_from_use()
  return {
    -- turn off DAW mode
    makeSysexEvent("02 00"),
  }
end

end)
__bundle_register("src.config.autoInputs", function(require, _LOADED, __bundle_register, __bundle_modules)
return {
  { name = "pageUpButton",     pattern = "B0 6a ?<???x>", port = 1 },
  { name = "pageDownButton",   pattern = "B0 6b ?<???x>", port = 1 },
  { name = "trackLeftButton",  pattern = "B0 66 ?<???x>", port = 1 },
  { name = "trackRightButton", pattern = "B0 67 ?<???x>", port = 1 },
  { name = "trackLeftButton",  pattern = "B0 66 ?<???x>", port = 1 }
}

end)
__bundle_register("src.lib.debug._", function(require, _LOADED, __bundle_register, __bundle_modules)
local concatenateKeys = require("src.lib.debug.concatenateKeys")
local midiEventToString = require("src.lib.debug.midiEventToString")
local logWithLogMessages = require("src.lib.debug.log")
local dumpWithLogMessages = require("src.lib.debug.dump")

local logMessages = {}

local function log(message)
  logWithLogMessages(logMessages, message)
end

local function dump()
  local events = dumpWithLogMessages(logMessages)
  logMessages = {}
  return events
end

return {
  concatenateKeys = concatenateKeys,
  midiEventToString = midiEventToString,
  log = log,
  dump = dump
}

end)
__bundle_register("src.lib.debug.dump", function(require, _LOADED, __bundle_register, __bundle_modules)
local makeLogEvent = require("src.lib.midi.makeLogEvent")

return function(logMessages)
  local events = {}
  for _, message in pairs(logMessages) do
    table.insert(events, makeLogEvent(message))
  end
  return events
end

end)
__bundle_register("src.lib.midi.makeLogEvent", function(require, _LOADED, __bundle_register, __bundle_modules)
local const = require("src.config.constants")
local textToHex = require("src.lib.hex.textToHex")

return function(msg)
  local event = const.debugSysexHeader .. " " .. textToHex(msg) .. "F7"
  return remote.make_midi(event)
end

end)
__bundle_register("src.lib.hex.textToHex", function(require, _LOADED, __bundle_register, __bundle_modules)
local decToHex = require("src.lib.hex.decToHex")

return function(text)
  local hex = ""
  local textLen = string.len(text)
  for i = 1, textLen do
    hex = hex .. decToHex(string.byte(text, i))
    if i ~= textLen then
      hex = hex .. " "
    end
  end
  return hex
end

end)
__bundle_register("src.lib.hex.decToHex", function(require, _LOADED, __bundle_register, __bundle_modules)
return function(decimalValue)
  return string.format("%02X", decimalValue)
end

end)
__bundle_register("src.config.constants", function(require, _LOADED, __bundle_register, __bundle_modules)
return {
  pickupTolerance = 10,
  maxLogMessages = 500,
  sysexHeader = "f0 00 20 29 02 15",
  debugSysexHeader = "f0 00 20 29 02 0a 02",
  fader = {
    unknown = 0,
    tooLow = 1,
    inSync = 2,
    tooHigh = 3,
    unassigned = 4
  }
}

end)
__bundle_register("src.lib.debug.log", function(require, _LOADED, __bundle_register, __bundle_modules)
local const = require("src.config.constants")

return function(logMessages, message)
  table.insert(logMessages, message)
  -- if the codec is not running in debug mode, the logs are never dumped
  -- we need to limit the number of log messages to prevent memory leaks
  if #logMessages > const.maxLogMessages then
    table.remove(logMessages, 1)
  end
end

end)
__bundle_register("src.lib.debug.midiEventToString", function(require, _LOADED, __bundle_register, __bundle_modules)
return function(event)
  local bytes = {}
  local n = event.size or #event
  for i = 1, n do
    table.insert(bytes, string.format("%02X", event[i]))
  end
  local str = table.concat(bytes, " ")
  if event.port then
    str = str .. string.format(" (port=%d)", event.port)
  end
  return str
end

end)
__bundle_register("src.lib.debug.concatenateKeys", function(require, _LOADED, __bundle_register, __bundle_modules)
-- this function accepts a table and returns a string with
-- all the keys in the table; you can specify keys to exclude
-- in the output by providing a second argument
return function(tbl, excludeKeys)
  local keys = {}
  local exclude = {}

  -- Populate the exclude table for O(1) lookups
  for _, key in ipairs(excludeKeys or {}) do
    exclude[key] = true
  end

  for key, _ in pairs(tbl) do
    if not exclude[key] then
      table.insert(keys, tostring(key))
    end
  end

  return table.concat(keys, ",")
end

end)
__bundle_register("src.lib.midi.makeSysexEvent", function(require, _LOADED, __bundle_register, __bundle_modules)
local const = require("src.config.constants")

return function(payload, options)
  return remote.make_midi(const.sysexHeader .. " " .. payload .. " f7", options or {})
end

end)
__bundle_register("src.deliverMidi.display", function(require, _LOADED, __bundle_register, __bundle_modules)
local state = require("src.lib.state._")
local textLinesToHex = require("src.lib.hex.textLinesToHex")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  if state.hasChanged("display") then
    local text = state.update("display")
    -- Configure display: arrangement 2 (3 lines)
    table.insert(events, makeSysexEvent("04 35 62"))

    local target = "35" -- stationary display
    local lines = textLinesToHex(text)

    for field, hex in ipairs(lines) do
      local fieldByte = string.format("%02x", field - 1) -- 00h, 01h, 02h...
      table.insert(events, makeSysexEvent(
        "06 " .. target .. " " .. fieldByte .. " " .. hex
      ))
    end

    -- Trigger display
    table.insert(events, makeSysexEvent("04 35 7f"))
  end
  return events
end

end)
__bundle_register("src.lib.hex.textLinesToHex", function(require, _LOADED, __bundle_register, __bundle_modules)
return function(str)
  local lines = {}
  for line in (str .. "\n"):gmatch("(.-)\n") do
    table.insert(lines, line)
  end

  local hexLines = {}
  for _, line in ipairs(lines) do
    local bytes = {}
    for i = 1, #line do
      local byte = string.byte(line, i)
      table.insert(bytes, string.format("%02x", byte))
    end
    table.insert(hexLines, table.concat(bytes, " "))
  end

  return hexLines
end

end)
__bundle_register("src.lib.state._", function(require, _LOADED, __bundle_register, __bundle_modules)
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
local const = require("src.config.constants")
local getValueFromPath = require("src.lib.table.getValueFromPath")

local StateManager = {}

function StateManager:new()
    local instance = {
        fader1 = {
            current = const.fader.unassigned,
            next = const.fader.unassigned
        },
        fader2 = {
            current = const.fader.unassigned,
            next = const.fader.unassigned
        },
        fader3 = {
            current = const.fader.unassigned,
            next = const.fader.unassigned
        },
        fader4 = {
            current = const.fader.unassigned,
            next = const.fader.unassigned
        },
        fader5 = {
            current = const.fader.unassigned,
            next = const.fader.unassigned
        },
        fader6 = {
            current = const.fader.unassigned,
            next = const.fader.unassigned
        },
        fader7 = {
            current = const.fader.unassigned,
            next = const.fader.unassigned
        },
        fader8 = {
            current = const.fader.unassigned,
            next = const.fader.unassigned
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
        button1 = {
            value = {
                current = false,
                next = false,
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
        button2 = {
            value = {
                current = false,
                next = false,
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
        button3 = {
            value = {
                current = false,
                next = false,
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
        button4 = {
            value = {
                current = false,
                next = false,
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
        button5 = {
            value = {
                current = false,
                next = false,
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
        button6 = {
            value = {
                current = false,
                next = false,
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
        button7 = {
            value = {
                current = false,
                next = false,
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
        button8 = {
            value = {
                current = false,
                next = false,
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
        button9 = {
            value = {
                current = false,
                next = false,
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
        button10 = {
            value = {
                current = false,
                next = false,
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
        button11 = {
            value = {
                current = false,
                next = false,
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
        button12 = {
            value = {
                current = false,
                next = false,
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
        button13 = {
            value = {
                current = false,
                next = false,
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
        button14 = {
            value = {
                current = false,
                next = false,
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
        button15 = {
            value = {
                current = false,
                next = false,
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
        button16 = {
            value = {
                current = false,
                next = false,
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
        display = {
            current = " ",
            next = " "
        },
        documentName = {
            current = " ",
            next = " "
        },
        targetTrackName = {
            current = " ",
            next = " "
        },
        deviceType = {
            current = " ",
            next = " "
        },
        deviceName = {
            current = " ",
            next = " "
        },
        patchName = {
            current = " ",
            next = " "
        }
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function StateManager:hasChanged(path)
    local item = getValueFromPath(self, path)
    if item == nil then
        return false
    end
    return item.next ~= item.current
end

function StateManager:update(path)
    local item = getValueFromPath(self, path)
    if item == nil then
        return
    end
    item.current = item.next
    return item.current
end

function StateManager:updateAll()
    for i = 1, 24 do
        self:update("encoder" .. i)
    end
    for i = 1, 8 do
        self:update("fader" .. i)
    end
    for i = 1, 16 do
        self:update("button" .. i)
    end
    self:update("documentName")
    self:update("targetTrackName")
    self:update("display")
    self:update("deviceType")
    self:update("deviceName")
    self:update("patchName")
end

function StateManager:get(path)
    return getValueFromPath(self, path).current
end

function StateManager:getNext(path)
    return getValueFromPath(self, path).next
end

function StateManager:set(path, next)
    local item = getValueFromPath(self, path)
    if item == nil then
        return
    end
    item.next = next
end

function StateManager:inc(path)
    local item = getValueFromPath(self, path)
    if item == nil then
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
    if item == nil then
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
    if item == nil then
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
    if item == nil then
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
__bundle_register("src.deliverMidi.buttons", function(require, _LOADED, __bundle_register, __bundle_modules)
local state = require("src.lib.state._")
local items = require("src.config.items")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, 16 do
    local path, enabled
    local enabledChanged = false
    local item = items["button" .. i]

    path = "button" .. i .. ".enabled"
    if state.hasChanged(path) then
      state.update(path)
      enabled = state.get(path)
      enabledChanged = true
      if not enabled then
        -- turn of button's LED
        table.insert(events, makeSysexEvent("01 53 xx 00 00 00", { x = item.controller }))
      end
    else
      enabled = state.get(path)
    end

    if enabled then
      path = "button" .. i .. ".value"
      if enabledChanged or state.hasChanged(path) then
        state.update(path)
        -- no MIDI command sent out for button change
      end
      path = "button" .. i .. ".colour"
      if enabledChanged or state.hasChanged(path) then
        local colour = state.update(path)
        table.insert(events, makeSysexEvent("01 53 xx " .. colour, { x = item.controller }))
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
  button1 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 25 7f", controller = 37, colour = "fhyd" },
  button2 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 26 7f", controller = 38, colour = "tang" },
  button3 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 27 7f", controller = 39, colour = "suns" },
  button4 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 28 7f", controller = 40, colour = "fore" },
  button5 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 29 7f", controller = 41, colour = "aqua" },
  button6 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 2a 7f", controller = 42, colour = "coco" },
  button7 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 2b 7f", controller = 43, colour = "plum" },
  button8 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 2c 7f", controller = 44, colour = "flam" },
  button9 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 2d 7f", controller = 45, colour = "fhyd" },
  button10 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 2e 7f", controller = 46, colour = "tang" },
  button11 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 2f 7f", controller = 47, colour = "suns" },
  button12 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 30 7f", controller = 48, colour = "fore" },
  button13 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 31 7f", controller = 49, colour = "aqua" },
  button14 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 32 7f", controller = 50, colour = "coco" },
  button15 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 33 7f", controller = 51, colour = "plum" },
  button16 = { input = "value", output = "value", min = 0, max = 127, midi = "b0 34 7f", controller = 52, colour = "flam" },
  documentName = { output = "text" },
  targetTrackName = { output = "text" },
  trackRightButton = { input = "button", output = "value", min = 0, max = 127 },
  trackLeftButton = { input = "button", output = "value", min = 0, max = 127 },
  pageUpButton = { input = "button", output = "value", min = 0, max = 127 },
  pageDownButton = { input = "button", output = "value", min = 0, max = 127 },
  playButton = { input = "button", output = "value", min = 0, max = 127 },
  recordButton = { input = "button", output = "value", min = 0, max = 127 },
  deviceType = { output = "text" },
  deviceName = { output = "text" },
  patchName = { output = "text" },
}

end)
__bundle_register("src.deliverMidi.faders", function(require, _LOADED, __bundle_register, __bundle_modules)
local state = require("src.lib.state._")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, 8 do
    local fader = "fader" .. i
    if state.hasChanged(fader) then
      -- currently not sending any fader CCs to remote surface
      -- we may change this later
      state.update(fader)
    end
  end
  return events
end

end)
__bundle_register("src.deliverMidi.encoders", function(require, _LOADED, __bundle_register, __bundle_modules)
local state = require("src.lib.state._")
local items = require("src.config.items")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")
local makeParamNameDisplayEvent = require("src.lib.midi.makeParamNameDisplayEvent")
local debug = require("src.lib.debug._")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, 24 do
    local path, enabled, changed
    local item = items["encoder" .. i]

    path = "encoder" .. i .. ".enabled"
    if state.hasChanged(path) then
      enabled = state.update(path)
      changed = true
      --debug.log("DM: " .. path .. " is now " .. (enabled and "true" or "false"))
      if not enabled then
        -- turn of encoder's LED
        table.insert(events, makeSysexEvent("01 53 xx 00 00 00", { x = item.controller }))
      end
    else
      enabled = state.get(path)
    end

    if enabled then
      path = "encoder" .. i .. ".value"
      if changed or state.hasChanged(path) then
        local value = state.update(path)
        --debug.log("DM: " .. path .. " is now " .. tostring(value))
        table.insert(events, remote.make_midi(item.midi, { x = value }))
        local paramNameDisplayEvent = makeParamNameDisplayEvent(remote.get_item_name(item.index), item.controller)
        debug.log("item.controller: " .. item.controller)
        debug.log(debug.midiEventToString(paramNameDisplayEvent))
        table.insert(events, paramNameDisplayEvent)
      end
      path = "encoder" .. i .. ".colour"
      if changed or state.hasChanged(path) then
        local colour = state.update(path)
        table.insert(events, makeSysexEvent("01 53 xx " .. colour, { x = item.controller }))
      end
    end
  end
  return events
end

end)
__bundle_register("src.lib.midi.makeParamNameDisplayEvent", function(require, _LOADED, __bundle_register, __bundle_modules)
local textToHex = require("src.lib.hex.textToHex")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")

return function(text, target)
  return makeSysexEvent("06 xx 00 " .. textToHex(text), { x = target })
end

end)
__bundle_register("src.setState.buttons", function(require, _LOADED, __bundle_register, __bundle_modules)
local items = require("src.config.items")
local state = require("src.lib.state._")
local getColour = require("src.lib.colour.getColour")

-- handles changes of the buttons of the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, 16 do
      local button = "button" .. i
      if changedItemIndex == items[button].index then
        if changedItem.is_enabled then
          local hostValue = changedItem.value > 0 and true or false
          state.set(button .. ".enabled", true)
          state.set(button .. ".value", hostValue)
          local colourValue = changedItem.value > 0 and 95 or 1
          state.set(button .. ".colour", getColour(items[button].colour, colourValue))
        else
          state.set(button .. ".enabled", false)
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
__bundle_register("src.setState.info", function(require, _LOADED, __bundle_register, __bundle_modules)
local state = require("src.lib.state._")
local items = require("src.config.items")
local debug = require("src.lib.debug._")

return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    if changedItemIndex == items.targetTrackName.index then
      local targetTrackName = remote.get_item_text_value(changedItemIndex)
      --debug.log("SSt: target track name is " .. targetTrackName)
      state.set("deviceType", targetTrackName)
      --state.set("display", targetTrackName)
    elseif changedItemIndex == items.documentName.index then
      local documentName = remote.get_item_text_value(changedItemIndex)
      debug.log("SSt: document name is now " .. documentName)
      state.set("documentName", documentName)
      --state.set("display", documentName)
    elseif changedItemIndex == items.deviceType.index then
      local deviceType = remote.get_item_text_value(changedItemIndex)
      --debug.log("SSt: device type is " .. deviceType)
      state.set("deviceType", deviceType)
    elseif changedItemIndex == items.deviceName.index then
      local deviceName = remote.get_item_text_value(changedItemIndex)
      --debug.log("SSt: device name is " .. deviceName)
      state.set("deviceName", deviceName)
      --state.set("display", deviceName)
    elseif changedItemIndex == items.patchName.index then
      local patchName = remote.get_item_text_value(changedItemIndex)
      --debug.log("SSt: patch name is " .. patchName)
      state.set("patchName", patchName)
      state.set("display", patchName)
    end
  end
end

end)
__bundle_register("src.setState.faders", function(require, _LOADED, __bundle_register, __bundle_modules)
local faderStates = require("src.lib.state.faders")
local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")

-- handles changes of the faders of the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, 8 do
      local fader = "fader" .. i
      if changedItemIndex == items[fader].index then
        if changedItem.is_enabled then
          local hostValue = changedItem.value
          local controlSurfaceValue = faderStates[fader].controlSurface
          local status
          if controlSurfaceValue == nil then
            -- it goes here when the codec is loaded
            -- because we do not know where the fader is at on the control surface
            status = const.fader.unknown
          elseif hostValue >= controlSurfaceValue - const.pickupTolerance and hostValue <= controlSurfaceValue + const.pickupTolerance then
            --local xy = changedItem.IN_SYNC.value
            status = const.fader.inSync
          elseif hostValue > controlSurfaceValue then
            --local xy = changedItem.TOO_LOW.value
            status = const.fader.tooLow
          elseif hostValue < controlSurfaceValue then
            --local xy = changedItem.TOO_HIGH.value
            status = const.fader.tooHigh
          end
          faderStates[fader].host = hostValue
          state.set(fader, status)
        else
          faderStates[fader] = {}
          state.set(fader, const.fader.unassigned)
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
__bundle_register("src.setState.encoders", function(require, _LOADED, __bundle_register, __bundle_modules)
local items = require("src.config.items")
local state = require("src.lib.state._")
local getColour = require("src.lib.colour.getColour")
--local debug = require("src.lib.debug._")

-- handles changes of the encoders of the host (Reason)
return function(changedItems)
  -- if #changedItems > 0 then
  --   for i = 1, 24 do
  --     local encoder = "encoder" .. i
  --     local itemState = remote.get_item_state(items[encoder].index)
  --     debug.log(tostring(i) .. "--------------------------------------------------")
  --     debug.log(encoder .. ".is_enabled:       " .. (itemState.is_enabled and "true" or "false"))
  --     debug.log(encoder .. ".remote_item_name: " .. itemState.remote_item_name)
  --     debug.log(encoder .. ".text_value:       " .. itemState.text_value)
  --   end
  -- end
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, 24 do
      local encoder = "encoder" .. i
      if changedItemIndex == items[encoder].index then
        if changedItem.is_enabled then
          local hostValue = changedItem.value
          --debug.log("SSt: host says " .. encoder .. ".enabled is true")
          --debug.log("SSt: host says " .. encoder .. ".value is " .. tostring(hostValue))
          state.set(encoder .. ".enabled", true)
          state.set(encoder .. ".value", hostValue)
          state.set(encoder .. ".colour", getColour(items[encoder].colour, hostValue))
        else
          local hostValue = changedItem.value
          --debug.log("SSt: host says " .. encoder .. ".enabled is false")
          --debug.log("SSt: host says " .. encoder .. ".value is " .. tostring(hostValue))
          state.set(encoder .. ".enabled", false)
        end
      end
    end
  end
end

end)
__bundle_register("src.processMidi.buttons", function(require, _LOADED, __bundle_register, __bundle_modules)
local items = require("src.config.items")
local state = require("src.lib.state._")
local getColour = require("src.lib.colour.getColour")

-- handles changes of the buttons of the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, 16 do
    local button = "button" .. i
    local item = items[button]
    local match = remote.match_midi(item.midi, event)
    if match and state.get(button .. ".enabled") then
      local turnedOn = state.flip(button .. ".value")
      local colourValue = turnedOn and 95 or 1
      state.set(button .. ".colour", getColour(item.colour, colourValue))

      -- update host (Reason)
      local hostValue = turnedOn and 127 or 0
      remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = hostValue })
      processed = true
    end
  end
  return processed
end

end)
__bundle_register("src.processMidi.faders", function(require, _LOADED, __bundle_register, __bundle_modules)
local faderStates = require("src.lib.state.faders")
local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")

-- handles changes of the faders of the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, 8 do
    local fader = "fader" .. i
    local ret = remote.match_midi(items[fader].midi, event)
    if ret then
      local remoteSurfaceValue = ret.x
      local hostValue = faderStates[fader].host
      local status = state.get(fader)
      if status == const.fader.unknown then
        -- it is goes here when the codec has just been loaded and
        -- we receive a CC from a fader for the first time
        if remoteSurfaceValue >= hostValue - const.pickupTolerance and remoteSurfaceValue <= hostValue + const.pickupTolerance then
          state.set(fader, const.fader.inSync)
        elseif remoteSurfaceValue < hostValue then
          state.set(fader, const.fader.tooLow)
        elseif remoteSurfaceValue > hostValue then
          state.set(fader, const.fader.tooHigh)
        end
      elseif status == const.fader.tooLow then
        if remoteSurfaceValue >= hostValue then
          state.set(fader, const.fader.inSync)
        end
      elseif status == const.fader.tooHigh then
        if remoteSurfaceValue <= hostValue then
          state.set(fader, const.fader.inSync)
        end
      end
      faderStates[fader].remoteSurface = remoteSurfaceValue

      if state.getNext(fader) == const.fader.inSync then
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
__bundle_register("src.processMidi.encoders", function(require, _LOADED, __bundle_register, __bundle_modules)
local items = require("src.config.items")
local state = require("src.lib.state._")
local getColour = require("src.lib.colour.getColour")

-- handles changes of the encoders of the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, 24 do
    local encoder = "encoder" .. i
    local item = items[encoder]
    local match = remote.match_midi(item.midi, event)
    if match and state.get(encoder .. ".enabled") then
      local remoteSurfaceValue = match.x
      state.set(encoder .. ".value", remoteSurfaceValue)
      state.set(encoder .. ".colour", getColour(item.colour, remoteSurfaceValue))

      -- update host (Reason)
      remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = remoteSurfaceValue })
      processed = true
    end
  end
  return processed
end

end)
return __bundle_require("__root")
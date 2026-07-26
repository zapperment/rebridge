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
        transport = {
            playing = {
                current = false,
                next = false
            },
            recording = {
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
        local encoder = "encoder" .. i
        self:update(encoder .. ".value")
        self:update(encoder .. ".colour")
        self:update(encoder .. ".enabled")
    end
    for i = 1, 8 do
        self:update("fader" .. i)
    end
    for i = 1, 16 do
        local button = "button" .. i
        self:update(button .. ".value")
        self:update(button .. ".colour")
        self:update(button .. ".enabled")
    end
    self:update("display")
    self:update("documentName")
    self:update("targetTrackName")
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

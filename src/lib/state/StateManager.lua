local const = require("src.config.constants")
local tbl = require("src.lib.table._")

local StateManager = {}

local function entry(value)
    return {
        current = value,
        next = value
    }
end

function StateManager:new()
    local instance = {
        transport = {
            playing = entry(false),
            recording = entry(false)
        },
        display = entry(" "),
        documentName = entry(" "),
        targetTrackName = entry(" "),
        deviceType = entry(" "),
        deviceName = entry(" "),
        patchName = entry(" ")
    }
    for i = 1, const.counts.encoders do
        instance["encoder" .. i] = {
            value = entry(0),
            colour = entry("00 00 00"),
            enabled = entry(false)
        }
    end
    for i = 1, const.counts.faders do
        instance["fader" .. i] = {
            controlSurfaceValue = entry(nil),
            hostValue = entry(0),
            hostTextValue = entry(""),
            param = entry(""),
            enabled = entry(false),
            status = entry(const.fader.unassigned)
        }
    end
    for i = 1, const.counts.buttons do
        instance["button" .. i] = {
            value = entry(false),
            colour = entry("00 00 00"),
            enabled = entry(false)
        }
    end
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function StateManager:hasChanged(path)
    local item = tbl.getValueFromPath(self, path)
    if item == nil then
        return false
    end
    return item.next ~= item.current
end

function StateManager:update(path)
    local item = tbl.getValueFromPath(self, path)
    if item == nil then
        return
    end
    item.current = item.next
    return item.current
end

function StateManager:updateAll()
    for i = 1, const.counts.encoders do
        local encoder = "encoder" .. i
        self:update(encoder .. ".value")
        self:update(encoder .. ".colour")
        self:update(encoder .. ".enabled")
    end
    for i = 1, const.counts.faders do
        self:update("fader" .. i)
    end
    for i = 1, const.counts.buttons do
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
    return tbl.getValueFromPath(self, path).current
end

function StateManager:getNext(path)
    return tbl.getValueFromPath(self, path).next
end

function StateManager:set(path, next)
    local item = tbl.getValueFromPath(self, path)
    if item == nil then
        return
    end
    item.next = next
end

function StateManager:inc(path)
    local item = tbl.getValueFromPath(self, path)
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
    local item = tbl.getValueFromPath(self, path)
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
    local item = tbl.getValueFromPath(self, path)
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
    local item = tbl.getValueFromPath(self, path)
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

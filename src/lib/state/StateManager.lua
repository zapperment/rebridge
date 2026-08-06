local const = require("src.config.constants")
local tbl = require("src.lib.table._")
local str = require("src.lib.string._")
local deb = require("src.lib.debug._")

local StateManager = {}

local function entry(value)
    return {
        current = value,
        next = value,
        forceUpdate = false
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
        patchName = entry(" "),
        hostValues = {}
    }
    for i = 1, const.counts.encoders do
        instance["encoder" .. i] = {
            enabled = entry(false),
            controlSurfaceValue = entry(0),
            param = entry(nil),
            hostValue = entry(nil),
            hostTextValue = entry(""),
        }
    end
    for i = 1, const.counts.faders do
        instance["fader" .. i] = {
            enabled = entry(false),
            controlSurfaceValue = entry(0),
            param = entry(nil),
            hostValue = entry(nil),
            hostTextValue = entry(""),
            status = entry(const.fader.unassigned)
        }
    end
    for i = 1, const.counts.buttons do
        instance["button" .. i] = {
            enabled = entry(false),
            controlSurfaceValue = entry(false),
            param = entry(nil),
            hostValue = entry(nil),
            hostTextValue = entry(""),
            type = entry(const.button.toggle)
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
    return item.forceUpdate or item.next ~= item.current
end

function StateManager:update(path)
    local item = tbl.getValueFromPath(self, path)
    if item == nil then
        return
    end
    local hasChanged = item.forceUpdate or item.next ~= item.current
    item.current = item.next
    item.forceUpdate = false
    return item.current, hasChanged
end

function StateManager:updateAll()
    local control = nil
    for i = 1, const.counts.encoders do
        control = "encoder" .. i
        self:update(control .. ".enabled")
        self:update(control .. ".controlSurfaceValue")
        self:update(control .. ".param")
        self:update(control .. ".hostValue")
        self:update(control .. ".hostTextValue")
    end
    for i = 1, const.counts.faders do
        control = "fader" .. i
        self:update(control .. ".enabled")
        self:update(control .. ".controlSurfaceValue")
        self:update(control .. ".param")
        self:update(control .. ".hostValue")
        self:update(control .. ".hostTextValue")
        self:update(control .. ".status")
    end
    for i = 1, const.counts.buttons do
        control = "button" .. i
        self:update(control .. ".enabled")
        self:update(control .. ".controlSurfaceValue")
        self:update(control .. ".param")
        self:update(control .. ".hostValue")
        self:update(control .. ".hostTextValue")
        self:update(control .. ".type")
    end
    self:update("transport.playing")
    self:update("transport.recording")
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
    local stateItem = tbl.getValueFromPath(self, path)
    if stateItem == nil then
        return nil
    end
    return stateItem.next
end

function StateManager:set(path, next)
    -- TODO: set forceUpdate flag on dependent items
    local item, parent = tbl.getValueFromPath(self, path)
    if item == nil then
        return
    end
    local isHostValue = str.endsWith(path, ".hostValue")
    local isParam = str.endsWith(path, ".param")
    local hasParent = parent ~= nil
    local parentHasHostValue = hasParent and parent.hostValue ~= nil and parent.hostValue.next ~= nil
    local parentHasParam = hasParent and parent.param ~= nil and parent.param.next ~= nil
    local parentHostValue = parentHasHostValue and parent.hostValue.next
    local parentParam = parentHasParam and parent.param.next
    local hostValue = isHostValue and next or parentHostValue
    local param = isParam and next or parentParam
    if (isHostValue and type(parentParam) == "string" and parentParam ~= "")
        or (isParam and type(param) == "string" and param ~= "" and parentHasHostValue) then
        self.hostValues[param] = hostValue
        deb.log(
            "[lib.state.StateManager] storing host value: **" ..
            param .. "=" .. tostring(hostValue) .. "**"
        )
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

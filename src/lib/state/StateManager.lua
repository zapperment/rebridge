local const = require("src.config.constants")
local conditionalValueLabels = require("src.config.conditionalValueLabels")
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

function StateManager:getHostValue(param)
    return self.hostValues[param]
end

function StateManager:updateHostValues(path, next, parent)
    local logMe = false
    local isHostValue = str.endsWith(path, ".hostValue")
    local isParam = str.endsWith(path, ".param")
    if (not isHostValue and not isParam) or not parent then
        return
    end
    ---@diagnostic disable: need-check-nil, undefined-field
    local parentHasHostValue = parent.hostValue and parent.hostValue.next ~= nil
    local parentHasParam = parent.param and parent.param.next and parent.param.next ~= ""
    local parentHostValue = parentHasHostValue and parent.hostValue.next
    local parentParam = parentHasParam and parent.param.next
    ---@diagnostic enable: need-check-nil, undefined-field
    local hostValue = isHostValue and next or parentHostValue
    local param = isParam and next or parentParam
    if (isHostValue and parentHasParam) or (isParam and parentHasHostValue) then
        self.hostValues[param] = hostValue
        if logMe then
            deb.log("[lib:state:StateManager] storing host value " .. param .. "=" .. tostring(hostValue))
        end
        self:updateDependencies(param, hostValue)
    end
end

function StateManager:updateDependencies(param, hostValue)
    local logMe = str.startsWith(param, "Mode")
    local deviceType = self:getNext("deviceType")
    if logMe then
        deb.log(
            "[lib:state:StateManager] " ..
            "deviceType=" .. deviceType
        )
    end
    local conditionals = conditionalValueLabels[deviceType]
    if not conditionals then
        if logMe then
            deb.log(
                "[lib:state:StateManager] " ..
                "no conditionals for device type " .. deviceType
            )
        end
        return
    end
    for dependentParam, conditionalConfig in pairs(conditionals) do
        local dependsOn = conditionalConfig.dependsOn
        if dependsOn == param then
            if logMe then
                deb.log(
                    "[lib:state:StateManager] " ..
                    "dependentParam=" .. dependentParam
                )
            end
            for i = 1, const.counts.encoders do
                local control = "encoder" .. i
                local controlParam = self[control].param.next
                if controlParam == dependentParam then
                    self[control].hostValue.forceUpdate = true
                    if logMe then
                        deb.log(
                            "[lib:state:StateManager] " ..
                            "forcing update of **" .. control .. "**"
                        )
                    end
                end
            end
            for i = 1, const.counts.buttons do
                local control = "button" .. i
                local controlParam = self[control].param.next
                if controlParam == dependentParam then
                    self[control].hostValue.forceUpdate = true
                    if logMe then
                        deb.log(
                            "[lib:state:StateManager] " ..
                            "forcing update of **" .. control .. "**"
                        )
                    end
                end
            end
        end
    end
end

function StateManager:set(path, next)
    -- TODO: set forceUpdate flag on dependent items
    local item, parent = tbl.getValueFromPath(self, path)
    if item == nil then
        return
    end
    self:updateHostValues(path, next, parent)
    self:updateDependencies(path, parent)
    item.next = next
end

function StateManager:inc(path)
    local item, parent = tbl.getValueFromPath(self, path)
    if item == nil then
        return
    end
    local next = item.current + 1
    if next > 127 then
        next = 127
    end
    self:updateHostValues(path, next, parent)
    item.next = next
end

function StateManager:dec(path)
    local item, parent = tbl.getValueFromPath(self, path)
    if item == nil then
        return
    end
    local next = item.current - 1
    if next < 0 then
        next = 0
    end
    self:updateHostValues(path, next, parent)
    item.next = next
end

function StateManager:add(path, delta, min, max)
    local item, parent = tbl.getValueFromPath(self, path)
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
    self:updateHostValues(path, next, parent)
    item.next = next
end

function StateManager:flip(path)
    local item, parent = tbl.getValueFromPath(self, path)
    if item == nil then
        return
    end
    if item.current then
        item.next = false
    else
        item.next = true
    end
    self:updateHostValues(path, next, parent)
    return item.next
end

return StateManager

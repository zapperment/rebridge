local const = require "src.config.constants"
local cond = require "src.config.conditionals"
local tbl = require "src.lib.table._"
local str = require "src.lib.string._"
local deb = require "src.lib.debug._"

local StateManager = {}

local function entry(value)
    return {
        current = value,
        next = value,
        forceUpdate = false,
    }
end

function StateManager:new()
    local instance = {
        transport = {
            playing = entry(false),
            recording = entry(false)
        },
        display = entry " ",
        documentName = entry " ",
        targetTrackName = entry " ",
        deviceType = entry " ",
        deviceName = entry " ",
        patchName = entry " ",
        hostValues = {},
        shifted = false,
    }
    for i = 1, const.counts.encoders do
        instance["encoder" .. i] = {
            enabled = entry(false),
            controlSurfaceValue = entry(0),
            param = entry(nil),
            hostValue = entry(nil),
            hostTextValue = entry("")
        }
        instance["encoder" .. i .. "alt"] = {
            enabled = entry(false),
            controlSurfaceValue = entry(0),
            param = entry(nil),
            hostValue = entry(nil),
            hostTextValue = entry("")
        }
    end
    for i = 1, const.counts.faders do
        instance["fader" .. i] = {
            enabled = entry(false),
            controlSurfaceValue = entry(0),
            param = entry(nil),
            hostValue = entry(nil),
            hostTextValue = entry(""),
            status = entry(const.fader.unassigned),
            forceDisplay = false
        }
        instance["fader" .. i .. "alt"] = {
            enabled = entry(false),
            controlSurfaceValue = entry(0),
            param = entry(nil),
            hostValue = entry(nil),
            hostTextValue = entry(""),
            status = entry(const.fader.unassigned),
            forceDisplay = false
        }
    end
    for i = 1, const.counts.buttons do
        instance["button" .. i] = {
            enabled = entry(false),
            controlSurfaceValue = entry(false),
            param = entry(nil),
            hostValue = entry(nil),
            hostTextValue = entry(""),
            type = entry(const.button.toggle),
            forceDisplay = false
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
    item.forceDisplay = false
    return item.current, hasChanged
end

function StateManager:updateAll()
    local control
    for i = 1, const.counts.encoders do
        control = "encoder" .. i
        self:update(control .. ".enabled")
        self:update(control .. ".controlSurfaceValue")
        self:update(control .. ".param")
        self:update(control .. ".hostValue")
        self:update(control .. ".hostTextValue")
        control = "encoder" .. i .. "alt"
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
        self:setForceDisplay(control, false)
        control = "fader" .. i .. "alt"
        self:update(control .. ".enabled")
        self:update(control .. ".controlSurfaceValue")
        self:update(control .. ".param")
        self:update(control .. ".hostValue")
        self:update(control .. ".hostTextValue")
        self:update(control .. ".status")
        self:setForceDisplay(control, false)
    end
    for i = 1, const.counts.buttons do
        control = "button" .. i
        self:update(control .. ".enabled")
        self:update(control .. ".controlSurfaceValue")
        self:update(control .. ".param")
        self:update(control .. ".hostValue")
        self:update(control .. ".hostTextValue")
        self:update(control .. ".type")
        self:setForceDisplay(control, false)
    end
    self:update "transport.playing"
    self:update "transport.recording"
    self:update "display"
    self:update "documentName"
    self:update "targetTrackName"
    self:update "deviceType"
    self:update "deviceName"
    self:update "patchName"
end

function StateManager:get(path)
    local stateItem = tbl.getValueFromPath(self, path)
    if stateItem == nil then
        return nil
    end
    return stateItem.next
end

function StateManager:getHostValue(param)
    return self.hostValues[param]
end

function StateManager:resetHostValues()
    self.hostValues = {}
end

function StateManager:updateHostValues(path, next, parent)
    local logMe = false -- str.startsWith(path, "button1.")
    local isHostValue = str.endsWith(path, ".hostValue")
    local isParam = str.endsWith(path, ".param")
    if (not isHostValue and not isParam) or not parent then
        return
    end
    ---@diagnostic disable: need-check-nil, undefined-field
    local parentHasHostValue = parent.hostValue and parent.hostValue.next ~= nil
    local parentHasParam = parent.param and parent.param.next and parent.param.next ~= ""
    local parentHostValue = parentHasHostValue and parent.hostValue.next or nil
    local parentParam = parentHasParam and parent.param.next or nil
    ---@diagnostic enable: need-check-nil, undefined-field
    if logMe and isParam then
        deb.log(
            "[lib:state:StateManager:updateHostValues] " ..
            "received param **" .. str.serialise(next) .. "** " ..
            "(" .. type(next) .. ")"
        )
    end
    if logMe and isHostValue then
        deb.log(
            "[lib:state:StateManager:updateHostValues] " ..
            "received host value **" .. str.serialise(next) .. "** " ..
            "(" .. type(next) .. ")"
        )
    end
    if logMe then
        deb.log(
            "[lib:state:StateManager:updateHostValues] " ..
            "parentHasHostValue=" .. str.serialise(parentHasHostValue) .. "; " ..
            "parentHostValue=" .. str.serialise(parentHostValue) .. "; " ..
            "parentHasParam=" .. str.serialise(parentHasParam) .. "; " ..
            "parentParam=" .. str.serialise(parentParam)
        )
    end
    local hostValue
    -- cannot use Lua "pseudo ternary" here (hostValue = isHostValue and next or parentParam)
    -- because this will produce nil if next is boolean false (switched off toggle)
    if isHostValue then
        hostValue = next
    else
        hostValue = parentHostValue
    end
    local param = isParam and next or parentParam
    if (isHostValue and parentHasParam) or (isParam and parentHasHostValue) then
        self.hostValues[param] = hostValue
        if logMe then
            deb.log("[lib:state:StateManager:updateHostValues] (/) storing host value: " ..
                param .. "=" .. str.serialise(hostValue))
        end
        self:updateDependencies(param)
    end
end

function StateManager:updateDependencies(param)
    local logMe = false -- param == "LFO Sync Enable"
    local deviceType = self:get "deviceType"
    if logMe then
        deb.log(
            "[lib:state:StateManager] " ..
            "deviceType=" .. deviceType
        )
    end
    local conditionalsForDevice = cond[deviceType]
    if not conditionalsForDevice then
        if logMe then
            deb.log(
                "[lib:state:StateManager] " ..
                "no conditionals for device type " .. deviceType
            )
        end
        return
    end
    for dependentParam, conditionalConfig in pairs(conditionalsForDevice) do
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
    local item, parent = tbl.getValueFromPath(self, path)
    if item == nil then
        return
    end
    self:updateHostValues(path, next, parent)
    self:updateDependencies(path)
    item.next = next
    return next
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
    self:updateDependencies(path)
    item.next = next
    return next
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
    self:updateDependencies(path)
    item.next = next
    return next
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
    self:updateDependencies(path)
    item.next = next
    return next
end

function StateManager:flip(path)
    local logMe = false -- str.startsWith(path, "button1.")
    local item, parent = tbl.getValueFromPath(self, path)
    if logMe then
        deb.log(
            "[lib:state:StateManager:flip] " ..
            "item=" .. str.serialise(item)
        )
        deb.log(
            "[lib:state:StateManager:flip] " ..
            "parent=" .. str.serialise(parent)
        )
    end
    if item == nil then
        return
    end
    if item.current then
        item.next = false
    else
        item.next = true
    end
    self:updateHostValues(path, item.next, parent)
    self:updateDependencies(path)
    return item.next
end

function StateManager:shift()
    self.shifted = true
end

function StateManager:unshift()
    self.shifted = false
end

function StateManager:setShifted(shifted)
    if type(shifted) ~= "boolean" then
        return
    end
    self.shifted = shifted
end

function StateManager:isShifted()
    return self.shifted;
end

function StateManager:forceDisplay(control)
    self:setForceDisplay(control, true)
end

function StateManager:setForceDisplay(control, forceDisplay)
    local logMe = false
    local item = self[control] -- ohoho - BAMM! - ohoho
    if item == nil then
        if logMe then
            deb.log(
                "[lib.state.StateManager:setForceDisplay] " ..
                "no item for " .. control .. ", not setting forceDisplay!"
            )
        end
        return
    end
    item.forceDisplay = forceDisplay
end

function StateManager:isDisplayForced(control)
    local logMe = false
    local item = self[control]
    if item == nil then
        if logMe then
            deb.log(
                "[lib.state.StateManager:isDisplayForced] " ..
                "no item for " .. control .. ", display not forced!"
            )
        end
        return false
    end
    local forceDisplay = item.forceDisplay
    item.forceDisplay = false
    return forceDisplay
end

function StateManager:canForceDisplay(control)
    return self[control].forceDisplay ~= nil
end

return StateManager

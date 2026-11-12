local items = require "src.lppcommon.config.items"
local const = require "src.lppcommon.config.constants"
local deb = require "src.lib.debug._"
local makeProcessSurface = require "src.lppcommon.remote.processMidi.surface"
local setTransport = require "src.lppcommon.remote.setState.transport"
local setLaunchnik = require "src.lppcommon.remote.setState.launchnik"
local makeDeliverSurface = require "src.lppcommon.remote.deliverMidi.surface"
local makePadsOff = require "src.lppcommon.remote.deliverMidi.padsOff"

-- makes the remote codec for the Launchpad Pro or Launchpad Pro [MK3] given
-- (see src/lppmk3/device.lua): the functions Reason calls, for the codec's
-- entry file to hand on
return function(device)
  local processSurface = makeProcessSurface(device)
  local deliverSurface = makeDeliverSurface(device)
  local padsOff = makePadsOff(device)

  local codec = {}

  function codec.init()
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
    if _ENV ~= "test" then
      deb.log(
        "[reason.codecs.novation." .. device.id .. "] " ..
        device.name .. " " ..
        "remote codec version " .. device.const.softwareVersion .. " " ..
        "initialised successfully!"
      )
    end
  end

  -- Remote surface (Launchpad) -> remote codec -> host (Reason)
  function codec.processMidi(event)
    return processSurface(event)
  end

  -- Host (Reason) -> remote codec
  function codec.setState(changedItems)
    setTransport(changedItems)
    setLaunchnik.setState(changedItems)
  end

  -- Remote codec -> remote surface (Launchpad)
  function codec.deliverMidi(_, port)
    if port == const.ports.log then
      return deb.dump()
    end
    return deliverSurface(port)
  end

  function codec.prepareForUse()
    local events = device.prepareForUse()
    -- clear the pads the last session left lit
    for _, event in ipairs(padsOff()) do
      table.insert(events, event)
    end
    return events
  end

  function codec.releaseFromUse()
    return device.releaseFromUse()
  end

  return codec
end

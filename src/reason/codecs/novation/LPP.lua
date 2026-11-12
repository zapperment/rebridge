local makeCodec = require "src.lppcommon.codec"
local device = require "src.lpp.device"

local codec = makeCodec(device)

---@diagnostic disable-next-line: lowercase-global
function remote_init()
  codec.init()
end

-- Remote surface (Launchpad) -> remote codec -> host (Reason)
---@diagnostic disable-next-line: lowercase-global
function remote_process_midi(event)
  return codec.processMidi(event)
end

-- Host (Reason) -> remote codec
---@diagnostic disable-next-line: lowercase-global
function remote_set_state(changedItems)
  codec.setState(changedItems)
end

-- Remote codec -> remote surface (Launchpad)
---@diagnostic disable-next-line: lowercase-global
function remote_deliver_midi(maxBytes, port)
  return codec.deliverMidi(maxBytes, port)
end

---@diagnostic disable-next-line: lowercase-global
function remote_prepare_for_use()
  return codec.prepareForUse()
end

---@diagnostic disable-next-line: lowercase-global
function remote_release_from_use()
  return codec.releaseFromUse()
end

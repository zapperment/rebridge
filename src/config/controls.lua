local const = require "src.config.constants"

local encoders = {}
for i = 1, const.counts.encoders do
  table.insert(encoders, "encoder" .. i)
  table.insert(encoders, "encoder" .. i .. "alt")
  table.insert(encoders, "encoder" .. i .. "alt2")
  table.insert(encoders, "encoder" .. i .. "alt3")
end

local faders = {}
for i = 1, const.counts.faders do
  table.insert(faders, "fader" .. i)
  table.insert(faders, "fader" .. i .. "alt")
end

local buttons = {}
for i = 1, const.counts.buttons do
  table.insert(buttons, "button" .. i)
end

local rackUIs = {}
for i = 1, const.counts.rackUIs do
  table.insert(rackUIs, "rackUI" .. i)
end

local all = {}
for _, group in ipairs { encoders, faders, buttons, rackUIs } do
  for _, name in ipairs(group) do
    table.insert(all, name)
  end
end

return {
  encoders = encoders,
  faders = faders,
  buttons = buttons,
  rackUIs = rackUIs,
  all = all
}

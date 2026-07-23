-- System exclusive messages
--
-- 7f 7f 7f 7f {type} {cc} {val} f7
-- {type}
--   01: Control change from Reason rack UI or automation
--       -> Update Max for Live device UI
--   02: Control change from MIDI controller
--       -> Update Reason rack UI
--   03: Control change from Max for Live device UI or automation
--       -> Update Reason rack UI
--       -> Update MIDI controller UI
-- {cc} MIDI CC controller number
-- {val} MIDI CC controller value (0-127)
--
Items = {
  keyboard = { input = "keyboard" },
  pitchBendWheel = { input = "value", min = 0, max = 16383 },
  channelPressure = { input = "value", min = 0, max = 127 },
  modulationWheel = { input = "value", min = 0, max = 127 },
  breath = { input = "value", min = 0, max = 127 },
  expressionPedal = { input = "value", min = 0, max = 127 },
  sustainPedal = { input = "value", min = 0, max = 127 },
  footSwitch = { input = "button", min = 0, max = 127 },
  targetPrevTrack = { input = "button", midiMatcher = "f0 7f 7f 7f xx 69 yy f7", controller = 105, min = 0, max = 127 },
  targetNextTrack = { input = "button", midiMatcher = "f0 7f 7f 7f xx 6a yy f7", controller = 106, min = 0, max = 127 },
  selectPrevPatch = { input = "button", midiMatcher = "f0 7f 7f 7f xx 6b yy f7", controller = 107, min = 0, max = 127 },
  selectNextPatch = { input = "button", midiMatcher = "f0 7f 7f 7f xx 6c yy f7", controller = 108, min = 0, max = 127 },
  controlA1 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 04 yy f7", controller = 4, min = 0, max = 127 },
  controlA2 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 05 yy f7", controller = 5, min = 0, max = 127 },
  controlA3 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 07 yy f7", controller = 7, min = 0, max = 127 },
  controlA4 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 08 yy f7", controller = 8, min = 0, max = 127 },
  controlA5 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 0a yy f7", controller = 10, min = 0, max = 127 },
  controlA6 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 0c yy f7", controller = 12, min = 0, max = 127 },
  controlA7 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 0d yy f7", controller = 13, min = 0, max = 127 },
  controlA8 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 0e yy f7", controller = 14, min = 0, max = 127 },
  controlB1 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 17 yy f7", controller = 23, min = 0, max = 127 },
  controlB2 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 18 yy f7", controller = 24, min = 0, max = 127 },
  controlB3 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 19 yy f7", controller = 25, min = 0, max = 127 },
  controlB4 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 1a yy f7", controller = 26, min = 0, max = 127 },
  controlB5 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 1b yy f7", controller = 27, min = 0, max = 127 },
  controlB6 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 1c yy f7", controller = 28, min = 0, max = 127 },
  controlB7 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 1d yy f7", controller = 29, min = 0, max = 127 },
  controlB8 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 1e yy f7", controller = 30, min = 0, max = 127 },
  controlC1 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 29 yy f7", controller = 41, min = 0, max = 127 },
  controlC2 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 2a yy f7", controller = 42, min = 0, max = 127 },
  controlC3 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 2b yy f7", controller = 43, min = 0, max = 127 },
  controlC4 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 2c yy f7", controller = 44, min = 0, max = 127 },
  controlC5 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 2d yy f7", controller = 45, min = 0, max = 127 },
  controlC6 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 2e yy f7", controller = 46, min = 0, max = 127 },
  controlC7 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 2f yy f7", controller = 47, min = 0, max = 127 },
  controlC8 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 30 yy f7", controller = 48, min = 0, max = 127 },
  controlD1 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 39 yy f7", controller = 57, min = 0, max = 127 },
  controlD2 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 3a yy f7", controller = 58, min = 0, max = 127 },
  controlD3 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 3b yy f7", controller = 59, min = 0, max = 127 },
  controlD4 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 3c yy f7", controller = 60, min = 0, max = 127 },
  controlD5 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 3d yy f7", controller = 61, min = 0, max = 127 },
  controlD6 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 3e yy f7", controller = 62, min = 0, max = 127 },
  controlD7 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 41 yy f7", controller = 65, min = 0, max = 127 },
  controlD8 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 42 yy f7", controller = 66, min = 0, max = 127 },
  controlE1 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 4a yy f7", controller = 74, min = 0, max = 127 },
  controlE2 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 4b yy f7", controller = 75, min = 0, max = 127 },
  controlE3 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 4c yy f7", controller = 76, min = 0, max = 127 },
  controlE4 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 4d yy f7", controller = 77, min = 0, max = 127 },
  controlE5 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 4e yy f7", controller = 78, min = 0, max = 127 },
  controlE6 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 4f yy f7", controller = 79, min = 0, max = 127 },
  controlE7 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 50 yy f7", controller = 80, min = 0, max = 127 },
  controlE8 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 51 yy f7", controller = 81, min = 0, max = 127 },
  controlF1 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 5a yy f7", controller = 90, min = 0, max = 127 },
  controlF2 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 5b yy f7", controller = 91, min = 0, max = 127 },
  controlF3 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 5c yy f7", controller = 92, min = 0, max = 127 },
  controlF4 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 5d yy f7", controller = 93, min = 0, max = 127 },
  controlF5 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 5e yy f7", controller = 94, min = 0, max = 127 },
  controlF6 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 5f yy f7", controller = 95, min = 0, max = 127 },
  controlF7 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 66 yy f7", controller = 102, min = 0, max = 127 },
  controlF8 = { input = "value", output = "value", midiMatcher = "f0 7f 7f 7f xx 67 yy f7", controller = 103, min = 0, max = 127 },
}

function remote_init()
  local itemsToDefine = {}
  for name, item in pairs(Items) do
    table.insert(itemsToDefine, {
      name = name,
      input = item.input,
      output = item.output,
      min = item.min,
      max = item.max
    })
    item.index = #itemsToDefine
    item.lastInputTime = 0
    item.dispatchToLaunchControl = false
    item.dispatchToLive = false
  end
  remote.define_items(itemsToDefine)
  remote.define_auto_inputs({
    { name = "keyboard",        pattern = "<100x>? yy zz" },
    { name = "pitchBendWheel",  pattern = "e? xx yy",     value = "y*128 + x" },
    { name = "channelPressure", pattern = "d? xx ??" },
    { name = "modulationWheel", pattern = "b? 01 xx" },
    { name = "breath",          pattern = "b? 02 xx" },
    { name = "expressionPedal", pattern = "b? 0B xx" },
    { name = "sustainPedal",    pattern = "b? 40 xx" },
    { name = "footSwitch",      pattern = "b? 44 xx" },
  })
end

-- Live -> Remote
function remote_process_midi(event)
  local processed = false
  for _, item in pairs(Items) do
    if item.midiMatcher ~= nil then
      local match = remote.match_midi(item.midiMatcher, event)
      if match ~= nil then
        item.lastInputTime = remote.get_time_ms()
        item.dispatchToLive = false
        if match.x == 1 then
          item.dispatchToLaunchControl = false
        end
        if match.x == 2 then
          item.dispatchToLaunchControl = true
        end
        -- Remote -> Reason
        remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = match.y })
        processed = true
      end
    end
  end
  return processed
end

-- Reason -> Remote
function remote_set_state(changed_items)
  local now = remote.get_time_ms()
  for _, item in pairs(Items) do
    for _, changedItemIndex in ipairs(changed_items) do
      if item.index == changedItemIndex and now - item.lastInputTime > 100 then
        item.dispatchToLive = true
        item.dispatchToLaunchControl = true
      end
    end
  end
end

-- Remote -> LaunchControl (port=1)
-- Remote -> Live (port=2)
function remote_deliver_midi(max_bytes, port)
  local events = {}
  for _, item in pairs(Items) do
    if port == 1 and item.dispatchToLaunchControl then
      table.insert(events, remote.make_midi("b0 xx yy", { x = item.controller, y = remote.get_item_value(item.index) }))
      item.dispatchToLaunchControl = false
    end
    if port == 2 and item.dispatchToLive then
      table.insert(events,
        remote.make_midi("f0 7f 7f 7f 7f 00 xx yy f7", { x = item.controller, y = remote.get_item_value(item.index) }))
      item.dispatchToLive = false
    end
  end
  return events
end

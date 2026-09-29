local const = require "src.lppmk3.config.constants"

-- the number of buttons of the switch meter to light at the given song
-- position: one for the step playback is in, plus one for every step of the
-- current switch interval before it
return function(songPosition, interval)
  local steps = const.counts.switchMeterButtons
  return math.floor((songPosition % interval) * steps / interval) + 1
end

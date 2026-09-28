local const = require "src.lppmk3.config.constants"

-- the switch interval in song position units for the given value of
-- LaunchEon's Pattern Timer, or nil if the timer is off
return function(patternTimer)
  local bars = const.switchIntervalBars[patternTimer]
  if not bars then
    return nil
  end
  return bars * const.songPositionPerBar
end

-- whether playback moving from the previous to the current song position has
-- reached a switch point: moving forward across a line of the switch
-- interval's grid, or jumping backwards exactly onto one (as at the end of
-- Reason's loop); a jump backwards onto any other position is not a switch
-- point, just like with LaunchEon itself
return function(previous, current, interval)
  if current > previous then
    return math.floor(current / interval) > math.floor(previous / interval)
  end
  if current < previous then
    return current % interval == 0
  end
  return false
end

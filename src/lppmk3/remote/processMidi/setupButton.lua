local const = require "src.lppmk3.config.constants"
local launchnik = require "src.lppmk3.lib.launchnik._"
local processLaunchnik = require "src.lppmk3.remote.processMidi.launchnik"

-- the surface reports its layout whenever it changes
local layoutReportMidi = "f0 00 20 29 02 0e 00 xx yy 00 f7"
local programmerLayout = 17

-- handles the Setup button of the surface, which stands for the setup button
-- of Launchnik; the button sends nothing of its own, but releasing it makes
-- the surface report the programmer layout on its DAW port; the surface sends
-- the same report when the codec switches it to programmer mode, so a report
-- that follows that switch closely is not a press
return function(event)
  local report = remote.match_midi(layoutReportMidi, event)
  if not report then
    return false
  end
  local state = launchnik.state
  local answersPrepare = state.preparedAt ~= nil
      and remote.get_time_ms() - state.preparedAt < const.setupButtonQuietTime
  if report.x == programmerLayout and not answersPrepare then
    processLaunchnik.write(event, launchnik.press.setupButton(state.setup))
  end
  return true
end

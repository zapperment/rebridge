local lu = require "test.lib._".luaUnit

_ENV = "test"

-- shared
require "test.TestMockFunction"
require "test.TestRemoteMaps"
require "test.TestStringUtils"
require "test.TestTableUtils"

-- Launch Control XL 3
require "test.lcxl3.TestCombinatorLabels"
require "test.lcxl3.TestConditionalColours"
require "test.lcxl3.TestControls"
require "test.lcxl3.TestDeliverButtons"
require "test.lcxl3.TestDeliverEncoders"
require "test.lcxl3.TestDeliverFaders"
require "test.lcxl3.TestDeliverPages"
require "test.lcxl3.TestDeliverSelection"
require "test.lcxl3.TestDisplayNames"
require "test.lcxl3.TestFaderPickup"
require "test.lcxl3.TestParamColours"
require "test.lcxl3.TestProcessButtons"
require "test.lcxl3.TestProcessNavigation"
require "test.lcxl3.TestProcessSelection"
require "test.lcxl3.TestSetStateButtons"
require "test.lcxl3.TestSetStatePages"
require "test.lcxl3.TestSetStateSelection"
require "test.lcxl3.TestRemoteInit"
require "test.lcxl3.TestShouldDisplay"
require "test.lcxl3.TestStateManagement"

-- the Launchpads
require "test.lpcommon.TestPress"
require "test.lpcommon.TestMakeChannelColourEvent"
require "test.lpcommon.TestShiftLayer"
require "test.lpcommon.TestStateShift"
for _, entry in ipairs(require "test.lpcommon.devices") do
  for _, name in ipairs({ "TestCodec", "TestLaunchnikLights", "TestPadsOff", "TestProcessLaunchnik", "TestProcessShift", "TestSurfaceInput", "TestSurfacePorts", "TestTransport" }) do
    require("test.lpcommon." .. name)(entry.device, entry.suffix)
  end
end

-- Launchpad Pro [MK3]
require "test.lppmk3.TestProcessSetupButton"

-- Launchpad Pro
require "test.lpp.TestDevice"
require "test.lpp.TestFunctionSelect"
require "test.lpp.TestMakeColourEvent"
require "test.lpp.TestProcessSetupButton"

-- Launchpad Mini [MK3] and Launchpad X
for _, entry in ipairs(require "test.lpcommon.sixteenButtonDevices") do
  require "test.lpcommon.TestSixteenButtonDevice"(entry.device, entry.suffix, entry.sysexHeader)
  require "test.lpcommon.TestSixteenButtonShiftLayer"(entry.device, entry.suffix)
end

-- Launchpad Mini, which has the same controls as those two
require "test.lpcommon.TestSixteenButtonShiftLayer"(require "src.lpm.device", "LPM")
require "test.lpm.TestAddress"
require "test.lpm.TestLedColour"
require "test.lpm.TestMakeColourEvent"
require "test.lpm.TestDevice"

-- Launchpad MK2, which has them too
require "test.lpcommon.TestSixteenButtonShiftLayer"(require "src.lpmk2.device", "LPMK2")
require "test.lpmk2.TestAddress"
require "test.lpmk2.TestMakeColourEvent"
require "test.lpmk2.TestDevice"

os.exit(lu.LuaUnit.run())

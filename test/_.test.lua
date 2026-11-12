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

-- Launchpad Pro and Launchpad Pro [MK3]
require "test.lppcommon.TestPress"
require "test.lppcommon.TestStateShift"
for _, entry in ipairs(require "test.lppcommon.devices") do
  for _, name in ipairs({ "TestCodec", "TestLaunchnikLights", "TestPadsOff", "TestProcessLaunchnik", "TestProcessShift", "TestSurfacePorts", "TestTransport" }) do
    require("test.lppcommon." .. name)(entry.device, entry.suffix)
  end
end

-- Launchpad Pro [MK3]
require "test.lppmk3.TestMakeColourEvent"
require "test.lppmk3.TestProcessSetupButton"

-- Launchpad Pro
require "test.lpp.TestDevice"
require "test.lpp.TestFunctionSelect"
require "test.lpp.TestMakeColourEvent"
require "test.lpp.TestProcessSetupButton"

os.exit(lu.LuaUnit.run())

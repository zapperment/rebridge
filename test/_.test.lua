local lu = require "test.lib._".luaUnit

_ENV = "test"

-- shared
require "test.TestMockFunction"
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

-- Launchpad Pro [MK3]
require "test.lppmk3.TestDeliverPadColours"
require "test.lppmk3.TestMakeColourEvent"

os.exit(lu.LuaUnit.run())

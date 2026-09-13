local lu = require "test.lib._".luaUnit

_ENV = "test"

require "test.TestCombinatorLabels"
require "test.TestConditionalColours"
require "test.TestControls"
require "test.TestDeliverButtons"
require "test.TestDeliverEncoders"
require "test.TestDeliverFaders"
require "test.TestDeliverPages"
require "test.TestDeliverSelection"
require "test.TestFaderPickup"
require "test.TestMockFunction"
require "test.TestParamColours"
require "test.TestProcessButtons"
require "test.TestProcessNavigation"
require "test.TestProcessSelection"
require "test.TestSetStateButtons"
require "test.TestSetStatePages"
require "test.TestSetStateSelection"
require "test.TestRemoteInit"
require "test.TestShouldDisplay"
require "test.TestStateManagement"
require "test.TestStringUtils"
require "test.TestTableUtils"

os.exit(lu.LuaUnit.run())

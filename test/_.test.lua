local lu = require("test.lib._").luaUnit

require("test.TestDeliverButtons")
require("test.TestDeliverEncoders")
require("test.TestDeliverFaders")
require("test.TestDeliverPages")
require("test.TestMockFunction")
require("test.TestParamColours")
require("test.TestProcessButtons")
require("test.TestProcessNavigation")
require("test.TestSetStatePages")
require("test.TestRemoteInit")
require("test.TestStateManagement")
require("test.TestStringUtils")

os.exit(lu.LuaUnit.run())

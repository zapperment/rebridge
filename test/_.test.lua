local lu = require("test.lib._").luaUnit

require("test.TestDeliverButtons")
require("test.TestDeliverEncoders")
require("test.TestDeliverFaders")
require("test.TestMockFunction")
require("test.TestProcessButtons")
require("test.TestProcessNavigation")
require("test.TestRemoteInit")
require("test.TestStateManagement")
require("test.TestStringUtils")

os.exit(lu.LuaUnit.run())

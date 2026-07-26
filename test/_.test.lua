local lu = require("test.lib._").luaUnit

require("test.TestMockFunction")
require("test.TestRemoteInit")
require("test.TestStateManagement")
require("test.TestStringUtils")

os.exit(lu.LuaUnit.run())

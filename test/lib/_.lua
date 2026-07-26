-- creates a global variable "remote" that mimicks the one that the Remote host provides
require("test.lib.mockRemote")

return {
    luaUnit = require("test.lib.luaUnit"),
    MockFunction = require("test.lib.MockFunction"),
    resetState = require("test.lib.resetState")
}

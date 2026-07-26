-- Mocks the remote host, i.e. Reason
local items = require("src.config.items")

local MockHost = {}

function MockHost:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    return instance
end

-- Simulates Reason starting up with a single Combinator device loaded;
-- the indices of all the remote items that are mapped are passed to 
-- remote_set_state
function MockHost:startup()
    local changedItems = {items.buttonLayerA.index, items.buttonLayerB.index}
    remote.mock("get_item_state"):fake({items.buttonLayerA.index},{value=1})
    remote.mock("get_item_state"):fake({items.buttonLayerB.index},{value=0})
    remote_set_state(changedItems)
end

return MockHost

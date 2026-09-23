local lu = require "test.lib._".luaUnit
local tbl = require "src.lib.table._"

TestTableUtils = {}

function TestTableUtils:testGetValueFromPath01()
    local value, parent = tbl.getValueFromPath({ a = { b = { c = "C" } } }, "a.b.c")
    lu.assertEquals(value, "C", "Leaf value of a deep path not found")
    lu.assertEquals(parent, { c = "C" }, "Parent of a deep path is not the table containing the leaf")
end

function TestTableUtils:testGetValueFromPath02()
    local value, parent = tbl.getValueFromPath({ a = { b = { c = "C" } } }, "a.b")
    lu.assertEquals(value, { c = "C" }, "Intermediate value not found")
    lu.assertEquals(parent, { b = { c = "C" } }, "Parent of an intermediate value is wrong")
end

function TestTableUtils:testGetValueFromPath03()
    local value, parent = tbl.getValueFromPath({ a = "A" }, "a")
    lu.assertEquals(value, "A", "Top level value not found")
    lu.assertEquals(parent, nil, "A top level value should not report the table itself as parent")
end

function TestTableUtils:testGetValueFromPath04()
    local value, parent = tbl.getValueFromPath({ a = { b = "B" } }, "a.x")
    lu.assertEquals(value, nil, "A missing leaf should not yield a value")
    lu.assertEquals(parent, { b = "B" }, "A missing leaf should still report its existing parent")
end

function TestTableUtils:testGetValueFromPath05()
    local value, parent = tbl.getValueFromPath({ a = { b = "B" } }, "x")
    lu.assertEquals(value, nil, "A missing top level token should not yield a value")
    lu.assertEquals(parent, nil, "A missing top level token should not report a parent")
end

function TestTableUtils:testGetValueFromPath06()
    local value, parent = tbl.getValueFromPath({ a = { b = "B" } }, "x.y.z")
    lu.assertEquals(value, nil, "A missing intermediate token should not yield a value")
    lu.assertEquals(parent, nil, "A missing intermediate token should not report a parent")
end

function TestTableUtils:testGetValueFromPath07()
    local value, parent = tbl.getValueFromPath({ a = { b = "B" } }, "a.b.c")
    lu.assertEquals(value, nil, "Descending into a non table value should not yield a value")
    lu.assertEquals(parent, nil, "Descending into a non table value should not report a parent")
end

function TestTableUtils:testGetValueFromPath08()
    local value, parent = tbl.getValueFromPath({ a = { b = false } }, "a.b")
    lu.assertEquals(value, false, "A false value should be returned rather than treated as missing")
    lu.assertEquals(parent, { b = false }, "A false value should still report its parent")
end

function TestTableUtils:testGetValueFromPath09()
    local value, parent = tbl.getValueFromPath({ a = { b = { c = "C" } } }, "a.b.c.d")
    lu.assertEquals(value, nil, "A path reaching past a leaf should not yield a value")
    lu.assertEquals(parent, nil, "A path reaching past a leaf should not report a parent")
end

function TestTableUtils:testGetValueFromPath10()
    local value, parent = tbl.getValueFromPath({ a = { b = { c = "C" } } }, "a.b.c.")
    lu.assertEquals(value, nil, "A path with an empty string as last token should not yield a value")
    lu.assertEquals(parent, nil, "A path with an empty string as last token should not report a parent")
end

function TestTableUtils:testMerge01()
    local result = tbl.merge({ a = "A" }, { b = "B" })
    lu.assertEquals(result, { a = "A", b = "B" }, "Entries with distinct keys from both tables should be kept")
end

function TestTableUtils:testMerge02()
    local result = tbl.merge({ a = "A1", b = "B" }, { a = "A2" })
    lu.assertEquals(result, { a = "A2", b = "B" }, "An entry in the second table should overwrite one with the same key in the first")
end

function TestTableUtils:testMerge03()
    local result = tbl.merge({ "x", "y" }, { "z" })
    lu.assertEquals(result, { "z", "y" }, "Numeric keys should be merged by key rather than appended")
end

function TestTableUtils:testMerge04()
    local a = { a = "A" }
    local b = { b = "B" }
    local result = tbl.merge(a, b)
    lu.assertEquals(a, { a = "A" }, "The first table should not be modified")
    lu.assertEquals(b, { b = "B" }, "The second table should not be modified")
    lu.assertNotIs(result, a, "The result should be a new table")
end

function TestTableUtils:testMerge05()
    local result = tbl.merge({ a = "A" }, {})
    lu.assertEquals(result, { a = "A" }, "Merging with an empty table should yield a copy of the first table")
end

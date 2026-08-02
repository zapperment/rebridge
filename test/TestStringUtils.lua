local lu = require("test.lib._").luaUnit
local string = require("src.lib.string._")

TestStringUtils = {}

function TestStringUtils:testSerialise01()
    local result = string.serialise("foo")
    local errorMessage = "Serialisation of string failed"
    lu.assertEquals(result, "\"foo\"", errorMessage)
end

function TestStringUtils:testSerialise02()
    local result = string.serialise(666)
    local errorMessage = "Serialisation of number failed"
    lu.assertEquals(result, "666", errorMessage)
end

function TestStringUtils:testSerialise03()
    local result = string.serialise(false)
    local errorMessage = "Serialisation of boolean false failed"
    lu.assertEquals(result, "false", errorMessage)
end

function TestStringUtils:testSerialise04()
    local result = string.serialise(true)
    local errorMessage = "Serialisation of boolean true failed"
    lu.assertEquals(result, "true", errorMessage)
end

function TestStringUtils:testSerialise05()
    local result = string.serialise()
    local errorMessage = "Serialisation without argument failed"
    lu.assertEquals(result, "nil", errorMessage)
end

function TestStringUtils:testSerialise06()
    local result = string.serialise(nil)
    local errorMessage = "Serialisation of nil failed"
    lu.assertEquals(result, "nil", errorMessage)
end

function TestStringUtils:testSerialise07()
    local result = string.serialise({})
    local errorMessage = "Serialisation of empty table failed"
    lu.assertEquals(result, "{}", errorMessage)
end

function TestStringUtils:testSerialise08()
    local result = string.serialise({ 1, 2, 3 })
    local errorMessage = "Serialisation of list of numbers failed"
    lu.assertEquals(result, "{[1]=1,[2]=2,[3]=3}", errorMessage)
end

function TestStringUtils:testSerialise09()
    local result = string.serialise({ "foo", "bar", "baz" })
    local errorMessage = "Serialisation of list of strings failed"
    lu.assertEquals(result, "{[1]=\"foo\",[2]=\"bar\",[3]=\"baz\"}", errorMessage)
end

function TestStringUtils:testSerialise10()
    local result = string.serialise({
        foo = 1,
        bar = 2,
        baz = 3
    })
    local errorMessage = "Serialisation of simple key-value table failed"
    lu.assertEquals(result, "{[\"baz\"]=3,[\"bar\"]=2,[\"foo\"]=1}", errorMessage)
end

function TestStringUtils:testSerialise11()
    local result = string.serialise({
        foo = {
            bar = "baz"
        }
    })
    local errorMessage = "Serialisation of nested key-value table failed"
    lu.assertEquals(result, "{[\"foo\"]={[\"bar\"]=\"baz\"}}", errorMessage)
end

function TestStringUtils:testSerialise12()
    local Foo = {}
    function Foo:new()
        local instance = {
            calls = {},
            fakes = {}
        }
        setmetatable(instance, self)
        self.__index = self
        return instance
    end

    function Foo:bar(...)
        return string.serialise(...)
    end

    local foo = Foo:new()
    local result = foo:bar({
        foo = {
            bar = "baz"
        }
    })
    local errorMessage = "Serialisation of nested key-value table in class method failed"
    lu.assertEquals(result, "{[\"foo\"]={[\"bar\"]=\"baz\"}}", errorMessage)
end

function TestStringUtils:testAreStringsSimilar01()
    local result = string.areStringsSimilar("", "")
    local errorMessage = "Two empty strings should be similar"
    lu.assertEquals(result, true, errorMessage)
end

function TestStringUtils:testAreStringsSimilar02()
    local result = string.areStringsSimilar("foo", "foo")
    local errorMessage = "Identical strings of odd length should be similar"
    lu.assertEquals(result, true, errorMessage)
end

function TestStringUtils:testAreStringsSimilar03()
    local result = string.areStringsSimilar("food", "food")
    local errorMessage = "Identical strings of even length should be similar"
    lu.assertEquals(result, true, errorMessage)
end

function TestStringUtils:testAreStringsSimilar04()
    local result = string.areStringsSimilar("hans", "wurst")
    local errorMessage = "Completely different strings should not be similar"
    lu.assertEquals(result, false, errorMessage)
end

function TestStringUtils:testAreStringsSimilar05()
    local result = string.areStringsSimilar(
        "control surface fader1 send value 89 (89) for param Schubidu",
        "control surface fader1 send value 90 (90) for param Schubidu"
    )
    local errorMessage = "Log messages differing only in the value should be similar"
    lu.assertEquals(result, true, errorMessage)
end

function TestStringUtils:testAreStringsSimilar06()
    local result = string.areStringsSimilar(
        "control surface fader1 send value 89 (89) for param Schubidu",
        "control surface encoder3 send value 89 (89) for param Schubidu"
    )
    local errorMessage = "In a long log message, a differing control name is still within the threshold"
    lu.assertEquals(result, true, errorMessage)
end

function TestStringUtils:testAreStringsSimilar06b()
    local result = string.areStringsSimilar(
        "control surface fader1 send value 89 (89) for param Schubidu",
        "control surface button2 pressed"
    )
    local errorMessage = "Structurally different log messages should not be similar"
    lu.assertEquals(result, false, errorMessage)
end

function TestStringUtils:testAreStringsSimilar07()
    local result = string.areStringsSimilar("hello world", "")
    local errorMessage = "An empty string should not be similar to a non-empty one"
    lu.assertEquals(result, false, errorMessage)
end

-- The two difference percentages are averaged, so a string that is a pure
-- prefix of the other contributes 0% and pulls the average down. "foo" has no
-- part of its own that differs, so only the 50% of "foobar" counts, halved to
-- exactly the threshold.
function TestStringUtils:testAreStringsSimilar08()
    local result = string.areStringsSimilar("foobar", "foo")
    local errorMessage = "A pure prefix is judged only by the longer string's difference"
    lu.assertEquals(result, true, errorMessage)
end

function TestStringUtils:testAreStringsSimilar08b()
    local result = string.areStringsSimilar("foobarbaz", "foo")
    local errorMessage = "A string three times as long should not be similar"
    lu.assertEquals(result, false, errorMessage)
end

function TestStringUtils:testAreStringsSimilar09()
    local result = string.areStringsSimilar("abcdefghijklmnopqrst", "abcdefghijXklmnopqrst")
    local errorMessage = "A single inserted character in a long string should stay similar"
    lu.assertEquals(result, true, errorMessage)
end

function TestStringUtils:testAreStringsSimilar10()
    local result = string.areStringsSimilar("aa", "a")
    local errorMessage = "Overlapping prefix and suffix should not be counted twice"
    lu.assertEquals(result, true, errorMessage)
end

function TestStringUtils:testAreStringsSimilar11()
    local result = string.areStringsSimilar("abab", "baba")
    local errorMessage = "Strings without common prefix or suffix should not be similar"
    lu.assertEquals(result, false, errorMessage)
end

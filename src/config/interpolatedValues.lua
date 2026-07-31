local const = require("src.config.constants")

local bipolar = const.interpolation.bipolar
local reciprocal = const.interpolation.reciprocal

return {
  algoritm = {
    ["Pan 1"] = { min = -100, max = 100, mode = bipolar },
    ["Pan 2"] = { min = -100, max = 100, mode = bipolar },
    ["Pan 3"] = { min = -100, max = 100, mode = bipolar },
    ["Pan 4"] = { min = -100, max = 100, mode = bipolar },
    ["Pan 5"] = { min = -100, max = 100, mode = bipolar },
    ["Pan 6"] = { min = -100, max = 100, mode = bipolar },
    ["Pan 7"] = { min = -100, max = 100, mode = bipolar },
    ["Pan 8"] = { min = -100, max = 100, mode = bipolar },
    ["Pan 9"] = { min = -100, max = 100, mode = bipolar },
    ["Freq 1 Op/Osc"] = { min = 0, max = 64, decimals = 2 },
    ["Freq 2 Op/Osc"] = { min = 0, max = 64, decimals = 2 },
    ["Freq 3 Op/Osc"] = { min = 0, max = 64, decimals = 2 },
    ["Freq 4 Op/Osc"] = { min = 0, max = 64, decimals = 2 },
    ["Freq 5 Op/Osc"] = { min = 0, max = 64, decimals = 2 },
    ["Freq 6 Op/Osc"] = { min = 0, max = 64, decimals = 2 },
    ["Freq 7 Op/Osc"] = { min = 0, max = 64, decimals = 2 },
    ["Freq 8 Op/Osc"] = { min = 0, max = 64, decimals = 2 },
    ["Freq 9 Op/Osc"] = { min = 0, max = 64, decimals = 2 },
    ["Tune 1"] = { min = -50, max = 50, mode = bipolar },
    ["Tune 2"] = { min = -50, max = 50, mode = bipolar },
    ["Tune 3"] = { min = -50, max = 50, mode = bipolar },
    ["Tune 4"] = { min = -50, max = 50, mode = bipolar },
    ["Tune 5"] = { min = -50, max = 50, mode = bipolar },
    ["Tune 6"] = { min = -50, max = 50, mode = bipolar },
    ["Tune 7"] = { min = -50, max = 50, mode = bipolar },
    ["Tune 8"] = { min = -50, max = 50, mode = bipolar },
    ["Tune 9"] = { min = -50, max = 50, mode = bipolar },
    ["Comp Ratio"] = { min = 1, max = 127, mode = reciprocal, decimals = 2, suffix = " : 1" }
  }
}

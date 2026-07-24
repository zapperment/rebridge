local decToHex = require("src.lib.hex.decToHex")

return function(text)
  local hex = ""
  local textLen = string.len(text)
  for i = 1, textLen do
    hex = hex .. decToHex(string.byte(text, i))
    if i ~= textLen then
      hex = hex .. " "
    end
  end
  return hex
end

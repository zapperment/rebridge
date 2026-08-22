-- Strips whitespace from both ends of a string. Reason pads some of the names it
-- reports, so names that are compared or looked up have to be trimmed first.
return function(text)
  if type(text) ~= "string" then
    return text
  end
  return text:match "^%s*(.-)%s*$"
end

local threshold = 0.25;

-- Compares two strings by stripping their common prefix and common suffix.
-- What remains is the part that actually differs; the strings count as similar
-- if that part is small relative to the length of both strings.
return function(msg1, msg2)
  local len1 = string.len(msg1)
  local len2 = string.len(msg2)

  if len1 == 0 and len2 == 0 then
    return true
  end

  -- Prefix and suffix must not overlap, so together they can never be longer
  -- than the shorter of the two strings
  local maxCommon = len1 < len2 and len1 or len2

  local prefix = 0
  while prefix < maxCommon
      and string.byte(msg1, prefix + 1) == string.byte(msg2, prefix + 1) do
    prefix = prefix + 1
  end

  local suffix = 0
  while suffix < maxCommon - prefix
      and string.byte(msg1, len1 - suffix) == string.byte(msg2, len2 - suffix) do
    suffix = suffix + 1
  end

  local diffNumChars1 = len1 - prefix - suffix
  local diffNumChars2 = len2 - prefix - suffix
  local diffNumChars1perc = len1 > 0 and diffNumChars1 / len1 or 0
  local diffNumChars2perc = len2 > 0 and diffNumChars2 / len2 or 0
  local avgDiffNumCharsPerc = (diffNumChars1perc + diffNumChars2perc) / 2

  return avgDiffNumCharsPerc <= threshold
end

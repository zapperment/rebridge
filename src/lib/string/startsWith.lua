return function(haystack, needle)
  return haystack:sub(1, #needle) == needle
end

return function(haystack, needle)
  return haystack:sub(- #needle) == needle
end

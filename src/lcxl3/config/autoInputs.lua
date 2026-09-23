-- The page buttons are not auto inputs: they only browse patches while Shift
-- is held down, so the codec processes them itself (see processMidi/navigation)
return {
  { name = "trackLeftButton",  pattern = "B0 66 ?<???x>", port = 1 },
  { name = "trackRightButton", pattern = "B0 67 ?<???x>", port = 1 }
}

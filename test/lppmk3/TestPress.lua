local test = require "test.lib._"
local lu = test.luaUnit
local press = require "src.lppmk3.lib.launchnik.press"

-- The cases are those of tests/PressTest.cpp in the Launchnik repository: the
-- surface has to change what the device's own panel changes. Tracks count from
-- 1 here and from 0 there.
TestPress = {}

local launchMode = press.setupLaunchMode
local clipPicking = press.setupClipPicking
local editing = press.setupFirstClipEditing + press.buttonIndex(4, 6)
local picked = press.buttonIndex(4, 6)
local fillInEditing = press.setupFirstFillInEditing + press.buttonIndex(4, 6)
local landingEditing = press.setupFirstLandingEditing + press.buttonIndex(4, 6)

function TestPress:testButtonIndexCountsDownTrackOneFirst()
  lu.assertEquals(press.buttonIndex(1, 1), 0)
  lu.assertEquals(press.buttonIndex(1, 8), 7)
  lu.assertEquals(press.buttonIndex(2, 1), 8)
  lu.assertEquals(press.buttonIndex(8, 8), 63)
end

function TestPress:testLaunchModeSelectsTheClip()
  lu.assertEquals(press.launchButton(launchMode, 3, 5, true, press.edited(false)), { kind = "selection", track = 3, value = 5 })
  lu.assertEquals(press.launchButton(launchMode, 8, 8, true, press.edited(false)), { kind = "selection", track = 8, value = 8 })
end

function TestPress:testLaunchModeEmptyLaunchButtonSelectsStop()
  lu.assertEquals(press.launchButton(launchMode, 3, 5, false, press.edited(false)), { kind = "selection", track = 3, value = 0 })
end

function TestPress:testStopButtonSelectsStop()
  lu.assertEquals(press.stopButton(5), { kind = "selection", track = 5, value = 0 })
end

-- the same cases as the function button tests of PressTest.cpp
function TestPress:testFunctionButtonInStopFunctionSelectsStop()
  lu.assertEquals(press.functionButton(press.functionStop, 5, true, true), { kind = "selection", track = 5, value = 0 })
  lu.assertNil(press.functionButton(press.functionStop, 5, true, false))
end

function TestPress:testFunctionButtonIsHeldDownAsMuteOrSoloButton()
  lu.assertEquals(press.functionButton(press.functionMute, 3, true, true), { kind = "mute", track = 3, value = 1 })
  lu.assertEquals(press.functionButton(press.functionMute, 3, true, false), { kind = "mute", track = 3, value = 0 })
  lu.assertEquals(press.functionButton(press.functionSolo, 8, true, true), { kind = "solo", track = 8, value = 1 })
  lu.assertEquals(press.functionButton(press.functionSolo, 8, true, false), { kind = "solo", track = 8, value = 0 })
end

function TestPress:testFunctionButtonOfATrackWithoutClipsDoesNothing()
  lu.assertNil(press.functionButton(press.functionStop, 5, false, true))
  lu.assertNil(press.functionButton(press.functionMute, 5, false, true))
  lu.assertNil(press.functionButton(press.functionSolo, 5, false, true))
  -- a button that is held down can still be let go of
  lu.assertEquals(press.functionButton(press.functionMute, 5, false, false), { kind = "mute", track = 5, value = 0 })
  lu.assertNil(press.functionButton(press.functionMute, 9, true, true))
end

function TestPress:testFunctionSelectButtonChoosesItsFunction()
  lu.assertEquals(press.functionSelectButton(press.functionMute), { kind = "function", value = 1 })
  lu.assertEquals(press.functionSelectButton(press.functionSolo), { kind = "function", value = 2 })
  lu.assertEquals(press.functionSelectButton(press.functionStop), { kind = "function", value = 0 })
  lu.assertNil(press.functionSelectButton(3))
end

function TestPress:testSetupButtonSwitchesBetweenLaunchModeAndClipPicking()
  lu.assertEquals(press.setupButton(launchMode), { kind = "setup", value = clipPicking })
  lu.assertEquals(press.setupButton(clipPicking), { kind = "setup", value = launchMode })
  -- from clip editing it leaves setup mode altogether
  lu.assertEquals(press.setupButton(editing), { kind = "setup", value = launchMode })
end

function TestPress:testClipPickingOpensThePressedLaunchButton()
  lu.assertEquals(press.launchButton(clipPicking, 1, 1, false, press.edited(false)), { kind = "setup", value = 2 })
  lu.assertEquals(press.launchButton(clipPicking, 8, 8, true, press.edited(false)), { kind = "setup", value = 65 })
  lu.assertEquals(press.launchButton(clipPicking, 4, 6, true, press.edited(false)), { kind = "setup", value = editing })
end

function TestPress:testClipEditingToggleSwitchesThePickedClip()
  lu.assertEquals(press.launchButton(editing, 8, 1, false, press.edited(false)), { kind = "present", index = picked, value = 1 })
  lu.assertEquals(press.launchButton(editing, 8, 1, false, press.edited(true)), { kind = "present", index = picked, value = 0 })
end

function TestPress:testBackButtonGoesBackOneStep()
  lu.assertNil(press.backButton(launchMode))
  lu.assertEquals(press.backButton(clipPicking), { kind = "setup", value = launchMode })
  lu.assertEquals(press.backButton(editing), { kind = "setup", value = clipPicking })
  -- from fill-in editing it returns to clip editing of the same launch
  -- button, and from landing editing to fill-in editing
  lu.assertEquals(press.backButton(fillInEditing), { kind = "setup", value = editing })
  lu.assertEquals(press.backButton(landingEditing), { kind = "setup", value = fillInEditing })
end

-- output A in pattern mode, B unipolar, C bipolar, the others as on a new
-- device; transitions off, except C at B and D at D
local function mixedModes(present)
  return press.edited(present, { 2, 1, 0, 1, 1, 1 }, { 0, 0, 2, 4, 0, 0 })
end

function TestPress:testClipEditingColourRows()
  for column = 1, 7 do
    lu.assertEquals(press.launchButton(editing, column, 1, false, press.edited(true)),
      { kind = "colour", index = picked, value = column - 1 })
    lu.assertEquals(press.launchButton(editing, column, 2, false, press.edited(true)),
      { kind = "colour", index = picked, value = 7 + column - 1 })
  end
  -- column 8 of the second colour row is not a control
  lu.assertNil(press.launchButton(editing, 8, 2, false, press.edited(true)))
end

function TestPress:testClipEditingPatternMode()
  -- output A, in row 3, is in pattern mode: all eight columns are patterns
  for column = 1, 8 do
    lu.assertEquals(press.launchButton(editing, column, 3, false, mixedModes(true)),
      { kind = "pattern", index = picked, output = 1, value = column - 1 })
  end
end

function TestPress:testClipEditingUnipolarAndBipolarValues()
  for column = 1, 7 do
    lu.assertEquals(press.launchButton(editing, column, 4, false, mixedModes(true)),
      { kind = "unipolar", index = picked, output = 2, value = column - 1 })
    lu.assertEquals(press.launchButton(editing, column, 5, false, mixedModes(true)),
      { kind = "bipolar", index = picked, output = 3, value = column - 1 })
    lu.assertEquals(press.launchButton(editing, column, 8, false, mixedModes(true)),
      { kind = "unipolar", index = picked, output = 6, value = column - 1 })
  end
end

function TestPress:testClipEditingTransitionButtonGoesRound()
  lu.assertEquals(press.launchButton(editing, 8, 4, false, mixedModes(true)),
    { kind = "transition", index = picked, output = 2, value = 1 })
  lu.assertEquals(press.launchButton(editing, 8, 5, false, mixedModes(true)),
    { kind = "transition", index = picked, output = 3, value = 3 })
  -- after D it is off again
  lu.assertEquals(press.launchButton(editing, 8, 6, false, mixedModes(true)),
    { kind = "transition", index = picked, output = 4, value = 0 })
end

function TestPress:testClipEditingUnusedLaunchButtonsDoNothing()
  lu.assertNil(press.launchButton(editing, 8, 2, true, press.edited(true)))
end

function TestPress:testClipEditingWithoutClipHasNoColourOrCVControls()
  for row = 1, 8 do
    lu.assertNil(press.launchButton(editing, 3, row, false, mixedModes(false)))
  end
  lu.assertNil(press.launchButton(editing, 8, 4, false, mixedModes(false)))
end

function TestPress:testSceneButtonSelectsItsRowOnEveryTrack()
  local holdsClip = { true, true, true, true, true, true, true, true }
  local changes = press.sceneButton(press.setupLaunchMode, 3, holdsClip)
  lu.assertEquals(#changes, 16)
  for track = 1, 8 do
    lu.assertEquals(changes[track], { kind = "selection", track = track, value = 3 })
    -- each track's relaunch press is held down as well
    lu.assertEquals(changes[8 + track], { kind = "relaunch", track = track, value = 1 })
  end
end

function TestPress:testLaunchHoldsTheRelaunchPressInLaunchModeOnly()
  lu.assertEquals(press.relaunchButton(launchMode, 3, true), { kind = "relaunch", track = 3, value = 1 })
  lu.assertNil(press.relaunchButton(clipPicking, 3, true))
  lu.assertNil(press.relaunchButton(editing, 3, true))
  -- letting go is passed on in every mode
  lu.assertEquals(press.relaunchButton(clipPicking, 3, false), { kind = "relaunch", track = 3, value = 0 })
  lu.assertNil(press.relaunchButton(launchMode, 9, true))
end

function TestPress:testSceneButtonStopsTracksWithAnEmptyLaunchButton()
  local holdsClip = { true, false, false, true, false, false, false, true }
  local changes = press.sceneButton(press.setupLaunchMode, 8, holdsClip)
  lu.assertEquals(#changes, 16)
  for track = 1, 8 do
    lu.assertEquals(changes[track], { kind = "selection", track = track, value = holdsClip[track] and 8 or 0 })
  end
end

function TestPress:testSceneButtonOfAnEmptySceneStopsEveryTrack()
  local holdsClip = { false, false, false, false, false, false, false, false }
  local changes = press.sceneButton(press.setupLaunchMode, 1, holdsClip)
  lu.assertEquals(#changes, 16)
  for track = 1, 8 do
    lu.assertEquals(changes[track], { kind = "selection", track = track, value = 0 })
  end
end

function TestPress:testSceneButtonDoesNothingInClipEditing()
  local holdsClip = { true, true, true, true, true, true, true, true }
  lu.assertEquals(press.sceneButton(editing, 3, holdsClip), {})
end

-- from the bottom: immediate, one beat, half a bar, 1, 2, 4, 8 and 16 bars
function TestPress:testSceneButtonInClipPickingChoosesItsLengthAndLeavesSetupMode()
  local holdsClip = { true, true, true, true, true, true, true, true }
  for scene = 1, 8 do
    lu.assertEquals(press.sceneButton(press.setupClipPicking, scene, holdsClip), {
      { kind = "length", value = 8 - scene },
      { kind = "setup", value = press.setupLaunchMode },
    })
  end
end

function TestPress:testSetupNumbering()
  lu.assertEquals(press.setupFirstFillInEditing, 66)
  lu.assertFalse(press.isClipEditing(clipPicking))
  lu.assertTrue(press.isClipEditing(2))
  lu.assertTrue(press.isClipEditing(65))
  lu.assertFalse(press.isClipEditing(66))
  lu.assertFalse(press.isFillInEditing(65))
  lu.assertTrue(press.isFillInEditing(66))
  lu.assertTrue(press.isFillInEditing(129))
  lu.assertFalse(press.isFillInEditing(130))
  lu.assertEquals(press.setupFirstLandingEditing, 130)
  lu.assertFalse(press.isLandingEditing(129))
  lu.assertTrue(press.isLandingEditing(130))
  lu.assertTrue(press.isLandingEditing(193))
  lu.assertFalse(press.isLandingEditing(194))
  lu.assertEquals(press.setupClearMode, 194)
  lu.assertNil(press.pickedButton(press.setupClearMode))
  lu.assertNil(press.pickedButton(launchMode))
  lu.assertNil(press.pickedButton(clipPicking))
  lu.assertEquals(press.pickedButton(editing), picked)
  lu.assertEquals(press.pickedButton(fillInEditing), picked)
  lu.assertEquals(press.pickedButton(landingEditing), picked)
end

function TestPress:testSetupButtonLeavesFillInEditing()
  lu.assertEquals(press.setupButton(fillInEditing), { kind = "setup", value = launchMode })
end

function TestPress:testForwardButtonGoesForwardOneStepWithAClip()
  lu.assertEquals(press.forwardButton(editing, true), { kind = "setup", value = fillInEditing })
  lu.assertNil(press.forwardButton(editing, false))
  lu.assertNil(press.forwardButton(launchMode, true))
  lu.assertNil(press.forwardButton(clipPicking, true))
  -- from fill-in editing on to landing editing, whether or not there is a
  -- fill-in, but not beyond
  lu.assertEquals(press.forwardButton(fillInEditing, true), { kind = "setup", value = landingEditing })
  lu.assertNil(press.forwardButton(fillInEditing, false))
  lu.assertNil(press.forwardButton(landingEditing, true))
end

function TestPress:testFillInButtonFollowsTheButton()
  lu.assertEquals(press.fillInButton(true), { kind = "fillin", value = 1 })
  lu.assertEquals(press.fillInButton(false), { kind = "fillin", value = 0 })
end

function TestPress:testLaunchButtonDoesNothingInFillInEditing()
  lu.assertNil(press.launchButton(fillInEditing, 8, 1, false, press.edited(true)))
  lu.assertNil(press.launchButton(fillInEditing, 1, 2, false, press.edited(true)))
end

local someClipValues = {
  patterns = { 0, 1, 2, 3, 4, 5 },
  unipolar = { 6, 5, 4, 3, 2, 1 },
  bipolar = { 0, 1, 2, 3, 4, 5 },
}

function TestPress:testFillInEditingDoesNothingElsewhere()
  lu.assertEquals(press.fillInEditingLaunchButton(launchMode, 8, 1, press.edited(false), someClipValues), {})
  lu.assertEquals(press.fillInEditingLaunchButton(clipPicking, 8, 1, press.edited(false), someClipValues), {})
  lu.assertEquals(press.fillInEditingLaunchButton(editing, 8, 1, press.edited(false), someClipValues), {})
end

-- a new fill-in is a copy of its clip's values, with every transition off, in
-- white
function TestPress:testFillInEditingToggleSetsUpANewFillIn()
  local expected = {
    { kind = "fillinpresent", index = picked, value = 1 },
    { kind = "fillincolour", index = picked, value = 0 },
  }
  for output = 1, 6 do
    table.insert(expected, { kind = "fillinpattern", index = picked, output = output, value = output - 1 })
    table.insert(expected, { kind = "fillinunipolar", index = picked, output = output, value = 7 - output })
    table.insert(expected, { kind = "fillinbipolar", index = picked, output = output, value = output - 1 })
    table.insert(expected, { kind = "fillintransition", index = picked, output = output, value = 0 })
  end
  table.insert(expected, { kind = "fillinonebarpattern", index = picked, value = 0 })
  lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 8, 1, mixedModes(false), someClipValues), expected)
  lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 8, 1, mixedModes(true), someClipValues), {
    { kind = "fillinpresent", index = picked, value = 0 },
  })
end

function TestPress:testFillInEditingColourAndCVRows()
  for column = 1, 7 do
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, column, 1, mixedModes(true), someClipValues), { { kind = "fillincolour", index = picked, value = column - 1 } })
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, column, 2, mixedModes(true), someClipValues), { { kind = "fillincolour", index = picked, value = 6 + column } })
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, column, 4, mixedModes(true), someClipValues), { { kind = "fillinunipolar", index = picked, output = 2, value = column - 1 } })
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, column, 5, mixedModes(true), someClipValues), { { kind = "fillinbipolar", index = picked, output = 3, value = column - 1 } })
  end
  for column = 1, 8 do
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, column, 3, mixedModes(true), someClipValues), { { kind = "fillinpattern", index = picked, output = 1, value = column - 1 } })
  end
  lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 8, 5, mixedModes(true), someClipValues), { { kind = "fillintransition", index = picked, output = 3, value = 3 } })
  -- the last track of the second colour row is the one-bar pattern switch
  lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 8, 2, mixedModes(true), someClipValues), { { kind = "fillinonebarpattern", index = picked, value = 1 } })
end

function TestPress:testFillInEditingWithoutFillInHasNoColourOrCVControls()
  for row = 1, 8 do
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 3, row, mixedModes(false), someClipValues), {})
  end
end

function TestPress:testSceneButtonDoesNothingInFillInEditing()
  local holdsClip = { true, true, true, true, true, true, true, true }
  lu.assertEquals(press.sceneButton(fillInEditing, 3, holdsClip), {})
  lu.assertEquals(press.sceneButton(landingEditing, 3, holdsClip), {})
end

function TestPress:testLandingEditingDoesNothingElsewhere()
  lu.assertEquals(press.landingEditingLaunchButton(clipPicking, 8, 1, press.edited(false), someClipValues), {})
  lu.assertEquals(press.landingEditingLaunchButton(fillInEditing, 8, 1, press.edited(false), someClipValues), {})
  lu.assertEquals(press.fillInEditingLaunchButton(landingEditing, 8, 1, press.edited(false), someClipValues), {})
  lu.assertNil(press.launchButton(landingEditing, 8, 1, false, press.edited(true)))
end

-- a new landing is a copy of its clip's values, with every transition off, in
-- white, like a new fill-in
function TestPress:testLandingEditingToggleSetsUpANewLanding()
  local expected = {
    { kind = "landingpresent", index = picked, value = 1 },
    { kind = "landingcolour", index = picked, value = 0 },
  }
  for output = 1, 6 do
    table.insert(expected, { kind = "landingpattern", index = picked, output = output, value = output - 1 })
    table.insert(expected, { kind = "landingunipolar", index = picked, output = output, value = 7 - output })
    table.insert(expected, { kind = "landingbipolar", index = picked, output = output, value = output - 1 })
    table.insert(expected, { kind = "landingtransition", index = picked, output = output, value = 0 })
  end
  table.insert(expected, { kind = "landingonebarpattern", index = picked, value = 0 })
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 1, mixedModes(false), someClipValues), expected)
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 1, mixedModes(true), someClipValues), {
    { kind = "landingpresent", index = picked, value = 0 },
  })
end

function TestPress:testLandingEditingColourAndCVRows()
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 3, 2, mixedModes(true), someClipValues), { { kind = "landingcolour", index = picked, value = 9 } })
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 6, 3, mixedModes(true), someClipValues), { { kind = "landingpattern", index = picked, output = 1, value = 5 } })
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 5, 4, mixedModes(true), someClipValues), { { kind = "landingunipolar", index = picked, output = 2, value = 4 } })
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 1, 5, mixedModes(true), someClipValues), { { kind = "landingbipolar", index = picked, output = 3, value = 0 } })
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 6, mixedModes(true), someClipValues), { { kind = "landingtransition", index = picked, output = 4, value = 0 } })
  -- without a landing there is nothing but the toggle
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 3, 2, mixedModes(false), someClipValues), {})
end

function TestPress:testOneBarPatternSwitchGoesOnAndOff()
  local landing = mixedModes(true)
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 2, landing, someClipValues), { { kind = "landingonebarpattern", index = picked, value = 1 } })
  landing.oneBarPattern = true
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 2, landing, someClipValues), { { kind = "landingonebarpattern", index = picked, value = 0 } })
  -- not there without a landing
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 2, mixedModes(false), someClipValues), {})
  -- in fill-in editing it is the fill-in's
  lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 8, 2, mixedModes(true), someClipValues), { { kind = "fillinonebarpattern", index = picked, value = 1 } })
  lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 8, 2, mixedModes(false), someClipValues), {})
end

-- the cases of the clear mode tests of PressTest.cpp
local clearMode = press.setupClearMode

function TestPress:testClearButtonSwitchesBetweenLaunchModeAndClearMode()
  lu.assertEquals(press.clearButton(launchMode), { kind = "setup", value = clearMode })
  lu.assertEquals(press.clearButton(clearMode), { kind = "setup", value = launchMode })
  -- in setup mode it does nothing
  lu.assertNil(press.clearButton(clipPicking))
  lu.assertNil(press.clearButton(editing))
  lu.assertNil(press.clearButton(fillInEditing))
  lu.assertNil(press.clearButton(landingEditing))
end

function TestPress:testSetupAndBackButtonsLeaveClearMode()
  lu.assertEquals(press.setupButton(clearMode), { kind = "setup", value = launchMode })
  lu.assertEquals(press.backButton(clearMode), { kind = "setup", value = launchMode })
  lu.assertNil(press.forwardButton(clearMode, true))
end

function TestPress:testClearModeEmptiesThePressedLaunchButtonAndReturns()
  lu.assertEquals(press.clearModeLaunchButton(clearMode, 4, 6, true), {
    { kind = "present", index = press.buttonIndex(4, 6), value = 0 },
    { kind = "setup", value = launchMode },
  })
end

function TestPress:testClearModeLeavesAnEmptyLaunchButtonEmpty()
  lu.assertEquals(press.clearModeLaunchButton(clearMode, 4, 6, false), { { kind = "setup", value = launchMode } })
end

function TestPress:testClearModeLaunchButtonDoesNothingElsewhere()
  lu.assertEquals(press.clearModeLaunchButton(launchMode, 4, 6, true), {})
  lu.assertEquals(press.clearModeLaunchButton(clipPicking, 4, 6, true), {})
  lu.assertEquals(press.clearModeLaunchButton(editing, 4, 6, true), {})
  -- and the ordinary rules do nothing in clear mode, not even a relaunch
  lu.assertNil(press.launchButton(clearMode, 4, 6, true, press.edited(false)))
  lu.assertNil(press.relaunchButton(clearMode, 4, true))
end

function TestPress:testSceneButtonInClearModeEmptiesItsSceneAndReturns()
  local holdsClip = { true, false, true, false, false, false, false, true }
  lu.assertEquals(press.sceneButton(clearMode, 5, holdsClip), {
    { kind = "present", index = press.buttonIndex(1, 5), value = 0 },
    { kind = "present", index = press.buttonIndex(3, 5), value = 0 },
    { kind = "present", index = press.buttonIndex(8, 5), value = 0 },
    { kind = "setup", value = launchMode },
  })
  -- a scene without clips only returns to launch mode
  local none = { false, false, false, false, false, false, false, false }
  lu.assertEquals(press.sceneButton(clearMode, 5, none), { { kind = "setup", value = launchMode } })
end

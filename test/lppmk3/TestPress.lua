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
  -- from fill-in editing it returns to clip editing of the same launch button
  lu.assertEquals(press.backButton(fillInEditing), { kind = "setup", value = editing })
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
  lu.assertEquals(#changes, 8)
  for track = 1, 8 do
    lu.assertEquals(changes[track], { kind = "selection", track = track, value = 3 })
  end
end

function TestPress:testSceneButtonStopsTracksWithAnEmptyLaunchButton()
  local holdsClip = { true, false, false, true, false, false, false, true }
  local changes = press.sceneButton(press.setupLaunchMode, 8, holdsClip)
  lu.assertEquals(#changes, 8)
  for track = 1, 8 do
    lu.assertEquals(changes[track], { kind = "selection", track = track, value = holdsClip[track] and 8 or 0 })
  end
end

function TestPress:testSceneButtonOfAnEmptySceneStopsEveryTrack()
  local holdsClip = { false, false, false, false, false, false, false, false }
  local changes = press.sceneButton(press.setupLaunchMode, 1, holdsClip)
  lu.assertEquals(#changes, 8)
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
  lu.assertNil(press.pickedButton(launchMode))
  lu.assertNil(press.pickedButton(clipPicking))
  lu.assertEquals(press.pickedButton(editing), picked)
  lu.assertEquals(press.pickedButton(fillInEditing), picked)
end

function TestPress:testSetupButtonLeavesFillInEditing()
  lu.assertEquals(press.setupButton(fillInEditing), { kind = "setup", value = launchMode })
end

function TestPress:testSetFillInButtonGoesOnFromClipEditingOfAClip()
  lu.assertEquals(press.setFillInButton(editing, true), { kind = "setup", value = fillInEditing })
  lu.assertNil(press.setFillInButton(editing, false))
  lu.assertNil(press.setFillInButton(launchMode, true))
  lu.assertNil(press.setFillInButton(clipPicking, true))
  lu.assertNil(press.setFillInButton(fillInEditing, true))
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
  lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 8, 2, mixedModes(true), someClipValues), {})
end

function TestPress:testFillInEditingWithoutFillInHasNoColourOrCVControls()
  for row = 1, 8 do
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 3, row, mixedModes(false), someClipValues), {})
  end
end

function TestPress:testSceneButtonDoesNothingInFillInEditing()
  local holdsClip = { true, true, true, true, true, true, true, true }
  lu.assertEquals(press.sceneButton(fillInEditing, 3, holdsClip), {})
end

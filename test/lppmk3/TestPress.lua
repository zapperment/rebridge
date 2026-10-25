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
local introEditing = press.setupFirstIntroEditing + press.buttonIndex(4, 6)
local outroEditing = press.setupFirstOutroEditing + press.buttonIndex(4, 6)

-- the colours of the clips of a scene, by track, which clearing keeps
local sceneColours = { 5, 5, 5, 5, 5, 5, 5, 5 }

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
  lu.assertEquals(press.launchButton(editing, 8, 1, false, press.edited(false)), { kind = "switches", index = picked, value = 1 })
  lu.assertEquals(press.launchButton(editing, 8, 1, false, press.edited(true)), { kind = "switches", index = picked, value = 0 })
end

function TestPress:testBackButtonGoesBackOneStep()
  lu.assertNil(press.backButton(launchMode))
  lu.assertEquals(press.backButton(clipPicking), { kind = "setup", value = launchMode })
  lu.assertEquals(press.backButton(editing), { kind = "setup", value = clipPicking })
  -- from fill-in editing it returns to clip editing of the same launch
  -- button, and from landing editing to fill-in editing
  lu.assertEquals(press.backButton(fillInEditing), { kind = "setup", value = editing })
  lu.assertEquals(press.backButton(landingEditing), { kind = "setup", value = fillInEditing })
  -- from intro editing to landing editing, and from outro editing to intro
  -- editing
  lu.assertEquals(press.backButton(introEditing), { kind = "setup", value = landingEditing })
  lu.assertEquals(press.backButton(outroEditing), { kind = "setup", value = introEditing })
end

-- output A in pattern mode, B unipolar, C bipolar, the others as on a new
-- device; transitions off, except C at B and D at D
local function mixedModes(present)
  return press.edited(present, { 2, 1, 0, 1, 1, 1 }, { 0, 0, 2, 4, 0, 0 })
end

-- the change a press makes to one setting of an output of mixedModes, whose
-- other settings are those of a new clip in row 1 and its transitions: all
-- four are one value
local function settingChange(prefix, setting, output, value)
  local settings = { pattern = 0, unipolar = 0, bipolar = 3, transition = ({ 0, 0, 2, 4, 0, 0 })[output] }
  settings[setting] = value
  return { kind = prefix .. "output", index = picked, output = output, value = press.packOutputSettings(settings.pattern, settings.unipolar, settings.bipolar, settings.transition) }
end

function TestPress:testClipEditingColourRows()
  for column = 1, 7 do
    lu.assertEquals(press.launchButton(editing, column, 1, false, press.edited(true)),
      { kind = "switches", index = picked, value = 1 + 2 * (column - 1) })
    lu.assertEquals(press.launchButton(editing, column, 2, false, press.edited(true)),
      { kind = "switches", index = picked, value = 1 + 2 * (7 + column - 1) })
  end
  -- column 8 of the second colour row is not a control
  lu.assertNil(press.launchButton(editing, 8, 2, false, press.edited(true)))
end

function TestPress:testClipEditingPatternMode()
  -- output A, in row 3, is in pattern mode: all eight columns are patterns
  for column = 1, 8 do
    lu.assertEquals(press.launchButton(editing, column, 3, false, mixedModes(true)),
      settingChange("", "pattern", 1, column - 1))
  end
end

function TestPress:testClipEditingUnipolarAndBipolarValues()
  for column = 1, 7 do
    lu.assertEquals(press.launchButton(editing, column, 4, false, mixedModes(true)),
      settingChange("", "unipolar", 2, column - 1))
    lu.assertEquals(press.launchButton(editing, column, 5, false, mixedModes(true)),
      settingChange("", "bipolar", 3, column - 1))
    lu.assertEquals(press.launchButton(editing, column, 8, false, mixedModes(true)),
      settingChange("", "unipolar", 6, column - 1))
  end
end

function TestPress:testClipEditingTransitionButtonGoesRound()
  lu.assertEquals(press.launchButton(editing, 8, 4, false, mixedModes(true)),
    settingChange("", "transition", 2, 1))
  lu.assertEquals(press.launchButton(editing, 8, 5, false, mixedModes(true)),
    settingChange("", "transition", 3, 3))
  -- after D it is off again
  lu.assertEquals(press.launchButton(editing, 8, 6, false, mixedModes(true)),
    settingChange("", "transition", 4, 0))
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
  local changes = press.sceneButton(press.setupLaunchMode, 3, holdsClip, sceneColours)
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
  local changes = press.sceneButton(press.setupLaunchMode, 8, holdsClip, sceneColours)
  lu.assertEquals(#changes, 16)
  for track = 1, 8 do
    lu.assertEquals(changes[track], { kind = "selection", track = track, value = holdsClip[track] and 8 or 0 })
  end
end

function TestPress:testSceneButtonOfAnEmptySceneStopsEveryTrack()
  local holdsClip = { false, false, false, false, false, false, false, false }
  local changes = press.sceneButton(press.setupLaunchMode, 1, holdsClip, sceneColours)
  lu.assertEquals(#changes, 16)
  for track = 1, 8 do
    lu.assertEquals(changes[track], { kind = "selection", track = track, value = 0 })
  end
end

function TestPress:testSceneButtonDoesNothingInClipEditing()
  local holdsClip = { true, true, true, true, true, true, true, true }
  lu.assertEquals(press.sceneButton(editing, 3, holdsClip, sceneColours), {})
end

-- from the bottom: immediate, one beat, half a bar, 1, 2, 4, 8 and 16 bars
function TestPress:testSceneButtonInClipPickingChoosesItsLengthAndLeavesSetupMode()
  local holdsClip = { true, true, true, true, true, true, true, true }
  for scene = 1, 8 do
    lu.assertEquals(press.sceneButton(press.setupClipPicking, scene, holdsClip, sceneColours), {
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
  lu.assertEquals(press.setupClearMode, 322)
  lu.assertNil(press.pickedButton(press.setupClearMode))
  lu.assertNil(press.pickedButton(launchMode))
  lu.assertNil(press.pickedButton(clipPicking))
  lu.assertEquals(press.pickedButton(editing), picked)
  lu.assertEquals(press.pickedButton(fillInEditing), picked)
  lu.assertEquals(press.pickedButton(landingEditing), picked)
  lu.assertEquals(press.setupFirstIntroEditing, 194)
  lu.assertTrue(press.isIntroEditing(194))
  lu.assertTrue(press.isIntroEditing(257))
  lu.assertFalse(press.isIntroEditing(258))
  lu.assertEquals(press.setupFirstOutroEditing, 258)
  lu.assertTrue(press.isOutroEditing(258))
  lu.assertTrue(press.isOutroEditing(321))
  lu.assertFalse(press.isOutroEditing(322))
  lu.assertEquals(press.pickedButton(introEditing), picked)
  lu.assertEquals(press.pickedButton(outroEditing), picked)
end


function TestPress:testSetupButtonLeavesFillInEditing()
  lu.assertEquals(press.setupButton(fillInEditing), { kind = "setup", value = launchMode })
end

function TestPress:testForwardButtonGoesForwardOneStepWithAClip()
  lu.assertEquals(press.forwardButton(editing, true), { kind = "setup", value = fillInEditing })
  lu.assertNil(press.forwardButton(editing, false))
  lu.assertNil(press.forwardButton(launchMode, true))
  lu.assertNil(press.forwardButton(clipPicking, true))
  -- from fill-in editing on to landing editing, intro editing and outro
  -- editing, whether or not there is a fill-in, landing or intro, but not
  -- beyond
  lu.assertEquals(press.forwardButton(fillInEditing, true), { kind = "setup", value = landingEditing })
  lu.assertNil(press.forwardButton(fillInEditing, false))
  lu.assertEquals(press.forwardButton(landingEditing, true), { kind = "setup", value = introEditing })
  lu.assertEquals(press.forwardButton(introEditing, true), { kind = "setup", value = outroEditing })
  lu.assertNil(press.forwardButton(introEditing, false))
  lu.assertNil(press.forwardButton(outroEditing, true))
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
    { kind = "fillinswitches", index = picked, value = 1 },
  }
  for output = 1, 6 do
    table.insert(expected, { kind = "fillin" .. "output", index = picked, output = output, value = press.packOutputSettings(output - 1, 7 - output, output - 1, 0) })
  end
  lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 8, 1, mixedModes(false), someClipValues), expected)
  lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 8, 1, mixedModes(true), someClipValues), {
    { kind = "fillinswitches", index = picked, value = 0 },
  })
end

function TestPress:testFillInEditingColourAndCVRows()
  for column = 1, 7 do
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, column, 1, mixedModes(true), someClipValues), { { kind = "fillinswitches", index = picked, value = 1 + 2 * (column - 1) } })
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, column, 2, mixedModes(true), someClipValues), { { kind = "fillinswitches", index = picked, value = 1 + 2 * (6 + column) } })
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, column, 4, mixedModes(true), someClipValues), { settingChange("fillin", "unipolar", 2, column - 1) })
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, column, 5, mixedModes(true), someClipValues), { settingChange("fillin", "bipolar", 3, column - 1) })
  end
  for column = 1, 8 do
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, column, 3, mixedModes(true), someClipValues), { settingChange("fillin", "pattern", 1, column - 1) })
  end
  lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 8, 5, mixedModes(true), someClipValues), { settingChange("fillin", "transition", 3, 3) })
  -- the last track of the second colour row is the one-bar pattern switch
  lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 8, 2, mixedModes(true), someClipValues), { { kind = "fillinswitches", index = picked, value = 1 + 28 } })
end

function TestPress:testFillInEditingWithoutFillInHasNoColourOrCVControls()
  for row = 1, 8 do
    lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 3, row, mixedModes(false), someClipValues), {})
  end
end

function TestPress:testSceneButtonDoesNothingInFillInEditing()
  local holdsClip = { true, true, true, true, true, true, true, true }
  lu.assertEquals(press.sceneButton(fillInEditing, 3, holdsClip, sceneColours), {})
  lu.assertEquals(press.sceneButton(landingEditing, 3, holdsClip, sceneColours), {})
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
    { kind = "landingswitches", index = picked, value = 1 },
  }
  for output = 1, 6 do
    table.insert(expected, { kind = "landing" .. "output", index = picked, output = output, value = press.packOutputSettings(output - 1, 7 - output, output - 1, 0) })
  end
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 1, mixedModes(false), someClipValues), expected)
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 1, mixedModes(true), someClipValues), {
    { kind = "landingswitches", index = picked, value = 0 },
  })
end

function TestPress:testLandingEditingColourAndCVRows()
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 3, 2, mixedModes(true), someClipValues), { { kind = "landingswitches", index = picked, value = 1 + 2 * (9) } })
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 6, 3, mixedModes(true), someClipValues), { settingChange("landing", "pattern", 1, 5) })
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 5, 4, mixedModes(true), someClipValues), { settingChange("landing", "unipolar", 2, 4) })
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 1, 5, mixedModes(true), someClipValues), { settingChange("landing", "bipolar", 3, 0) })
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 6, mixedModes(true), someClipValues), { settingChange("landing", "transition", 4, 0) })
  -- without a landing there is nothing but the toggle
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 3, 2, mixedModes(false), someClipValues), {})
end

function TestPress:testOneBarPatternSwitchGoesOnAndOff()
  local landing = mixedModes(true)
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 2, landing, someClipValues), { { kind = "landingswitches", index = picked, value = 1 + 28 } })
  landing.oneBarPattern = true
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 2, landing, someClipValues), { { kind = "landingswitches", index = picked, value = 1 } })
  -- not there without a landing
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 2, mixedModes(false), someClipValues), {})
  -- in fill-in editing it is the fill-in's
  lu.assertEquals(press.fillInEditingLaunchButton(fillInEditing, 8, 2, mixedModes(true), someClipValues), { { kind = "fillinswitches", index = picked, value = 1 + 28 } })
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
  lu.assertEquals(press.clearModeLaunchButton(clearMode, 4, 6, true, 5), {
    { kind = "switches", index = press.buttonIndex(4, 6), value = 2 * 5 },
    { kind = "setup", value = launchMode },
  })
end

function TestPress:testClearModeLeavesAnEmptyLaunchButtonEmpty()
  lu.assertEquals(press.clearModeLaunchButton(clearMode, 4, 6, false, 5), { { kind = "setup", value = launchMode } })
end

function TestPress:testClearModeLaunchButtonDoesNothingElsewhere()
  lu.assertEquals(press.clearModeLaunchButton(launchMode, 4, 6, true, 5), {})
  lu.assertEquals(press.clearModeLaunchButton(clipPicking, 4, 6, true, 5), {})
  lu.assertEquals(press.clearModeLaunchButton(editing, 4, 6, true, 5), {})
  -- and the ordinary rules do nothing in clear mode, not even a relaunch
  lu.assertNil(press.launchButton(clearMode, 4, 6, true, press.edited(false)))
  lu.assertNil(press.relaunchButton(clearMode, 4, true))
end

function TestPress:testSceneButtonInClearModeEmptiesItsSceneAndReturns()
  local holdsClip = { true, false, true, false, false, false, false, true }
  lu.assertEquals(press.sceneButton(clearMode, 5, holdsClip, sceneColours), {
    { kind = "switches", index = press.buttonIndex(1, 5), value = 2 * 5 },
    { kind = "switches", index = press.buttonIndex(3, 5), value = 2 * 5 },
    { kind = "switches", index = press.buttonIndex(8, 5), value = 2 * 5 },
    { kind = "setup", value = launchMode },
  })
  -- a scene without clips only returns to launch mode
  local none = { false, false, false, false, false, false, false, false }
  lu.assertEquals(press.sceneButton(clearMode, 5, none, sceneColours), { { kind = "setup", value = launchMode } })
end

local sourcePicking = press.setupSourcePicking

function TestPress:testDuplicateModeStates()
  lu.assertEquals(sourcePicking, 323)
  lu.assertEquals(press.setupFirstClipDestinationPicking, 324)
  lu.assertEquals(press.setupFirstSceneDestinationPicking, 388)
  lu.assertEquals(press.setupCount, 396)
  lu.assertFalse(press.isDuplicateMode(press.setupClearMode))
  lu.assertTrue(press.isDuplicateMode(sourcePicking))
  lu.assertTrue(press.isDuplicateMode(395))
  lu.assertFalse(press.isDuplicateMode(396))
  lu.assertFalse(press.isLandingEditing(sourcePicking))
  lu.assertNil(press.pickedButton(324))
  lu.assertEquals(press.sourceButton(324 + press.buttonIndex(4, 6)), press.buttonIndex(4, 6))
  lu.assertNil(press.sourceButton(sourcePicking))
  lu.assertNil(press.sourceButton(393))
  lu.assertEquals(press.sourceScene(393), 6)
  lu.assertNil(press.sourceScene(324))
end

function TestPress:testDuplicateButtonSwitchesBetweenLaunchModeAndDuplicateMode()
  lu.assertEquals(press.duplicateButton(launchMode), { kind = "setup", value = sourcePicking })
  -- from either step it returns to launch mode, copying nothing
  for _, step in ipairs({ sourcePicking, 324, 393 }) do
    lu.assertEquals(press.duplicateButton(step), { kind = "setup", value = launchMode })
  end
  -- in setup mode and clear mode it does nothing
  for _, step in ipairs({ clipPicking, editing, fillInEditing, landingEditing, press.setupClearMode }) do
    lu.assertNil(press.duplicateButton(step))
  end
  -- nor does the clear button in duplicate mode
  lu.assertNil(press.clearButton(sourcePicking))
  lu.assertNil(press.clearButton(324))
end

function TestPress:testSetupAndBackButtonsLeaveDuplicateMode()
  for _, step in ipairs({ sourcePicking, 324 + picked, 393 }) do
    lu.assertEquals(press.setupButton(step), { kind = "setup", value = launchMode })
    lu.assertEquals(press.backButton(step), { kind = "setup", value = launchMode })
    lu.assertNil(press.forwardButton(step, true))
    -- and the ordinary rules do nothing, not even a relaunch
    lu.assertNil(press.launchButton(step, 4, 6, true, press.edited(false)))
    lu.assertNil(press.relaunchButton(step, 4, true))
    lu.assertEquals(press.sceneButton(step, 6, { true, true, true, true, true, true, true, true }, sceneColours), {})
  end
end

-- settings that differ from one another and from a new clip's, so that a
-- copy can be told from them; even seeds hold a clip, odd ones are empty
local function someSettings(seed)
  local settings = { present = seed % 2 == 0, colour = seed % 14, patterns = {}, unipolar = {}, bipolar = {}, transitions = {}, oneBarPattern = seed % 3 == 0 }
  for output = 1, press.outputCount do
    settings.patterns[output] = (seed + output) % 8
    settings.unipolar[output] = (seed + output + 1) % 7
    settings.bipolar[output] = (seed + output + 2) % 7
    settings.transitions[output] = (seed + output) % 5
  end
  return settings
end

local function someButton(seed)
  return { clip = someSettings(seed), fillIn = someSettings(seed + 5), landing = someSettings(seed + 10), intro = someSettings(seed + 15), outro = someSettings(seed + 20) }
end

-- the field of a button and of its settings that each kind of change sets
local copiedSettings = {}
for prefix, field in pairs({ [""] = "clip", fillin = "fillIn", landing = "landing", intro = "intro", outro = "outro" }) do
  copiedSettings[prefix .. "switches"] = { field, "switches" }
  copiedSettings[prefix .. "output"] = { field, "output" }
end

-- plays the changes to one launch button back into the shape of a button,
-- and counts them
local function replay(changes, index)
  local button = {}
  for _, field in ipairs({ "clip", "fillIn", "landing", "intro", "outro" }) do
    button[field] = { patterns = {}, unipolar = {}, bipolar = {}, transitions = {} }
  end
  local count = 0
  for _, change in ipairs(changes) do
    if change.kind ~= "setup" and change.index == index then
      count = count + 1
      local field, setting = unpack(copiedSettings[change.kind])
      local settings = button[field]
      if change.output then
        local pattern, unipolar, bipolar, transition = press.unpackOutputSettings(change.value)
        settings.patterns[change.output] = pattern
        settings.unipolar[change.output] = unipolar
        settings.bipolar[change.output] = bipolar
        settings.transitions[change.output] = transition
      else
        local present, colour, oneBarPattern = press.unpackSwitches(change.value)
        settings.present, settings.colour = present, colour
        if field ~= "clip" then
          settings.oneBarPattern = oneBarPattern
        end
      end
    end
  end
  return button, count
end

-- a clip has no one-bar pattern of its own, so the copy leaves it out
local function withoutClipOneBarPattern(button)
  button.clip.oneBarPattern = nil
  return button
end

function TestPress:testSourcePickingPicksALaunchButtonWithAClip()
  lu.assertEquals(press.duplicateModeLaunchButton(sourcePicking, 4, 6, true, someButton(1)), { { kind = "setup", value = 324 + picked } })
  -- an empty launch button cannot be the source
  lu.assertEquals(press.duplicateModeLaunchButton(sourcePicking, 4, 6, false, someButton(1)), {})
end

function TestPress:testClipDestinationPickingCopiesEverythingAndReturns()
  local source = someButton(2)
  -- the destination may be on another track, empty or not
  for _, held in ipairs({ false, true }) do
    local changes = press.duplicateModeLaunchButton(324 + picked, 6, 3, held, source)
    lu.assertEquals(#changes, 36)
    lu.assertEquals(changes[36], { kind = "setup", value = launchMode })
    local copy, count = replay(changes, press.buttonIndex(6, 3))
    lu.assertEquals(count, 35)
    lu.assertEquals(copy, withoutClipOneBarPattern(someButton(2)))
  end
end

function TestPress:testClipDestinationPickingIgnoresTheSource()
  lu.assertEquals(press.duplicateModeLaunchButton(324 + picked, 4, 6, true, someButton(2)), {})
end

function TestPress:testDuplicateModeLaunchButtonDoesNothingElsewhere()
  for _, step in ipairs({ launchMode, clipPicking, press.setupClearMode, 393 }) do
    lu.assertEquals(press.duplicateModeLaunchButton(step, 4, 3, true, someButton(2)), {})
  end
end

function TestPress:testSourcePickingPicksASceneWithAClip()
  lu.assertEquals(press.duplicateModeSceneButton(sourcePicking, 6, true, {}), { { kind = "setup", value = 393 } })
  -- a scene without clips cannot be the source
  lu.assertEquals(press.duplicateModeSceneButton(sourcePicking, 6, false, {}), {})
end

function TestPress:testSceneDestinationPickingCopiesTheWholeSceneAndReturns()
  local sources = {}
  for track = 1, 8 do
    sources[track] = someButton(track)
  end
  -- odd tracks hold no clip here: the copy empties them in the destination
  lu.assertFalse(sources[1].clip.present)
  lu.assertTrue(sources[2].clip.present)
  -- with clips or without, any scene but the source is a destination
  local changes = press.duplicateModeSceneButton(393, 2, false, sources)
  lu.assertEquals(#changes, 8 * 35 + 1)
  lu.assertEquals(changes[#changes], { kind = "setup", value = launchMode })
  for track = 1, 8 do
    local copy, count = replay(changes, press.buttonIndex(track, 2))
    lu.assertEquals(count, 35)
    lu.assertEquals(copy, withoutClipOneBarPattern(someButton(track)))
  end
end

function TestPress:testDuplicateModeSceneButtonDoesNothingElsewhere()
  -- the source itself
  lu.assertEquals(press.duplicateModeSceneButton(393, 6, true, {}), {})
  -- with a launch button as the source, scene buttons do nothing
  lu.assertEquals(press.duplicateModeSceneButton(324 + picked, 2, true, {}), {})
  for _, step in ipairs({ launchMode, clipPicking, press.setupClearMode }) do
    lu.assertEquals(press.duplicateModeSceneButton(step, 2, true, {}), {})
  end
end

-- the same cases as TestIntroAndOutroEditing of PressTest.cpp
function TestPress:testIntroAndOutroEditing()
  -- nothing changes outside its own step
  lu.assertEquals(press.introEditingLaunchButton(outroEditing, 8, 1, press.edited(false), someClipValues), {})
  lu.assertEquals(press.outroEditingLaunchButton(introEditing, 8, 1, press.edited(false), someClipValues), {})
  lu.assertEquals(press.landingEditingLaunchButton(introEditing, 8, 1, press.edited(false), someClipValues), {})
  lu.assertNil(press.launchButton(introEditing, 8, 1, false, press.edited(true)))
  lu.assertNil(press.launchButton(outroEditing, 8, 1, false, press.edited(true)))

  -- a new intro or outro is a copy of its clip's values, with every
  -- transition off and one-bar pattern off, in white
  for _, case in ipairs({ { "intro", introEditing, press.introEditingLaunchButton }, { "outro", outroEditing, press.outroEditingLaunchButton } }) do
    local prefix, setup, editLaunchButton = case[1], case[2], case[3]
    local expected = {
      { kind = prefix .. "switches", index = picked, value = 1 },
    }
    for output = 1, 6 do
      table.insert(expected, { kind = prefix .. "output", index = picked, output = output, value = press.packOutputSettings(output - 1, 7 - output, output - 1, 0) })
    end
    lu.assertEquals(editLaunchButton(setup, 8, 1, mixedModes(false), someClipValues), expected)
    lu.assertEquals(editLaunchButton(setup, 8, 1, mixedModes(true), someClipValues), { { kind = prefix .. "switches", index = picked, value = 0 } })
    lu.assertEquals(editLaunchButton(setup, 3, 2, mixedModes(true), someClipValues), { { kind = prefix .. "switches", index = picked, value = 1 + 2 * 9 } })
    lu.assertEquals(editLaunchButton(setup, 5, 4, mixedModes(true), someClipValues), { settingChange(prefix, "unipolar", 2, 4) })
    lu.assertEquals(editLaunchButton(setup, 8, 6, mixedModes(true), someClipValues), { settingChange(prefix, "transition", 4, 0) })
    lu.assertEquals(editLaunchButton(setup, 8, 2, mixedModes(true), someClipValues), { { kind = prefix .. "switches", index = picked, value = 1 + 28 } })
    lu.assertEquals(editLaunchButton(setup, 3, 2, mixedModes(false), someClipValues), {})
  end
end

-- the same cases as TestOutputSettingsPackIntoOneNumber of LauncherTest.cpp:
-- the four settings of a CV output are one number, every combination its own
function TestPress:testOutputSettingsPackIntoOneNumber()
  local seen = {}
  for pattern = 0, 7 do
    for unipolar = 0, 6 do
      for bipolar = 0, 6 do
        for transition = 0, 4 do
          local packed = press.packOutputSettings(pattern, unipolar, bipolar, transition)
          lu.assertTrue(packed >= 0 and packed < 1960 and not seen[packed])
          seen[packed] = true
          lu.assertEquals({ press.unpackOutputSettings(packed) }, { pattern, unipolar, bipolar, transition })
        end
      end
    end
  end
  -- what a new clip has in row 1
  lu.assertEquals(press.packOutputSettings(0, 0, 3, 0), 168)
end

-- the same cases as TestEditingKeepsTheOtherSettingsOfTheOutput of
-- PressTest.cpp: a press changes one setting and hands on the other three
function TestPress:testEditingKeepsTheOtherSettingsOfTheOutput()
  local values = { patterns = { 0, 5, 0, 0, 0, 0 }, unipolar = { 0, 2, 0, 0, 0, 0 }, bipolar = { 3, 6, 3, 3, 3, 3 } }
  local settings = press.edited(true, { 2, 1, 0, 1, 1, 1 }, { 0, 2, 0, 0, 0, 0 }, false, values)
  -- output B is unipolar: column 4 sets the unipolar value 3
  lu.assertEquals(press.launchButton(editing, 4, 4, false, settings), { kind = "output", index = picked, output = 2, value = press.packOutputSettings(5, 3, 6, 2) })
  -- the transition button moves the transition on and keeps the values
  lu.assertEquals(press.launchButton(editing, 8, 4, false, settings), { kind = "output", index = picked, output = 2, value = press.packOutputSettings(5, 2, 6, 3) })
end

-- the same cases as TestSwitchesPackIntoOneNumber of LauncherTest.cpp
function TestPress:testSwitchesPackIntoOneNumber()
  local seen = {}
  for _, present in ipairs({ false, true }) do
    for colour = 0, 13 do
      for _, oneBarPattern in ipairs({ false, true }) do
        local packed = press.packSwitches(present, colour, oneBarPattern)
        lu.assertTrue(packed >= 0 and packed < 56 and not seen[packed])
        seen[packed] = true
        lu.assertEquals({ press.unpackSwitches(packed) }, { present, colour, oneBarPattern })
      end
    end
  end
end

-- the same cases as TestSwitchesKeepEachOther of PressTest.cpp: a press
-- changes one switch and hands on the others
function TestPress:testSwitchesKeepEachOther()
  local clip = press.edited(true, nil, nil, false, { colour = 9, patterns = {}, unipolar = {}, bipolar = {} })
  lu.assertEquals(press.launchButton(editing, 8, 1, false, clip), { kind = "switches", index = picked, value = press.packSwitches(false, 9, false) })
  local landing = press.edited(true, nil, nil, true, { colour = 9, patterns = {}, unipolar = {}, bipolar = {} })
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 3, 1, landing, someClipValues), { { kind = "landingswitches", index = picked, value = press.packSwitches(true, 2, true) } })
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 2, landing, someClipValues), { { kind = "landingswitches", index = picked, value = press.packSwitches(true, 9, false) } })
  lu.assertEquals(press.landingEditingLaunchButton(landingEditing, 8, 1, landing, someClipValues), { { kind = "landingswitches", index = picked, value = press.packSwitches(false, 9, true) } })
  lu.assertEquals(press.clearModeLaunchButton(clearMode, 4, 6, true, 11)[1], { kind = "switches", index = picked, value = press.packSwitches(false, 11, false) })
end

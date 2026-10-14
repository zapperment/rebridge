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

function TestPress:testButtonIndexCountsDownTrackOneFirst()
  lu.assertEquals(press.buttonIndex(1, 1), 0)
  lu.assertEquals(press.buttonIndex(1, 8), 7)
  lu.assertEquals(press.buttonIndex(2, 1), 8)
  lu.assertEquals(press.buttonIndex(8, 8), 63)
end

function TestPress:testLaunchModeSelectsTheClip()
  lu.assertEquals(press.launchButton(launchMode, 3, 5, true, false), { kind = "selection", track = 3, value = 5 })
  lu.assertEquals(press.launchButton(launchMode, 8, 8, true, false), { kind = "selection", track = 8, value = 8 })
end

function TestPress:testLaunchModeEmptyLaunchButtonSelectsStop()
  lu.assertEquals(press.launchButton(launchMode, 3, 5, false, false), { kind = "selection", track = 3, value = 0 })
end

function TestPress:testStopButtonSelectsStop()
  lu.assertEquals(press.stopButton(5), { kind = "selection", track = 5, value = 0 })
end

function TestPress:testSetupButtonSwitchesBetweenLaunchModeAndClipPicking()
  lu.assertEquals(press.setupButton(launchMode), { kind = "setup", value = clipPicking })
  lu.assertEquals(press.setupButton(clipPicking), { kind = "setup", value = launchMode })
  -- from clip editing it leaves setup mode altogether
  lu.assertEquals(press.setupButton(editing), { kind = "setup", value = launchMode })
end

function TestPress:testClipPickingOpensThePressedLaunchButton()
  lu.assertEquals(press.launchButton(clipPicking, 1, 1, false, false), { kind = "setup", value = 2 })
  lu.assertEquals(press.launchButton(clipPicking, 8, 8, true, false), { kind = "setup", value = 65 })
  lu.assertEquals(press.launchButton(clipPicking, 4, 6, true, false), { kind = "setup", value = editing })
end

function TestPress:testClipEditingToggleSwitchesThePickedClip()
  lu.assertEquals(press.launchButton(editing, 8, 1, false, false), { kind = "present", index = picked, value = 1 })
  lu.assertEquals(press.launchButton(editing, 8, 1, false, true), { kind = "present", index = picked, value = 0 })
end

function TestPress:testBackButtonGoesBackOneStep()
  lu.assertNil(press.backButton(launchMode))
  lu.assertEquals(press.backButton(clipPicking), { kind = "setup", value = launchMode })
  lu.assertEquals(press.backButton(editing), { kind = "setup", value = clipPicking })
end

-- the back button has taken over from the launch button in row 8, column 8
function TestPress:testClipEditingLastLaunchButtonDoesNothing()
  lu.assertNil(press.launchButton(editing, 8, 8, false, true))
  lu.assertNil(press.launchButton(editing, 8, 8, false, false))
end

function TestPress:testClipEditingColourRows()
  for column = 1, 7 do
    lu.assertEquals(press.launchButton(editing, column, 2, false, true),
      { kind = "colour", index = picked, value = column - 1 })
    lu.assertEquals(press.launchButton(editing, column, 3, false, true),
      { kind = "colour", index = picked, value = 7 + column - 1 })
  end
  -- column 8 of the colour rows is not a control
  lu.assertNil(press.launchButton(editing, 8, 2, false, true))
  lu.assertNil(press.launchButton(editing, 8, 3, false, true))
end

function TestPress:testClipEditingPatternRow()
  for column = 1, 8 do
    lu.assertEquals(press.launchButton(editing, column, 5, false, true),
      { kind = "pattern", index = picked, value = column - 1 })
  end
end

function TestPress:testClipEditingUnusedLaunchButtonsDoNothing()
  lu.assertNil(press.launchButton(editing, 1, 1, false, true))
  lu.assertNil(press.launchButton(editing, 4, 4, false, true))
  -- not even the picked launch button itself, whatever it holds
  lu.assertNil(press.launchButton(editing, 4, 6, true, true))
  lu.assertNil(press.launchButton(editing, 1, 8, false, true))
end

function TestPress:testClipEditingWithoutClipHasNoColourOrPatternControls()
  lu.assertNil(press.launchButton(editing, 3, 2, false, false))
  lu.assertNil(press.launchButton(editing, 3, 3, false, false))
  lu.assertNil(press.launchButton(editing, 3, 5, false, false))
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

local DJUI = LibStub('DJUI')

if DJUI.saved then
	return
end

local savedDefault = {
	unitFrames = {
		player = {
			dimensions = {300, 80},
			position = {CENTER, GuiRoot, CENTER, -400, 400},
		},
		target = {
			dimensions = {300, 80},
			position = {CENTER, GuiRoot, CENTER, 400, 400},
		},
	},
}
--  Saved Vars
DJUI.saved = ZO_SavedVars:New("DJUISavedVars", DJUI.version, nil, savedDefault)
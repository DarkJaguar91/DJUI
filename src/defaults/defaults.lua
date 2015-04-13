--
-- Created by
-- User: Brandon
-- Date: 2015-04-05
-- Time: 08:21 AM
--

local NAME = 'DJUI'
local DJUI = LibStub(NAME)

if DJUI.saved then
    return
end

DJUI.savedDefaults = {
    player = {
        levelColor = {0.6, 0.6, 0.6, 1},
        nameColor = {0.6, 0.6, 0.6, 1},
        position = nil,
        hideAlpha = 0.15,
        width = 300,
        bars = {
            [POWERTYPE_HEALTH] = {
                color = {0.8, 0.1, 0.15, 1},
                barTexture = {'/esoui/art/miscellaneous/progressbar_genericfill.dds', {0, 1, 0, 0.6}, {'/esoui/art/miscellaneous/progressbar_genericfill_leadingedge.dds', 10, 20}, {0, 1, 0, 0.6}},
                glossTexture = {'/esoui/art/miscellaneous/progressbar_genericfill_gloss.dds', {0, 1, 0, 0.6}, {'/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds', 10, 20}, {0, 1, 0, 0.6}},
                borderTexture = {'/esoui/art/miscellaneous/progressbar_frame.dds', {0, 0.612, 0, 0.59}},
                backgroundTexture = {'/esoui/art/miscellaneous/progressbar_frame_bg.dds', {0, 0.612, 0, 0.59}},
                valueColor = {0.6, 0.6, 0.6, 1},
                percentColor = {0.6, 0.6, 0.6, 1},
            },
            [POWERTYPE_MAGICKA] = {
                color = {0.1, 0.15, 0.8, 1},
                barTexture = {'/esoui/art/miscellaneous/progressbar_genericfill.dds', {0, 1, 0, 0.6}, {'/esoui/art/miscellaneous/progressbar_genericfill_leadingedge.dds', 10, 20}, {0, 1, 0, 0.6}},
                glossTexture = {'/esoui/art/miscellaneous/progressbar_genericfill_gloss.dds', {0, 1, 0, 0.6}, {'/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds', 10, 20}, {0, 1, 0, 0.6}},
                borderTexture = {'/esoui/art/miscellaneous/progressbar_frame.dds', {0, 0.612, 0, 0.59}},
                backgroundTexture = {'/esoui/art/miscellaneous/progressbar_frame_bg.dds', {0, 0.612, 0, 0.59}},
                valueColor = {0.6, 0.6, 0.6, 1},
                percentColor = {0.6, 0.6, 0.6, 1},
            },
            [POWERTYPE_STAMINA] = {
                color = {0.1, 0.6, 0.15, 1},
                barTexture = {'/esoui/art/miscellaneous/progressbar_genericfill.dds', {0, 1, 0, 0.6}, {'/esoui/art/miscellaneous/progressbar_genericfill_leadingedge.dds', 10, 20}, {0, 1, 0, 0.6}},
                glossTexture = {'/esoui/art/miscellaneous/progressbar_genericfill_gloss.dds', {0, 1, 0, 0.6}, {'/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds', 10, 20}, {0, 1, 0, 0.6}},
                borderTexture = {'/esoui/art/miscellaneous/progressbar_frame.dds', {0, 0.612, 0, 0.59}},
                backgroundTexture = {'/esoui/art/miscellaneous/progressbar_frame_bg.dds', {0, 0.612, 0, 0.59}},
                valueColor = {0.6, 0.6, 0.6, 1},
                percentColor = {0.6, 0.6, 0.6, 1},
            },
            [POWERTYPE_MOUNT_STAMINA] = {
                color = {0, 0.4, 0.1, 1},
                barTexture = {'/esoui/art/unitattributevisualizer/attributebar_small_fill_center.dds', nil, {'/esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge.dds', 10, 10}, nil },
                glossTexture = {'/esoui/art/unitattributevisualizer/attributebar_small_fill_center_gloss.dds', {0, 1, 0, 1}, {'/esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge_gloss.dds', 10, 10}, {0, 1, 0, 1}},
                borderTexture = {'/esoui/art/unitattributevisualizer/attributebar_small_frame.dds', {0.06, 0.943, 0.424, 0.568}},
                backgroundTexture = {'/esoui/art/unitattributevisualizer/attributebar_small_base.dds', {0.06, 0.943, 0.424, 0.568}},
                valueColor = {0, 0, 0, 0},
                percentColor = {0, 0, 0, 0},
            },
        },
    },
    target = {
        nameReactionColor = true,
        barReactionColor = false,
        levelColor = {0.6, 0.6, 0.6, 1},
        nameColor = {0.6, 0.6, 0.6, 1},
        position = nil,
        width = 300,
        hideDefault = true,
        bars = {
            [POWERTYPE_HEALTH] = {
                color = {0.8, 0.1, 0.15, 1},
                barTexture = {'/esoui/art/miscellaneous/progressbar_genericfill.dds', {0, 1, 0, 0.6}, {'/esoui/art/miscellaneous/progressbar_genericfill_leadingedge.dds', 10, 20}, {0, 1, 0, 0.6}},
                glossTexture = {'/esoui/art/miscellaneous/progressbar_genericfill_gloss.dds', {0, 1, 0, 0.6}, {'/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds', 10, 20}, {0, 1, 0, 0.6}},
                borderTexture = {'/esoui/art/miscellaneous/progressbar_frame.dds', {0, 0.612, 0, 0.59}},
                backgroundTexture = {'/esoui/art/miscellaneous/progressbar_frame_bg.dds', {0, 0.612, 0, 0.59}},
                valueColor = {0.6, 0.6, 0.6, 1},
                percentColor = {0.6, 0.6, 0.6, 1},
            },
        },
    },
}

DJUI:AddLoad(function()
--    DJUI.saved = ZO_SavedVars:New("DarkJaguarUISavedVars", DJUI.version, 'test', DJUI.savedDefaults)
    DJUI.saved = DJUI.savedDefaults
end)
----------------------------------------------------------------------------------
-- Created by: Brandon Talbot ( -_Dark-Jaguar_- )                               --
----------------------------------------------------------------------------------

DJUI.constants = {
	['colors'] = {
		[POWERTYPE_HEALTH] = { 0.8, 0.05, 0.09, 1 },
		[POWERTYPE_MAGICKA] = { 0.05, 0.09, 0.8, 1 },
		[POWERTYPE_STAMINA] = { 0.1333, 0.54509803, 0.1333, 1 },
	},
	['reaction'] = {
		[UNIT_REACTION_FRIENDLY] = { 0, 1, 0, 1},
		[UNIT_REACTION_HOSTILE] = { 1, 0, 0, 1},
		[UNIT_REACTION_NEUTRAL] = { 1, 1, 0, 1},
		[UNIT_REACTION_NPC_ALLY] = { 0, 1, 0, 1},
		[UNIT_REACTION_PLAYER_ALLY] = { 0, 1, 0, 1},
	},
}
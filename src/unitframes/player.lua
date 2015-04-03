local DJUI = LibStub:GetLibrary('DJUI')

if DJUI.unitFrames.player then
	return
end

local player = DJUI.unitFrames.unitFrame()
DJUI.unitFrames.player = player

local tag = 'player'
local inCombat = false
local cinematic = false
player.tag = tag

local function complete()
	player:HideLogic()
end

player.health:SetBarColor(0.8, 0.1, 0.15, 1)
player.health:SetAnimationCompleteListener(complete)

player.magicka:SetBarColor(0.1, 0.1, 0.6, 1)
player.magicka:SetAnimationCompleteListener(complete)

player.stamina:SetBarColor(0.05, 0.6, 0.03, 1)
player.stamina:SetAnimationCompleteListener(complete)

function player:SetBarValues(powerType, val, max, effMax)
	if player.bars[powerType] then
		if not val then
   		val, max, effMax = GetUnitPower(tag, powerType)
   	end
   	player.bars[powerType]:SetValue(val, max)
	end
	
end

function player:HideLogic()
	if inCombat then
		self:Show()
		return
	end
	if cinematic then
		self:Hide()
		return
	end
	
	if self.health:GetPercentage() == 100 and
		self.stamina:GetPercentage() == 100 and
		self.magicka:GetPercentage() == 100 then
		self:Hide(0.15)
	else
		self:Show()
	end
end

DJUI:AddLoad(function(saved)
	player:SetDimensions(unpack(saved.unitFrames.player.dimensions))
	player:SetAnchor(unpack(saved.unitFrames.player.position))

	player.level:SetText(GetUnitLevel(tag))
	player.name:SetText(GetUnitName(tag))
	
	player:SetBarValues(POWERTYPE_HEALTH)
	player:SetBarValues(POWERTYPE_MAGICKA)
	player:SetBarValues(POWERTYPE_STAMINA)
	
	ZO_PlayerAttributeHealth:SetHidden(true)
	ZO_PlayerAttributeMagicka:SetHidden(true)
	ZO_PlayerAttributeStamina:SetHidden(true)
end)

DJUI:AddEvent(EVENT_POWER_UPDATE, function(_, unitTag, _, type, val, max, effMax)
	if (unitTag == tag) then
		player:SetBarValues(type, val, max, effMax)
	end
end)

DJUI:AddEvent(EVENT_PLAYER_COMBAT_STATE, function(_, combatState)
	inCombat = combatState
	player:HideLogic()
end)

DJUI:AddEvent(EVENT_GAME_CAMERA_ACTIVATED, function()
	cinematic = false
	player:HideLogic()
end)

DJUI:AddEvent(EVENT_GAME_CAMERA_DEACTIVATED, function()
	cinematic = true
	player:HideLogic()
end)
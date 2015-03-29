----------------------------------------------------------------------------------
-- Created by: Brandon Talbot ( -_Dark-Jaguar_- )                               --
----------------------------------------------------------------------------------
local unitFrames = {}
unitFrames.__index = unitFrames
unitFrames.inCombat = false

--region Player object
unitFrames.player = {}
unitFrames.player.__index = unitFrames.player
unitFrames.player.tag = 'player'
unitFrames.player.frame = DJPlayerFrame
unitFrames.player.rechargingAlpha = 0.45
unitFrames.player.chargedAlpha = 0.1

function unitFrames.player:Init()
	unitFrames:createHideAnimation(self.frame, 800)
	unitFrames:InitFrame(self.tag)
	self:HideLogic()
end

function unitFrames.player:HideLogic()
	self.frame.hideTimeline:Stop()
	if unitFrames.inCombat then
		self.frame:SetAlpha(1)
		return
	end

	local recharging = false

	local bar = unitFrames:getBar(self.tag, POWERTYPE_HEALTH)
	local _, max = bar:GetMinMax()
	if bar:GetValue() ~= max then
		recharging = true
	end

	bar = unitFrames:getBar(self.tag, POWERTYPE_MAGICKA)
	_, max = bar:GetMinMax()
	if bar:GetValue() ~= max then
		recharging = true
	end	

	bar = unitFrames:getBar(self.tag, POWERTYPE_STAMINA)
	_, max = bar:GetMinMax()
	if bar:GetValue() ~= max then
		recharging = true
	end

	if recharging then
		self.frame.hideAnimation:SetAlphaValues(self.frame:GetAlpha(), self.rechargingAlpha)
		self.frame.hideTimeline:PlayFromStart()
	else
		self.frame.hideAnimation:SetAlphaValues(self.frame:GetAlpha(), self.chargedAlpha)
		self.frame.hideTimeline:PlayFromStart()
	end
end

--endregion

--region Target object
unitFrames.target = {}
unitFrames.target.__index = unitFrames.target
unitFrames.target.tag = 'reticleover'
unitFrames.target.frame = DJTargetFrame

function unitFrames.target:Init()
	local tag = self.tag
	if DoesUnitExist(tag) then
		self.frame:SetAlpha(1)
		unitFrames:InitFrame(tag)
	else
		self.frame:SetAlpha(0)
	end
end

function unitFrames.target:HideLogic()
	-- nofink its a stub o.0
end

--endregion

--region Global Constants
unitFrames.barTexts = {
	[POWERTYPE_HEALTH] = 'Health',
	[POWERTYPE_MAGICKA] = 'Magika',
	[POWERTYPE_STAMINA] = 'Stamina',
}

unitFrames.tagTexts = {
	['player'] = 'Player',
	['reticleover'] = 'Target',
}

--endregion

--region UI Item Getters
function unitFrames:getUnitObject(tag) 
	if tag == 'player' then
		return self.player
	elseif tag == 'reticleover' then
		return self.target
	end
end

function unitFrames:getBarParent(tag, type)
	local tagText, typeText = unitFrames.tagTexts[tag], unitFrames.barTexts[type]

	if tagText and typeText then
		return _G['DJ' .. tagText .. typeText]
	end 	
end

function unitFrames:getBar(tag, type)
	local tagText, typeText = unitFrames.tagTexts[tag], unitFrames.barTexts[type]

	if tagText and typeText then
		return _G['DJ' .. tagText .. typeText .. 'Bar']
	end 	
end

function unitFrames:getPercentageText(tag, type)
	local tagText, typeText = unitFrames.tagTexts[tag], unitFrames.barTexts[type]

	if tagText and typeText then
		return _G['DJ' .. tagText .. typeText .. 'BarPercentageText']
	end 	
end

function unitFrames:getValueText(tag, type)
	local tagText, typeText = unitFrames.tagTexts[tag], unitFrames.barTexts[type]

	if tagText and typeText then
		return _G['DJ' .. tagText .. typeText .. 'BarValueText']
	end 	
end

function unitFrames:getNameLabel(tag)
	local tagText = unitFrames.tagTexts[tag]

	if tagText then
		return _G['DJ' .. tagText .. "NameLabel"]
	end
end

function unitFrames:getLevelLabel(tag)
	local tagText = unitFrames.tagTexts[tag]

	if tagText then
		return _G['DJ' .. tagText .. "LevelLabel"]
	end
end

--endregion

--region Animation Constructors
function unitFrames:createBarAnimation(bar, type, tag)
	bar.updateAnimation, bar.updateTimeline = CreateSimpleAnimation(ANIMATION_CUSTOM, bar)
	bar.updateTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
	bar.updateAnimation:SetDuration(400)

	bar.updateAnimation.startVal = 0
	bar.updateAnimation.endVal = 0
	bar.updateAnimation.difference = 0
	bar.updateAnimation.maxVal = 0

	bar.updateAnimation:SetUpdateFunction(function(_, percentage)
		local value = zo_round(bar.updateAnimation.startVal + bar.updateAnimation.difference * percentage)
		unitFrames:UpdatePowerDetails(tag, type, value, bar.updateAnimation.maxVal)
	end)
end

function unitFrames:createHideAnimation(frame, duration)
	frame.hideAnimation, frame.hideTimeline = CreateSimpleAnimation(ANIMATION_ALPHA, frame)

	frame.hideAnimation:SetDuration(duration or 1000)
	frame.hideTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
end
--endregion

--region Init methods
function unitFrames:InitPowerDetails(unitTag, barType, value, max)
	self:UpdatePowerDetails(unitTag, barType, value, max)

	local bar = self:getBar(unitTag, barType)
	local par = self:getBarParent(unitTag, barType)

	if bar and par then
		if max == 0 then
			par:SetAlpha(0)
		else
			par:SetAlpha(1)
		end
		
		bar:SetColor(unpack(DJUI.constants.colors[barType]))

		unitFrames:createBarAnimation(bar, barType, unitTag)
	end
end


function unitFrames:InitializeUnitFrame(tag)
	local obj = self:getUnitObject(tag)
	if obj then
		obj:Init()
	end
end

function unitFrames:InitFrame(tag)
	local nameLabel = unitFrames:getNameLabel(tag)
	if nameLabel then
		nameLabel:SetText(GetUnitName(tag))
	end
	local levelLabel = unitFrames:getLevelLabel(tag)
	if levelLabel then
		levelLabel:SetText(GetUnitLevel(tag))
	end

	local val, max = GetUnitPower(tag, POWERTYPE_HEALTH)
	unitFrames:InitPowerDetails(tag, POWERTYPE_HEALTH, val, max)

	val, max = GetUnitPower(tag, POWERTYPE_MAGICKA)
	unitFrames:InitPowerDetails(tag, POWERTYPE_MAGICKA, val, max)

	val, max = GetUnitPower(tag, POWERTYPE_STAMINA)
	unitFrames:InitPowerDetails(tag, POWERTYPE_STAMINA, val, max)
end
--endregion

--region Update methods
function unitFrames:UpdatePowerDetails(unitTag, barType, value, max)
	local bar = self:getBar(unitTag, barType)
	if bar then
		bar:SetMinMax(0, max)
		bar:SetValue(value)
	end

	local percentageText = self:getPercentageText(unitTag, barType)
	if percentageText then
		percentageText:SetText(zo_floor(value / max * 100) .. "%")
	end

	local valueText = self:getValueText(unitTag, barType)
	if valueText then
		valueText:SetText(value)
	end

	unitFrames:getUnitObject(unitTag):HideLogic()
end
--endregion

--region Event Management
DJUI:AddPlugin("DJUnitFrames", unitFrames, function()
	unitFrames:InitializeUnitFrame('player')
	unitFrames:InitializeUnitFrame('reticleover')
	ZO_PlayerAttributeHealth:SetHidden(true)
	ZO_PlayerAttributeMagicka:SetHidden(true)
	ZO_PlayerAttributeStamina:SetHidden(true)
	_G["ZO_TargetUnitFramereticleover"]:SetAnchor(TOPRIGHT, nil, nil, -100, -100)
end)

DJUI:AddEvent(EVENT_POWER_UPDATE, function(_, unitTag, _, powerType, value, max)
	local bar = unitFrames:getBar(unitTag, powerType)
	if bar and bar.updateTimeline then
		bar.updateTimeline:Stop()
		bar.updateAnimation.startVal = bar:GetValue()
		bar.updateAnimation.endVal = value
		bar.updateAnimation.difference = value - bar.updateAnimation.startVal
		bar.updateAnimation.maxVal = max
		bar.updateTimeline:PlayFromStart()
	end
end)

DJUI:AddEvent(EVENT_RETICLE_TARGET_CHANGED, function()
	unitFrames:InitializeUnitFrame('reticleover')
end)

DJUI:AddEvent(EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
	d(inCombat)
	unitFrames.inCombat = inCombat
	unitFrames.player:HideLogic()
end)
--endregion
----------------------------------------------------------------------------------
-- Created by: Brandon Talbot ( -_Dark-Jaguar_- )                               --
----------------------------------------------------------------------------------

local playerPlugin = {}
playerPlugin.__index = playerPlugin;
playerPlugin.unitTag = 'player'

playerPlugin.bars = {
	[POWERTYPE_HEALTH] = DJPlayerHealthBar,
	[POWERTYPE_MAGICKA] = DJPlayerMagikaBar,
	[POWERTYPE_STAMINA] = DJPlayerStaminaBar,
}

playerPlugin.percentageTexts = {
	[POWERTYPE_HEALTH] = DJPlayerHealthBarPercentageText,
	[POWERTYPE_MAGICKA] = DJPlayerMagikaBarPercentageText,
	[POWERTYPE_STAMINA] = DJPlayerStaminaBarPercentageText,
}

playerPlugin.valueTexts = {
	[POWERTYPE_HEALTH] = DJPlayerHealthBarValueText,
	[POWERTYPE_MAGICKA] = DJPlayerMagikaBarValueText,
	[POWERTYPE_STAMINA] = DJPlayerStaminaBarValueText,
}

--region Functions

local function createBarAnimation(bar, type)
	bar.updateAnimation, bar.updateTimeline = CreateSimpleAnimation(ANIMATION_CUSTOM, bar)
	bar.updateTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
	bar.updateAnimation:SetDuration(400)

	bar.updateAnimation.startVal = 0
	bar.updateAnimation.endVal = 0
	bar.updateAnimation.difference = 0
	bar.updateAnimation.maxVal = 0

	bar.updateAnimation:SetUpdateFunction(function(_, percentage)
		local value = zo_round(bar.updateAnimation.startVal + bar.updateAnimation.difference * percentage)
		playerPlugin:UpdatePowerDetails(type, value, bar.updateAnimation.maxVal)
	end)
end

--endregion

--region Update Funcs

function playerPlugin:InitPowerDetails(barType, value, max)
	self:UpdatePowerDetails(barType, value, max)

	local bar = self.bars[barType]

	if bar then
		bar:SetColor(unpack(DJUI.constants.colors[barType]))
		createBarAnimation(bar, barType)
	end
end

function playerPlugin:UpdatePowerDetails(barType, value, max)
	local bar = self.bars[barType]
	if bar then
		bar:SetMinMax(0, max)
		bar:SetValue(value)
	end

	local percentageText = self.percentageTexts[barType]
	if percentageText then
		percentageText:SetText(zo_floor(value / max * 100) .. "%")
	end

	local valueText = self.valueTexts[barType]
	if valueText then
		valueText:SetText(value)
	end
end

--endregion

--region Events
playerPlugin.onLoadFunction = function()
	DJPlayerNameLabel:SetText(GetUnitName(playerPlugin.unitTag))

	local val, max = GetUnitPower(playerPlugin.unitTag, POWERTYPE_HEALTH)
	playerPlugin:InitPowerDetails(POWERTYPE_HEALTH, val, max)

	val, max = GetUnitPower(playerPlugin.unitTag, POWERTYPE_MAGICKA)
	playerPlugin:InitPowerDetails(POWERTYPE_MAGICKA, val, max)

	val, max = GetUnitPower(playerPlugin.unitTag, POWERTYPE_STAMINA)
	playerPlugin:InitPowerDetails(POWERTYPE_STAMINA, val, max)
end

playerPlugin.onPowerUpdateEvent = function(_, unitTag, _, powerType, value, max)
	if unitTag == playerPlugin.unitTag then
		local bar = playerPlugin.bars[powerType]
		if bar then
			bar.updateTimeline:Stop()
			bar.updateAnimation.startVal = bar:GetValue()
			bar.updateAnimation.endVal = value
			bar.updateAnimation.difference = value - bar.updateAnimation.startVal
			bar.updateAnimation.maxVal = max
			bar.updateTimeline:PlayFromStart()
		end
	end
end
--endregion

-- DJUI:AddPlugin("DJPlayer", playerPlugin, playerPlugin.onLoadFunction)
-- DJUI:AddEvent(EVENT_POWER_UPDATE, playerPlugin.onPowerUpdateEvent)
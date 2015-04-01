local player = DJUnitFrame()
local tag = 'player'
player.tag = tag

player:SetDimensions(300, 80)
player:SetAnchor(CENTER, GuiRoot, CENTER, -300, 400)

player.health:SetBarColor(0.8, 0.1, 0.15, 1)
player.health:SetBorderSize(2)
player.health:SetBorderColor(0, 0, 0, 1)

player.magicka:SetBarColor(0.1, 0.1, 0.6, 1)
player.magicka:SetBorderSize(2)
player.magicka:SetBorderColor(0, 0, 0, 1)

player.stamina:SetBarColor(0.05, 0.6, 0.03, 1)
player.stamina:SetBorderSize(2)
player.stamina:SetBorderColor(0, 0, 0, 1)

function player:SetBarValues(powerType, val, max, effMax)
	if player.bars[powerType] then
		if not val then
   		val, max, effMax = GetUnitPower(tag, powerType)
   	end
   	player.bars[powerType]:SetValue(val, max)
	end
end

DJUI:AddPlugin('Player', player, function()
	player.level:SetText(GetUnitLevel(tag))
	player.name:SetText(GetUnitName(tag))
	
	player:SetBarValues(POWERTYPE_HEALTH)
	player:SetBarValues(POWERTYPE_MAGICKA)
	player:SetBarValues(POWERTYPE_STAMINA)
end)

DJUI:AddEvent(EVENT_POWER_UPDATE, function(_, unitTag, _, type, val, max, effMax)
	if (unitTag == tag) then
		player:SetBarValues(type, val, max, effMax)
	end
end)
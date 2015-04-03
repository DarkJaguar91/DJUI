local target = DJUnitFrame(true)
local tag = 'reticleover'
target.tag = tag

target:SetDimensions(300, 80)
target:SetAnchor(CENTER, GuiRoot, CENTER, 300, 400)

target.health:SetBarColor(0.8, 0.1, 0.15, 1)

target.magicka:SetBarColor(0.1, 0.1, 0.6, 1)

target.stamina:SetBarColor(0.05, 0.6, 0.03, 1)

function target:SetBarValues(powerType, val, max, effMax)
	if target.bars[powerType] then
		if not val then
   		val, max, effMax = GetUnitPower(tag, powerType)
   	end
   	
   	if (max ~= 0) then
   		target.bars[powerType]:SetValue(val, max)
   		target.bars[powerType]:Show()	
   	else
   		target.bars[powerType]:Hide()
   	end
   	
	end
end

function target:Init()
	target.level:SetText(GetUnitLevel(tag))
	target.name:SetText(GetUnitName(tag))
	
	target:SetBarValues(POWERTYPE_HEALTH)
	target:SetBarValues(POWERTYPE_MAGICKA)
	target:SetBarValues(POWERTYPE_STAMINA)
	
	target:Show()
end

DJUI:AddPlugin('Target', target, function()
	target:Hide()
end)

DJUI:AddEvent(EVENT_RETICLE_TARGET_CHANGED, function(_)
	if DoesUnitExist(tag) then
		target:Init()
	else
		target:Hide()
	end
end)

DJUI:AddEvent(EVENT_POWER_UPDATE, function(_, unitTag, _, type, val, max, effMax)
	if (unitTag == tag) then
		target:SetBarValues(type, val, max, effMax)
	end
end)
local unitFrame = {}
unitFrame.__index = unitFrame

function unitFrame:__init__(reverse)
	self.tlw = CreateTopLevelWindow()
	self.reverse = reverse
	self:CreateUIElements()
	self:CreateAnimations()
	
	self:SetMetaTable()
end

function unitFrame:CreateUIElements()
	self.level = CreateControl(nil, self.tlw, CT_LABEL)
	self.level:SetAnchor(self.reverse and TOPRIGHT or TOPLEFT)
	self.level:SetFont('$(MEDIUM_FONT)|20|soft-shadow-thick')
	self.level:SetColor(0.6, 0.6, 0.6, 1)
	self.level:SetText('10')

	self.name = CreateControl(nil, self.tlw, CT_LABEL)
	self.name:SetAnchor(self.reverse and TOPRIGHT or TOPLEFT, self.level, self.reverse and TOPLEFT or TOPRIGHT, self.reverse and -10 or 10)
	self.name:SetFont('$(MEDIUM_FONT)|20|soft-shadow-thin')
	self.name:SetColor(0.6, 0.6, 0.6, 1)
	self.name:SetText('Name')

	self.health = DJStatusBar(self.tlw, self.reverse)
	self.health:SetHeight(20)
	self.health:SetAnchor(TOPLEFT, self.tlw, TOPLEFT, nil, self.level:GetHeight())
	self.health:SetAnchor(TOPRIGHT, self.tlw, TOPRIGHT, nil, self.level:GetHeight())
	self.health:SetBarColor(1, 0, 0, 1)
	self.health:SetBorderCenterColor(0, 0, 0, 0)
	self.health:SetBorderEdgeColor(0, 0, 0, 0)
	
	self.magicka = DJStatusBar(self.tlw, self.reverse)
	self.magicka:SetHeight(20)
	self.magicka:SetAnchor(TOPLEFT, self.health.border, BOTTOMLEFT)
	self.magicka:SetAnchor(TOPRIGHT, self.health.border, BOTTOMRIGHT)
	self.magicka:SetBarColor(0, 0, 1, 1)
	self.magicka:SetBorderCenterColor(0, 0, 0, 0)
	self.magicka:SetBorderEdgeColor(0, 0, 0, 0)
	
	self.stamina = DJStatusBar(self.tlw, self.reverse)
	self.stamina:SetHeight(20)
	self.stamina:SetAnchor(TOPLEFT, self.magicka.border, BOTTOMLEFT)
	self.stamina:SetAnchor(TOPRIGHT, self.magicka.border, BOTTOMRIGHT)
	self.stamina:SetBarColor(0, 1, 0, 1)
	self.stamina:SetBorderCenterColor(0, 0, 0, 0)
	self.stamina:SetBorderEdgeColor(0, 0, 0, 0)
	
	self.bars = {
		[POWERTYPE_HEALTH] = self.health,
		[POWERTYPE_MAGICKA] = self.magicka,
		[POWERTYPE_STAMINA] = self.stamina,
	}
end

function unitFrame:CreateAnimations()
	self.hideAnimation, self.hideTimeline = CreateSimpleAnimation(ANIMATION_ALPHA, self.tlw)
	self.hideTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
	
	self.hideAnimation:SetDuration(600)
end

function unitFrame:Show()
	self.hideTimeline:Stop()
	self.hideAnimation:SetAlphaValues(self.tlw:GetAlpha(), 1)
	self.hideTimeline:PlayFromStart()
end

function unitFrame:Hide()
	self.hideTimeline:Stop()
	self.hideAnimation:SetAlphaValues(self.tlw:GetAlpha(), 0)
	self.hideTimeline:PlayFromStart()
end

function unitFrame:SetMetaTable()
	local metaTable = getmetatable(self)
	
	local oldIndex = metaTable.__index
	
	metaTable.__index = function(_, key)
		if type(oldIndex) == 'function' then
			local obj = oldIndex(metaTable, key)
			if obj then return obj end
		elseif oldIndex[key] then
			return oldIndex[key]
		end
		
		if self.tlw[key] then
			return function(_, ...)
				return self.tlw[key](self.tlw, ...)
			end
		end
	end
end

DJClass 'DJUnitFrame'(unitFrame)

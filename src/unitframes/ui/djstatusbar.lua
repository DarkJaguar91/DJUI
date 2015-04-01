local statusBarObj = {}
statusBarObj.__index = statusBarObj

function statusBarObj:__init__(TLW, reverse)
	self.tlw = TLW or CreateTopLevelWindow()
	self.reverse = reverse
	self:CreateUIElements()
	self:CreateAnimations()
	self:CreateMetaTable()
end

function statusBarObj:CreateUIElements()
	self.border = CreateControl(nil, self.tlw, CT_BACKDROP)
	self.border:SetCenterColor(0, 0, 0, 0)
	self.border:SetEdgeColor(0, 0, 0, 0)
	self.border:SetDrawLayer(0)
	self.border:SetDrawLevel(2)
	
	self.background = CreateControl(nil, self.border, CT_TEXTURE)
	self.background:SetColor(0.6, 0.6, 0.6, 0.2)
	self.background:SetAnchor(TOPLEFT)
		self.background:SetAnchor(BOTTOMRIGHT)
	
	self.bar = CreateControl(nil, self.border, CT_STATUSBAR)
	self.bar:SetAnchor(TOPLEFT)
	self.bar:SetAnchor(BOTTOMRIGHT)
	self.bar:SetMinMax(0, 100)
	self.bar:SetValue(50)
	self.bar:SetDrawLayer(0)
	self.bar:SetDrawLevel(1)
	self.bar:SetBarAlignment(self.reverse and BAR_ALIGNMENT_REVERSE or BAR_ALIGNMENT_NORMAL)
	
	self.glow = CreateControl(nil, self.border, CT_TEXTURE)
	self.glow:SetColor(0, 0, 0, 0)
	self.glow:SetAnchor(TOPLEFT)
	self.glow:SetAnchor(BOTTOMRIGHT)
	self.glow:SetDrawLayer(0)
	self.glow:SetDrawLevel(3)
	
	self.percent = CreateControl(nil, self.border, CT_LABEL)
	self.percent:SetColor(0, 0, 0, 1)
	self.percent:SetFont('$(CHAT_FONT)|12|shadow')
	self.percent:SetAnchor(self.reverse and TOPLEFT or TOPRIGHT, nil, nil, self.reverse and 5 or -5, -1)
	
	self.value = CreateControl(nil, self.border, CT_LABEL)
	self.value:SetColor(0, 0, 0, 1)
	self.value:SetFont('$(CHAT_FONT)|12|shadow')
	self.value:SetAnchor(self.reverse and TOPRIGHT or TOPLEFT, nil, nil, self.reverse and -5 or 5, -1)
end

function statusBarObj:CreateAnimations()
	self.updateAnimation, self.updateTimeline = CreateSimpleAnimation(ANIMATION_CUSTOM, self.bar)
	self.updateTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
	self.updateAnimation:SetDuration(400)

	self.updateAnimation.startVal = 0
	self.updateAnimation.difference = 0

	self.updateAnimation:SetUpdateFunction(function(_, percentage)
		local value = zo_round(self.updateAnimation.startVal + self.updateAnimation.difference * percentage)
		self:UpdateDetails(value)
	end)
end

function statusBarObj:CreateMetaTable()
	local metaTable = getmetatable(self)
	
	local oldIndex = metaTable.__index
	
	metaTable.__index = function(_, key)
		if type(oldIndex) == 'function' then
			local obj = oldIndex(metaTable, key)
			if obj then return obj end
		elseif oldIndex[key] then
			return oldIndex[key]
		end
	
		local _begin, _end, prefix, suffix = tostring(key):find('(.*)Bar(.*)')
		if prefix or suffix then
			if self.bar[prefix .. suffix] then
				return function(_, ...)
					return self.bar[prefix .. suffix](self.bar, ...)
				end
			end
		end
		
		_begin, _end, prefix, suffix = tostring(key):find('(.*)Border(.*)')
		if prefix or suffix then
			if self.border[prefix .. suffix] then
				return function(_, ...)
					return self.border[prefix .. suffix](self.border, ...)
				end
			end
		end
		
		_begin, _end, prefix, suffix = tostring(key):find('(.*)Glow(.*)')
		if prefix or suffix then
			if self.glow[prefix .. suffix] then
				return function(_, ...)
					return self.glow[prefix .. suffix](self.glow, ...)
				end
			end
		end
	end
end

function statusBarObj:SetBorderColor(r, g, b, a)
	self.border:SetEdgeColor(r, g, b, a)
end

function statusBarObj:SetBorderSize(w)
	self.border:SetEdgeTexture(nil, 2, 2, w)
	self.bar:SetAnchor(TOPLEFT, nil, nil, w, w)
	self.bar:SetAnchor(BOTTOMRIGHT, nil, nil, -w, -w)
end

function statusBarObj:SetValue(value, max, min)
	if max then
		self.bar:SetMinMax(min or 0, max)
	end

	self.updateTimeline:Stop()
	self.updateAnimation.startVal = self.bar:GetValue()
	self.updateAnimation.difference = value - self.updateAnimation.startVal
	self.updateTimeline:PlayFromStart()
end

function statusBarObj:UpdateDetails(current)
	local _, max = self.bar:GetMinMax()
	
	self.bar:SetValue(current)	
	self.percent:SetText(math.floor(current / max * 100) .. '%')
	self.value:SetText(current)
end

function statusBarObj:SetAnchor(point, relativeTo, relativePoint, xoff, yoff)
	self.border:SetAnchor(point, relativeTo, relativePoint, xoff, yoff)
end

function statusBarObj:SetDimensions(w, h)
	self.border:SetDimensions(w, h)
end

function statusBarObj:SetWidth(w)
	self.border:SetWidth(w)
end

function statusBarObj:SetHeight(h)
	self.border:SetHeight(h)
	self.percent:SetFont('$(CHAT_FONT)|' .. math.floor(h*0.8) .. '|shadow')
	self.value:SetFont('$(CHAT_FONT)|' .. math.floor(h*0.8) .. '|shadow')
end

function statusBarObj:Show()
	self.border:SetAlpha(1)
end

function statusBarObj:Hide()
	self.border:SetAlpha(0)
end

DJClass 'DJStatusBar'(statusBarObj)
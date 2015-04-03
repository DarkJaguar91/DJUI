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
	self.border = CreateControl(nil, self.tlw, CT_TEXTURE)
	self.border:SetTexture('/esoui/art/miscellaneous/progressbar_frame.dds')
	self.border:SetDrawLayer(0)
	self.border:SetDrawLevel(3)
	self.border:SetTextureCoords(0, 0.612, 0, 0.6)
	self.border:SetTextureRotation(self.reverse and 3.14159265 or 0)
	
	self.background = CreateControl(nil, self.border, CT_TEXTURE)
	self.background:SetAnchorFill(self.border)
	self.background:SetDrawLayer(0)
	self.background:SetDrawLevel(1)
	self.background:SetTexture('/esoui/art/miscellaneous/progressbar_frame_bg.dds')
	self.background:SetTextureCoords(0, 0.612, 0, 6)
	self.background:SetTextureRotation(self.reverse and 3.14159265 or 0)
	
	self.bar = CreateControl(nil, self.border, CT_STATUSBAR)
	self.bar:SetAnchorFill(self.border)
	self.bar:SetMinMax(0, 100)
	self.bar:SetValue(50)
	self.bar:SetDrawLayer(0)
	self.bar:SetDrawLevel(2)
	self.bar:SetBarAlignment(self.reverse and BAR_ALIGNMENT_REVERSE or BAR_ALIGNMENT_NORMAL)
	self.bar:SetTexture('/esoui/art/miscellaneous/progressbar_genericfill.dds')
	self.bar:SetTextureCoords(0, 1, 0, 0.6)
   self.bar:EnableLeadingEdge(true)
   self.bar:SetLeadingEdge('/esoui/art/miscellaneous/progressbar_genericfill_leadingedge.dds', 10, 20)
   self.bar:SetLeadingEdgeTextureCoords(0, 1, 0, 0.6)	
   
   self.glow = CreateControl(nil, self.border, CT_STATUSBAR)
	self.glow:SetAnchorFill(self.border)
	self.glow:SetColor(1, 1, 1, 0.8)
	self.glow:SetDrawLayer(0)
	self.glow:SetDrawLevel(2)
	self.glow:SetBarAlignment(self.reverse and BAR_ALIGNMENT_REVERSE or BAR_ALIGNMENT_NORMAL)
	self.glow:SetTexture('/esoui/art/miscellaneous/progressbar_genericfill_gloss.dds')
	self.glow:SetTextureCoords(0, 1, 0, 0.6)	
	self.glow:SetLeadingEdge('/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds', 10, 20)
   self.glow:SetLeadingEdgeTextureCoords(0, 1, 0, 0.6)	
		
	self.percent = CreateControl(nil, self.border, CT_LABEL)
	self.percent:SetColor(0.6, 0.6, 0.6, 1)
	self.percent:SetFont('$(CHAT_FONT)|8|shadow')
	self.percent:SetAnchor(self.reverse and TOPLEFT or TOPRIGHT, nil, nil, self.reverse and 10 or -10)
	self.percent:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	
	self.value = CreateControl(nil, self.border, CT_LABEL)
	self.value:SetColor(0.6, 0.6, 0.6, 1)
	self.value:SetFont('$(CHAT_FONT)|8|shadow')
	self.value:SetAnchor(self.reverse and TOPRIGHT or TOPLEFT, nil, nil, self.reverse and -3 or 3)
	self.value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
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

function statusBarObj:SetValue(value, max, min)
	if max then
		self.bar:SetMinMax(min or 0, max)
		self.glow:SetMinMax(min or 0, max)
	end

	self.updateTimeline:Stop()
	self.updateAnimation.startVal = self.bar:GetValue()
	self.updateAnimation.difference = value - self.updateAnimation.startVal
	self.updateTimeline:PlayFromStart()
end

function statusBarObj:UpdateDetails(current)
	local _, max = self.bar:GetMinMax()
	
	self.bar:SetValue(current)	
	self.glow:SetValue(current)
	self.percent:SetText(self:GetPercentage() .. '%')
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
	self.percent:SetHeight(h)
	self.percent:SetFont('$(CHAT_FONT)|' .. math.floor(h*0.6) .. '|shadow')
	self.value:SetHeight(h)
	self.value:SetFont('$(CHAT_FONT)|' .. math.floor(h*0.6) .. '|shadow')
end

function statusBarObj:GetPercentage()
	local min, max = self.bar:GetMinMax()
	return math.floor(self.bar:GetValue() / max * 100)
end

function statusBarObj:Show()
	self.border:SetAlpha(1)
end

function statusBarObj:Hide()
	self.border:SetAlpha(0)
end

function statusBarObj:SetAnimationCompleteListener(func)
	self.updateTimeline:SetHandler('OnStop', func)
end

DJClass 'DJStatusBar'(statusBarObj)
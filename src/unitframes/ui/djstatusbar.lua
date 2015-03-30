local statusBarObj = {}
statusBarObj.__index = statusBarObj

function statusBarObj:__init__(TLW)
	self.tlw = TLW or CreateTopLevelWindow()
	self:CreateUIElements()
	self:CreateMetaTable()
end

function statusBarObj:CreateUIElements()
	self.border = CreateControl(nil, self.tlw, CT_BACKDROP)
	self.border:SetCenterColor(0, 0, 0, 0)
	self.border:SetEdgeColor(0, 0, 0, 0)
	self.bar = CreateControl(nil, self.border, CT_STATUSBAR)
	
	self.bar:SetAnchor(TOPLEFT)
	self.bar:SetAnchor(BOTTOMRIGHT)
	self.bar:SetMinMax(0, 100)
	self.bar:SetValue(50)
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
	end
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
end

DJClass 'DJStatusBar'(statusBarObj)
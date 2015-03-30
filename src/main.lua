require('class/Class')

local statusBarObj = {}
statusBarObj.__index = statusBarObj

function statusBarObj:__init__()
	self:CreateUIElements()
end

function statusBarObj:CreateUIElements()
	self.faggot = 'lol'
end

DJClass 'DJStatusBar'(statusBarObj)
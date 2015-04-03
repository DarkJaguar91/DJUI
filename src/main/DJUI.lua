----------------------------------------------------------------------------------
-- Created by: Brandon Talbot ( -_Dark-Jaguar_- )                               --
----------------------------------------------------------------------------------

DJUI = {}
DJUI.__index = DJUI

DJUI.plugins = {}
DJUI.onLoadFuncs = {}
DJUI.events = {}

DJUI.addonName = 'DJUI'

--region Plugin Regestering
function DJUI:AddPlugin(name, plugin, onLoadFunction)
	assert(not self.plugins[name], "Error: Plugin already added with that name!")
	assert(plugin, "Error: Plugin expected, received nil!")

	self.plugins[name] = plugin

	if onLoadFunction then
		table.insert(DJUI.onLoadFuncs, onLoadFunction)
	end
end

EVENT_MANAGER:RegisterForEvent(DJUI.addonName, EVENT_ADD_ON_LOADED, function (_, addonName)
	if addonName ~= DJUI.addonName then return end

	for _, v in pairs(DJUI.onLoadFuncs) do
		v()
	end

	EVENT_MANAGER:UnregisterForEvent(DJUI.addonName, EVENT_ADD_ON_LOADED)
end)

--endregion

--region Event Management

function DJUI:AddEvent(eventName, eventFunction)
	assert(eventName, "Error: Event name needed, received nil")
	assert(eventFunction, "Error: Event function needed, received nil ")
	assert(type(eventFunction) == 'function', "Error: Event function must be a function")

	if self.events[eventName] then
		d('Already Exists - adding func')
		table.insert(self.events[eventName], eventFunction)
		return
	end

	self.events[eventName] = {eventFunction}

	local function eventCall(...)
		for _, v in pairs(self.events[eventName]) do
			v(...)
		end
	end

	EVENT_MANAGER:RegisterForEvent(DJUI.addonName, eventName, eventCall)
end

--endregion

SLASH_COMMANDS['/rl'] = function ()
	ReloadUI()
end
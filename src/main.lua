DJUI = {}
DJUI.__index = DJUI

DJUI.name = 'DJUI'

DJUI.plugins = {}
function DJUI:AddPlugin(pluginName, plugin, loadFunction)
	DJUI.plugins[pluginName] = plugin
	plugin.loadFunc = loadFunction
end

DJUI.events = {}
function DJUI:AddEvent(event, func)
	if not DJUI.events[event] then
		DJUI.events[event] = {}
		
		EVENT_MANAGER:RegisterForEvent(DJUI.name, event, function(...)
			for k, v in pairs(DJUI.events[event]) do
				v(...)
			end
		end)
	end
	
	table.insert(DJUI.events[event], func)
end

EVENT_MANAGER:RegisterForEvent(DJUI.name, EVENT_ADD_ON_LOADED, function(_, addonName)
	if addonName == DJUI.name then
			
		for k, v in pairs(DJUI.plugins) do
			if v.loadFunc then
				v.loadFunc()
			end
		end
		
		EVENT_MANAGER:UnregisterForEvent(DJUI.name, EVENT_ADD_ON_LOADED)
	end
end)

if not SLASH_COMMANDS['/rl'] then
	SLASH_COMMANDS['/rl'] = function()
		ReloadUI()
	end
end

local VERSION = 0.1
local NAME = "DJUI"

local DJUI = LibStub:NewLibrary(NAME, VERSION)

if not DJUI then
  return    -- already loaded and no upgrade necessary
end

DJUI.name = NAME
DJUI.version = VERSION
DJUI.__index = DJUI
DJUI.unitFrames = {} -- declare unit frames handle

DJUI.onLoadFuncs = nil
function DJUI:AddLoad(loadFunction)
	assert(loadFunction and type(loadFunction) == 'function', 'Load Functions need to be of type Function')
	if not DJUI.onLoadFuncs then
		DJUI.onLoadFuncs = {}
		
		EVENT_MANAGER:RegisterForEvent(DJUI.name, EVENT_ADD_ON_LOADED, function(_, name)
			if DJUI.name == name then
				for k, v in pairs(DJUI.onLoadFuncs) do
					v(DJUI.saved)
				end
				
				EVENT_MANAGER:UnregisterForEvent(DJUI.name, EVENT_ADD_ON_LOADED)
			end
		end)
	end
	
	table.insert(DJUI.onLoadFuncs, loadFunction)
end

DJUI.events = {}
function DJUI:AddEvent(event, func)
	assert(func and type(func) == 'function', 'Events need to be of type Function')
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

if not SLASH_COMMANDS['/rl'] then
	SLASH_COMMANDS['/rl'] = function()
		ReloadUI()
	end
end
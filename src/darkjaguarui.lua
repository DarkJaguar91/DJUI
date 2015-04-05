--
-- Created by
-- User: Brandon
-- Date: 2015-04-04
-- Time: 10:17 PM
--

local NAME, VERSION = 'DJUI', 0.01

local DJUI = LibStub:NewLibrary(NAME, VERSION)

if not DJUI then
    return    -- already loaded and no upgrade necessary
end

DJUI.name = NAME
DJUI.version = VERSION
DJUI.__index = DJUI

--region Load Functions

DJUI.onLoadFunctions = nil

function DJUI:AddLoad(func)
    assert(func and type(func) == 'function', 'Requires a function as the first paramenter')

    if not self.onLoadFunctions then
        self.onLoadFunctions = {}

        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, function(_, addonName)
            if addonName ~= self.name then return end

            for _, v in pairs(self.onLoadFunctions) do
                v(DJUI.saved)
            end

            EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
        end)
    end

    table.insert(self.onLoadFunctions, func)
end

--endregion

--region Events

DJUI.events = {}
function DJUI:AddEvent(event, func)
    assert(func and type(func) == 'function', 'Requires a function as the second paramenter')

    if not self.events[event] then
        self.events[event] = {}

        EVENT_MANAGER:RegisterForEvent(self.name, event, function(...)
            for _, v in pairs(self.events[event]) do
                v(...)
            end
        end)
    end
    table.insert(self.events[event], func)
end

--endregion

--region Movable frames

DJUI.movableFrames = {}
function DJUI:AddMoveableFrame(frame)
    if frame.ChangeMoveState then
        table.insert(DJUI.movableFrames, frame)
    end
end

--endregion

--region Global Slash Commands

SLASH_COMMANDS['/rl'] = function()
    ReloadUI()
end

SLASH_COMMANDS['/djui'] = function(command)
    if command == 'unlock' then
        for _, v in pairs(DJUI.movableFrames) do
            if v and v.ChangeMoveState then
                v:ChangeMoveState(true)
            end
        end
        d('DJUI: Frames unlocked - Type /djui lock')
        return
    end

    if command == 'lock' then
        for _, v in pairs(DJUI.movableFrames) do
            if v and v.ChangeMoveState then
                v:ChangeMoveState(false)
            end
        end
        d('DJUI: Frames Locked')
        return
    end

    d('--------------------')
    d('DJUI - Slash Commands:')
    d('• unlock - Allow you to move all DJUI frames')
    d('• lock - Locks all DJUI frames in place')
    d('--------------------')
end

--endregion
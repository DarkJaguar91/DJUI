----------------------------------------------------------------------------------
-- Created by: Brandon Talbot ( -_Dark-Jaguar_- )                               --
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Defining Event Class                                                         --
----------------------------------------------------------------------------------
DJEventManager = class(function(EventManager, addonName)
    EventManager.name = addonName
    EventManager.loadEvents = {}
    EventManager.powerUpdateEvents = {}

    EventManager:__Init();
end)

function DJEventManager:__Init()
    function self.OnLoad(event, addonName)
        if (addonName ~= self.name) then return end

        for i, v in pairs(self.loadEvents) do
            v()
        end

        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    end

    function self.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, value, max, effectiveMax)
        for i, v in pairs(self.powerUpdateEvents) do
            if v["unit"] == unitTag and v["type"] == powerType then
                v["func"](value, max)
            end
        end
    end

    ----------------------------------------------------------------------------------
    -- Register Events                                                              --
    ----------------------------------------------------------------------------------
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, self.OnLoad)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_POWER_UPDATE, self.OnPowerUpdate)
end

function DJEventManager:AddLoadEvent(func)
    table.insert(self.loadEvents, func)
end

function DJEventManager:AddPowerUpdateEvent(func, unit, powerType)
    table.insert(self.powerUpdateEvents, {
        ["func"] = func,
        ["unit"] = unit,
        ["type"] = powerType,
    })
end
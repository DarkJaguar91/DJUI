----------------------------------------------------------------------------------
-- Created by: Brandon Talbot ( -_Dark-Jaguar_- )                               --
-- Used to construct a Power Bar                                                --
----------------------------------------------------------------------------------

-- Window manager to create controls
local wm = GetWindowManager()

----------------------------------------------------------------------------------
-- Contructors                                                                  --
----------------------------------------------------------------------------------
DJPowerBar = class(function (powerBar, name)
    powerBar.name = name
    powerBar:__init();
end)

function DJPowerBar:__init()
    self.tlw = wm:CreateTopLevelWindow(self.name)

    self.bar = wm:CreateControl(self.name .. "Bar", self.tlw, CT_STATUSBAR)
    self.bar:SetColor(1, 1, 1, 1)
    self.bar:SetMinMax(0, 100)
    self.bar:SetValue(100)
    self.bar:SetAnchor(TOPLEFT, self.tlw, TOPLEFT, 0, 0)
    self.bar:SetAnchor(BOTTOMRIGHT, self.tlw, BOTTOMRIGHT, 0, 0)

    self.tlw:SetHidden(false)
end

----------------------------------------------------------------------------------
-- Setters                                                                      --
----------------------------------------------------------------------------------
function DJPowerBar:SetEventManager(EventManager, unit, type)
    if (EventManager and unit and type) then
        self.unit = unit
        self.type = type

        self.onLoadEvent = function ()
            local current, max = GetUnitPower(self.unit, self.type)
            self:Update(current, 0, max)
        end

        self.onUpdateEvent = function(current, max)
            self:Update(current, 0, max)
        end

        EventManager:AddLoadEvent(self.onLoadEvent)
        EventManager:AddPowerUpdateEvent(self.onUpdateEvent, self.unit, self.type)
    end
    return self
end

function DJPowerBar:SetBarColor(r,g,b,a)
    self.bar:SetColor(r, g, b, a)
    return self
end

function DJPowerBar:SetSize(w, h)
    self.tlw:SetDimensions(w, h or w)
    return self
end

function DJPowerBar:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
    self.tlw:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
    return self
end

function DJPowerBar:SetTexture(path)
    self.bar:SetTexture(path)
    return self
end

function DJPowerBar:Update(current, min, max)
    self.bar:SetMinMax(min, max)
    self.bar:SetValue(current)
    return self
end
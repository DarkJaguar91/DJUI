--
-- Created by
-- User: Brandon
-- Date: 2015-04-05
-- Time: 08:03 AM
--

local NAME = 'DJUI'
local DJUI = LibStub(NAME)

if DJUI.unitframes and DJUI.unitframes.target then
    return
end

if not DJUI.unitframes then
    DJUI.unitframes = {}
end

--region Init

DJUI.unitframes.target = {}
local target = DJUI.unitframes.target
target.__index = target

target.tag = 'reticleover'
target.moving = false
target.barReactionColor = false
target.nameReactionColor = false

--endregion

--region Controls

target.tlw = CreateTopLevelWindow()
target.tlw:SetDimensions(300, 40)

target.health = DJUI.ui.statusBar(target.tlw, true)

target.health:SetHeight(20)

target.health:SetAnchor(TOPLEFT, nil, nil, 0, 20)
target.health:SetAnchor(TOPRIGHT, nil, nil, 0, 20)

target.level = CreateControl(nil, target.tlw, CT_LABEL)
target.level:SetAnchor(TOPRIGHT)
target.level:SetFont('$(CHAT_FONT)|18|shadow')
target.level:SetVerticalAlignment(TEXT_ALIGN_CENTER)

target.name = CreateControl(nil, target.tlw, CT_LABEL)
target.name:SetAnchor(TOPRIGHT, target.level, TOPLEFT, -10)
target.name:SetFont('$(CHAT_FONT)|18|shadow')
target.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)

target.moveOverlay = CreateControl(nil, target.tlw, CT_TEXTURE)
target.moveOverlay:SetAnchorFill(target.tlw)
target.moveOverlay:SetColor(0.8, 0.8, 0, 0.8)
target.moveOverlay:SetAlpha(0)
target.moveOverlay:SetDrawLayer(2)
target.moveOverlay:SetDrawLevel(3)
target.moveOverlay.text = CreateControl(nil, target.moveOverlay, CT_LABEL)
target.moveOverlay.text:SetAnchor(CENTER)
target.moveOverlay.text:SetFont('$(CHAT_FONT)|20')
target.moveOverlay.text:SetText('Target')
target.moveOverlay.text:SetColor(0, 0, 0, 1)
target.moveOverlay.text:SetDrawLayer(2)
target.moveOverlay.text:SetDrawLevel(4)

target.hideAnim, target.hideTimeline = CreateSimpleAnimation(ANIMATION_ALPHA, target.tlw)
target.hideAnim:SetDuration(1000)
target.hideTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)

--endregion

--region Vars

target.bars = {
    [POWERTYPE_HEALTH] = target.health,
}

--endregion

--region Methods

function target:Load(save)
    self.level:SetColor(unpack(save.levelColor))
    self.name:SetColor(unpack(save.nameColor))

    if save.position then
        self.tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, save.position.x, save.position.y)
    else
        self.tlw:SetAnchor(TOPLEFT, GuiRoot, CENTER, 250, 305)
    end

    self.tlw:SetWidth(save.width)

    self.barReactionColor = save.barReactionColor
    self.nameReactionColor = save.nameReactionColor

    if save.hideDefault then
        if not self.defaultLoc then
            self.defaultLoc = {ZO_TargetUnitFramereticleover:GetLeft(), ZO_TargetUnitFramereticleover:GetTop()}
        end
        ZO_TargetUnitFramereticleover:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, -1000, -1000)
    elseif self.defaultLoc then
        ZO_TargetUnitFramereticleover:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.defaultLoc[1], self.defaultLoc[2])
    end

    for k, v in pairs(self.bars) do
        v:Load(save.bars[k])
    end

    target:UpdateAlpha()
end

function target:InitBars()
    for k, v in pairs(self.bars) do
        local val, max = GetUnitPower(target.tag, k)
        v:SetValue(val, max)
    end
end

function target:Init()
    self.name:SetText(GetUnitName(target.tag))
    self.level:SetText(GetUnitLevel(target.tag))

    self:InitBars()
end

function target:UpdateAlpha()
    if self.moving then
        self.tlw:SetAlpha(1)
        return
    end
    if DoesUnitExist(target.tag) then
        self:Init()

        self:Show()
        if self.nameReactionColor then
            local r, g, b = GetUnitReactionColor(target.tag)
            self.name:SetColor(r,g,b,1)
        end

        if self.barReactionColor then
            local r, g, b = GetUnitReactionColor(target.tag)
            self.health:SetBarColor(r,g,b,1)
        end
    else
        self:Hide()
    end
end

function target:Show()
    self.hideTimeline:Stop()
    self.hideAnim:SetAlphaValues(self.tlw:GetAlpha(), 1)
    self.hideTimeline:PlayFromStart()
end

function target:Hide(alpha)
    self.hideTimeline:Stop()
    self.hideAnim:SetAlphaValues(self.tlw:GetAlpha(), alpha or 0)
    self.hideTimeline:PlayFromStart()
end

--endregion

--region Events

function target:ChangeMoveState(value)
    target.tlw:SetMouseEnabled(value)
    target.tlw:SetMovable(value)

    target.moveOverlay:SetAlpha(value and 1 or 0)

    target.moving = value
    target:UpdateAlpha()
end

target.tlw:SetHandler('OnMoveStop', function()
    DJUI.saved.target.position = {
        x = target.tlw:GetLeft(),
        y = target.tlw:GetTop(),
    }
end)

DJUI:AddLoad(function(saved)
    target:Load(saved.target)

    target:CreateSettings()

    -- TODO Hide Default
end)

DJUI:AddEvent(EVENT_POWER_UPDATE, function(_, unitTag, powerIndex, powerType, val, max, effMax)
    if unitTag == target.tag then
        local bar = target.bars[powerType]
        if bar then
            bar:SetValue(val, max)
        end
        target:UpdateAlpha()
    end
end)

DJUI:AddEvent(EVENT_RETICLE_TARGET_CHANGED, function(_)
    target:UpdateAlpha()
end)

--endregion

--region Settings

function target:CreateSettings()
    local LAM = LibStub("LibAddonMenu-2.0")
    DJUI:AddMoveableFrame(self)

    self.settings = {
        type = 'panel',
        name = 'DJUI Target Unit Frame',
        registerForRefresh = true,
    }

    self.settingsOptions = {
        {
            type = "checkbox",
            name = "Hide Default Target Bar?",
            tooltip = "Hides the Default Target Bar",
            getFunc = function() return DJUI.saved.target.hideDefault end,
            setFunc = function(value)
                DJUI.saved.target.hideDefault = value
                self:Load(DJUI.saved.target)
            end,
        },
        {
            type = "slider",
            name = "Target Frame Width",
            tooltip = "Set the target unit frames width.",
            min = 220,
            max = 500,
            getFunc = function() return DJUI.saved.target.width end,
            setFunc = function(value)
                DJUI.saved.target.width = value
                target:Load(DJUI.saved.target)
            end,
        },
        {
            type = "colorpicker",
            name = "Level Color Picker",
            tooltip = "Set the colour of your targets level text.",
            getFunc = function() return unpack(DJUI.saved.target.levelColor) end, --(alpha is optional)
            setFunc = function(r, g, b, a)
                DJUI.saved.target.levelColor = { r, g, b, a }
                self:Load(DJUI.saved.target)
            end,
        },
        {
            type = "checkbox",
            name = "User Reaction Color For Name?",
            tooltip = "Shows the reaction color for name instead of chosen color",
            getFunc = function() return DJUI.saved.target.nameReactionColor end,
            setFunc = function(value)
                DJUI.saved.target.nameReactionColor = value
                self:Load(DJUI.saved.target)
            end,
            width = "half",	--or "half" (optional)
            warning = "Will ignore chosen color!.",	--(optional)
        },
        {
            type = "colorpicker",
            name = "Name Color Picker",
            tooltip = "Set the colour of your targets name text.",
            getFunc = function() return unpack(DJUI.saved.target.nameColor) end, --(alpha is optional)
            setFunc = function(r, g, b, a)
                DJUI.saved.target.nameColor = { r, g, b, a }
                self:Load(DJUI.saved.target)
            end,
            width = "half",	--or "half" (optional)
        },
        {
            type = "submenu",
            name = "Health Bar Colours",
            controls = {
                {
                    type = "checkbox",
                    name = "User Reaction Color For Bar?",
                    tooltip = "Shows the reaction color for the health bar instead of chosen color",
                    getFunc = function() return DJUI.saved.target.barReactionColor end,
                    setFunc = function(value)
                        DJUI.saved.target.barReactionColor = value
                        self:Load(DJUI.saved.target)
                    end,
                    width = "half",	--or "half" (optional)
                    warning = "Will ignore chosen color!.",	--(optional)
                },
                {
                    type = "colorpicker",
                    name = "Bar Color Picker",
                    tooltip = "Set the colour of your targets health bar.",
                    getFunc = function() return unpack(DJUI.saved.target.bars[POWERTYPE_HEALTH].color) end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        DJUI.saved.target.bars[POWERTYPE_HEALTH].color = { r, g, b, a }
                        self:Load(DJUI.saved.target)
                    end,
                    width = "half",	--or "half" (optional)
                },
                {
                    type = "colorpicker",
                    name = "Value Text Color Picker",
                    tooltip = "Set the colour of your targets health bar value text.",
                    getFunc = function() return unpack(DJUI.saved.target.bars[POWERTYPE_HEALTH].valueColor) end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        DJUI.saved.target.bars[POWERTYPE_HEALTH].valueColor = { r, g, b, a }
                        self:Load(DJUI.saved.target)
                    end,
                },
                {
                    type = "colorpicker",
                    name = "Percentage Text Color Picker",
                    tooltip = "Set the colour of your targets health bar percentage text.",
                    getFunc = function() return unpack(DJUI.saved.target.bars[POWERTYPE_HEALTH].percentColor) end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        DJUI.saved.target.bars[POWERTYPE_HEALTH].percentColor = { r, g, b, a }
                        self:Load(DJUI.saved.target)
                    end,
                },
            }
        },
        {
            type = "button",
            name = "Reset Defaults",
            tooltip = "Resets all settings to default.",
            func = function() 
                DJUI.saved.target = DJUI.savedDefaults.target
                self:Load(DJUI.saved.target)
                ReloadUI()
            end,
            warning = "Will reload the UI!", --(optional)
        },
    }

    LAM:RegisterAddonPanel(self.settings.name, self.settings)
    LAM:RegisterOptionControls(self.settings.name, self.settingsOptions)
end

--endregion
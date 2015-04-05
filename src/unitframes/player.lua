--
-- Created by
-- User: Brandon
-- Date: 2015-04-05
-- Time: 08:03 AM
--

local NAME = 'DJUI'
local DJUI = LibStub(NAME)

if DJUI.unitframes and DJUI.unitframes.player then
    return
end

if not DJUI.unitframes then
    DJUI.unitframes = {}
end

--region Init

DJUI.unitframes.player = {}
local player = DJUI.unitframes.player
player.__index = player

player.tag = 'player'
player.combat = false
player.cinematic = false
player.moving = false

--endregion

--region Controls

player.tlw = CreateTopLevelWindow()
player.tlw:SetDimensions(300, 95)

player.health = DJUI.ui.statusBar(player.tlw)
player.magicka = DJUI.ui.statusBar(player.tlw)
player.stamina = DJUI.ui.statusBar(player.tlw)

player.health:SetHeight(20)
player.magicka:SetHeight(20)
player.stamina:SetHeight(20)

player.health:SetAnchor(TOPLEFT, nil, nil, 0, 20)
player.health:SetAnchor(TOPRIGHT, nil, nil, 0, 20)
player.magicka:SetAnchor(TOPLEFT, player.health.background, BOTTOMLEFT)
player.magicka:SetAnchor(TOPRIGHT, player.health.background, BOTTOMRIGHT)
player.stamina:SetAnchor(TOPLEFT, player.magicka.background, BOTTOMLEFT)
player.stamina:SetAnchor(TOPRIGHT, player.magicka.background, BOTTOMRIGHT)

player.level = CreateControl(nil, player.tlw, CT_LABEL)
player.level:SetAnchor(TOPLEFT)
player.level:SetFont('$(CHAT_FONT)|18|shadow')
player.level:SetVerticalAlignment(TEXT_ALIGN_CENTER)

player.name = CreateControl(nil, player.tlw, CT_LABEL)
player.name:SetAnchor(TOPLEFT, player.level, TOPRIGHT, 10)
player.name:SetFont('$(CHAT_FONT)|18|shadow')
player.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)

player.moveOverlay = CreateControl(nil, player.tlw, CT_TEXTURE)
player.moveOverlay:SetAnchorFill(player.tlw)
player.moveOverlay:SetColor(0.8, 0.8, 0, 0.8)
player.moveOverlay:SetAlpha(0)
player.moveOverlay:SetDrawLayer(2)
player.moveOverlay:SetDrawLevel(3)
player.moveOverlay.text = CreateControl(nil, player.moveOverlay, CT_LABEL)
player.moveOverlay.text:SetAnchor(CENTER)
player.moveOverlay.text:SetFont('$(CHAT_FONT)|20')
player.moveOverlay.text:SetText('Player')
player.moveOverlay.text:SetColor(0, 0, 0, 1)
player.moveOverlay.text:SetDrawLayer(2)
player.moveOverlay.text:SetDrawLevel(4)

local function complete()
    player:UpdateAlpha()
end

player.health:SetAnimationCompleteListener(complete)
player.magicka:SetAnimationCompleteListener(complete)
player.stamina:SetAnimationCompleteListener(complete)

player.hideAnim, player.hideTimeline = CreateSimpleAnimation(ANIMATION_ALPHA, player.tlw)
player.hideAnim:SetDuration(1000)
player.hideTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)

--endregion

--region Vars

player.bars = {
    [POWERTYPE_HEALTH] = player.health,
    [POWERTYPE_MAGICKA] = player.magicka,
    [POWERTYPE_STAMINA] = player.stamina,
}

--endregion

--region Methods

function player:Load(save)
    self.level:SetColor(unpack(save.levelColor))
    self.name:SetColor(unpack(save.nameColor))

    if save.position then
        self.tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, save.position.x, save.position.y)
    else
        self.tlw:SetAnchor(TOPLEFT, GuiRoot, CENTER, -550, 305)
    end

    self.tlw:SetWidth(save.width)
    self.hideAlpha = save.hideAlpha

    for k, v in pairs(self.bars) do
        v:Load(save.bars[k])
    end

    player:UpdateAlpha()
end

function player:InitBars()
    for k, v in pairs(self.bars) do
        local val, max = GetUnitPower(player.tag, k)
        v:SetValue(val, max)
    end
end

function player:UpdateAlpha()
    if self.moving then
        self.tlw:SetAlpha(1)
        return
    end
    if self.combat then
        self:Show()
        return
    end

    if self.cinematic then
        self:Hide()
        return
    end

    if self:AreAllBarsFull() then
        self:Hide(self.hideAlpha)
    else
        self:Show()
    end
end

function player:AreAllBarsFull()
    for k, v in pairs(self.bars) do
        if v:GetPercentage() ~= 100 then
            return false
        end
    end
    return true
end

function player:Show()
    self.hideTimeline:Stop()
    self.hideAnim:SetAlphaValues(self.tlw:GetAlpha(), 1)
    self.hideTimeline:PlayFromStart()
end

function player:Hide(alpha)
    self.hideTimeline:Stop()
    self.hideAnim:SetAlphaValues(self.tlw:GetAlpha(), alpha or 0)
    self.hideTimeline:PlayFromStart()
end

--endregion

--region Events

function player:ChangeMoveState(value)
    player.tlw:SetMouseEnabled(value)
    player.tlw:SetMovable(value)

    player.moveOverlay:SetAlpha(value and 1 or 0)

    player.moving = value
    player:UpdateAlpha()
end

player.tlw:SetHandler('OnMoveStop', function()
    DJUI.saved.player.position = {
        x = player.tlw:GetLeft(),
        y = player.tlw:GetTop(),
    }
end)

DJUI:AddLoad(function(saved)
    player:Load(saved.player)

    player.level:SetText(GetUnitLevel(player.tag))
    player.name:SetText(GetUnitName(player.tag))

    player:InitBars();

    player:CreateSettings()

    ZO_PlayerAttributeHealth:SetHidden(true)
    ZO_PlayerAttributeMagicka:SetHidden(true)
    ZO_PlayerAttributeStamina:SetHidden(true)
end)

DJUI:AddEvent(EVENT_POWER_UPDATE, function(_, unitTag, powerIndex, powerType, val, max, effMax)
    if unitTag == player.tag then
        local bar = player.bars[powerType]
        if bar then
            bar:SetValue(val, max)
        end
        player:UpdateAlpha()
    end
end)

DJUI:AddEvent(EVENT_PLAYER_COMBAT_STATE, function(_, combat)
    player.combat = combat
    player:UpdateAlpha()
end)

DJUI:AddEvent(EVENT_GAME_CAMERA_ACTIVATED, function()
    player.cinematic = false
    player:UpdateAlpha()
end)

DJUI:AddEvent(EVENT_GAME_CAMERA_DEACTIVATED, function()
    player.cinematic = true
    player:UpdateAlpha()
end)
--endregion

--region Settings

function player:CreateSettings()
    local LAM = LibStub("LibAddonMenu-2.0")
    DJUI:AddMoveableFrame(self)

    self.settings = {
        type = 'panel',
        name = 'DJUI Player Unit Frame',
    }

    self.settingsOptions = {
        {
            type = "slider",
            name = "Player Frame Width",
            tooltip = "Set the player unit frames width.",
            min = 220,
            max = 500,
            getFunc = function() return DJUI.saved.player.width end,
            setFunc = function(value)
                DJUI.saved.player.width = value
                player:Load(DJUI.saved.player)
            end,
        },
        {
            type = "slider",
            name = "Player Frame Alpha",
            tooltip = "Set the player unit frames alpha when out of combat.",
            min = 0,
            max = 100,
            getFunc = function() return DJUI.saved.player.hideAlpha * 100 end,
            setFunc = function(value)
                DJUI.saved.player.hideAlpha = value / 100
                player:Load(DJUI.saved.player)
            end,
        },
        {
            type = "colorpicker",
            name = "Level Color Picker",
            tooltip = "Set the colour of your players level text.",
            getFunc = function() return unpack(DJUI.saved.player.levelColor) end, --(alpha is optional)
            setFunc = function(r, g, b, a)
                DJUI.saved.player.levelColor = { r, g, b, a }
                self:Load(DJUI.saved.player)
            end,
        },
        {
            type = "colorpicker",
            name = "Name Color Picker",
            tooltip = "Set the colour of your players name text.",
            getFunc = function() return unpack(DJUI.saved.player.nameColor) end, --(alpha is optional)
            setFunc = function(r, g, b, a)
                DJUI.saved.player.nameColor = { r, g, b, a }
                self:Load(DJUI.saved.player)
            end,
        },
        {
            type = "submenu",
            name = "Health Bar Colours",
            controls = {
                {
                    type = "colorpicker",
                    name = "Bar Color Picker",
                    tooltip = "Set the colour of your players health bar.",
                    getFunc = function() return unpack(DJUI.saved.player.bars[POWERTYPE_HEALTH].color) end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        DJUI.saved.player.bars[POWERTYPE_HEALTH].color = { r, g, b, a }
                        self:Load(DJUI.saved.player)
                    end,
                },
                {
                    type = "colorpicker",
                    name = "Value Text Color Picker",
                    tooltip = "Set the colour of your players health bar value text.",
                    getFunc = function() return unpack(DJUI.saved.player.bars[POWERTYPE_HEALTH].valueColor) end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        DJUI.saved.player.bars[POWERTYPE_HEALTH].valueColor = { r, g, b, a }
                        self:Load(DJUI.saved.player)
                    end,
                },
                {
                    type = "colorpicker",
                    name = "Percentage Text Color Picker",
                    tooltip = "Set the colour of your players health bar percentage text.",
                    getFunc = function() return unpack(DJUI.saved.player.bars[POWERTYPE_HEALTH].percentColor) end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        DJUI.saved.player.bars[POWERTYPE_HEALTH].percentColor = { r, g, b, a }
                        self:Load(DJUI.saved.player)
                    end,
                },
            }
        },
        {
            type = "submenu",
            name = "Magicka Bar Colours",
            controls = {
                {
                    type = "colorpicker",
                    name = "Bar Color Picker",
                    tooltip = "Set the colour of your players Magicka bar.",
                    getFunc = function() return unpack(DJUI.saved.player.bars[POWERTYPE_MAGICKA].color) end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        DJUI.saved.player.bars[POWERTYPE_MAGICKA].color = { r, g, b, a }
                        self:Load(DJUI.saved.player)
                    end,
                },
                {
                    type = "colorpicker",
                    name = "Value Text Color Picker",
                    tooltip = "Set the colour of your players Magicka bar value text.",
                    getFunc = function() return unpack(DJUI.saved.player.bars[POWERTYPE_MAGICKA].valueColor) end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        DJUI.saved.player.bars[POWERTYPE_MAGICKA].valueColor = { r, g, b, a }
                        self:Load(DJUI.saved.player)
                    end,
                },
                {
                    type = "colorpicker",
                    name = "Percentage Text Color Picker",
                    tooltip = "Set the colour of your players Magicka bar percentage text.",
                    getFunc = function() return unpack(DJUI.saved.player.bars[POWERTYPE_MAGICKA].percentColor) end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        DJUI.saved.player.bars[POWERTYPE_MAGICKA].percentColor = { r, g, b, a }
                        self:Load(DJUI.saved.player)
                    end,
                },
            }
        },
        {
            type = "submenu",
            name = "Stamina Bar Colours",
            controls = {
                {
                    type = "colorpicker",
                    name = "Bar Color Picker",
                    tooltip = "Set the colour of your players Stamina bar.",
                    getFunc = function() return unpack(DJUI.saved.player.bars[POWERTYPE_STAMINA].color) end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        DJUI.saved.player.bars[POWERTYPE_STAMINA].color = { r, g, b, a }
                        self:Load(DJUI.saved.player)
                    end,
                },
                {
                    type = "colorpicker",
                    name = "Value Text Color Picker",
                    tooltip = "Set the colour of your players Stamina bar value text.",
                    getFunc = function() return unpack(DJUI.saved.player.bars[POWERTYPE_STAMINA].valueColor) end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        DJUI.saved.player.bars[POWERTYPE_STAMINA].valueColor = { r, g, b, a }
                        self:Load(DJUI.saved.player)
                    end,
                },
                {
                    type = "colorpicker",
                    name = "Percentage Text Color Picker",
                    tooltip = "Set the colour of your players Stamina bar percentage text.",
                    getFunc = function() return unpack(DJUI.saved.player.bars[POWERTYPE_STAMINA].percentColor) end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        DJUI.saved.player.bars[POWERTYPE_STAMINA].percentColor = { r, g, b, a }
                        self:Load(DJUI.saved.player)
                    end,
                },
            }
        },
    }

    LAM:RegisterAddonPanel(self.settings.name, self.settings)
    LAM:RegisterOptionControls(self.settings.name, self.settingsOptions)
end

--endregion
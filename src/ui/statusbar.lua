--
-- Created by
-- User: Brandon
-- Date: 2015-04-04
-- Time: 10:40 PM
--

local NAME = 'DJUI'

local DJUI = LibStub(NAME)

if DJUI.ui and DJUI.ui.statusBar then
    return
end

if not DJUI.ui then
    DJUI.ui = {}
end

--region Local Functions

local function createControls(self, rev)
    self.background = CreateControl(nil, self.tlw, CT_TEXTURE)
    self.background:SetDrawLayer(0)
    self.background:SetDrawLevel(1)
    self.background:SetTextureRotation(rev and 3.14159265 or 0)


    self.border = CreateControl(nil, self.background, CT_TEXTURE)
    self.border:SetAnchorFill(self.background)
    self.border:SetDrawLayer(0)
    self.border:SetDrawLevel(3)
    self.border:SetTextureRotation(rev and 3.14159265 or 0)

    self.bar = CreateControl(nil, self.background, CT_STATUSBAR)
    self.bar:SetAnchorFill(self.background)
    self.bar:SetDrawLayer(0)
    self.bar:SetDrawLevel(2)
    self.bar:SetMinMax(0, 100)
    self.bar:SetValue(50)
    self.bar:SetBarAlignment(rev and BAR_ALIGNMENT_REVERSE or BAR_ALIGNMENT_NORMAL)

    self.gloss = CreateControl(nil, self.background, CT_STATUSBAR)
    self.gloss:SetAnchorFill(self.background)
    self.gloss:SetDrawLayer(0)
    self.gloss:SetDrawLevel(2)
    self.gloss:SetMinMax(0, 100)
    self.gloss:SetValue(50)
    self.gloss:SetBarAlignment(rev and BAR_ALIGNMENT_REVERSE or BAR_ALIGNMENT_NORMAL)

    self.value = CreateControl(nil, self.background, CT_LABEL)
    self.value:SetAnchor(rev and TOPRIGHT or TOPLEFT, nil, nil, rev and -3 or 3)
    self.value:SetAnchor(rev and BOTTOMRIGHT or BOTTOMLEFT, nil, nil, rev and -3 or 3)
    self.value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.value:SetFont('$(CHAT_FONT)|8|shadow')

    self.percent = CreateControl(nil, self.background, CT_LABEL)
    self.percent:SetAnchor(rev and TOPLEFT or TOPRIGHT, nil, nil, rev and 10 or -10)
    self.percent:SetAnchor(rev and BOTTOMLEFT or BOTTOMRIGHT, nil, nil, rev and 10 or -10)
    self.percent:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.percent:SetFont('$(CHAT_FONT)|8|shadow')
end

local function createAnimations(self)
    self.updateAnimation, self.updateTimeline = CreateSimpleAnimation(ANIMATION_CUSTOM, self.bar)
    self.updateTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    self.updateAnimation:SetDuration(600)

    self.updateAnimation.startVal = 0
    self.updateAnimation.difference = 0

    self.updateAnimation:SetUpdateFunction(function(_, percentage)
        local value = zo_round(self.updateAnimation.startVal + self.updateAnimation.difference * percentage)
        self:UpdateDetails(value)
    end)
end

local function setupMetaTable(self)
    local meta = getmetatable(self)

    local oldIndex = meta.__index

    meta.__index = function(_, key)
        if oldIndex then
            if type(oldIndex) == 'function' then
                local oldObj = oldIndex(meta, key)
                if oldObj then
                    return oldObj
                end
            else
                if oldIndex[key] then
                    return oldIndex[key]
                end
            end
        end

        local backgroundMeta = DJUI.ui.util:CreateMetaFunction(key, self.background)
        if backgroundMeta then
            return backgroundMeta
        end

        local borderMeta = DJUI.ui.util:CreateMetaFunction(key, self.border, 'Border')
        if borderMeta then
            return borderMeta
        end
        
        local barMeta = DJUI.ui.util:CreateMetaFunction(key, self.bar, 'Bar')
        if barMeta then
            return barMeta
        end

        local glossMeta = DJUI.ui.util:CreateMetaFunction(key, self.gloss, 'Gloss')
        if glossMeta then
            return glossMeta
        end
    end
end

--endregion

--region Setup

local statusBar = {}
statusBar.__index = statusBar

function statusBar:__init__(TLW, rev)
    self.tlw = TLW or CreateTopLevelWindow()

    createControls(self, rev)
    createAnimations(self)
    setupMetaTable(self)
end

function statusBar:Load(details)
    if details.color then
        self.bar:SetColor(unpack(details.color))
    end

    if details.backgroundTexture then
        if (details.backgroundTexture[1]) then
            self.background:SetTexture(details.backgroundTexture[1])
        end
        if details.backgroundTexture[2] then
            self.background:SetTextureCoords(unpack(details.backgroundTexture[2]))
        end
    end

    if details.borderTexture then
        if (details.borderTexture[1]) then
            self.border:SetTexture(details.borderTexture[1])
        end
        if details.borderTexture[2] then
            self.border:SetTextureCoords(unpack(details.borderTexture[2]))
        end
    end

    if details.barTexture then
        if details.barTexture[1] then
            self.bar:SetTexture(details.barTexture[1])
        end
        if details.barTexture[2] then
            self.bar:SetTextureCoords(unpack(details.barTexture[2]))
        end
        if details.barTexture[3] then
            self.bar:EnableLeadingEdge(true)
            self.bar:SetLeadingEdge(unpack(details.barTexture[3]))
        else
            self.bar:EnableLeadingEdge(false)
        end
        if details.barTexture[4] then
            self.bar:SetLeadingEdgeTextureCoords(unpack(details.barTexture[4]))
        end
    end

    if details.glossTexture then
        if details.glossTexture[1] then
            self.gloss:SetTexture(details.glossTexture[1])
        end
        if details.glossTexture[2] then
            self.gloss:SetTextureCoords(unpack(details.glossTexture[2]))
        end
        if details.glossTexture[3] then
            self.gloss:EnableLeadingEdge(true)
            self.gloss:SetLeadingEdge(unpack(details.glossTexture[3]))
        else
            self.gloss:EnableLeadingEdge(false)
        end
        if details.glossTexture[4] then
            self.gloss:SetLeadingEdgeTextureCoords(unpack(details.glossTexture[4]))
        end
    end

    if details.valueColor then
        self.value:SetColor(unpack(details.valueColor))
    end

    if details.percentColor then
        self.percent:SetColor(unpack(details.percentColor))
    end
end
--endregion

--region Overrides

function statusBar:SetDimensions(w, h)
    self:SetHeight(h)
    self:SetWidth(w)
end

function statusBar:SetHeight(h)
    self.background:SetHeight(h)
    self.value:SetFont('$(CHAT_FONT)|' .. math.floor(h*0.6) .. '|shadow')
    self.percent:SetFont('$(CHAT_FONT)|' .. math.floor(h*0.6) .. '|shadow')
end

function statusBar:SetValue(value, max)
    if max then
        self.bar:SetMinMax(0, max)
        self.gloss:SetMinMax(0, max)
    end

    self.updateTimeline:Stop()
    self.updateAnimation.startVal = self.bar:GetValue()
    self.updateAnimation.difference = value - self.updateAnimation.startVal
    self.updateTimeline:PlayFromStart()
end

function statusBar:UpdateDetails(current)
    self.bar:SetValue(current)
    self.gloss:SetValue(current)
    self.percent:SetText(self:GetPercentage() .. '%')
    self.value:SetText(DJUI.ui.util:CommaNumber(current))
end

function statusBar:GetPercentage()
    local _, max = self.bar:GetMinMax()
    return math.floor(self.bar:GetValue() / max * 100)
end

function statusBar:Show()
    self.border:SetAlpha(1)
end

function statusBar:Hide()
    self.border:SetAlpha(0)
end

function statusBar:SetAnimationCompleteListener(func)
    self.updateTimeline:SetHandler('OnStop', func)
end

--endregion

--region Add To DJUI
DJUI.ui.statusBar = DJUI.class 'statusBar'(statusBar)
--endregion
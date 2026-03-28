--- FluentWoW – Settings/SettingsExpander.lua
-- Expandable settings group — header card with chevron + child card container.
-- Mirrors WCT SettingsExpander.
--
-- States: Normal | Hover | Expanded | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion
local Tex = lib.Textures

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class FWoWSettingsExpander
local ExpanderMixin = {}

local function registerThemeListener(self)
    if self._themeListenerRegistered or not self._themeListener then return end
    lib.EventBus:On("ThemeChanged", self._themeListener)
    self._themeListenerRegistered = true
end

local function unregisterThemeListener(self)
    if not self._themeListenerRegistered or not self._themeListener then return end
    lib.EventBus:Off("ThemeChanged", self._themeListener)
    self._themeListenerRegistered = false
end

local function updateHeaderLayout(self)
    if self._updatingHeader then return end
    self._updatingHeader = true

    self.Header.TitleLabel:SetWordWrap(true)
    self.Header.DescLabel:SetWordWrap(true)
    self.Header.TitleLabel:ClearAllPoints()
    if self.Header.Icon:IsShown() then
        self.Header.TitleLabel:SetPoint("TOPLEFT", self.Header.Icon, "TOPRIGHT", T:GetNumber("Spacing.LG"), 0)
    else
        self.Header.TitleLabel:SetPoint("TOPLEFT", self.Header, "TOPLEFT", T:GetNumber("Spacing.XL"), -T:GetNumber("Spacing.LG"))
    end
    self.Header.TitleLabel:SetPoint("RIGHT", self.Header.Chevron, "LEFT", -T:GetNumber("Spacing.XL"), 0)

    self.Header.DescLabel:ClearAllPoints()
    self.Header.DescLabel:SetPoint("TOPLEFT", self.Header.TitleLabel, "BOTTOMLEFT", 0, -T:GetNumber("Spacing.LG"))
    self.Header.DescLabel:SetPoint("RIGHT", self.Header.TitleLabel, "RIGHT", 0, 0)

    local padTop = T:GetNumber("Spacing.LG")
    local padBottom = T:GetNumber("Spacing.LG")
    local gap = self.Header.DescLabel:IsShown() and T:GetNumber("Spacing.LG") or 0
    local titleHeight = self.Header.TitleLabel:GetStringHeight() or 0
    local descHeight = self.Header.DescLabel:IsShown() and (self.Header.DescLabel:GetStringHeight() or 0) or 0
    local iconHeight = self.Header.Icon:IsShown() and (self.Header.Icon:GetHeight() or 20) or 0
    local desiredHeight = math.max(48, padTop + math.max(iconHeight, titleHeight + gap + descHeight) + padBottom)

    if math.abs((self.Header:GetHeight() or 0) - desiredHeight) > 0.5 then
        self.Header:SetHeight(desiredHeight)
    end

    self._updatingHeader = false
end

local function applyVisuals(self, state)
    state = state or self:GetState()
    local hdr = self.Header

    -- Header background
    local bgKey = "Color.Surface.Raised"
    if state == "Hover"    then bgKey = "Color.Surface.Raised" end
    if state == "Disabled" then bgKey = "Color.Surface.Raised" end

    hdr.BG:SetVertexColor(T:GetColor(bgKey))
    hdr.Border:SetVertexColor(T:GetColor("Color.Border.Subtle"))

    -- Hover
    if state == "Hover" then
        hdr.Hover:SetVertexColor(T:GetColor("Color.Overlay.Hover"))
        hdr.Hover:Show()
    else
        hdr.Hover:Hide()
    end

    -- Text
    local titleKey = state == "Disabled" and "Color.Text.Disabled" or "Color.Text.Primary"
    local descKey  = state == "Disabled" and "Color.Text.Disabled" or "Color.Text.Secondary"
    hdr.TitleLabel:SetTextColor(T:GetColor(titleKey))
    if hdr.DescLabel:IsShown() then
        hdr.DescLabel:SetTextColor(T:GetColor(descKey))
    end

    -- Chevron
    hdr.Chevron:SetText(self._expanded and Icons.ChevronDown or Icons.ChevronRight)
    hdr.Chevron:SetTextColor(T:GetColor(state == "Disabled" and "Color.Text.Disabled" or "Color.Text.Secondary"))

    -- Icon tint
    if hdr.Icon:IsShown() then
        local iconKey = state == "Disabled" and "Color.Icon.Disabled" or "Color.Icon.Default"
        hdr.Icon:SetVertexColor(T:GetColor(iconKey))
    end

    -- Content area
    self.Content.ContentBG:SetVertexColor(T:GetColor("Color.Surface.Overlay"))
    self.Content.Separator:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    -- Opacity
    if state == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end
end

function ExpanderMixin:OnStateChanged(newState, prevState)
    applyVisuals(self, newState)
end

-------------------------------------------------------------------------------
-- Card management
-------------------------------------------------------------------------------

local CARD_GAP = 1  -- 1px divider between cards (no equivalent token; semantic separator)

function ExpanderMixin:_LayoutCards()
    local yOff = 0
    for i, card in ipairs(self._cards) do
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", self.Content, "TOPLEFT", 0, -yOff)
        card:SetPoint("RIGHT", self.Content, "RIGHT")
        card:SetShown(self._expanded)
        yOff = yOff + card:GetHeight()
        if i < #self._cards then yOff = yOff + CARD_GAP end
    end
    self._contentHeight = math.max(1, yOff)
    if self._expanded then
        self.Content:SetHeight(self._contentHeight)
        self:SetHeight(self.Header:GetHeight() + self._contentHeight)
    else
        self.Content:SetHeight(1)
        self:SetHeight(self.Header:GetHeight())
    end
end

---@param card Frame  a FWoWSettingsCard or any Frame
function ExpanderMixin:AddCard(card)
    if not self._cards then self._cards = {} end
    card:SetParent(self.Content)
    table.insert(self._cards, card)
    card:SetShown(self._expanded)
    if not card._fwowExpanderLayoutHooked then
        card._fwowExpanderLayoutHooked = true
        card:HookScript("OnSizeChanged", function()
            self:_LayoutCards()
        end)
    end
    self:_LayoutCards()
end

---@param card Frame
function ExpanderMixin:RemoveCard(card)
    if not self._cards then return end
    for i, c in ipairs(self._cards) do
        if c == card then
            table.remove(self._cards, i)
            card:ClearAllPoints()
            card:Hide()
            break
        end
    end
    self:_LayoutCards()
end

---@return table
function ExpanderMixin:GetCards()
    return self._cards or {}
end

-------------------------------------------------------------------------------
-- Expand / Collapse
-------------------------------------------------------------------------------

---@param expanded boolean
---@param instant? boolean  skip animation
function ExpanderMixin:SetExpanded(expanded, instant)
    if expanded == self._expanded then
        local headerH = self.Header:GetHeight()
        local contentH = self._contentHeight or 0
        for _, card in ipairs(self._cards or {}) do
            card:SetShown(expanded)
        end
        if expanded then
            self.Content:Show()
            self.Content:SetHeight(contentH)
            self:SetHeight(headerH + contentH)
        else
            self.Content:Hide()
            self.Content:SetHeight(1)
            self:SetHeight(headerH)
        end
        return
    end
    self._expanded = expanded

    local hdr = self.Header
    hdr.Chevron:SetText(expanded and Icons.ChevronDown or Icons.ChevronRight)

    local headerH = hdr:GetHeight()
    local contentH = self._contentHeight or 0

    if expanded then
        for _, card in ipairs(self._cards or {}) do
            card:Show()
        end
        self.Content:Show()
        if instant or Mot.reducedMotion then
            self.Content:SetHeight(contentH)
            self:SetHeight(headerH + contentH)
        else
            self.Content:SetHeight(1)
            self:SetHeight(headerH + 1)
            Mot:HeightTo(self.Content, 1, contentH)
            Mot:HeightTo(self, headerH, headerH + contentH)
        end
    else
        if instant or Mot.reducedMotion then
            for _, card in ipairs(self._cards or {}) do
                card:Hide()
            end
            self.Content:Hide()
            self.Content:SetHeight(1)
            self:SetHeight(headerH)
        else
            Mot:HeightTo(self.Content, contentH, 1, nil, function()
                for _, card in ipairs(self._cards or {}) do
                    card:Hide()
                end
                self.Content:Hide()
            end)
            Mot:HeightTo(self, headerH + contentH, headerH)
        end
    end

    self._vsm:SetState(expanded and "Expanded" or "Normal")
    if self._onToggled then lib.Utils.SafeCall(self._onToggled, self, expanded) end
end

---@return boolean
function ExpanderMixin:IsExpanded()
    return self._expanded
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

---@param text string
function ExpanderMixin:SetTitle(text)
    self.Header.TitleLabel:SetText(text or "")
    updateHeaderLayout(self)
    self:_LayoutCards()
end

---@param text string
function ExpanderMixin:SetDescription(text)
    if text and text ~= "" then
        self.Header.DescLabel:SetText(text)
        self.Header.DescLabel:Show()
    else
        self.Header.DescLabel:Hide()
    end
    updateHeaderLayout(self)
    self:_LayoutCards()
end

---@param path string|number
function ExpanderMixin:SetIconTexture(path)
    if path then
        self.Header.Icon:SetTexture(path)
        self.Header.Icon:Show()
    else
        self.Header.Icon:Hide()
    end
    updateHeaderLayout(self)
end

---@param callback function(self, expanded)
function ExpanderMixin:SetOnToggled(callback)
    self._onToggled = callback
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWSettingsExpander_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, ExpanderMixin)
    self:FWoWInit()
    self._expanded = false
    self._cards = {}
    self._contentHeight = 0
    self._updatingHeader = false
    self._themeListenerRegistered = false

    -- Typography
    local titleFont = T:Get("Typography.Body")
    if titleFont then
        self.Header.TitleLabel:SetFont(titleFont.font, titleFont.size, titleFont.flags)
    end
    local descFont = T:Get("Typography.Caption")
    if descFont then
        self.Header.DescLabel:SetFont(descFont.font, descFont.size, descFont.flags)
    end
    self.Header.Chevron:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
    self.Header.Chevron:SetText(Icons.ChevronRight)
    lib.SetupTexture(self.Header.BG, Tex.RR4, 4)
    lib.SetupTexture(self.Header.Border, Tex.RR4_Border, 4)
    lib.SetupTexture(self.Header.Hover, Tex.RR4, 4)
    lib.SetupTexture(self.Content.ContentBG, Tex.RR4, 4)
    self.Content:SetClipsChildren(true)
    updateHeaderLayout(self)

    applyVisuals(self)
    self._themeListener = function() applyVisuals(self) end
    registerThemeListener(self)
    self:HookScript("OnShow", function(frame)
        registerThemeListener(frame)
        applyVisuals(frame)
    end)
    self:HookScript("OnHide", function(frame)
        unregisterThemeListener(frame)
    end)
end

function FWoWSettingsExpander_Header_OnClick(self)
    local expander = self:GetParent()
    if not expander._enabled then return end
    expander:SetExpanded(not expander._expanded)
end

function FWoWSettingsExpander_Header_OnEnter(self)
    local expander = self:GetParent()
    if not expander._enabled then return end
    expander._vsm:SetState("Hover")
end

function FWoWSettingsExpander_Header_OnLeave(self)
    local expander = self:GetParent()
    if not expander._enabled then return end
    if expander._expanded then
        expander._vsm:SetState("Expanded")
    else
        expander._vsm:SetState("Normal")
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWSettingsExpander
function lib:CreateSettingsExpander(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWSettingsExpanderTemplate")
    ---@cast f FWoWSettingsExpander
    return f
end

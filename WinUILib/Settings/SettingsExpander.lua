--- WinUILib – Settings/SettingsExpander.lua
-- Expandable settings group — header card with chevron + child card container.
-- Mirrors WCT SettingsExpander.
--
-- States: Normal | Hover | Expanded | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens
local Mot = lib.Motion

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILSettingsExpander
local ExpanderMixin = {}

local function applyVisuals(self, state)
    state = state or self:GetState()
    local hdr = self.Header

    -- Header background
    local bgKey = "Color.Surface.Raised"
    if state == "Hover"    then bgKey = "Color.Surface.Raised" end
    if state == "Disabled" then bgKey = "Color.Surface.Raised" end

    hdr.BG:SetColorTexture(T:GetColor(bgKey))
    hdr.Border:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    -- Hover
    if state == "Hover" then
        hdr.Hover:SetColorTexture(T:GetColor("Color.Overlay.Hover"))
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
    hdr.Chevron:SetText(self._expanded and "\226\150\190" or "\226\150\184")  -- ▾ / ▸
    hdr.Chevron:SetTextColor(T:GetColor(state == "Disabled" and "Color.Text.Disabled" or "Color.Text.Secondary"))

    -- Icon tint
    if hdr.Icon:IsShown() then
        local iconKey = state == "Disabled" and "Color.Icon.Disabled" or "Color.Icon.Default"
        hdr.Icon:SetVertexColor(T:GetColor(iconKey))
    end

    -- Content area
    self.Content.ContentBG:SetColorTexture(T:GetColor("Color.Surface.Overlay"))
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
        yOff = yOff + card:GetHeight()
        if i < #self._cards then yOff = yOff + CARD_GAP end
    end
    self._contentHeight = yOff
    if self._expanded then
        self.Content:SetHeight(self._contentHeight)
        self:SetHeight(self.Header:GetHeight() + self._contentHeight)
    end
end

---@param card Frame  a WUILSettingsCard or any Frame
function ExpanderMixin:AddCard(card)
    if not self._cards then self._cards = {} end
    card:SetParent(self.Content)
    table.insert(self._cards, card)
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
    if expanded == self._expanded then return end
    self._expanded = expanded

    local hdr = self.Header
    hdr.Chevron:SetText(expanded and "\226\150\190" or "\226\150\184")

    local headerH = hdr:GetHeight()
    local contentH = self._contentHeight or 0

    if expanded then
        self.Content:Show()
        if instant or Mot.reducedMotion then
            self.Content:SetHeight(contentH)
            self:SetHeight(headerH + contentH)
        else
            self.Content:SetHeight(1)
            self:SetHeight(headerH + 1)
            Mot:HeightTo(self.Content, 1, contentH, nil, function()
                self:SetHeight(headerH + contentH)
            end)
        end
    else
        if instant or Mot.reducedMotion then
            self.Content:Hide()
            self.Content:SetHeight(1)
            self:SetHeight(headerH)
        else
            Mot:HeightTo(self.Content, contentH, 1, nil, function()
                self.Content:Hide()
                self:SetHeight(headerH)
            end)
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
end

---@param text string
function ExpanderMixin:SetDescription(text)
    if text and text ~= "" then
        self.Header.DescLabel:SetText(text)
        self.Header.DescLabel:Show()
        local padT  = T:GetNumber("Spacing.LG")   -- 12
        local gap   = T:GetNumber("Spacing.XS")    -- 2
        local padB  = T:GetNumber("Spacing.LG")    -- 12
        local minH  = T:GetNumber("Spacing.XXXL") + T:GetNumber("Spacing.XL")  -- 48
        local h = padT + self.Header.TitleLabel:GetStringHeight() + gap + self.Header.DescLabel:GetStringHeight() + padB
        self.Header:SetHeight(math.max(minH, h))
    else
        self.Header.DescLabel:Hide()
        self.Header:SetHeight(T:GetNumber("Spacing.XXXL") + T:GetNumber("Spacing.XL"))  -- 48
    end
end

---@param path string|number
function ExpanderMixin:SetIconTexture(path)
    if path then
        self.Header.Icon:SetTexture(path)
        self.Header.Icon:Show()
    else
        self.Header.Icon:Hide()
        self.Header.TitleLabel:ClearAllPoints()
        self.Header.TitleLabel:SetPoint("TOPLEFT", self.Header, "TOPLEFT", T:GetNumber("Spacing.XL"), -T:GetNumber("Spacing.LG"))
        self.Header.TitleLabel:SetPoint("RIGHT", self.Header.Chevron, "LEFT", -T:GetNumber("Spacing.MD"), 0)
    end
end

---@param callback function(self, expanded)
function ExpanderMixin:SetOnToggled(callback)
    self._onToggled = callback
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILSettingsExpander_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, ExpanderMixin)
    self:WUILInit()
    self._expanded = false
    self._cards = {}
    self._contentHeight = 0

    -- Typography
    local titleFont = T:Get("Typography.Body")
    if titleFont then
        self.Header.TitleLabel:SetFont(titleFont.font, titleFont.size, titleFont.flags)
    end
    local descFont = T:Get("Typography.Caption")
    if descFont then
        self.Header.DescLabel:SetFont(descFont.font, descFont.size, descFont.flags)
    end
    local chevFont = T:Get("Typography.Body")
    if chevFont then
        self.Header.Chevron:SetFont(chevFont.font, chevFont.size, chevFont.flags)
    end

    self.Header.Chevron:SetText("\226\150\184")  -- ▸

    applyVisuals(self)
    self._themeListener = function() applyVisuals(self) end
    lib.EventBus:On("ThemeChanged", self._themeListener)
end

function WUILSettingsExpander_Header_OnClick(self)
    local expander = self:GetParent()
    if not expander._enabled then return end
    expander:SetExpanded(not expander._expanded)
end

function WUILSettingsExpander_Header_OnEnter(self)
    local expander = self:GetParent()
    if not expander._enabled then return end
    expander._vsm:SetState("Hover")
end

function WUILSettingsExpander_Header_OnLeave(self)
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
---@return WUILSettingsExpander
function lib:CreateSettingsExpander(parent, name)
    return CreateFrame("Frame", name, parent, "WUILSettingsExpanderTemplate")
end

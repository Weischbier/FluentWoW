--- FluentWoW – Controls/Expander/Expander.lua
-- Collapsible panel with animated expand/collapse.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/expander
-- States: Normal | Hover | Expanded | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT

-- Header height derived from tokens: XXXL(32) + MD(8) = 40
local function HEADER_H()
    return T:GetNumber("Spacing.XXXL") + T:GetNumber("Spacing.MD")
end

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILExpander
local ExpanderMixin = {}

function ExpanderMixin:OnStateChanged(newState, prevState)
    local state = newState

    if state == "Disabled" then
        self.Header.BG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
        self.Header.Label:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self.Header.Chevron:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
        local bgKey = (state == "Hover") and "Color.Surface.Elevated" or "Color.Surface.Raised"
        self.Header.BG:SetColorTexture(T:GetColor(bgKey))
        self.Header.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
        self.Header.Chevron:SetTextColor(T:GetColor("Color.Text.Secondary"))
        self.Header.Hover:SetColorTexture(T:GetColor("Color.Overlay.Hover"))
    end

    self.Content.ContentBG:SetColorTexture(T:GetColor("Color.Surface.Raised"))

    if self._expanded then
        self.Header.Chevron:SetText(Icons.ChevronDown)
    else
        self.Header.Chevron:SetText(Icons.ChevronRight)
    end
end

---@param text string
function ExpanderMixin:SetTitle(text)
    self.Header.Label:SetText(text)
end

---@return string
function ExpanderMixin:GetTitle()
    return self.Header.Label:GetText() or ""
end

---@param expanded boolean
---@param instant? boolean
function ExpanderMixin:SetExpanded(expanded, instant)
    if self._expanded == expanded then return end
    self._expanded = expanded

    if expanded then
        self.Content:Show()
        local targetH = self._contentHeight or 100
        local hdrH = HEADER_H()
        if instant or Mot.reducedMotion then
            self.Content:SetHeight(targetH)
            self:SetHeight(hdrH + targetH)
        else
            Mot:HeightTo(self.Content, 1, targetH,
                lib.Tokens:GetNumber("Motion.Duration.Normal"),
                function()
                    self:SetHeight(hdrH + targetH)
                end)
            -- animate container height in parallel
            Mot:HeightTo(self, hdrH, hdrH + targetH)
        end
        self._vsm:SetState("Expanded")
    else
        local fromH = self.Content:GetHeight()
        local hdrH = HEADER_H()
        if instant or Mot.reducedMotion then
            self.Content:Hide()
            self.Content:SetHeight(1)
            self:SetHeight(hdrH)
        else
            Mot:HeightTo(self.Content, fromH, 1,
                lib.Tokens:GetNumber("Motion.Duration.Normal"),
                function()
                    self.Content:Hide()
                end)
            Mot:HeightTo(self, self:GetHeight(), hdrH)
        end
        self._vsm:SetState("Normal")
    end
end

---@return boolean
function ExpanderMixin:IsExpanded()
    return self._expanded == true
end

---@param height number
function ExpanderMixin:SetContentHeight(height)
    self._contentHeight = height
    if self._expanded then
        self.Content:SetHeight(height)
        self:SetHeight(HEADER_H() + height)
    end
end

---@param fn function
function ExpanderMixin:SetOnToggled(fn)
    self._onToggled = fn
end

--- Returns the content frame for embedding child controls.
---@return Frame
function ExpanderMixin:GetContentFrame()
    return self.Content
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILExpander_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, ExpanderMixin)
    self:WUILInit()
    self._expanded = false
    self._contentHeight = 100
    self.Header.Chevron:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
    self:OnStateChanged("Normal")
end

function WUILExpander_OnHeaderClick(self)
    local expander = self:GetParent()
    if not expander._enabled then return end
    expander:SetExpanded(not expander._expanded)
    if expander._onToggled then
        lib.Utils.SafeCall(expander._onToggled, expander, expander._expanded)
    end
end

function WUILExpander_OnHeaderEnter(self)
    local expander = self:GetParent()
    if not expander._enabled then return end
    if not expander._expanded then
        expander._vsm:SetState("Hover")
    end
end

function WUILExpander_OnHeaderLeave(self)
    local expander = self:GetParent()
    if not expander._enabled then return end
    if not expander._expanded then
        expander._vsm:SetState("Normal")
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return WUILExpander
function lib:CreateExpander(parent, name)
    local f = CreateFrame("Frame", name, parent, "WUILExpanderTemplate")
    ---@cast f WUILExpander
    return f
end

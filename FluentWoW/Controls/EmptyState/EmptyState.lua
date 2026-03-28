--- FluentWoW – Controls/EmptyState/EmptyState.lua
-- Placeholder shown in empty content areas (no items, no results, etc.).
-- Inspired by WinUI empty state patterns.
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT

local function updateLayout(self)
    self.TitleLabel:SetWordWrap(true)
    self.DescLabel:SetWordWrap(true)

    self.TitleLabel:ClearAllPoints()
    if self.Icon:IsShown() then
        self.TitleLabel:SetPoint("TOP", self.Icon, "BOTTOM", 0, -16)
    else
        self.TitleLabel:SetPoint("TOP", self, "TOP", 0, -24)
    end
    self.TitleLabel:SetPoint("LEFT", self, "LEFT", 24, 0)
    self.TitleLabel:SetPoint("RIGHT", self, "RIGHT", -24, 0)

    self.DescLabel:ClearAllPoints()
    self.DescLabel:SetPoint("TOP", self.TitleLabel, "BOTTOM", 0, -8)
    self.DescLabel:SetPoint("LEFT", self, "LEFT", 24, 0)
    self.DescLabel:SetPoint("RIGHT", self, "RIGHT", -24, 0)

    self.ActionSlot:ClearAllPoints()
    self.ActionSlot:SetPoint("TOP", self.DescLabel, "BOTTOM", 0, -16)
    self.ActionSlot:SetPoint("LEFT", self, "LEFT", 24, 0)
    self.ActionSlot:SetPoint("RIGHT", self, "RIGHT", -24, 0)

    local iconH = self.Icon:IsShown() and (self.Icon:GetStringHeight() or T:GetNumber("Icon.XL")) or 0
    local titleH = self.TitleLabel:GetStringHeight() or 0
    local descH = self.DescLabel:GetStringHeight() or 0
    local actionH = self.ActionSlot:IsShown() and (self.ActionSlot:GetHeight() + 16) or 0
    self:SetHeight(math.max(120, 24 + iconH + 16 + titleH + 8 + descH + actionH + 24))
end

-------------------------------------------------------------------------------
-- EmptyState Mixin
-------------------------------------------------------------------------------

---@class FWoWEmptyState
local EmptyStateMixin = {}

function EmptyStateMixin:OnStateChanged(newState, prevState)
    self.TitleLabel:SetTextColor(T:GetColor("Color.Text.Primary"))
    self.DescLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
    self.Icon:SetTextColor(T:GetColor("Color.Text.Secondary"))

    if newState == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end
end

---@param icon string Fluent icon character
function EmptyStateMixin:SetIcon(icon)
    if icon and icon ~= "" then
        if ICON_FONT then
            self.Icon:SetFont(ICON_FONT, T:GetNumber("Icon.XL"), "")
        end
        self.Icon:SetText(icon)
        self.Icon:Show()
    else
        self.Icon:Hide()
    end
    updateLayout(self)
end

---@param title string
function EmptyStateMixin:SetTitle(title)
    self.TitleLabel:SetText(title)
    updateLayout(self)
end

---@return string
function EmptyStateMixin:GetTitle()
    return self.TitleLabel:GetText() or ""
end

---@param desc string
function EmptyStateMixin:SetDescription(desc)
    self.DescLabel:SetText(desc)
    updateLayout(self)
end

---@return string
function EmptyStateMixin:GetDescription()
    return self.DescLabel:GetText() or ""
end

---@param control Frame action button to show below description
function EmptyStateMixin:SetActionControl(control)
    self._actionControl = control
    if control then
        control:SetParent(self.ActionSlot)
        control:ClearAllPoints()
        control:SetPoint("CENTER", self.ActionSlot, "CENTER")
        self.ActionSlot:Show()
    else
        self.ActionSlot:Hide()
    end
    updateLayout(self)
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWEmptyState_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, EmptyStateMixin)
    self:FWoWInit()

    local titleFont = T:Get("Typography.Title")
    if titleFont then
        self.TitleLabel:SetFont(titleFont.font, titleFont.size, titleFont.flags)
    end

    local bodyFont = T:Get("Typography.Body")
    if bodyFont then
        self.DescLabel:SetFont(bodyFont.font, bodyFont.size, bodyFont.flags)
    end

    self.ActionSlot:Hide()
    updateLayout(self)
    self:OnStateChanged("Normal")
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWEmptyState
function lib:CreateEmptyState(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWEmptyStateTemplate")
    ---@cast f FWoWEmptyState
    return f
end

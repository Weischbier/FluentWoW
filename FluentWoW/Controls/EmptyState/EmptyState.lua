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
end

---@param title string
function EmptyStateMixin:SetTitle(title)
    self.TitleLabel:SetText(title)
end

---@return string
function EmptyStateMixin:GetTitle()
    return self.TitleLabel:GetText() or ""
end

---@param desc string
function EmptyStateMixin:SetDescription(desc)
    self.DescLabel:SetText(desc)
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

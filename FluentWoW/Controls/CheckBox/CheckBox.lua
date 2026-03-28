--- FluentWoW – Controls/CheckBox/CheckBox.lua
-- Three-state checkbox: unchecked, checked, indeterminate.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/checkbox
-- States: Normal | Hover | Pressed | Disabled | Checked
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion
local Tex = lib.Textures

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT

local function updateLayout(self)
    local font = T:Get("Typography.Body")
    if font then
        self.Label:SetFont(font.font, font.size, font.flags)
    end

    self.Check:ClearAllPoints()
    self.Check:SetPoint("CENTER", self.Box, "CENTER", 0, 0)

    self.Label:ClearAllPoints()
    self.Label:SetPoint("LEFT", self.Box, "RIGHT", T:GetNumber("Spacing.MD"), 0)
    self.Label:SetPoint("RIGHT", self, "RIGHT", 0, 0)

    local labelW = self.Label:GetStringWidth() or 0
    local extra = labelW > 0 and (T:GetNumber("Spacing.MD") + labelW) or 0
    self:SetSize(math.max(20 + extra, 20), 20)
end

local function updateVisualState(self, state)
    local targetState = state or self._vsm:GetState() or "Normal"
    local active = self._checked or self._indeterminate

    if self._vsm:GetState() ~= targetState then
        self._vsm:SetState(targetState)
    else
        self:OnStateChanged(targetState, targetState)
    end

    if active and targetState == "Normal" then
        self:OnStateChanged("Checked", targetState)
    end
end

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class FWoWCheckBox
local CheckBoxMixin = {}

function CheckBoxMixin:OnStateChanged(newState, prevState)
    local state = newState
    local boxKey, labelKey, checkShow

    if state == "Disabled" then
        boxKey   = "Color.Border.Default"
        labelKey = "Color.Text.Disabled"
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
        labelKey = "Color.Text.Primary"
        if self._checked or self._indeterminate then
            boxKey = "Color.Accent.Primary"
            if state == "Hover" then boxKey = "Color.Accent.Hover" end
        else
            boxKey = "Color.Border.Default"
            if state == "Hover" then boxKey = "Color.Border.Focus" end
        end
    end

    if self._checked or self._indeterminate then
        self.Box:SetTexture(Tex.RoundSquareFill)
    else
        self.Box:SetTexture(Tex.RoundSquare)
    end
    self.Box:SetVertexColor(T:GetColor(boxKey))
    self.Label:SetTextColor(T:GetColor(labelKey))

    if self._checked then
        self.Check:Show()
        self.Check:SetText(Icons.CheckMark)
        self.Check:SetTextColor(T:GetColor("Color.Icon.OnAccent"))
    elseif self._indeterminate then
        self.Check:Show()
        self.Check:SetText(Icons.Remove)
        self.Check:SetTextColor(T:GetColor("Color.Icon.OnAccent"))
    else
        self.Check:Hide()
    end
end

---@param checked boolean
function CheckBoxMixin:SetChecked(checked)
    self._checked = checked
    self._indeterminate = false
    if checked then
        updateVisualState(self, "Checked")
    else
        updateVisualState(self, "Normal")
    end
end

---@return boolean
function CheckBoxMixin:IsChecked()
    return self._checked == true
end

---@param indeterminate boolean
function CheckBoxMixin:SetIndeterminate(indeterminate)
    self._indeterminate = indeterminate
    if indeterminate then
        self._checked = false
    end
    if indeterminate then
        updateVisualState(self, "Checked")
    else
        updateVisualState(self, self._checked and "Checked" or "Normal")
    end
end

---@return boolean
function CheckBoxMixin:IsIndeterminate()
    return self._indeterminate == true
end

---@param enabled boolean
function CheckBoxMixin:SetThreeState(enabled)
    self._threeState = enabled == true
end

---@return boolean
function CheckBoxMixin:IsThreeState()
    return self._threeState == true
end

---@return string
function CheckBoxMixin:GetCheckState()
    if self._indeterminate then
        return "Indeterminate"
    end
    if self._checked then
        return "Checked"
    end
    return "Unchecked"
end

---@param text string
function CheckBoxMixin:SetText(text)
    self.Label:SetText(text)
    updateLayout(self)
end

---@return string
function CheckBoxMixin:GetText()
    return self.Label:GetText() or ""
end

---@param fn function
function CheckBoxMixin:SetOnChanged(fn)
    self._onChanged = fn
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWCheckBox_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, CheckBoxMixin)
    self:FWoWInit()
    self._checked = false
    self._indeterminate = false
    self._threeState = false
    self.Box:SetTexture(Tex.RoundSquare)
    self.Check:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
    updateLayout(self)
    self:OnStateChanged("Normal")
end

function FWoWCheckBox_OnClick(self)
    if not self._enabled then return end
    if self._threeState then
        if not self._checked and not self._indeterminate then
            self._checked = true
            self._indeterminate = false
        elseif self._checked then
            self._checked = false
            self._indeterminate = true
        else
            self._checked = false
            self._indeterminate = false
        end
    else
        self._indeterminate = false
        self._checked = not self._checked
    end

    updateVisualState(self, (self._checked or self._indeterminate) and "Checked" or "Normal")
    if self._onChanged then
        lib.Utils.SafeCall(self._onChanged, self, self._checked, self:GetCheckState())
    end
end

function FWoWCheckBox_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    self:ShowTooltip()
end

function FWoWCheckBox_OnLeave(self)
    if not self._enabled then return end
    updateVisualState(self, (self._checked or self._indeterminate) and "Checked" or "Normal")
    GameTooltip:Hide()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWCheckBox
function lib:CreateCheckBox(parent, name)
    local f = CreateFrame("Button", name, parent, "FWoWCheckBoxTemplate")
    ---@cast f FWoWCheckBox
    return f
end

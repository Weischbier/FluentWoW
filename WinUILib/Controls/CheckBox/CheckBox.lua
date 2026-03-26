--- WinUILib – Controls/CheckBox/CheckBox.lua
-- Three-state checkbox: unchecked, checked, indeterminate.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/checkbox
-- States: Normal | Hover | Pressed | Disabled | Checked
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens
local Mot = lib.Motion

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILCheckBox
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
        if self._checked then
            boxKey = "Color.Accent.Primary"
            if state == "Hover" then boxKey = "Color.Accent.Hover" end
        else
            boxKey = "Color.Border.Default"
            if state == "Hover" then boxKey = "Color.Border.Focus" end
        end
    end

    self.Box:SetColorTexture(T:GetColor(boxKey))
    self.Label:SetTextColor(T:GetColor(labelKey))

    if self._checked then
        self.Check:Show()
        self.Check:SetVertexColor(T:GetColor("Color.Icon.OnAccent"))
    elseif self._indeterminate then
        self.Check:Show()
        self.Check:SetVertexColor(T:GetColor("Color.Icon.OnAccent"))
    else
        self.Check:Hide()
    end
end

---@param checked boolean
function CheckBoxMixin:SetChecked(checked)
    self._checked = checked
    self._indeterminate = false
    if checked then
        self._vsm:SetState("Checked")
    else
        self._vsm:SetState("Normal")
    end
end

---@return boolean
function CheckBoxMixin:IsChecked()
    return self._checked == true
end

---@param indeterminate boolean
function CheckBoxMixin:SetIndeterminate(indeterminate)
    self._indeterminate = indeterminate
    self:OnStateChanged(self._vsm:GetState())
end

---@return boolean
function CheckBoxMixin:IsIndeterminate()
    return self._indeterminate == true
end

---@param text string
function CheckBoxMixin:SetText(text)
    self.Label:SetText(text)
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

function WUILCheckBox_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, CheckBoxMixin)
    self:WUILInit()
    self._checked = false
    self._indeterminate = false
    self.Check:SetColorTexture(1, 1, 1)
    self:OnStateChanged("Normal")
end

function WUILCheckBox_OnClick(self)
    if not self._enabled then return end
    self._indeterminate = false
    self._checked = not self._checked
    if self._checked then
        self._vsm:SetState("Checked")
    else
        self._vsm:SetState("Normal")
    end
    if self._onChanged then
        lib.Utils.SafeCall(self._onChanged, self, self._checked)
    end
end

function WUILCheckBox_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    self:ShowTooltip()
end

function WUILCheckBox_OnLeave(self)
    if not self._enabled then return end
    if self._checked then
        self._vsm:SetState("Checked")
    else
        self._vsm:SetState("Normal")
    end
    GameTooltip:Hide()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return WUILCheckBox
function lib:CreateCheckBox(parent, name)
    return CreateFrame("Button", name, parent, "WUILCheckBoxTemplate")
end

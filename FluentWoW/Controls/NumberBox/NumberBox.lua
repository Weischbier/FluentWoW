--- FluentWoW – Controls/NumberBox/NumberBox.lua
-- Validated numeric input with spin buttons and optional min/max/step.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/number-box
-- States: Normal | Hover | Focused | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT

-------------------------------------------------------------------------------
-- NumberBox Mixin
-------------------------------------------------------------------------------

---@class FWoWNumberBox
local NumberBoxMixin = {}

local function clampValue(self, value)
    if self._min and value < self._min then value = self._min end
    if self._max and value > self._max then value = self._max end
    return value
end

local function applyLayout(self)
    local headerHeight = (self._headerText and self._headerText ~= "")
        and (T:GetNumber("Spacing.XL") + T:GetNumber("Spacing.SM")) or 0

    self:SetHeight(32 + headerHeight)
    self.HeaderLabel:SetShown(headerHeight > 0)
    self.HeaderLabel:SetText(self._headerText or "")

    self.Field:ClearAllPoints()
    if headerHeight > 0 then
        self.Field:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -headerHeight)
        self.Field:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -headerHeight)
        self.Field:SetHeight(32)
    else
        self.Field:SetAllPoints(self)
    end
end

function NumberBoxMixin:OnStateChanged(newState, prevState)
    local state = newState
    local field = self.Field

    local sr, sg, sb = T:GetColor("Color.Surface.Base")
    field.Shadow:SetColorTexture(sr, sg, sb, 0.85)

    if state == "Disabled" then
        field.BG:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        field.Border:SetColorTexture(T:GetColor("Color.Border.Default"))
        field.TopEdge:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        field.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        field.EditBox:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
        field.EditBox:EnableMouse(false)
        field.EditBox:EnableKeyboard(false)
    elseif state == "Focused" then
        self:SetAlpha(1)
        field.BG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
        field.Border:SetColorTexture(T:GetColor("Color.Border.Focus"))
        field.TopEdge:SetColorTexture(T:GetColor("Color.Accent.Light"))
        field.BottomEdge:SetColorTexture(T:GetColor("Color.Accent.Primary"))
        field.EditBox:SetTextColor(T:GetColor("Color.Text.Primary"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
        field.EditBox:EnableMouse(true)
        field.EditBox:EnableKeyboard(true)
    elseif state == "Hover" then
        self:SetAlpha(1)
        field.BG:SetColorTexture(T:GetColor("Color.Surface.Overlay"))
        field.Border:SetColorTexture(T:GetColor("Color.Border.Default"))
        field.TopEdge:SetColorTexture(T:GetColor("Color.Border.Focus"))
        field.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        field.EditBox:SetTextColor(T:GetColor("Color.Text.Primary"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
        field.EditBox:EnableMouse(true)
        field.EditBox:EnableKeyboard(true)
    else
        self:SetAlpha(1)
        field.BG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
        field.Border:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        field.TopEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        field.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        field.EditBox:SetTextColor(T:GetColor("Color.Text.Primary"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
        field.EditBox:EnableMouse(true)
        field.EditBox:EnableKeyboard(true)
    end

    -- Spin button arrows
    local arrowKey = state == "Disabled" and "Color.Text.Disabled" or "Color.Text.Secondary"
    field.SpinUp.Arrow:SetTextColor(T:GetColor(arrowKey))
    field.SpinDown.Arrow:SetTextColor(T:GetColor(arrowKey))
end

---@param value number
function NumberBoxMixin:SetValue(value)
    value = clampValue(self, value)
    self._value = value
    self.Field.EditBox:SetText(tostring(value))
end

---@return number
function NumberBoxMixin:GetValue()
    return self._value or 0
end

---@param min number
function NumberBoxMixin:SetMinimum(min)
    self._min = min
    self._value = clampValue(self, self._value or 0)
    self.Field.EditBox:SetText(tostring(self._value))
end

---@param max number
function NumberBoxMixin:SetMaximum(max)
    self._max = max
    self._value = clampValue(self, self._value or 0)
    self.Field.EditBox:SetText(tostring(self._value))
end

---@param step number
function NumberBoxMixin:SetStep(step)
    self._step = step
end

---@return number
function NumberBoxMixin:GetStep()
    return self._step or 1
end

---@param text string
function NumberBoxMixin:SetHeader(text)
    self._headerText = text
    applyLayout(self)
    self:OnStateChanged(self._vsm:GetState())
end

---@param fn function(self, value)
function NumberBoxMixin:SetOnValueChanged(fn)
    self._onValueChanged = fn
end

function NumberBoxMixin:_CommitValue()
    local text = self.Field.EditBox:GetText()
    local num = tonumber(text)
    if num then
        num = clampValue(self, num)
        self._value = num
    end
    self.Field.EditBox:SetText(tostring(self._value))
    if self._onValueChanged then
        lib.Utils.SafeCall(self._onValueChanged, self, self._value)
    end
end

function NumberBoxMixin:_Spin(delta)
    local step = self._step or 1
    local newVal = clampValue(self, (self._value or 0) + delta * step)
    if newVal ~= self._value then
        self._value = newVal
        self.Field.EditBox:SetText(tostring(newVal))
        if self._onValueChanged then
            lib.Utils.SafeCall(self._onValueChanged, self, newVal)
        end
    end
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWNumberBox_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, NumberBoxMixin)
    self:FWoWInit()
    self._value = 0
    self._min = nil
    self._max = nil
    self._step = 1

    if ICON_FONT then
        self.Field.SpinUp.Arrow:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
        self.Field.SpinUp.Arrow:SetText(Icons.ChevronUp)
        self.Field.SpinDown.Arrow:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
        self.Field.SpinDown.Arrow:SetText(Icons.ChevronDown)
    else
        self.Field.SpinUp.Arrow:SetText("+")
        self.Field.SpinDown.Arrow:SetText("-")
    end

    self.Field.EditBox:SetText("0")
    applyLayout(self)
    self:OnStateChanged("Normal")
end

function FWoWNumberBox_OnEnter(self)
    if self._enabled then self._vsm:SetState("Hover") end
end

function FWoWNumberBox_OnLeave(self)
    if self._enabled and self._vsm:GetState() ~= "Focused" then
        self._vsm:SetState("Normal")
    end
end

function FWoWNumberBox_OnFocusGained(self)
    local parent = self:GetParent():GetParent()
    if parent._enabled then parent._vsm:SetState("Focused") end
end

function FWoWNumberBox_OnFocusLost(self)
    local parent = self:GetParent():GetParent()
    parent:_CommitValue()
    if parent._enabled then parent._vsm:SetState("Normal") end
end

function FWoWNumberBox_OnEnterPressed(self)
    local parent = self:GetParent():GetParent()
    parent:_CommitValue()
    self:ClearFocus()
end

function FWoWNumberBox_OnEscapePressed(self)
    local parent = self:GetParent():GetParent()
    self:SetText(tostring(parent._value or 0))
    self:ClearFocus()
end

function FWoWNumberBox_OnTextChanged(self, userInput)
    if not userInput then return end
    -- Allow typing; validation happens on commit
end

function FWoWNumberBox_SpinUp_OnClick(self)
    local nb = self:GetParent():GetParent()
    nb:_Spin(1)
end

function FWoWNumberBox_SpinDown_OnClick(self)
    local nb = self:GetParent():GetParent()
    nb:_Spin(-1)
end

function FWoWNumberBox_Spin_OnEnter(self)
    self.BG:SetColorTexture(T:GetColor("Color.Overlay.Hover"))
    self.BG:Show()
end

function FWoWNumberBox_Spin_OnLeave(self)
    self.BG:Hide()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWNumberBox
function lib:CreateNumberBox(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWNumberBoxTemplate")
    ---@cast f FWoWNumberBox
    return f
end

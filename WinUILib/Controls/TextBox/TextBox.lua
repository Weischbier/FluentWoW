--- WinUILib – Controls/TextBox/TextBox.lua
-- Single-line text input with placeholder, clear button, and focus styling.
-- Also includes SearchBox variant with search icon.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/text-box
-- States: Normal | Hover | Focused | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILTextBox
local TextBoxMixin = {}

function TextBoxMixin:OnStateChanged(newState, prevState)
    local state = newState

    if state == "Disabled" then
        self.BG:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        self.Border:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.EditBox:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
        self.EditBox:EnableMouse(false)
    elseif state == "Focused" then
        self:SetAlpha(1)
        self.BG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
        self.Border:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        self.BottomEdge:SetColorTexture(T:GetColor("Color.Accent.Primary"))
        self.EditBox:SetTextColor(T:GetColor("Color.Text.Primary"))
        self.EditBox:EnableMouse(true)
    elseif state == "Hover" then
        self:SetAlpha(1)
        self.BG:SetColorTexture(T:GetColor("Color.Surface.Overlay"))
        self.Border:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        self.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.EditBox:SetTextColor(T:GetColor("Color.Text.Primary"))
        self.EditBox:EnableMouse(true)
    else
        self:SetAlpha(1)
        self.BG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
        self.Border:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        self.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.EditBox:SetTextColor(T:GetColor("Color.Text.Primary"))
        self.EditBox:EnableMouse(true)
    end

    self:_UpdatePlaceholder()
    self:_UpdateClear()
end

function TextBoxMixin:_UpdatePlaceholder()
    local text = self.EditBox:GetText()
    if text == "" and self._vsm:GetState() ~= "Focused" then
        self.Placeholder:Show()
    else
        self.Placeholder:Hide()
    end
end

function TextBoxMixin:_UpdateClear()
    local text = self.EditBox:GetText()
    if text ~= "" and self._vsm:GetState() == "Focused" then
        self.ClearBtn:Show()
    else
        self.ClearBtn:Hide()
    end
end

---@param text string
function TextBoxMixin:SetText(text)
    self.EditBox:SetText(text)
    self:_UpdatePlaceholder()
    self:_UpdateClear()
end

---@return string
function TextBoxMixin:GetText()
    return self.EditBox:GetText() or ""
end

---@param text string
function TextBoxMixin:SetPlaceholder(text)
    self._placeholderText = text
    self.Placeholder:SetText(text)
    self.Placeholder:SetTextColor(T:GetColor("Color.Text.Secondary"))
end

---@param fn function
function TextBoxMixin:SetOnTextChanged(fn)
    self._onTextChanged = fn
end

---@param fn function
function TextBoxMixin:SetOnEnterPressed(fn)
    self._onEnterPressed = fn
end

---@param maxLen integer
function TextBoxMixin:SetMaxLength(maxLen)
    self.EditBox:SetMaxLetters(maxLen)
end

---@param isPassword boolean
function TextBoxMixin:SetPassword(isPassword)
    self.EditBox:SetSecurityFlag(isPassword and 1 or 0)
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILTextBox_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, TextBoxMixin)
    self:WUILInit()
    self._placeholderText = ""
    self.ClearBtn.X:SetTextColor(T:GetColor("Color.Text.Secondary"))
    self:OnStateChanged("Normal")
end

function WUILSearchBox_OnLoad(self)
    WUILTextBox_OnLoad(self)
    self._isSearch = true
    self:SetPlaceholder("Search")
end

function WUILTextBox_OnTextChanged(self, userInput)
    local parent = self:GetParent()
    parent:_UpdatePlaceholder()
    parent:_UpdateClear()
    if parent._onTextChanged then
        lib.Utils.SafeCall(parent._onTextChanged, parent, self:GetText(), userInput)
    end
end

function WUILTextBox_OnFocusGained(self)
    local parent = self:GetParent()
    parent._vsm:SetState("Focused")
end

function WUILTextBox_OnFocusLost(self)
    local parent = self:GetParent()
    parent._vsm:SetState("Normal")
end

function WUILTextBox_OnEnterPressed(self)
    local parent = self:GetParent()
    if parent._onEnterPressed then
        lib.Utils.SafeCall(parent._onEnterPressed, parent, self:GetText())
    end
    self:ClearFocus()
end

function WUILTextBox_OnEscapePressed(self)
    self:ClearFocus()
end

function WUILTextBox_OnClear(self)
    local parent = self:GetParent()
    parent.EditBox:SetText("")
    parent.EditBox:SetFocus()
end

function WUILTextBox_OnEnter(self)
    if not self._enabled then return end
    if self._vsm:GetState() ~= "Focused" then
        self._vsm:SetState("Hover")
    end
    self:ShowTooltip()
end

function WUILTextBox_OnLeave(self)
    if not self._enabled then return end
    if self._vsm:GetState() ~= "Focused" then
        self._vsm:SetState("Normal")
    end
    GameTooltip:Hide()
end

function WUILTextBox_OnMouseDown(self)
    if not self._enabled then return end
    self.EditBox:SetFocus()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return Frame
function lib:CreateTextBox(parent, name)
    return CreateFrame("Frame", name, parent, "WUILTextBoxTemplate")
end

---@param parent Frame
---@param name? string
---@return Frame
function lib:CreateSearchBox(parent, name)
    return CreateFrame("Frame", name, parent, "WUILSearchBoxTemplate")
end

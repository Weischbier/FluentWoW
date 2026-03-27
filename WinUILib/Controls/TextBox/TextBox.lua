--- WinUILib – Controls/TextBox/TextBox.lua
-- Single-line text input with placeholder, clear button, and focus styling.
-- Also includes SearchBox variant with search icon.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/text-box
-- States: Normal | Hover | Focused | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT

local function applyLayout(self)
    local headerHeight = self._headerText ~= nil and self._headerText ~= "" and (T:GetNumber("Spacing.XL") + T:GetNumber("Spacing.SM")) or 0
    local fieldHeight = self._multiline and (self._multilineHeight or 96) or 32
    local leftInset = self.SearchIcon and 30 or 12
    local rightInset = (self._multiline or self._readOnly) and 12 or 32

    self:SetHeight(fieldHeight + headerHeight)
    self.HeaderLabel:SetShown(headerHeight > 0)
    self.HeaderLabel:SetText(self._headerText or "")

    self.Field:ClearAllPoints()
    if headerHeight > 0 then
        self.Field:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -headerHeight)
        self.Field:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -headerHeight)
        self.Field:SetHeight(fieldHeight)
    else
        self.Field:SetAllPoints(self)
    end

    self.Field.EditBox:SetMultiLine(self._multiline == true)
    self.Field.EditBox:ClearAllPoints()
    self.Field.EditBox:SetPoint("TOPLEFT", leftInset, -8)
    self.Field.EditBox:SetPoint("BOTTOMRIGHT", -rightInset, 8)

    self.Field.Placeholder:ClearAllPoints()
    self.Field.Placeholder:SetPoint("TOPLEFT", leftInset, -8)
    self.Field.Placeholder:SetPoint("BOTTOMRIGHT", -rightInset, 8)
end

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILTextBox
local TextBoxMixin = {}

function TextBoxMixin:OnStateChanged(newState, prevState)
    local state = newState
    local field = self.Field

    local shadowR, shadowG, shadowB = T:GetColor("Color.Surface.Base")
    field.Shadow:SetColorTexture(shadowR, shadowG, shadowB, 0.85)

    if state == "Disabled" then
        field.BG:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        field.Border:SetColorTexture(T:GetColor("Color.Border.Default"))
        field.TopEdge:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        field.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        field.EditBox:SetTextColor(T:GetColor("Color.Text.Disabled"))
        field.ClearBtn.X:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
        field.EditBox:EnableMouse(false)
        field.EditBox:EnableKeyboard(false)
    elseif self._readOnly then
        self:SetAlpha(1)
        field.BG:SetColorTexture(T:GetColor("Color.Surface.Base"))
        field.Border:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        field.TopEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        field.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        field.EditBox:SetTextColor(T:GetColor("Color.Accent.Primary"))
        field.ClearBtn.X:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
        field.EditBox:EnableMouse(false)
        field.EditBox:EnableKeyboard(false)
    elseif state == "Focused" then
        self:SetAlpha(1)
        field.BG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
        field.Border:SetColorTexture(T:GetColor("Color.Border.Focus"))
        field.TopEdge:SetColorTexture(T:GetColor("Color.Accent.Light"))
        field.BottomEdge:SetColorTexture(T:GetColor("Color.Accent.Primary"))
        field.EditBox:SetTextColor(T:GetColor("Color.Text.Primary"))
        field.ClearBtn.X:SetTextColor(T:GetColor("Color.Accent.Primary"))
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
        field.ClearBtn.X:SetTextColor(T:GetColor("Color.Text.Primary"))
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
        field.ClearBtn.X:SetTextColor(T:GetColor("Color.Text.Secondary"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
        field.EditBox:EnableMouse(true)
        field.EditBox:EnableKeyboard(true)
    end

    if self.SearchIcon then
        local iconKey = state == "Focused" and "Color.Accent.Primary"
            or state == "Hover" and "Color.Text.Primary"
            or state == "Disabled" and "Color.Text.Disabled"
            or "Color.Text.Secondary"
        self.SearchIcon:SetTextColor(T:GetColor(iconKey))
    end

    self:_UpdatePlaceholder()
    self:_UpdateClear()
end

function TextBoxMixin:_UpdatePlaceholder()
    local text = self.Field.EditBox:GetText()
    if text == "" and self._vsm:GetState() ~= "Focused" then
        self.Field.Placeholder:Show()
    else
        self.Field.Placeholder:Hide()
    end
end

function TextBoxMixin:_UpdateClear()
    local text = self.Field.EditBox:GetText()
    if not self._readOnly and not self._multiline and text ~= "" and self._vsm:GetState() == "Focused" then
        self.Field.ClearBtn:Show()
    else
        self.Field.ClearBtn:Hide()
    end
end

---@param text string
function TextBoxMixin:SetText(text)
    self.Field.EditBox:SetText(text)
    self:_UpdatePlaceholder()
    self:_UpdateClear()
end

---@return string
function TextBoxMixin:GetText()
    return self.Field.EditBox:GetText() or ""
end

---@param text string
function TextBoxMixin:SetPlaceholder(text)
    self._placeholderText = text
    self.Field.Placeholder:SetText(text)
    self.Field.Placeholder:SetTextColor(T:GetColor("Color.Text.Secondary"))
end

---@param text string
function TextBoxMixin:SetHeader(text)
    self._headerText = text
    applyLayout(self)
    self:OnStateChanged(self._vsm:GetState())
end

---@param readOnly boolean
function TextBoxMixin:SetReadOnly(readOnly)
    self._readOnly = readOnly == true
    if self._readOnly then
        self.Field.EditBox:ClearFocus()
    end
    applyLayout(self)
    self:OnStateChanged(self._vsm:GetState())
end

---@param multiline boolean
---@param height? number
function TextBoxMixin:SetMultiline(multiline, height)
    self._multiline = multiline == true
    if height then
        self._multilineHeight = height
    elseif self._multiline and not self._multilineHeight then
        self._multilineHeight = 96
    end
    applyLayout(self)
    self:OnStateChanged(self._vsm:GetState())
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
    self.Field.EditBox:SetMaxLetters(maxLen)
end

---@param isPassword boolean
function TextBoxMixin:SetPassword(isPassword)
    -- WoW EditBox does not support native password masking.
    -- This is a no-op placeholder; implement character masking if needed.
    lib:Debug("TextBox:SetPassword is not supported in WoW")
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILTextBox_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, TextBoxMixin)
    self:WUILInit()
    self._placeholderText = ""
    self._headerText = nil
    self._readOnly = false
    self._multiline = false
    self._multilineHeight = nil
    self.Field.ClearBtn.X:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
    self.Field.ClearBtn.X:SetText(Icons.Cancel)
    self.Field.ClearBtn.X:SetTextColor(T:GetColor("Color.Text.Secondary"))
    applyLayout(self)
    self:OnStateChanged("Normal")
end

function WUILSearchBox_OnLoad(self)
    WUILTextBox_OnLoad(self)
    self._isSearch = true
    if self.SearchIcon then
        self.SearchIcon:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
        self.SearchIcon:SetText(Icons.Search)
    end
    applyLayout(self)
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
    if parent._readOnly then
        self:ClearFocus()
        return
    end
    parent._vsm:SetState("Focused")
end

function WUILTextBox_OnFocusLost(self)
    local parent = self:GetParent()
    parent._vsm:SetState("Normal")
end

function WUILTextBox_OnEnterPressed(self)
    local parent = self:GetParent()
    if parent._multiline then
        self:Insert("\n")
        return
    end
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
    parent.Field.EditBox:SetText("")
    parent.Field.EditBox:SetFocus()
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
    if not self._enabled or self._readOnly then return end
    self.Field.EditBox:SetFocus()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return WUILTextBox
function lib:CreateTextBox(parent, name)
    local f = CreateFrame("Frame", name, parent, "WUILTextBoxTemplate")
    ---@cast f WUILTextBox
    return f
end

---@param parent Frame
---@param name? string
---@return WUILTextBox
function lib:CreateSearchBox(parent, name)
    local f = CreateFrame("Frame", name, parent, "WUILSearchBoxTemplate")
    ---@cast f WUILTextBox
    return f
end

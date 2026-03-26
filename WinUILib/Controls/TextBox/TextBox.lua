--- WinUILib – Controls/TextBox/TextBox.lua
-- Styled EditBox wrapper with placeholder, focus line, and validation states.
-- Design ref: WinUI TextBox, SearchBox, NumberBox
--
-- Public API:
--   :SetText(text)        :GetText()
--   :SetPlaceholder(text)
--   :SetMaxLength(n)
--   :SetNumericOnly(bool)
--   :SetEnabled(bool)
--   :SetValidationState("Normal"|"Error"|"Warning", message?)
--   OnTextChanged(self, text)
--   OnConfirmed(self, text)    (Enter key)
--   OnCancelled(self)          (Escape key)
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens

local BORDER_NORMAL = { 0.50, 0.50, 0.55, 1 }
local BORDER_HOVER  = { 0.68, 0.68, 0.72, 1 }
local BORDER_FOCUS  = { 0.05, 0.55, 0.88, 1 }
local BORDER_ERROR  = { 0.90, 0.20, 0.20, 1 }
local BORDER_WARN   = { 1.00, 0.80, 0.10, 1 }
local BG_NORMAL     = { 0.10, 0.10, 0.11, 1 }
local BG_HOVER      = { 0.13, 0.13, 0.14, 1 }

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILTextBox_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.TextBox)
    self:WUILInit()
    self._placeholder     = ""
    self._validationState = "Normal"
    self:_ApplyBorderState("Normal")
end

function WUILTextBox_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    local border = _G[self:GetName() .. "_Border"]
    if border and self._validationState == "Normal" then
        border:SetColorTexture(table.unpack(BORDER_HOVER))
    end
    local bg = _G[self:GetName() .. "_BG"]
    if bg then bg:SetColorTexture(table.unpack(BG_HOVER)) end
end

function WUILTextBox_OnLeave(self)
    if not self._enabled then return end
    local focused = _G[self:GetName() .. "_Input"]
    if focused and focused:HasFocus() then return end  -- keep focus style
    self._vsm:SetState("Normal")
    self:_ApplyBorderState(self._validationState)
end

function WUILTextBox_OnFocusGained(self)
    -- self = EditBox; get container
    local container = self:GetParent()
    if not container then return end
    container._vsm:SetState("Focused")
    local border = _G[container:GetName() .. "_Border"]
    if border then border:SetColorTexture(table.unpack(BORDER_FOCUS)) end
    local fl = _G[container:GetName() .. "_FocusLine"]
    if fl then fl:SetAlpha(1) end
    -- Hide placeholder when focused
    local ph = _G[container:GetName() .. "_Placeholder"]
    if ph then ph:Hide() end
end

function WUILTextBox_OnFocusLost(self)
    local container = self:GetParent()
    if not container then return end
    container._vsm:SetState("Normal")
    local fl = _G[container:GetName() .. "_FocusLine"]
    if fl then fl:SetAlpha(0) end
    container:_ApplyBorderState(container._validationState)
    -- Show placeholder if empty
    local input = _G[container:GetName() .. "_Input"]
    local ph    = _G[container:GetName() .. "_Placeholder"]
    if ph and input then
        ph:SetShown(input:GetText() == "")
    end
end

function WUILTextBox_OnTextChanged(self, userInput)
    local container = self:GetParent()
    if not container then return end
    local text = self:GetText()
    -- Show / hide placeholder
    local ph = _G[container:GetName() .. "_Placeholder"]
    if ph then ph:SetShown(text == "") end
    if container.OnTextChanged and userInput then
        lib.Utils.SafeCall(container.OnTextChanged, container, text)
    end
end

function WUILTextBox_OnEnterPressed(self)
    local container = self:GetParent()
    if not container then return end
    if container.OnConfirmed then
        lib.Utils.SafeCall(container.OnConfirmed, container, self:GetText())
    end
    self:ClearFocus()
end

function WUILTextBox_OnEscapePressed(self)
    local container = self:GetParent()
    if not container then return end
    if container.OnCancelled then
        lib.Utils.SafeCall(container.OnCancelled, container)
    end
    self:ClearFocus()
end

-- SearchBox init – offset the internal EditBox for the search icon
function WUILSearchBox_OnLoad(self)
    WUILTextBox_OnLoad(self)
    local input = _G[self:GetName() .. "_Input"]
    if input then
        input:ClearAllPoints()
        input:SetPoint("LEFT",  self, "LEFT",  28, 0)
        input:SetPoint("RIGHT", self, "RIGHT", -8, 0)
    end
    local ph = _G[self:GetName() .. "_Placeholder"]
    if ph then
        ph:ClearAllPoints()
        ph:SetPoint("LEFT",  self, "LEFT",  28, 0)
        ph:SetPoint("RIGHT", self, "RIGHT", -8, 0)
    end
end

-------------------------------------------------------------------------------
-- TextBox mixin
-------------------------------------------------------------------------------

---@class WUILTextBox : WUILControlBase
local TextBox = {}
lib._controls.TextBox = TextBox

---@param text string
function TextBox:SetText(text)
    local input = _G[self:GetName() .. "_Input"]
    if input then
        input:SetText(text or "")
        local ph = _G[self:GetName() .. "_Placeholder"]
        if ph then ph:SetShown((text or "") == "") end
    end
end

---@return string
function TextBox:GetText()
    local input = _G[self:GetName() .. "_Input"]
    return input and input:GetText() or ""
end

---@param text string
function TextBox:SetPlaceholder(text)
    self._placeholder = text
    local ph = _G[self:GetName() .. "_Placeholder"]
    if ph then
        ph:SetText(text or "")
        ph:SetShown(self:GetText() == "")
    end
end

---@param n integer
function TextBox:SetMaxLength(n)
    local input = _G[self:GetName() .. "_Input"]
    if input then input:SetMaxLetters(n) end
end

---@param numeric boolean
function TextBox:SetNumericOnly(numeric)
    local input = _G[self:GetName() .. "_Input"]
    if input then input:SetNumeric(numeric) end
end

--- Sets a validation state: "Normal" | "Error" | "Warning"
---@param state   string
---@param message string?  Optional tooltip message
function TextBox:SetValidationState(state, message)
    self._validationState = state
    self:_ApplyBorderState(state)
    if message then self:SetTooltip(message) end
end

function TextBox:_ApplyBorderState(state)
    local border = _G[self:GetName() .. "_Border"]
    local bg     = _G[self:GetName() .. "_BG"]
    if border then
        if state == "Error" then
            border:SetColorTexture(table.unpack(BORDER_ERROR))
        elseif state == "Warning" then
            border:SetColorTexture(table.unpack(BORDER_WARN))
        else
            border:SetColorTexture(table.unpack(BORDER_NORMAL))
        end
    end
    if bg then bg:SetColorTexture(table.unpack(BG_NORMAL)) end
end

function TextBox:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        local input = _G[self:GetName() .. "_Input"]
        if input then input:SetEnabled(false) end
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    elseif prevState == "Disabled" then
        local input = _G[self:GetName() .. "_Input"]
        if input then input:SetEnabled(true) end
        self:SetAlpha(1)
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent      Frame
---@param placeholder string?
---@param width       number?
---@return Frame
function lib:CreateTextBox(parent, placeholder, width)
    local tb = CreateFrame("Frame", nil, parent, "WUILTextBoxTemplate")
    if placeholder then tb:SetPlaceholder(placeholder) end
    if width then tb:SetWidth(width) end
    return tb
end

---@param parent      Frame
---@param placeholder string?
---@return Frame
function lib:CreateSearchBox(parent, placeholder)
    local sb = CreateFrame("Frame", nil, parent, "WUILSearchBoxTemplate")
    sb:SetPlaceholder(placeholder or "Search…")
    return sb
end

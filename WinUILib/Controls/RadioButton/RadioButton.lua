--- WinUILib – Controls/RadioButton/RadioButton.lua
-- Mutually exclusive selection within a group.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/radio-button
-- States: Normal | Hover | Pressed | Disabled | Selected
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens

-------------------------------------------------------------------------------
-- Group tracking
-------------------------------------------------------------------------------

local _groups = {}

local function deselectGroup(group, except)
    if not _groups[group] then return end
    for _, rb in ipairs(_groups[group]) do
        if rb ~= except and rb._selected then
            rb._selected = false
            rb._vsm:SetState("Normal")
        end
    end
end

local function unregisterFromGroup(self, group)
    if not _groups[group] then return end
    for i, rb in ipairs(_groups[group]) do
        if rb == self then
            table.remove(_groups[group], i)
            if #_groups[group] == 0 then
                _groups[group] = nil
            end
            return
        end
    end
end

local function registerInGroup(self, group)
    if not _groups[group] then _groups[group] = {} end
    for _, rb in ipairs(_groups[group]) do
        if rb == self then return end
    end
    table.insert(_groups[group], self)
end

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILRadioButton
local RadioMixin = {}

function RadioMixin:OnStateChanged(newState, prevState)
    local state = newState

    if state == "Disabled" then
        self.Circle:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.Label:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
        self.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
        if self._selected then
            local cKey = (state == "Hover") and "Color.Accent.Hover" or "Color.Accent.Primary"
            self.Circle:SetColorTexture(T:GetColor(cKey))
            self.Dot:Show()
            self.Dot:SetColorTexture(T:GetColor("Color.Icon.OnAccent"))
        else
            local cKey = (state == "Hover") and "Color.Border.Focus" or "Color.Border.Default"
            self.Circle:SetColorTexture(T:GetColor(cKey))
            self.Dot:Hide()
        end
    end
end

---@param selected boolean
function RadioMixin:SetSelected(selected)
    self._selected = selected
    if selected then
        deselectGroup(self._group, self)
        self._vsm:SetState("Selected")
    else
        self._vsm:SetState("Normal")
    end
end

---@return boolean
function RadioMixin:IsSelected()
    return self._selected == true
end

---@param group string
function RadioMixin:SetGroup(group)
    if self._group then
        unregisterFromGroup(self, self._group)
    end
    self._group = group
    registerInGroup(self, group)
    -- Enforce single selection in the new group
    if self._selected then
        deselectGroup(group, self)
    end
end

---@param text string
function RadioMixin:SetText(text)
    self.Label:SetText(text)
end

---@return string
function RadioMixin:GetText()
    return self.Label:GetText() or ""
end

---@param fn function
function RadioMixin:SetOnSelected(fn)
    self._onSelected = fn
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILRadioButton_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, RadioMixin)
    self:WUILInit()
    self._selected = false
    self._group = "default"
    registerInGroup(self, "default")
    self:HookScript("OnHide", function(frame)
        if frame._group then
            unregisterFromGroup(frame, frame._group)
        end
    end)
    self:HookScript("OnShow", function(frame)
        if frame._group then
            registerInGroup(frame, frame._group)
            if frame._selected then
                deselectGroup(frame._group, frame)
            end
        end
    end)
    self:OnStateChanged("Normal")
end

function WUILRadioButton_OnClick(self)
    if not self._enabled then return end
    if self._selected then return end
    deselectGroup(self._group, self)
    self._selected = true
    self._vsm:SetState("Selected")
    if self._onSelected then
        lib.Utils.SafeCall(self._onSelected, self)
    end
end

function WUILRadioButton_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    self:ShowTooltip()
end

function WUILRadioButton_OnLeave(self)
    if not self._enabled then return end
    if self._selected then
        self._vsm:SetState("Selected")
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
---@return WUILRadioButton
function lib:CreateRadioButton(parent, name)
    local f = CreateFrame("Button", name, parent, "WUILRadioButtonTemplate")
    ---@cast f WUILRadioButton
    return f
end

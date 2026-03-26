--- WinUILib – Controls/RadioButton/RadioButton.lua
-- RadioButton with group management.
-- Design ref: WinUI RadioButton
--
-- Usage:
--   local rb1 = lib:CreateRadioButton(parent, "Option A", "groupName")
--   local rb2 = lib:CreateRadioButton(parent, "Option B", "groupName")
--   rb1.OnSelected = function(rb) print("selected:", rb._label) end
--
-- Group semantics: only one button in a named group may be Selected at a time.
-- Groups are identified by a string key scoped to the current UI session.
-------------------------------------------------------------------------------

local lib = WinUILib

-- Global group registry: [groupKey] = { button, ... }
local _groups = {}

local RING_NORMAL  = { 0.50, 0.50, 0.55, 1 }
local RING_HOVER   = { 0.68, 0.68, 0.72, 1 }
local RING_CHECKED = { 0.05, 0.55, 0.88, 1 }
local FILL_NORMAL  = { 0.10, 0.10, 0.11, 1 }

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILRadioButton_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.RadioButton)
    self:WUILInit()
    self._selected  = false
    self._groupKey  = nil
    self:_UpdateVisuals()
end

function WUILRadioButton_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    local ring = _G[self:GetName() .. "_Ring"]
    if ring and not self._selected then
        ring:SetColorTexture(table.unpack(RING_HOVER))
    end
    if self._tooltipTitle then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self._tooltipTitle, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end
end

function WUILRadioButton_OnLeave(self)
    if not self._enabled then return end
    self._vsm:SetState("Normal")
    self:_UpdateVisuals()
    GameTooltip:Hide()
end

function WUILRadioButton_OnClick(self, button)
    if button ~= "LeftButton" or not self._enabled then return end
    self:Select()
end

-------------------------------------------------------------------------------
-- RadioButton mixin
-------------------------------------------------------------------------------

---@class WUILRadioButton : WUILControlBase
local RadioButton = {}
lib._controls.RadioButton = RadioButton

--- Selects this radio button, deselecting all others in the same group.
function RadioButton:Select()
    if self._selected then return end
    -- Deselect siblings
    if self._groupKey and _groups[self._groupKey] then
        for _, rb in ipairs(_groups[self._groupKey]) do
            if rb ~= self and rb._selected then
                rb._selected = false
                rb:_UpdateVisuals()
            end
        end
    end
    self._selected = true
    self:_UpdateVisuals()
    if self.OnSelected then
        lib.Utils.SafeCall(self.OnSelected, self)
    end
end

--- Sets the group this radio button belongs to.
---@param groupKey string
function RadioButton:SetGroup(groupKey)
    -- Remove from old group
    if self._groupKey and _groups[self._groupKey] then
        for i, rb in ipairs(_groups[self._groupKey]) do
            if rb == self then table.remove(_groups[self._groupKey], i); break end
        end
    end
    self._groupKey = groupKey
    if not _groups[groupKey] then _groups[groupKey] = {} end
    table.insert(_groups[groupKey], self)
end

---@return boolean
function RadioButton:IsSelected()
    return self._selected == true
end

--- Sets the label text.
---@param text string
function RadioButton:SetLabel(text)
    self._label = text
    local label = _G[self:GetName() .. "_Label"]
    if label then label:SetText(text) end
end

function RadioButton:_UpdateVisuals()
    local ring = _G[self:GetName() .. "_Ring"]
    local dot  = _G[self:GetName() .. "_Dot"]
    if not (ring and dot) then return end

    if self._selected then
        ring:SetColorTexture(table.unpack(RING_CHECKED))
        dot:Show()
    else
        ring:SetColorTexture(table.unpack(RING_NORMAL))
        dot:Hide()
    end
    local disabled = not self._enabled
    self:SetAlpha(disabled and lib.Tokens:GetNumber("Opacity.Disabled") or 1)
end

function RadioButton:OnStateChanged(newState, prevState)
    if newState ~= "Hover" then self:_UpdateVisuals() end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent   Frame
---@param label    string?
---@param groupKey string?
---@return Frame
function lib:CreateRadioButton(parent, label, groupKey)
    local rb = CreateFrame("CheckButton", nil, parent, "WUILRadioButtonTemplate")
    if label    then rb:SetLabel(label) end
    if groupKey then rb:SetGroup(groupKey) end
    return rb
end

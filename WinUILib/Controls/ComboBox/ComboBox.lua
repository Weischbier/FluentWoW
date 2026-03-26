--- WinUILib – Controls/ComboBox/ComboBox.lua
-- Dropdown selection control.
-- Design ref: WinUI ComboBox
--
-- Public API:
--   :AddItem(text, value?)
--   :SetItems({{ text=, value= }, ...})
--   :SetSelectedIndex(i)
--   :SetSelectedValue(v)
--   :GetSelected()          → text, value, index
--   :ClearItems()
--   :SetPlaceholder(text)
--   :SetEnabled(bool)
--   OnSelectionChanged(self, text, value, index)
--
-- Combat note: opening the dropdown in combat is blocked (CombatLockdown).
-- The frame strata is TOOLTIP to overlay other frames when open.
-------------------------------------------------------------------------------

local lib = WinUILib
local Pool = lib.FramePool

-- All open dropdowns – we close them when another opens or the user clicks away
local _openDropdown = nil
local ITEM_H        = 28
local MAX_VISIBLE   = 8   -- max rows before the dropdown scrolls (future)
local BORDER_NORM   = { 0.50, 0.50, 0.55, 1 }
local BORDER_HOVER  = { 0.68, 0.68, 0.72, 1 }
local BG_NORM       = { 0.10, 0.10, 0.11, 1 }
local BG_HOVER      = { 0.13, 0.13, 0.14, 1 }
local ITEM_HOVER_BG = { 0.05, 0.55, 0.88, 0.20 }

-- Click-away handler
local _dismissFrame = CreateFrame("Frame")
_dismissFrame:SetAllPoints(UIParent)
_dismissFrame:EnableMouse(true)
_dismissFrame:SetFrameStrata("DIALOG")
_dismissFrame:Hide()
_dismissFrame:SetScript("OnMouseDown", function()
    if _openDropdown then _openDropdown:_CloseDropdown() end
    _dismissFrame:Hide()
end)

-------------------------------------------------------------------------------
-- ComboBoxItem (dropdown row)
-------------------------------------------------------------------------------

function WUILComboBoxItem_OnLoad(self)
    self._owner = nil
    self._value = nil
    self._index = nil
end

function WUILComboBoxItem_OnEnter(self)
    local bg = _G[self:GetName() .. "_BG"]
    if bg then bg:SetColorTexture(table.unpack(ITEM_HOVER_BG)) end
end

function WUILComboBoxItem_OnLeave(self)
    local bg = _G[self:GetName() .. "_BG"]
    if bg then bg:SetColorTexture(0, 0, 0, 0) end
end

function WUILComboBoxItem_OnClick(self, btn)
    if btn ~= "LeftButton" then return end
    if self._owner then
        self._owner:_SelectItem(self._index)
    end
end

-------------------------------------------------------------------------------
-- ComboBox header scripts
-------------------------------------------------------------------------------

function WUILComboBox_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.ComboBox)
    self:WUILInit()
    self._items        = {}
    self._selectedIdx  = nil
    self._placeholder  = "Select…"
    self._dropdown     = nil
    self._itemPool     = nil
    -- Show placeholder initially
    local st = _G[self:GetName() .. "_SelectedText"]
    if st then st:SetText(self._placeholder) end
end

function WUILComboBox_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    local border = _G[self:GetName() .. "_Border"]
    if border then border:SetColorTexture(table.unpack(BORDER_HOVER)) end
    local bg = _G[self:GetName() .. "_BG"]
    if bg then bg:SetColorTexture(table.unpack(BG_HOVER)) end
end

function WUILComboBox_OnLeave(self)
    if not self._enabled then return end
    self._vsm:SetState("Normal")
    local border = _G[self:GetName() .. "_Border"]
    if border then border:SetColorTexture(table.unpack(BORDER_NORM)) end
    local bg = _G[self:GetName() .. "_BG"]
    if bg then bg:SetColorTexture(table.unpack(BG_NORM)) end
end

function WUILComboBox_OnClick(self, btn)
    if btn ~= "LeftButton" or not self._enabled then return end
    if lib.Utils.InCombat() then
        lib:Debug("ComboBox: blocked in combat")
        return
    end
    if _openDropdown == self then
        self:_CloseDropdown()
    else
        if _openDropdown then _openDropdown:_CloseDropdown() end
        self:_OpenDropdown()
    end
end

-------------------------------------------------------------------------------
-- ComboBox mixin
-------------------------------------------------------------------------------

---@class WUILComboBox : WUILControlBase
local ComboBox = {}
lib._controls.ComboBox = ComboBox

---@param text  string
---@param value any?
function ComboBox:AddItem(text, value)
    table.insert(self._items, { text = text, value = value ~= nil and value or text })
    -- If dropdown is currently open, rebuild it
    if _openDropdown == self then
        self:_CloseDropdown()
        self:_OpenDropdown()
    end
end

---@param items { text: string, value: any? }[]
function ComboBox:SetItems(items)
    self._items = {}
    for _, item in ipairs(items) do
        self:AddItem(item.text, item.value)
    end
end

function ComboBox:ClearItems()
    self._items = {}
    self._selectedIdx = nil
    self:_UpdateHeader()
end

---@param i integer  1-based
function ComboBox:SetSelectedIndex(i)
    if i >= 1 and i <= #self._items then
        self:_SelectItem(i, true)
    end
end

---@param v any
function ComboBox:SetSelectedValue(v)
    for i, item in ipairs(self._items) do
        if item.value == v then
            self:_SelectItem(i, true)
            return
        end
    end
end

--- Returns selected text, value, index (nil if nothing selected).
---@return string?, any?, integer?
function ComboBox:GetSelected()
    if not self._selectedIdx then return nil, nil, nil end
    local item = self._items[self._selectedIdx]
    return item and item.text, item and item.value, self._selectedIdx
end

---@param text string
function ComboBox:SetPlaceholder(text)
    self._placeholder = text
    if not self._selectedIdx then
        local st = _G[self:GetName() .. "_SelectedText"]
        if st then st:SetText(text) end
    end
end

--- Internal: select an item by index and fire callback.
---@param idx     integer
---@param silent  boolean?
function ComboBox:_SelectItem(idx, silent)
    self._selectedIdx = idx
    self:_UpdateHeader()
    self:_CloseDropdown()
    if not silent and self.OnSelectionChanged then
        local item = self._items[idx]
        lib.Utils.SafeCall(self.OnSelectionChanged, self,
            item.text, item.value, idx)
    end
end

function ComboBox:_UpdateHeader()
    local st = _G[self:GetName() .. "_SelectedText"]
    if not st then return end
    if self._selectedIdx then
        local item = self._items[self._selectedIdx]
        st:SetText(item and item.text or "")
        st:SetTextColor(0.85, 0.85, 0.88)
    else
        st:SetText(self._placeholder)
        st:SetTextColor(0.50, 0.50, 0.55)
    end
end

function ComboBox:_OpenDropdown()
    if not self._dropdown then
        self._dropdown = CreateFrame("Frame", nil, UIParent,
                                     "WUILComboBoxDropdownTemplate")
        self._dropdown:SetWidth(self:GetWidth())
        self._itemPool = lib.FramePool:New("Button", self._dropdown,
                                            "WUILComboBoxItemTemplate")
    end
    local dd = self._dropdown
    dd:SetWidth(self:GetWidth())

    -- Populate item rows
    self._itemPool:ReleaseAll()
    local yOff = -2
    for i, item in ipairs(self._items) do
        local row = self._itemPool:Acquire()
        row._owner = self
        row._index = i
        row._value = item.value
        local txt = _G[row:GetName() .. "_Text"]
        if txt then
            txt:SetText(item.text)
            if i == self._selectedIdx then
                txt:SetTextColor(0.05, 0.55, 0.88)
            else
                txt:SetTextColor(0.85, 0.85, 0.88)
            end
        end
        row:SetWidth(dd:GetWidth())
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", dd, "TOPLEFT", 0, yOff)
        yOff = yOff - ITEM_H
    end
    dd:SetHeight(math.min(#self._items, MAX_VISIBLE) * ITEM_H + 4)

    -- Position below header (flip up if no room)
    dd:ClearAllPoints()
    local screenH = GetScreenHeight()
    local myBottom = self:GetBottom() or 0
    if myBottom - dd:GetHeight() < 0 then
        dd:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
    else
        dd:SetPoint("TOPLEFT",    self, "BOTTOMLEFT", 0, -4)
    end

    lib.Motion:FadeIn(dd, 0.12)
    _openDropdown = self
    _dismissFrame:Show()
end

function ComboBox:_CloseDropdown()
    if not self._dropdown then return end
    lib.Motion:FadeOut(self._dropdown, 0.10)
    _openDropdown = nil
    _dismissFrame:Hide()
end

function ComboBox:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self:SetAlpha(lib.Tokens:GetNumber("Opacity.Disabled"))
    elseif prevState == "Disabled" then
        self:SetAlpha(1)
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param items  { text: string, value: any? }[]?
---@return Frame
function lib:CreateComboBox(parent, items)
    local cb = CreateFrame("Button", nil, parent, "WUILComboBoxTemplate")
    if items then cb:SetItems(items) end
    return cb
end

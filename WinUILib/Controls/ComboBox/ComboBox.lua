--- WinUILib – Controls/ComboBox/ComboBox.lua
-- Dropdown selection control with combat-safe popup.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/combo-box
-- States: Normal | Hover | Expanded | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens
local Mot = lib.Motion

-------------------------------------------------------------------------------
-- Active ComboBox tracking (cross-close)
-------------------------------------------------------------------------------

local _activeCombo

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILComboBox
local ComboMixin = {}

function ComboMixin:OnStateChanged(newState, prevState)
    local state = newState
    local shadowR, shadowG, shadowB = T:GetColor("Color.Surface.Base")

    self.Shadow:SetColorTexture(shadowR, shadowG, shadowB, 0.85)
    self.Dropdown.DropBG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
    self.Dropdown.DropBorder:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    if state == "Disabled" then
        self.BG:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        self.Border:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.TopEdge:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        self.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.SelectedLabel:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self.Arrow:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    elseif state == "Expanded" then
        self:SetAlpha(1)
        self.BG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
        self.Border:SetColorTexture(T:GetColor("Color.Border.Focus"))
        self.TopEdge:SetColorTexture(T:GetColor("Color.Accent.Light"))
        self.BottomEdge:SetColorTexture(T:GetColor("Color.Accent.Primary"))
        self.SelectedLabel:SetTextColor(T:GetColor("Color.Text.Primary"))
        self.Arrow:SetTextColor(T:GetColor("Color.Accent.Primary"))
    elseif state == "Hover" then
        self:SetAlpha(1)
        self.BG:SetColorTexture(T:GetColor("Color.Surface.Overlay"))
        self.Border:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.TopEdge:SetColorTexture(T:GetColor("Color.Border.Focus"))
        self.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.SelectedLabel:SetTextColor(T:GetColor("Color.Text.Primary"))
        self.Arrow:SetTextColor(T:GetColor("Color.Text.Primary"))
    else
        self:SetAlpha(1)
        self.BG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
        self.Border:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        self.TopEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.SelectedLabel:SetTextColor(T:GetColor("Color.Text.Primary"))
        self.Arrow:SetTextColor(T:GetColor("Color.Text.Secondary"))
    end
end

---@param items table array of { text=string, value=any }
function ComboMixin:SetItems(items)
    self._items = items
    self._selectedIndex = nil
    self.SelectedLabel:SetText("")
end

---@return table
function ComboMixin:GetItems()
    return self._items or {}
end

---@param index integer
function ComboMixin:SetSelectedIndex(index)
    local items = self._items or {}
    if index < 1 or index > #items then return end
    self._selectedIndex = index
    self.SelectedLabel:SetText(items[index].text or "")
end

---@return integer|nil
function ComboMixin:GetSelectedIndex()
    return self._selectedIndex
end

---@return any|nil
function ComboMixin:GetSelectedValue()
    if not self._selectedIndex then return nil end
    local item = (self._items or {})[self._selectedIndex]
    return item and item.value
end

---@param fn function
function ComboMixin:SetOnSelectionChanged(fn)
    self._onSelectionChanged = fn
end

function ComboMixin:_Open()
    if InCombatLockdown() then
        lib:Debug("ComboBox: blocked in combat")
        return
    end
    -- Cross-close: close any other open ComboBox
    if _activeCombo and _activeCombo ~= self then
        _activeCombo:_Close()
    end
    _activeCombo = self
    self:_BuildDropdown()
    self.Dropdown.DropBG:SetColorTexture(T:GetColor("Color.Surface.Overlay"))
    Mot:FadeIn(self.Dropdown)
    self._vsm:SetState("Expanded")
end

function ComboMixin:_Close()
    if _activeCombo == self then _activeCombo = nil end
    Mot:FadeOut(self.Dropdown)
    self._vsm:SetState("Normal")
end

function ComboMixin:_BuildDropdown()
    if not self._itemPool then
        self._itemPool = lib.FramePool:New("Button", self.Dropdown.Scroll.Child, "WUILComboBoxItemTemplate", function(btn)
            btn._comboParent = nil
            btn._itemIndex = nil
        end)
    end
    self._itemPool:ReleaseAll()

    local items = self._items or {}
    local itemHeight = T:GetNumber("Spacing.XXL") + T:GetNumber("Spacing.SM")  -- 24+4 = 28
    local dropdownWidth = math.max(self:GetWidth(), T:GetNumber("Spacing.XXXL") * 6 + T:GetNumber("Spacing.XL"))
    local contentWidth = math.max(1, dropdownWidth - T:GetNumber("Spacing.MD") * 2)
    local yOff = 0

    self.Dropdown:SetWidth(dropdownWidth)
    self.Dropdown.Scroll.Child:SetWidth(contentWidth)

    for i, item in ipairs(items) do
        local btn = self._itemPool:Acquire()
        btn:SetParent(self.Dropdown.Scroll.Child)
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", 0, -yOff)
        btn:SetPoint("RIGHT", 0, 0)
        btn:SetWidth(contentWidth)
        btn.Text:SetText(item.text or "")
        btn.Text:SetTextColor(T:GetColor("Color.Text.Primary"))
        btn.Highlight:SetColorTexture(T:GetColor("Color.Overlay.Hover"))
        btn._comboParent = self
        btn._itemIndex = i
        yOff = yOff + itemHeight
    end

    self.Dropdown.Scroll.Child:SetHeight(math.max(1, yOff))
    local maxVisible = math.min(#items, 8)
    self.Dropdown:SetHeight(maxVisible * itemHeight + T:GetNumber("Spacing.MD"))
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILComboBox_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, ComboMixin)
    self:WUILInit()
    self._items = {}
    self.Dropdown.Scroll:SetScrollChild(self.Dropdown.Scroll.Child)
    self.Dropdown.Scroll:EnableMouseWheel(true)
    local font = T:Get("Typography.BodyBold")
    if font then
        self.SelectedLabel:SetFont(font.font, font.size, font.flags)
    end
    self:OnStateChanged("Normal")
end

function WUILComboBox_OnClick(self)
    if not self._enabled then return end
    if self._vsm:GetState() == "Expanded" then
        self:_Close()
    else
        self:_Open()
    end
end

function WUILComboBox_OnEnter(self)
    if not self._enabled then return end
    if self._vsm:GetState() ~= "Expanded" then
        self._vsm:SetState("Hover")
    end
    self:ShowTooltip()
end

function WUILComboBox_OnLeave(self)
    if not self._enabled then return end
    if self._vsm:GetState() ~= "Expanded" then
        self._vsm:SetState("Normal")
    end
    GameTooltip:Hide()
end

function WUILComboBox_OnHide(self)
    if self.Dropdown:IsShown() then
        self.Dropdown:Hide()
    end
    if _activeCombo == self then _activeCombo = nil end
    if self._vsm:GetState() == "Expanded" then
        self._vsm:SetState("Normal")
    end
end

function WUILComboBoxItem_OnClick(self)
    local combo = self._comboParent
    if not combo then return end
    combo:SetSelectedIndex(self._itemIndex)
    combo:_Close()
    if combo._onSelectionChanged then
        lib.Utils.SafeCall(combo._onSelectionChanged, combo, self._itemIndex)
    end
end

function WUILComboBoxItem_OnEnter(self)
    self.Highlight:Show()
end

function WUILComboBoxItem_OnLeave(self)
    self.Highlight:Hide()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return WUILComboBox
function lib:CreateComboBox(parent, name)
    local f = CreateFrame("Frame", name, parent, "WUILComboBoxTemplate")
    ---@cast f WUILComboBox
    return f
end

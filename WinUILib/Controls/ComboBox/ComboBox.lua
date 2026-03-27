--- WinUILib – Controls/ComboBox/ComboBox.lua
-- Dropdown selection control with combat-safe popup.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/combo-box
-- States: Normal | Hover | Expanded | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens
local Mot = lib.Motion

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT

local function applyLayout(self)
    local headerHeight = self._headerText ~= nil and self._headerText ~= "" and (T:GetNumber("Spacing.XL") + T:GetNumber("Spacing.SM")) or 0
    local fieldHeight = 32

    self:SetHeight(fieldHeight + headerHeight)
    self.HeaderLabel:SetShown(headerHeight > 0)
    self.HeaderLabel:SetText(self._headerText or "")
    self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))

    self.Field:ClearAllPoints()
    if headerHeight > 0 then
        self.Field:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -headerHeight)
        self.Field:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -headerHeight)
        self.Field:SetHeight(fieldHeight)
    else
        self.Field:SetAllPoints(self)
    end
end

local function updateText(self)
    local items = self._items or {}
    local item = self._selectedIndex and items[self._selectedIndex] or nil
    if item and item.text and item.text ~= "" then
        self.SelectedLabel:SetText(item.text)
        self.SelectedLabel:SetTextColor(T:GetColor("Color.Text.Primary"))
    else
        self.SelectedLabel:SetText(self._placeholderText or "")
        self.SelectedLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
    end
end

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

    self.Field.Shadow:SetColorTexture(shadowR, shadowG, shadowB, 0.85)
    self.Dropdown.DropBG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
    self.Dropdown.DropBorder:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    if state == "Disabled" then
        self.Field.BG:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        self.Field.Border:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.Field.TopEdge:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        self.Field.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.SelectedLabel:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self.Field.Arrow:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    elseif state == "Expanded" then
        self:SetAlpha(1)
        self.Field.BG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
        self.Field.Border:SetColorTexture(T:GetColor("Color.Border.Focus"))
        self.Field.TopEdge:SetColorTexture(T:GetColor("Color.Accent.Light"))
        self.Field.BottomEdge:SetColorTexture(T:GetColor("Color.Accent.Primary"))
        self.Field.Arrow:SetTextColor(T:GetColor("Color.Accent.Primary"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
    elseif state == "Hover" then
        self:SetAlpha(1)
        self.Field.BG:SetColorTexture(T:GetColor("Color.Surface.Overlay"))
        self.Field.Border:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.Field.TopEdge:SetColorTexture(T:GetColor("Color.Border.Focus"))
        self.Field.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.Field.Arrow:SetTextColor(T:GetColor("Color.Text.Primary"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
    else
        self:SetAlpha(1)
        self.Field.BG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
        self.Field.Border:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        self.Field.TopEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.Field.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Default"))
        self.Field.Arrow:SetTextColor(T:GetColor("Color.Text.Secondary"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
    end

    updateText(self)
end

---@param items table array of { text=string, value=any }
function ComboMixin:SetItems(items)
    self._items = items
    self._selectedIndex = nil
    updateText(self)
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
    updateText(self)
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

---@param text string
function ComboMixin:SetHeader(text)
    self._headerText = text
    applyLayout(self)
    self:OnStateChanged(self._vsm:GetState())
end

---@param text string
function ComboMixin:SetPlaceholder(text)
    self._placeholderText = text
    updateText(self)
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
    self._headerText = nil
    self._placeholderText = ""
    self.Dropdown.Scroll:SetScrollChild(self.Dropdown.Scroll.Child)
    self.Dropdown.Scroll:EnableMouseWheel(true)
    local font = T:Get("Typography.BodyBold")
    if font then
        self.SelectedLabel:SetFont(font.font, font.size, font.flags)
    end
    self.Field.Arrow:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
    self.Field.Arrow:SetText(Icons.ChevronDown)
    applyLayout(self)
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

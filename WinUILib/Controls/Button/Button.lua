--- WinUILib – Controls/Button/Button.lua
-- Behaviour layer for WUILButtonTemplate, WUILIconButtonTemplate,
-- WUILToggleButtonTemplate.
--
-- Design reference: WinUI Button, AppBarButton, ToggleButton
-- https://learn.microsoft.com/windows/apps/design/controls/buttons
--
-- States: Normal | Hover | Pressed | Disabled
-- ToggleButton adds: Checked | CheckedHover | CheckedPressed
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens
local Mot = lib.Motion

-- Colour lookups (resolved at runtime so theme changes apply immediately)
local function accentR()  return T:GetColor("Color.Accent.Primary") end
local function accentH()  return T:GetColor("Color.Accent.Hover") end
local function accentP()  return T:GetColor("Color.Accent.Pressed") end

-- Overlay alpha values matching WinUI fill-button interaction states
local HOVER_ALPHA   = 0.08
local PRESS_ALPHA   = 0.14
local DISABLED_MULT = 0.40   -- opacity factor for disabled state

-------------------------------------------------------------------------------
-- Shared script handlers (used by all button variants)
-------------------------------------------------------------------------------

function WUILButton_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    self:WUILInit()
end

function WUILButton_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    local ov = self["$parent_Overlay"] or self:GetParent() and nil
    -- Use named child lookup via frame API
    local overlay = _G[self:GetName() .. "_Overlay"]
    if overlay then overlay:SetAlpha(HOVER_ALPHA) end
end

function WUILButton_OnLeave(self)
    if not self._enabled then return end
    self._vsm:SetState("Normal")
    local overlay = _G[self:GetName() .. "_Overlay"]
    if overlay then overlay:SetAlpha(0) end
    GameTooltip:Hide()
end

function WUILButton_OnMouseDown(self, button)
    if button ~= "LeftButton" or not self._enabled then return end
    self._vsm:SetState("Pressed")
    local overlay = _G[self:GetName() .. "_Overlay"]
    if overlay then overlay:SetAlpha(PRESS_ALPHA) end
    Mot:ScalePress(self)
end

function WUILButton_OnMouseUp(self, button)
    if button ~= "LeftButton" then return end
    if not self._enabled then return end
    local state = MouseIsOver(self) and "Hover" or "Normal"
    self._vsm:SetState(state)
    local overlay = _G[self:GetName() .. "_Overlay"]
    if overlay then
        overlay:SetAlpha(state == "Hover" and HOVER_ALPHA or 0)
    end
end

function WUILButton_OnClick(self, button)
    if button ~= "LeftButton" or not self._enabled then return end
    if self.OnActivated then
        lib.Utils.SafeCall(self.OnActivated, self)
    end
end

-------------------------------------------------------------------------------
-- WUILButton public API mixin
-------------------------------------------------------------------------------

---@class WUILButton : WUILControlBase
local WUILButton = {}
lib._controls.Button = WUILButton

--- Sets the button label text.
---@param text string
function WUILButton:SetLabel(text)
    local label = _G[self:GetName() .. "_Label"]
    if label then label:SetText(text) end
end

--- Sets an atlas icon (for WUILIconButtonTemplate).
---@param atlas  string  Atlas name
---@param size   number? Icon size in pixels (default 16)
function WUILButton:SetIcon(atlas, size)
    local icon = _G[self:GetName() .. "_Icon"]
    if not icon then return end
    icon:SetAtlas(atlas)
    if size then icon:SetSize(size, size) end
    icon:Show()
end

--- Overrides base colour for this button instance (optional customisation).
---@param r number  @param g number  @param b number  @param a number?
function WUILButton:SetAccentColor(r, g, b, a)
    local bg = _G[self:GetName() .. "_BG"]
    if bg then bg:SetColorTexture(r, g, b, a or 1) end
end

--- Applies disabled visual state.
function WUILButton:OnStateChanged(newState, prevState)
    local alpha = (newState == "Disabled") and DISABLED_MULT or 1
    self:SetAlpha(alpha)
    if newState == "Normal" then
        local overlay = _G[self:GetName() .. "_Overlay"]
        if overlay then overlay:SetAlpha(0) end
    end
end

-------------------------------------------------------------------------------
-- ToggleButton
-------------------------------------------------------------------------------

local TOGGLE_CHECKED_BG = { 0.05, 0.55, 0.88, 1 }
local TOGGLE_NORMAL_BG  = { 0.13, 0.13, 0.14, 1 }

function WUILToggleButton_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, WUILButton)
    self:WUILInit()
    self._checked = false
end

function WUILToggleButton_OnClick(self, button)
    if button ~= "LeftButton" or not self._enabled then return end
    self._checked = not self._checked
    self:_UpdateChecked()
    if self.OnToggled then
        lib.Utils.SafeCall(self.OnToggled, self, self._checked)
    end
end

function WUILButton:_UpdateChecked()
    local bg = _G[self:GetName() .. "_BG"]
    if not bg then return end
    if self._checked then
        bg:SetColorTexture(table.unpack(TOGGLE_CHECKED_BG))
        local label = _G[self:GetName() .. "_Label"]
        if label then label:SetTextColor(1, 1, 1) end
    else
        bg:SetColorTexture(table.unpack(TOGGLE_NORMAL_BG))
        local label = _G[self:GetName() .. "_Label"]
        if label then label:SetTextColor(0.85, 0.85, 0.88) end
    end
end

--- Returns the checked state of a ToggleButton.
---@return boolean
function WUILButton:IsChecked()
    return self._checked == true
end

--- Programmatically sets the checked state.
---@param checked boolean
function WUILButton:SetChecked(checked)
    self._checked = checked
    self:_UpdateChecked()
end

-------------------------------------------------------------------------------
-- Factory helpers (alternative to XML instantiation)
-------------------------------------------------------------------------------

--- Creates a new Button frame programmatically.
---@param parent Frame
---@param variant string?  "Accent"|"Subtle"|"Destructive" (default "Accent")
---@param label   string?
---@return Frame
function lib:CreateButton(parent, variant, label)
    local template = "WUILButtonTemplate"
    if variant == "Subtle"      then template = "WUILButtonSubtleTemplate"
    elseif variant == "Destructive" then template = "WUILButtonDestructiveTemplate"
    end
    local btn = CreateFrame("Button", nil, parent, template)
    if label then btn:SetLabel(label) end
    return btn
end

--- Creates a new IconButton frame.
---@param parent Frame
---@param atlas  string
---@param size   number?
---@return Frame
function lib:CreateIconButton(parent, atlas, size)
    local btn = CreateFrame("Button", nil, parent, "WUILIconButtonTemplate")
    btn:SetIcon(atlas, size)
    return btn
end

--- Creates a new ToggleButton frame.
---@param parent Frame
---@param label  string?
---@return Frame
function lib:CreateToggleButton(parent, label)
    local btn = CreateFrame("CheckButton", nil, parent, "WUILToggleButtonTemplate")
    if label then btn:SetLabel(label) end
    return btn
end

--- WinUILib – Controls/CheckBox/CheckBox.lua
-- Three-state CheckBox: Unchecked | Checked | Indeterminate
-- Design ref: WinUI CheckBox (microsoft-ui-xaml)
--
-- Public API:
--   :SetChecked(bool|"Indeterminate")
--   :GetChecked()  → bool|"Indeterminate"
--   :SetLabel(text)
--   :SetEnabled(bool)
--   OnCheckedChanged(self, state)  callback
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens

-- Visual constants (mapped to tokens)
local BOX_BORDER_NORMAL   = { 0.50, 0.50, 0.55, 1.0 }
local BOX_BORDER_HOVER    = { 0.68, 0.68, 0.72, 1.0 }
local BOX_BORDER_CHECKED  = { 0.05, 0.55, 0.88, 1.0 }
local BOX_FILL_CHECKED    = { 0.05, 0.55, 0.88, 1.0 }
local BOX_FILL_NORMAL     = { 0.10, 0.10, 0.11, 1.0 }
local CHECK_COLOR         = { 1.00, 1.00, 1.00, 1.0 }
local DASH_COLOR          = { 0.05, 0.55, 0.88, 1.0 }

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILCheckBox_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.CheckBox)
    self:WUILInit()
    self._checkState = false  -- false | true | "Indeterminate"
    self:_UpdateVisuals()
end

function WUILCheckBox_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    local border = _G[self:GetName() .. "_Border"]
    if border then border:SetColorTexture(table.unpack(BOX_BORDER_HOVER)) end
    if self._tooltipTitle then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self._tooltipTitle, 1, 1, 1, 1, true)
        if self._tooltipText then
            GameTooltip:AddLine(self._tooltipText, nil, nil, nil, true)
        end
        GameTooltip:Show()
    end
end

function WUILCheckBox_OnLeave(self)
    if not self._enabled then return end
    self._vsm:SetState("Normal")
    self:_UpdateVisuals()
    GameTooltip:Hide()
end

function WUILCheckBox_OnClick(self, button)
    if button ~= "LeftButton" or not self._enabled then return end
    -- Cycle: false → true → false  (indeterminate only set programmatically)
    if self._checkState == "Indeterminate" then
        self._checkState = false
    else
        self._checkState = not self._checkState
    end
    self:_UpdateVisuals()
    if self.OnCheckedChanged then
        lib.Utils.SafeCall(self.OnCheckedChanged, self, self._checkState)
    end
end

-------------------------------------------------------------------------------
-- CheckBox mixin
-------------------------------------------------------------------------------

---@class WUILCheckBox : WUILControlBase
local CheckBox = {}
lib._controls.CheckBox = CheckBox

--- Sets the checked state.
---@param state boolean|"Indeterminate"
function CheckBox:SetChecked(state)
    self._checkState = state
    self:_UpdateVisuals()
end

--- Returns the current state.
---@return boolean|"Indeterminate"
function CheckBox:GetChecked()
    return self._checkState
end

--- Sets the label text.
---@param text string
function CheckBox:SetLabel(text)
    local label = _G[self:GetName() .. "_Label"]
    if label then label:SetText(text) end
end

--- Updates all visuals to match _checkState and VSM state.
function CheckBox:_UpdateVisuals()
    local border = _G[self:GetName() .. "_Border"]
    local fill   = _G[self:GetName() .. "_Fill"]
    local check  = _G[self:GetName() .. "_Check"]
    if not (border and fill and check) then return end

    local disabled = not self._enabled
    local state    = self._checkState

    if state == true then
        -- Checked
        border:SetColorTexture(table.unpack(BOX_BORDER_CHECKED))
        fill:SetColorTexture(table.unpack(BOX_FILL_CHECKED))
        -- Draw check mark as a coloured square (simplified; atlas in real impl)
        check:SetColorTexture(table.unpack(CHECK_COLOR))
        check:Show()
    elseif state == "Indeterminate" then
        -- Indeterminate – filled box with dash tint
        border:SetColorTexture(table.unpack(BOX_BORDER_CHECKED))
        fill:SetColorTexture(table.unpack(BOX_FILL_CHECKED))
        check:SetColorTexture(table.unpack(CHECK_COLOR))
        check:Show()
        -- For a dash, we'd use a different atlas; here we tint differently
        check:SetSize(8, 3)
    else
        -- Unchecked
        border:SetColorTexture(table.unpack(BOX_BORDER_NORMAL))
        fill:SetColorTexture(table.unpack(BOX_FILL_NORMAL))
        check:Hide()
        check:SetSize(10, 10)  -- reset size
    end

    -- Disabled overlay
    local alpha = disabled and T:GetNumber("Opacity.Disabled") or 1
    self:SetAlpha(alpha)
    if self.EnableMouse then self:EnableMouse(not disabled) end
end

--- State change callback from VSM.
function CheckBox:OnStateChanged(newState, prevState)
    if newState ~= "Hover" then
        self:_UpdateVisuals()
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

--- Creates a CheckBox frame.
---@param parent Frame
---@param label  string?
---@param initialState boolean|"Indeterminate"?
---@return Frame
function lib:CreateCheckBox(parent, label, initialState)
    local cb = CreateFrame("CheckButton", nil, parent, "WUILCheckBoxTemplate")
    if label then cb:SetLabel(label) end
    if initialState ~= nil then cb:SetChecked(initialState) end
    return cb
end

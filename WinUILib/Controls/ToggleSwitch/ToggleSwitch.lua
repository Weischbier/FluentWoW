--- WinUILib – Controls/ToggleSwitch/ToggleSwitch.lua
-- Toggle switch (on/off pill) control.
-- Design ref: WinUI ToggleSwitch
--
-- Visual behaviour:
--   Off: grey track, thumb LEFT  (x=4)
--   On:  accent track, thumb RIGHT (x=22)
--   Thumb animates between positions.
--
-- Public API:
--   :SetOn(bool)  :IsOn()
--   :SetLabel(onText, offText)
--   OnToggled(self, isOn)
-------------------------------------------------------------------------------

local lib = WinUILib
local Mot = lib.Motion

local TRACK_OFF     = { 0.22, 0.22, 0.24, 1 }
local TRACK_ON      = { 0.05, 0.55, 0.88, 1 }
local TRACK_HOV_OFF = { 0.28, 0.28, 0.32, 1 }
local TRACK_HOV_ON  = { 0.15, 0.65, 1.00, 1 }
local THUMB_COLOR   = { 0.85, 0.85, 0.88, 1 }
local THUMB_ON      = { 1.00, 1.00, 1.00, 1 }

local THUMB_OFF_X = 4
local THUMB_ON_X  = 22

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILToggleSwitch_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.ToggleSwitch)
    self:WUILInit()
    self._on        = false
    self._onText    = "On"
    self._offText   = "Off"
    self:_UpdateVisuals(false)  -- no animation on load
end

function WUILToggleSwitch_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    local track = _G[self:GetName() .. "_Track"]
    if track then
        track:SetColorTexture(table.unpack(self._on and TRACK_HOV_ON or TRACK_HOV_OFF))
    end
    if self._tooltipTitle then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self._tooltipTitle, 1, 1, 1, 1, true)
        if self._tooltipText then GameTooltip:AddLine(self._tooltipText, nil, nil, nil, true) end
        GameTooltip:Show()
    end
end

function WUILToggleSwitch_OnLeave(self)
    if not self._enabled then return end
    self._vsm:SetState("Normal")
    self:_UpdateVisuals(false)
    GameTooltip:Hide()
end

function WUILToggleSwitch_OnMouseDown(self, btn)
    if btn ~= "LeftButton" or not self._enabled then return end
    -- Slightly shrink thumb on press for tactile feedback
    local thumb = _G[self:GetName() .. "_Thumb"]
    if thumb then thumb:SetSize(12, 12) end
end

function WUILToggleSwitch_OnClick(self, btn)
    if btn ~= "LeftButton" or not self._enabled then return end
    self._on = not self._on
    self:_UpdateVisuals(true)
    if self.OnToggled then
        lib.Utils.SafeCall(self.OnToggled, self, self._on)
    end
end

-------------------------------------------------------------------------------
-- ToggleSwitch mixin
-------------------------------------------------------------------------------

---@class WUILToggleSwitch : WUILControlBase
local ToggleSwitch = {}
lib._controls.ToggleSwitch = ToggleSwitch

---@param on boolean
---@param animate boolean?
function ToggleSwitch:SetOn(on, animate)
    self._on = on
    self:_UpdateVisuals(animate ~= false)
end

---@return boolean
function ToggleSwitch:IsOn()
    return self._on == true
end

--- Sets the On/Off label text shown to the right of the track.
---@param onText  string?  default "On"
---@param offText string?  default "Off"
function ToggleSwitch:SetLabel(onText, offText)
    self._onText  = onText  or "On"
    self._offText = offText or "Off"
    self:_UpdateVisuals(false)
end

--- Updates all visuals to reflect the current _on state.
---@param animate boolean
function ToggleSwitch:_UpdateVisuals(animate)
    local track = _G[self:GetName() .. "_Track"]
    local thumb = _G[self:GetName() .. "_Thumb"]
    local label = _G[self:GetName() .. "_Label"]
    if not (track and thumb) then return end

    local disabled = not self._enabled

    -- Thumb position
    thumb:ClearAllPoints()
    thumb:SetPoint("LEFT", self, "LEFT", self._on and THUMB_ON_X or THUMB_OFF_X, 0)
    thumb:SetSize(14, 14)  -- restore after press

    -- Track colour
    if self._on then
        track:SetColorTexture(table.unpack(disabled and TRACK_OFF or TRACK_ON))
        thumb:SetColorTexture(table.unpack(THUMB_ON))
    else
        track:SetColorTexture(table.unpack(TRACK_OFF))
        thumb:SetColorTexture(table.unpack(THUMB_COLOR))
    end

    -- Label
    if label then
        label:SetText(self._on and self._onText or self._offText)
    end

    self:SetAlpha(disabled and lib.Tokens:GetNumber("Opacity.Disabled") or 1)
end

function ToggleSwitch:OnStateChanged(newState, prevState)
    if newState ~= "Hover" then self:_UpdateVisuals(false) end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent  Frame
---@param onText  string?
---@param offText string?
---@return Frame
function lib:CreateToggleSwitch(parent, onText, offText)
    local ts = CreateFrame("Button", nil, parent, "WUILToggleSwitchTemplate")
    ts:SetLabel(onText, offText)
    return ts
end

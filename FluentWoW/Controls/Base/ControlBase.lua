--- FluentWoW – Controls/Base/ControlBase.lua
-- Base mixin applied to all FluentWoW controls.
-- Provides: state machine, token access, tooltip, enable/disable, lifecycle.
-------------------------------------------------------------------------------

local lib = FluentWoW

---@class FWoWControlBase
local ControlBase = {}
lib._controls.ControlBase = ControlBase

--- Walk the parent chain looking for a FWoWMainFrame ancestor.
---@param frame Frame
---@return boolean
local function hasMainFrameAncestor(frame)
    local parent = frame:GetParent()
    while parent do
        if parent._FWoWMainFrame then return true end
        parent = parent:GetParent()
    end
    return false
end

--- Controls that are exempt from the MainFrame ancestor requirement.
local ANCESTOR_EXEMPT = {
    FWoWMainFrame     = true,  -- IS the root
    FWoWContentDialog = true,  -- fullscreen overlay attached to UIParent
    FWoWTeachingTip   = true,  -- contextual callout anchored to any target
}

---@param opts? table
function ControlBase:FWoWInit(opts)
    self._FWoW        = true
    self._opts        = opts or {}
    self._enabled     = true
    self._vsm         = lib.StateMachine:New(self)
    self._tooltipText = nil
    self._tooltipTitle = nil

    -- Enforce MainFrame as required root container
    if not (opts and opts._ancestorExempt) and not ANCESTOR_EXEMPT[self._FWoWControlType] then
        if not hasMainFrameAncestor(self) then
            lib:Debug("WARNING: " .. tostring(self._FWoWControlType or "Control")
                .. " created outside a FWoWMainFrame. All FluentWoW controls must"
                .. " be descendants of a MainFrame created via CreateMainFrame().")
        end
    end

    self._themeListener = function()
        if self.OnStateChanged then
            lib.Utils.SafeCall(self.OnStateChanged, self, self._vsm:GetState(), self._vsm:GetState())
        end
    end
    lib.EventBus:On("ThemeChanged", self._themeListener)
end

---@param enabled boolean
function ControlBase:SetEnabled(enabled)
    self._enabled = enabled
    self._vsm:SetFlag("Disabled", not enabled)
    if self.EnableMouse then
        self:EnableMouse(enabled)
    end
end

---@return boolean
function ControlBase:IsEnabled()
    return self._enabled
end

---@param title string
---@param text? string
function ControlBase:SetTooltip(title, text)
    self._tooltipTitle = title
    self._tooltipText  = text
end

---@param key string
---@return any
function ControlBase:Token(key)
    return lib.Tokens:Get(key)
end

---@return string
function ControlBase:GetState()
    return self._vsm:GetState()
end

---@param newState string
---@param prevState string
function ControlBase:OnStateChanged(newState, prevState)
end

---@param flag string
---@param value boolean
function ControlBase:OnFlagChanged(flag, value)
end

--- Shows the standard tooltip for this control.
function ControlBase:ShowTooltip()
    if not self._tooltipTitle then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local r, g, b = lib.Tokens:GetColor("Color.Text.Primary")
    GameTooltip:SetText(self._tooltipTitle, r, g, b, true)
    if self._tooltipText then
        local tr, tg, tb = lib.Tokens:GetColor("Color.Text.Secondary")
        GameTooltip:AddLine(self._tooltipText, tr, tg, tb, true)
    end
    GameTooltip:Show()
end

-------------------------------------------------------------------------------
-- Shared texture asset paths
-------------------------------------------------------------------------------

lib.Textures = {
    RR4          = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_RoundRect4_64x64",
    RR4_Border   = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_RoundRect4_Border_64x64",
    RR4_Shadow   = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_RoundRect4_Shadow_96x96",
    RR8          = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_RoundRect8_64x64",
    RR8_Border   = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_RoundRect8_Border_64x64",
    RR8_Shadow   = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_RoundRect8_Shadow_96x96",
    RoundSquare  = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_RoundSquare_20x20",
    RoundSquareFill = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_RoundSquare_Filled_20x20",
    CircleRing   = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_CircleRing_20x20",
    CircleDot    = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_CircleDot_10x10",
    Circle14     = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_Circle_14x14",
    Circle20     = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_Circle_20x20",
    CircleShadow = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_Circle_Shadow_24x24",
    PillTrack    = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_PillTrack_32x8",
    PillFill     = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_PillFill_32x8",
    Pill         = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_Pill_44x20",
    PillBorder   = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_Pill_Border_44x20",
    BadgePill    = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_Badge_Pill_48x20",
    NavIndicator = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_NavIndicator_3x16",
    TabIndicator = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_TabIndicator_32x3",
    ScrollThumb  = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_ScrollThumb_8x32",
    ProgressRing = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_ProgressRing_32x32",
    ArrowUp      = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_Arrow_Up_16x8",
    FocusRect4   = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_FocusRect4_64x64",
    FocusRect8   = "Interface\\AddOns\\FluentWoW\\Assets\\Textures\\FWoW_FocusRect8_64x64",
}

--- Set up a texture region with a 9-slice image for shaped backgrounds.
---@param tex Texture
---@param path string
---@param margin number  9-slice inset in pixels (corner radius)
function lib.SetupTexture(tex, path, margin)
    tex:SetTexture(path)
    if margin and margin > 0 then
        tex:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
        tex:SetTextureSliceMargins(margin, margin, margin, margin)
    end
end

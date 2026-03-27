--- WinUILib – Controls/Button/Button.lua
-- Button family: Accent (primary), Subtle (secondary), Destructive, Icon, Toggle.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/buttons
-- States: Normal | Hover | Pressed | Disabled | Checked (Toggle only)
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens
local Mot = lib.Motion

-------------------------------------------------------------------------------
-- Style definitions (token key maps)
-------------------------------------------------------------------------------

local STYLES = {
    Accent = {
        bg       = "Color.Accent.Primary",
        bgHover  = "Color.Accent.Hover",
        bgPress  = "Color.Accent.Pressed",
        label    = "Color.Text.OnAccent",
        topEdge  = "Color.Accent.Light",
    },
    Subtle = {
        bg       = "Color.Surface.Elevated",
        bgHover  = "Color.Overlay.Hover",
        bgPress  = "Color.Overlay.Press",
        label    = "Color.Text.Primary",
        topEdge  = "Color.Border.Subtle",
    },
    Destructive = {
        bg       = "Color.Feedback.Error",
        bgHover  = "Color.Feedback.ErrorHover",
        bgPress  = "Color.Feedback.Error",
        label    = "Color.Text.OnAccent",
        topEdge  = "Color.Feedback.Error",
    },
}

-------------------------------------------------------------------------------
-- Shared apply-style helper
-------------------------------------------------------------------------------

local function applyVisuals(self)
    local style = self._style or STYLES.Accent
    local state = self._vsm:GetState()

    local bgKey, labelKey, bottomKey, overlayKey
    if state == "Disabled" then
        bgKey    = style.bg
        labelKey = "Color.Text.Disabled"
        bottomKey = "Color.Border.Default"
    elseif state == "Pressed" then
        bgKey    = style.bgPress
        labelKey = style.label
        bottomKey = style.bgPress
        overlayKey = "Color.Overlay.Press"
    elseif state == "Hover" then
        bgKey    = style.bgHover
        labelKey = style.label
        bottomKey = style.bg
        overlayKey = "Color.Overlay.Hover"
    else
        bgKey    = style.bg
        labelKey = style.label
        bottomKey = style.bgPress
    end

    self.BG:SetColorTexture(T:GetColor(bgKey))
    self.Label:SetTextColor(T:GetColor(labelKey))
    self.TopEdge:SetColorTexture(T:GetColor(style.topEdge))
    self.BottomEdge:SetColorTexture(T:GetColor(bottomKey))

    if self.Shadow then
        local sr, sg, sb = T:GetColor("Color.Surface.Base")
        self.Shadow:SetColorTexture(sr, sg, sb, 0.85)
    end

    if overlayKey then
        self.Overlay:SetColorTexture(T:GetColor(overlayKey))
        self.Overlay:Show()
    else
        self.Overlay:Hide()
    end

    if state == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end
end

-------------------------------------------------------------------------------
-- Toggle-specific visuals
-------------------------------------------------------------------------------

local function applyToggleVisuals(self)
    local state = self._vsm:GetState()
    local checked = self._checked

    local bgKey, labelKey, topKey, bottomKey, overlayKey
    if state == "Disabled" then
        bgKey    = "Color.Surface.Elevated"
        labelKey = "Color.Text.Disabled"
        topKey   = "Color.Border.Subtle"
        bottomKey = "Color.Border.Default"
    elseif checked then
        if state == "Pressed" then
            bgKey = "Color.Accent.Pressed"
            overlayKey = "Color.Overlay.Press"
        elseif state == "Hover" then
            bgKey = "Color.Accent.Hover"
            overlayKey = "Color.Overlay.Hover"
        else
            bgKey = "Color.Accent.Primary"
        end
        labelKey = "Color.Text.OnAccent"
        topKey   = "Color.Accent.Light"
        bottomKey = "Color.Accent.Pressed"
    else
        if state == "Pressed" then
            bgKey = "Color.Overlay.Press"
            overlayKey = "Color.Overlay.Press"
        elseif state == "Hover" then
            bgKey = "Color.Overlay.Hover"
            overlayKey = "Color.Overlay.Hover"
        else
            bgKey = "Color.Surface.Elevated"
        end
        labelKey = "Color.Text.Primary"
        topKey   = "Color.Border.Subtle"
        bottomKey = "Color.Border.Default"
    end

    self.BG:SetColorTexture(T:GetColor(bgKey))
    self.Label:SetTextColor(T:GetColor(labelKey))
    self.TopEdge:SetColorTexture(T:GetColor(topKey))
    self.BottomEdge:SetColorTexture(T:GetColor(bottomKey))

    if self.Shadow then
        local sr, sg, sb = T:GetColor("Color.Surface.Base")
        self.Shadow:SetColorTexture(sr, sg, sb, 0.85)
    end

    if overlayKey then
        self.Overlay:SetColorTexture(T:GetColor(overlayKey))
        self.Overlay:Show()
    else
        self.Overlay:Hide()
    end

    if state == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end
end

-------------------------------------------------------------------------------
-- Shared mixin
-------------------------------------------------------------------------------

---@class WUILButton
local ButtonMixin = {}

function ButtonMixin:OnStateChanged(newState, prevState)
    if self._isToggle then
        applyToggleVisuals(self)
    else
        applyVisuals(self)
    end
end

---@param text string
function ButtonMixin:SetText(text)
    self.Label:SetText(text)
end

---@return string
function ButtonMixin:GetText()
    return self.Label:GetText() or ""
end

---@param styleName string "Accent"|"Subtle"|"Destructive"
function ButtonMixin:SetStyle(styleName)
    self._style = STYLES[styleName] or STYLES.Accent
    applyVisuals(self)
end

---@param fn function
function ButtonMixin:SetOnClick(fn)
    self._onClick = fn
end

-------------------------------------------------------------------------------
-- Icon-button mixin additions
-------------------------------------------------------------------------------

---@class WUILIconButton
local IconMixin = {}

function IconMixin:OnStateChanged(newState, prevState)
    local state = newState
    local bgKey, borderKey, overlayKey
    if state == "Disabled" then
        bgKey = "Color.Surface.Elevated"
        borderKey = "Color.Border.Subtle"
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    elseif state == "Pressed" then
        bgKey = "Color.Surface.Overlay"
        borderKey = "Color.Accent.Primary"
        overlayKey = "Color.Overlay.Press"
        self:SetAlpha(1)
    elseif state == "Hover" then
        bgKey = "Color.Surface.Overlay"
        borderKey = "Color.Border.Focus"
        overlayKey = "Color.Overlay.Hover"
        self:SetAlpha(1)
    else
        bgKey = "Color.Surface.Elevated"
        borderKey = "Color.Border.Subtle"
        self:SetAlpha(1)
    end
    self.BG:SetColorTexture(T:GetColor(bgKey))
    self.Border:SetColorTexture(T:GetColor(borderKey))

    if self.Shadow then
        local sr, sg, sb = T:GetColor("Color.Surface.Base")
        self.Shadow:SetColorTexture(sr, sg, sb, 0.85)
    end

    if overlayKey then
        self.Overlay:SetColorTexture(T:GetColor(overlayKey))
        self.Overlay:Show()
    else
        self.Overlay:Hide()
    end

    local iconKey = (state == "Disabled") and "Color.Icon.Disabled" or "Color.Icon.Default"
    self.Icon:SetVertexColor(T:GetColor(iconKey))
end

---@param path string atlas or file path
---@param isAtlas? boolean
function IconMixin:SetIcon(path, isAtlas)
    if isAtlas then
        self.Icon:SetAtlas(path)
    else
        self.Icon:SetTexture(path)
    end
end

function IconMixin:SetOnClick(fn)
    self._onClick = fn
end

-------------------------------------------------------------------------------
-- Toggle-button mixin additions
-------------------------------------------------------------------------------

---@class WUILToggleButton
local ToggleMixin = {}

function ToggleMixin:OnStateChanged(newState, prevState)
    applyToggleVisuals(self)
end

---@param checked boolean
function ToggleMixin:SetChecked(checked)
    self._checked = checked
    applyToggleVisuals(self)
end

---@return boolean
function ToggleMixin:IsChecked()
    return self._checked == true
end

---@param fn function
function ToggleMixin:SetOnToggle(fn)
    self._onToggle = fn
end

function ToggleMixin:SetText(text)
    self.Label:SetText(text)
end

function ToggleMixin:GetText()
    return self.Label:GetText() or ""
end

function ToggleMixin:SetOnClick(fn)
    self._onClick = fn
end

-------------------------------------------------------------------------------
-- Global script handlers (shared)
-------------------------------------------------------------------------------

function WUILButton_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, ButtonMixin)
    self:WUILInit()
    self._style = STYLES.Accent
    self._isToggle = false
    local font = T:Get("Typography.BodyBold")
    if font then
        self.Label:SetFont(font.font, font.size, font.flags)
    end
    applyVisuals(self)
end

function WUILButtonSubtle_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, ButtonMixin)
    self:WUILInit()
    self._style = STYLES.Subtle
    self._isToggle = false
    local font = T:Get("Typography.BodyBold")
    if font then
        self.Label:SetFont(font.font, font.size, font.flags)
    end
    applyVisuals(self)
end

function WUILButtonDestructive_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, ButtonMixin)
    self:WUILInit()
    self._style = STYLES.Destructive
    self._isToggle = false
    local font = T:Get("Typography.BodyBold")
    if font then
        self.Label:SetFont(font.font, font.size, font.flags)
    end
    applyVisuals(self)
end

function WUILIconButton_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, IconMixin)
    self:WUILInit()
    self.BG:SetColorTexture(T:GetColor("Color.Surface.Elevated"))
    self.Icon:SetVertexColor(T:GetColor("Color.Icon.Default"))
end

function WUILToggleButton_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, ToggleMixin)
    self:WUILInit()
    self._isToggle = true
    self._checked  = false
    local font = T:Get("Typography.BodyBold")
    if font then
        self.Label:SetFont(font.font, font.size, font.flags)
    end
    applyToggleVisuals(self)
end

function WUILButton_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    self:ShowTooltip()
end

function WUILButton_OnLeave(self)
    if not self._enabled then return end
    if self._isToggle and self._checked then
        self._vsm:SetState("Checked")
    else
        self._vsm:SetState("Normal")
    end
    GameTooltip:Hide()
end

function WUILButton_OnMouseDown(self)
    if not self._enabled then return end
    self._vsm:SetState("Pressed")
    Mot:ScalePress(self)
end

function WUILButton_OnMouseUp(self)
    if not self._enabled then return end
    if self:IsMouseOver() then
        self._vsm:SetState("Hover")
    elseif self._isToggle and self._checked then
        self._vsm:SetState("Checked")
    else
        self._vsm:SetState("Normal")
    end
end

function WUILButton_OnClick(self, button)
    if not self._enabled then return end
    if self._onClick then
        lib.Utils.SafeCall(self._onClick, self, button)
    end
end

function WUILToggleButton_OnClick(self, button)
    if not self._enabled then return end
    self._checked = not self._checked
    if self._checked then
        self._vsm:SetState("Checked")
    else
        self._vsm:SetState("Normal")
    end
    if self._onToggle then
        lib.Utils.SafeCall(self._onToggle, self, self._checked)
    end
    if self._onClick then
        lib.Utils.SafeCall(self._onClick, self, button)
    end
end

function WUILButton_OnEnable(self)
    self._enabled = true
    self._vsm:SetFlag("Disabled", false)
end

function WUILButton_OnDisable(self)
    self._enabled = false
    self._vsm:SetFlag("Disabled", true)
end

-------------------------------------------------------------------------------
-- Factory methods
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@param style? string  "Accent"|"Subtle"|"Destructive"
---@return WUILButton
function lib:CreateButton(parent, name, style)
    local template = "WUILButtonTemplate"
    if style == "Subtle" then
        template = "WUILButtonSubtleTemplate"
    elseif style == "Destructive" then
        template = "WUILButtonDestructiveTemplate"
    end
    local f = CreateFrame("Button", name, parent, template)
    ---@cast f WUILButton
    return f
end

---@param parent Frame
---@param name? string
---@return WUILIconButton
function lib:CreateIconButton(parent, name)
    local f = CreateFrame("Button", name, parent, "WUILIconButtonTemplate")
    ---@cast f WUILIconButton
    return f
end

---@param parent Frame
---@param name? string
---@return WUILToggleButton
function lib:CreateToggleButton(parent, name)
    local f = CreateFrame("Button", name, parent, "WUILToggleButtonTemplate")
    ---@cast f WUILToggleButton
    return f
end

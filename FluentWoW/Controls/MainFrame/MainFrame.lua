--- FluentWoW – Controls/MainFrame/MainFrame.lua
-- Top-level application window — the primary frame consumer addons create.
-- Equivalent to Ace3's AceGUI "Frame" container but with WinUI design language.
--
-- Features:
--   Draggable title bar, resizable edges, close button (×), content area,
--   status bar, ESC-to-close, position/size persistence via status table,
--   optional app icon, combat-safe show/hide.
--
-- States: Normal, Hover (close btn only)
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class FWoWMainFrame
local MainFrameMixin = {}

function MainFrameMixin:OnStateChanged(newState, prevState)
    -- MainFrame itself doesn't change visual state; sub-parts (close btn) do
end

--- Apply all token-driven visuals.
local function applyVisuals(self)
    -- Backdrop
    local bg = self.Backdrop
    local r, g, b, a = T:GetColor("Color.Surface.Base")
    bg.BG:SetColorTexture(r, g, b, a)
    local br, bg2, bb, ba = T:GetColor("Color.Border.Subtle")
    bg.EdgeTop:SetColorTexture(br, bg2, bb, ba)
    bg.EdgeBottom:SetColorTexture(br, bg2, bb, ba)
    bg.EdgeLeft:SetColorTexture(br, bg2, bb, ba)
    bg.EdgeRight:SetColorTexture(br, bg2, bb, ba)

    -- Title bar
    local tb = self.TitleBar
    local tr, tg2, tb2, ta = T:GetColor("Color.Surface.Raised")
    tb.BG:SetColorTexture(tr, tg2, tb2, ta)

    -- Title text
    local font = T:Get("Typography.Title")
    if font then
        tb.Title:SetFont(font.font, font.size, font.flags)
    end
    local txr, txg, txb = T:GetColor("Color.Text.Primary")
    tb.Title:SetTextColor(txr, txg, txb)

    -- Close button label
    local cbFont = T:Get("Typography.Header")
    if cbFont then
        self.CloseBtn.Label:SetFont(cbFont.font, cbFont.size, cbFont.flags)
    end
    self.CloseBtn.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
    self.CloseBtn.Hover:SetColorTexture(T:GetColor("Color.Feedback.Error"))

    -- Status bar
    local sb = self.StatusBar
    local sr, sg, sbb, sa = T:GetColor("Color.Surface.Raised")
    sb.BG:SetColorTexture(sr, sg, sbb, sa)
    sb.TopEdge:SetColorTexture(br, bg2, bb, ba)
    local capFont = T:Get("Typography.Caption")
    if capFont then
        sb.Text:SetFont(capFont.font, capFont.size, capFont.flags)
    end
    sb.Text:SetTextColor(T:GetColor("Color.Text.Secondary"))

    -- Icon (hidden by default)
    tb.Icon:Hide()
end

local function registerThemeListener(self)
    if self._themeListenerRegistered or not self._themeListener then return end
    lib.EventBus:On("ThemeChanged", self._themeListener)
    self._themeListenerRegistered = true
end

local function setTitleBarSlot(slot, control, width)
    if slot._content and slot._content ~= control then
        slot._content:ClearAllPoints()
        slot._content:SetParent(nil)
    end

    slot._content = control
    if not control then
        slot:SetWidth(1)
        slot:Hide()
        return
    end

    slot:SetWidth(width or control:GetWidth() or 1)
    slot:Show()
    control:SetParent(slot)
    control:ClearAllPoints()
    control:SetAllPoints(slot)
    control:Show()
end

local function unregisterThemeListener(self)
    if not self._themeListenerRegistered or not self._themeListener then return end
    lib.EventBus:Off("ThemeChanged", self._themeListener)
    self._themeListenerRegistered = false
end

-------------------------------------------------------------------------------
-- Title / Status / Icon
-------------------------------------------------------------------------------

---@param title string
function MainFrameMixin:SetTitle(title)
    self.TitleBar.Title:SetText(title or "")
end

---@param text string
function MainFrameMixin:SetStatusText(text)
    self.StatusBar.Text:SetText(text or "")
end

---@param path string  texture file path or fileID
function MainFrameMixin:SetIcon(path)
    if path then
        self.TitleBar.Icon:SetTexture(path)
        self.TitleBar.Icon:Show()
    else
        self.TitleBar.Icon:Hide()
    end
end

---@param control Frame|nil
---@param width? number
function MainFrameMixin:SetTitleBarLeftControl(control, width)
    setTitleBarSlot(self.TitleBar.LeftSlot, control, width)
end

---@param control Frame|nil
---@param width? number
function MainFrameMixin:SetTitleBarRightControl(control, width)
    setTitleBarSlot(self.TitleBar.RightSlot, control, width)
end

---@return Frame
function MainFrameMixin:GetTitleBarLeftArea()
    return self.TitleBar.LeftSlot
end

---@return Frame
function MainFrameMixin:GetTitleBarRightArea()
    return self.TitleBar.RightSlot
end

-------------------------------------------------------------------------------
-- Content area
-------------------------------------------------------------------------------

---@return Frame
function MainFrameMixin:GetContentArea()
    return self.ContentArea
end

---@param insetL? number  left inset (default 16)
---@param insetR? number  right inset (default 16)
---@param insetT? number  top inset below title bar (default 40)
---@param insetB? number  bottom inset above status bar (default 28)
function MainFrameMixin:SetContentInsets(insetL, insetR, insetT, insetB)
    local sp = T
    local l = insetL or sp:GetNumber("Spacing.XL")
    local r = insetR or sp:GetNumber("Spacing.XL")
    local t = insetT or sp:GetNumber("Spacing.XXXL") + sp:GetNumber("Spacing.MD")  -- 40
    local b = insetB or sp:GetNumber("Spacing.XXL") + sp:GetNumber("Spacing.SM")   -- 28
    self.ContentArea:ClearAllPoints()
    self.ContentArea:SetPoint("TOPLEFT", l, -t)
    self.ContentArea:SetPoint("BOTTOMRIGHT", -r, b)
end

-------------------------------------------------------------------------------
-- Show / Hide (combat-safe)
-------------------------------------------------------------------------------

function MainFrameMixin:Open()
    if InCombatLockdown() then
        lib:Debug("MainFrame:Open blocked — in combat")
        return
    end
    self:Show()
end

function MainFrameMixin:Close()
    self:Hide()
end

-------------------------------------------------------------------------------
-- Resize
-------------------------------------------------------------------------------

---@param enabled boolean
function MainFrameMixin:SetResizable(enabled)
    self._resizable = enabled
    local fn = enabled and "Show" or "Hide"
    self.SizerSE[fn](self.SizerSE)
    self.SizerS[fn](self.SizerS)
    self.SizerE[fn](self.SizerE)
end

-------------------------------------------------------------------------------
-- Position / Size persistence (like Ace3 status table)
-------------------------------------------------------------------------------

---@param tbl table  layout persistence table (from saved variables)
function MainFrameMixin:SetStatusTable(tbl)
    assert(type(tbl) == "table", "SetStatusTable requires a table")
    self._status = tbl
    self:_ApplyStatus()
end

function MainFrameMixin:_ApplyStatus()
    local s = self._status or self._localStatus
    self:SetSize(s.width or 700, s.height or 500)
    self:ClearAllPoints()
    if s.top and s.left then
        self:SetPoint("TOP", UIParent, "BOTTOM", 0, s.top)
        self:SetPoint("LEFT", UIParent, "LEFT", s.left, 0)
    else
        self:SetPoint("CENTER", UIParent, "CENTER")
    end
end

function MainFrameMixin:_SaveStatus()
    local s = self._status or self._localStatus
    s.width  = self:GetWidth()
    s.height = self:GetHeight()
    s.top    = self:GetTop()
    s.left   = self:GetLeft()
end

-------------------------------------------------------------------------------
-- Callbacks
-------------------------------------------------------------------------------

---@param callback function  called when frame is closed
function MainFrameMixin:SetOnClose(callback)
    self._onClose = callback
end

---@param callback function  called when frame is shown
function MainFrameMixin:SetOnShow(callback)
    self._onShow = callback
end

---@param callback function  called when frame is resized (width, height)
function MainFrameMixin:SetOnResize(callback)
    self._onResize = callback
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWMainFrame_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, MainFrameMixin)
    self._FWoWControlType = "FWoWMainFrame"
    self._FWoWMainFrame   = true
    self:FWoWInit()

    self._localStatus = {}
    self._status      = nil
    self._resizable   = true
    self._themeListenerRegistered = false
    self.TitleBar.LeftSlot:SetWidth(1)
    self.TitleBar.RightSlot:SetWidth(1)

    -- Register for ESC-to-close
    if self:GetName() then
        tinsert(UISpecialFrames, self:GetName())
    end

    applyVisuals(self)
    self._themeListener = function() applyVisuals(self) end
end

function FWoWMainFrame_OnShow(self)
    registerThemeListener(self)
    applyVisuals(self)
    if Mot then Mot:FadeIn(self) end
    if self._onShow then lib.Utils.SafeCall(self._onShow, self) end
end

function FWoWMainFrame_OnHide(self)
    unregisterThemeListener(self)
    self:_SaveStatus()
    if self._onClose then lib.Utils.SafeCall(self._onClose, self) end
end

function FWoWMainFrame_OnSizeChanged(self, w, h)
    if self._onResize then lib.Utils.SafeCall(self._onResize, self, w, h) end
end

-- Title bar drag
function FWoWMainFrame_TitleBar_OnMouseDown(self)
    self:GetParent():StartMoving()
end

function FWoWMainFrame_TitleBar_OnMouseUp(self)
    local frame = self:GetParent()
    frame:StopMovingOrSizing()
    frame:_SaveStatus()
end

-- Close button
function FWoWMainFrame_CloseBtn_OnClick(self)
    PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_CLOSE or 851)
    self:GetParent():Close()
end

function FWoWMainFrame_CloseBtn_OnEnter(self)
    self.Hover:Show()
    self.Label:SetTextColor(T:GetColor("Color.Text.OnAccent"))
end

function FWoWMainFrame_CloseBtn_OnLeave(self)
    self.Hover:Hide()
    self.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
end

-- Resize grippers
function FWoWMainFrame_SizerSE_OnMouseDown(self)
    self:GetParent():StartSizing("BOTTOMRIGHT")
end

function FWoWMainFrame_SizerS_OnMouseDown(self)
    self:GetParent():StartSizing("BOTTOM")
end

function FWoWMainFrame_SizerE_OnMouseDown(self)
    self:GetParent():StartSizing("RIGHT")
end

function FWoWMainFrame_Sizer_OnMouseUp(self)
    local frame = self:GetParent()
    frame:StopMovingOrSizing()
    frame:_SaveStatus()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

local _frameCount = 0

---@param name? string     global name (needed for ESC-to-close)
---@param title? string    window title
---@return FWoWMainFrame
function lib:CreateMainFrame(name, title)
    if not name then
        _frameCount = _frameCount + 1
        name = "FWoWMainFrame" .. _frameCount
    end
    local f = CreateFrame("Frame", name, UIParent, "FWoWMainFrameTemplate")
    ---@cast f FWoWMainFrame
    if title then f:SetTitle(title) end
    f:_ApplyStatus()
    return f
end

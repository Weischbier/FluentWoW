--- WinUILib – Controls/MainFrame/MainFrame.lua
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

local lib = WinUILib
local T   = lib.Tokens
local Mot = lib.Motion

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILMainFrame
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
        self.TitleBar.Title:SetPoint("LEFT", self.TitleBar.Icon, "RIGHT", T:GetNumber("Spacing.MD"), 0)
    else
        self.TitleBar.Icon:Hide()
        self.TitleBar.Title:SetPoint("LEFT", self.TitleBar, "LEFT", T:GetNumber("Spacing.XL"), 0)
    end
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

function WUILMainFrame_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, MainFrameMixin)
    self:WUILInit()

    self._localStatus = {}
    self._status      = nil
    self._resizable   = true

    -- Register for ESC-to-close
    if self:GetName() then
        tinsert(UISpecialFrames, self:GetName())
    end

    applyVisuals(self)

    -- Theme change listener (stored for cleanup)
    self._themeListener = function() applyVisuals(self) end
    lib.EventBus:On("ThemeChanged", self._themeListener)
end

function WUILMainFrame_OnShow(self)
    if Mot then Mot:FadeIn(self) end
    if self._onShow then lib.Utils.SafeCall(self._onShow, self) end
end

function WUILMainFrame_OnHide(self)
    self:_SaveStatus()
    if self._onClose then lib.Utils.SafeCall(self._onClose, self) end
end

function WUILMainFrame_OnSizeChanged(self, w, h)
    if self._onResize then lib.Utils.SafeCall(self._onResize, self, w, h) end
end

-- Title bar drag
function WUILMainFrame_TitleBar_OnMouseDown(self)
    self:GetParent():StartMoving()
end

function WUILMainFrame_TitleBar_OnMouseUp(self)
    local frame = self:GetParent()
    frame:StopMovingOrSizing()
    frame:_SaveStatus()
end

-- Close button
function WUILMainFrame_CloseBtn_OnClick(self)
    PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_CLOSE or 851)
    self:GetParent():Close()
end

function WUILMainFrame_CloseBtn_OnEnter(self)
    self.Hover:Show()
    self.Label:SetTextColor(T:GetColor("Color.Text.OnAccent"))
end

function WUILMainFrame_CloseBtn_OnLeave(self)
    self.Hover:Hide()
    self.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
end

-- Resize grippers
function WUILMainFrame_SizerSE_OnMouseDown(self)
    self:GetParent():StartSizing("BOTTOMRIGHT")
end

function WUILMainFrame_SizerS_OnMouseDown(self)
    self:GetParent():StartSizing("BOTTOM")
end

function WUILMainFrame_SizerE_OnMouseDown(self)
    self:GetParent():StartSizing("RIGHT")
end

function WUILMainFrame_Sizer_OnMouseUp(self)
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
---@return WUILMainFrame
function lib:CreateMainFrame(name, title)
    if not name then
        _frameCount = _frameCount + 1
        name = "WUILMainFrame" .. _frameCount
    end
    local f = CreateFrame("Frame", name, UIParent, "WUILMainFrameTemplate")
    ---@cast f WUILMainFrame
    if title then f:SetTitle(title) end
    f:_ApplyStatus()
    return f
end

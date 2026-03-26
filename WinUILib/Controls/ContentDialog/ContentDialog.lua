--- WinUILib – Controls/ContentDialog/ContentDialog.lua
-- Modal dialog with title, body content, primary + secondary + close actions.
-- Design ref: WinUI ContentDialog
--
-- Public API:
--   :SetTitle(text)
--   :SetContent(text)
--   :SetPrimaryButton(text, callback)
--   :SetSecondaryButton(text, callback)
--   :SetCloseOnPrimary(bool)    default true
--   :SetCloseOnSecondary(bool)  default true
--   :Open()
--   :Close()
--   OnOpened(self)  OnClosed(self, result)   result = "Primary"|"Secondary"|"Close"
--
-- Combat note: dialogs MUST NOT be shown during combat as they disable mouse
-- on the secure UI.  Callers should guard with InCombatLockdown().
-- This implementation blocks Show() in combat and queues it for post-combat.
-------------------------------------------------------------------------------

local lib = WinUILib
local Mot = lib.Motion

-- Singleton: only one dialog may be open at a time in WoW.
local _activeDialog = nil

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILContentDialog_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.ContentDialog)
    self:WUILInit()
    self._pendingOpen       = false
    self._closeOnPrimary    = true
    self._closeOnSecondary  = true
    self._result            = nil

    -- Wire built-in buttons
    local pri = _G[self:GetName() .. "_PrimaryBtn"]
    if pri then
        Mixin(pri, lib._controls.ControlBase)
        pri:WUILInit()
        pri:SetLabel("OK")
        pri:SetScript("OnClick", function(btn, b)
            if b == "LeftButton" then self:_OnPrimary() end
        end)
    end

    local sec = _G[self:GetName() .. "_SecondaryBtn"]
    if sec then
        Mixin(sec, lib._controls.ControlBase)
        sec:WUILInit()
        sec:SetLabel("Cancel")
        sec:SetScript("OnClick", function(btn, b)
            if b == "LeftButton" then self:_OnSecondary() end
        end)
    end

    -- Register for PLAYER_REGEN_ENABLED to auto-show queued dialogs
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:SetScript("OnEvent", function(s, event)
        if event == "PLAYER_REGEN_ENABLED" and s._pendingOpen then
            s._pendingOpen = false
            s:Open()
        end
    end)
end

function WUILContentDialog_OnKeyDown(self, key)
    if key == "ESCAPE" then
        self:Close()
    elseif key == "RETURN" then
        self:_OnPrimary()
    end
end

-------------------------------------------------------------------------------
-- ContentDialog mixin
-------------------------------------------------------------------------------

---@class WUILContentDialog : WUILControlBase
local ContentDialog = {}
lib._controls.ContentDialog = ContentDialog

---@param text string
function ContentDialog:SetTitle(text)
    local t = _G[self:GetName() .. "_Title"]
    if t then t:SetText(text or "") end
end

---@param text string
function ContentDialog:SetContent(text)
    local c = _G[self:GetName() .. "_Content"]
    if c then
        c:SetText(text or "")
        -- Resize dialog card to fit content
        self:_AutoSize()
    end
end

---@param text string
---@param cb   function?
function ContentDialog:SetPrimaryButton(text, cb)
    local btn = _G[self:GetName() .. "_PrimaryBtn"]
    if btn then
        btn:SetLabel(text or "OK")
        btn:SetShown((text or "") ~= "")
    end
    self._primaryCallback = cb
end

---@param text string
---@param cb   function?
function ContentDialog:SetSecondaryButton(text, cb)
    local btn = _G[self:GetName() .. "_SecondaryBtn"]
    if btn then
        btn:SetLabel(text or "Cancel")
        btn:SetShown((text or "") ~= "")
    end
    self._secondaryCallback = cb
end

---@param v boolean
function ContentDialog:SetCloseOnPrimary(v)   self._closeOnPrimary   = v end

---@param v boolean
function ContentDialog:SetCloseOnSecondary(v) self._closeOnSecondary = v end

--- Opens the dialog; defers if in combat.
function ContentDialog:Open()
    if lib.Utils.InCombat() then
        self._pendingOpen = true
        lib:Debug("ContentDialog: deferred (in combat)")
        return
    end
    if _activeDialog and _activeDialog ~= self then
        _activeDialog:Close()
    end
    _activeDialog = self
    Mot:FadeIn(self, 0.20)
    self:SetPropagateKeyboardInput(false)  -- capture Escape / Enter
    if self.OnOpened then lib.Utils.SafeCall(self.OnOpened, self) end
end

--- Closes the dialog with an optional result string.
---@param result string?
function ContentDialog:Close(result)
    self._result = result or "Close"
    Mot:FadeOut(self, 0.15, function()
        if _activeDialog == self then _activeDialog = nil end
        if self.OnClosed then
            lib.Utils.SafeCall(self.OnClosed, self, self._result)
        end
    end)
end

function ContentDialog:_OnPrimary()
    if self._primaryCallback then
        lib.Utils.SafeCall(self._primaryCallback, self)
    end
    if self._closeOnPrimary then self:Close("Primary") end
end

function ContentDialog:_OnSecondary()
    if self._secondaryCallback then
        lib.Utils.SafeCall(self._secondaryCallback, self)
    end
    if self._closeOnSecondary then self:Close("Secondary") end
end

function ContentDialog:_AutoSize()
    local content = _G[self:GetName() .. "_Content"]
    local bg      = _G[self:GetName() .. "_BG"]
    local border  = _G[self:GetName() .. "_Border"]
    if not (content and bg) then return end
    local textH = content:GetStringHeight()
    local h     = math.max(160, 80 + textH + 60)
    bg:SetHeight(h)
    if border then border:SetHeight(h) end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

--- Creates a ContentDialog (attached to UIParent; there should be few of these).
---@param title   string?
---@param content string?
---@return Frame
function lib:CreateContentDialog(title, content)
    local d = CreateFrame("Frame", nil, UIParent, "WUILContentDialogTemplate")
    if title   then d:SetTitle(title) end
    if content then d:SetContent(content) end
    return d
end

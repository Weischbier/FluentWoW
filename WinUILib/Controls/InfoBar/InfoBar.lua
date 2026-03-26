--- WinUILib – Controls/InfoBar/InfoBar.lua
-- Inline status bar for informational, success, warning, and error messages.
-- Design ref: WinUI InfoBar (CommunityToolkit origin, now in WinUI 3)
--
-- Severity:  "Informational" | "Success" | "Warning" | "Error"
--
-- Public API:
--   :SetSeverity("Informational"|"Success"|"Warning"|"Error")
--   :SetTitle(text)
--   :SetMessage(text)
--   :SetClosable(bool)  -- show/hide X button
--   :Open()   :Close()
--   OnClosed(self)
-------------------------------------------------------------------------------

local lib = WinUILib
local Mot = lib.Motion

-- Severity → accent colour and icon colour
local SEVERITY = {
    Informational = { accent = {0.05, 0.55, 0.88, 1}, icon = {0.05, 0.55, 0.88, 1} },
    Success       = { accent = {0.20, 0.80, 0.40, 1}, icon = {0.20, 0.80, 0.40, 1} },
    Warning       = { accent = {1.00, 0.80, 0.10, 1}, icon = {1.00, 0.80, 0.10, 1} },
    Error         = { accent = {0.90, 0.20, 0.20, 1}, icon = {0.90, 0.20, 0.20, 1} },
}

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILInfoBar_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.InfoBar)
    self:WUILInit()
    self._severity = "Informational"
    self._closable = true
    self:_ApplySeverity()
end

function WUILInfoBar_CloseBtn_OnLoad(self)
    local x = _G[self:GetName() .. "_X"]
    if x then x:SetText("✕") end
end

function WUILInfoBar_CloseBtn_OnClick(self, btn)
    if btn ~= "LeftButton" then return end
    local bar = self:GetParent()
    if bar and bar.Close then bar:Close() end
end

-------------------------------------------------------------------------------
-- InfoBar mixin
-------------------------------------------------------------------------------

---@class WUILInfoBar : WUILControlBase
local InfoBar = {}
lib._controls.InfoBar = InfoBar

---@param sev string  "Informational"|"Success"|"Warning"|"Error"
function InfoBar:SetSeverity(sev)
    self._severity = SEVERITY[sev] and sev or "Informational"
    self:_ApplySeverity()
end

---@param text string
function InfoBar:SetTitle(text)
    local label = _G[self:GetName() .. "_Title"]
    if label then label:SetText(text or "") end
    self:_ResizeToContent()
end

---@param text string
function InfoBar:SetMessage(text)
    local msg = _G[self:GetName() .. "_Message"]
    if msg then
        msg:SetText(text or "")
        msg:SetShown((text or "") ~= "")
    end
    self:_ResizeToContent()
end

---@param closable boolean
function InfoBar:SetClosable(closable)
    self._closable = closable
    local btn = _G[self:GetName() .. "_CloseBtn"]
    if btn then btn:SetShown(closable) end
end

--- Shows the InfoBar with a fade-in.
function InfoBar:Open()
    Mot:FadeIn(self, 0.20)
end

--- Hides the InfoBar with a fade-out.
function InfoBar:Close()
    Mot:FadeOut(self, 0.15, function()
        if self.OnClosed then
            lib.Utils.SafeCall(self.OnClosed, self)
        end
    end)
end

function InfoBar:_ApplySeverity()
    local def = SEVERITY[self._severity]
    if not def then return end
    local accent = _G[self:GetName() .. "_Accent"]
    local icon   = _G[self:GetName() .. "_Icon"]
    if accent then accent:SetColorTexture(table.unpack(def.accent)) end
    if icon   then icon:SetColorTexture(table.unpack(def.icon)) end
end

function InfoBar:_ResizeToContent()
    local msg = _G[self:GetName() .. "_Message"]
    if msg and msg:IsShown() then
        local h = math.max(64, msg:GetStringHeight() + 44)
        self:SetHeight(h)
    else
        self:SetHeight(44)
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent   Frame
---@param severity string?  default "Informational"
---@param title    string?
---@param message  string?
---@return Frame
function lib:CreateInfoBar(parent, severity, title, message)
    local ib = CreateFrame("Frame", nil, parent, "WUILInfoBarTemplate")
    if severity then ib:SetSeverity(severity) end
    if title    then ib:SetTitle(title) end
    if message  then ib:SetMessage(message) end
    return ib
end

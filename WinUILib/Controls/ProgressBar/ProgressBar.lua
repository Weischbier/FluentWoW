--- WinUILib – Controls/ProgressBar/ProgressBar.lua
-- Determinate / indeterminate progress bar and spinner ring.
-- Design ref: WinUI ProgressBar, ProgressRing
--
-- ProgressBar API:
--   :SetValue(0-100)   :GetValue()
--   :SetIndeterminate(bool)
--   :SetColor(r,g,b,a)
--
-- ProgressRing API:
--   :Start()  :Stop()
--
-- Combat note: OnUpdate-driven indeterminate animation is combat-safe;
-- we never touch secure frames.
-------------------------------------------------------------------------------

local lib = WinUILib

-------------------------------------------------------------------------------
-- ProgressBar
-------------------------------------------------------------------------------

function WUILProgressBar_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.ProgressBar)
    self:WUILInit()
    self._value         = 0
    self._indeterminate = false
    self:_UpdateFill()
end

function WUILProgressBarIndeterminate_OnLoad(self)
    WUILProgressBar_OnLoad(self)
    self:SetIndeterminate(true)
end

function WUILProgressBar_OnSizeChanged(self)
    self:_UpdateFill()
end

---@class WUILProgressBar : WUILControlBase
local ProgressBar = {}
lib._controls.ProgressBar = ProgressBar

---@param v number  0-100
function ProgressBar:SetValue(v)
    self._value = math.max(0, math.min(100, v))
    self._indeterminate = false
    self:_StopIndeterminateAnim()
    self:_UpdateFill()
end

---@return number
function ProgressBar:GetValue()
    return self._value
end

---@param on boolean
function ProgressBar:SetIndeterminate(on)
    self._indeterminate = on
    if on then
        self:_StartIndeterminateAnim()
    else
        self:_StopIndeterminateAnim()
        self:_UpdateFill()
    end
end

---@param r number  @param g number  @param b number  @param a number?
function ProgressBar:SetColor(r, g, b, a)
    local fill = _G[self:GetName() .. "_Fill"]
    if fill then fill:SetColorTexture(r, g, b, a or 1) end
end

function ProgressBar:_UpdateFill()
    local fill  = _G[self:GetName() .. "_Fill"]
    if not fill then return end
    local w = self:GetWidth() or 0
    fill:SetWidth(math.max(0, w * (self._value / 100)))
end

-- Indeterminate shimmer: a ~60% fill block that oscillates left-to-right
local IND_SPEED = 0.8   -- full track width per second
function ProgressBar:_StartIndeterminateAnim()
    self._indPhase = 0
    self:SetScript("OnUpdate", function(self, elapsed)
        if not self._indeterminate then return end
        self._indPhase = (self._indPhase or 0) + elapsed * IND_SPEED
        if self._indPhase > 1.6 then self._indPhase = 0 end
        local fill = _G[self:GetName() .. "_Fill"]
        if not fill then return end
        local w    = self:GetWidth() or 0
        local fw   = w * 0.4
        -- Animate offset as a triangle wave: 0 → 1 → 0
        local t = self._indPhase <= 0.8 and (self._indPhase / 0.8)
                                         or (1 - (self._indPhase - 0.8) / 0.8)
        fill:SetWidth(fw)
        fill:ClearAllPoints()
        fill:SetPoint("LEFT", self, "LEFT", (w - fw) * t, 0)
        fill:SetPoint("TOP")
        fill:SetPoint("BOTTOM")
    end)
end

function ProgressBar:_StopIndeterminateAnim()
    self:SetScript("OnUpdate", nil)
    local fill = _G[self:GetName() .. "_Fill"]
    if fill then
        fill:ClearAllPoints()
        fill:SetPoint("TOPLEFT")
        fill:SetPoint("BOTTOMLEFT")
    end
end

-------------------------------------------------------------------------------
-- ProgressRing (spinner)
-------------------------------------------------------------------------------

function WUILProgressRing_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.ProgressRing)
    self:WUILInit()
    self._angle    = 0
    self._spinning = false
end

function WUILProgressRing_OnShow(self)
    self:Start()
end

function WUILProgressRing_OnHide(self)
    self:Stop()
end

---@class WUILProgressRing : WUILControlBase
local ProgressRing = {}
lib._controls.ProgressRing = ProgressRing

local SPIN_SPEED = 360  -- degrees per second

function ProgressRing:Start()
    self._spinning = true
    self:SetScript("OnUpdate", function(self, elapsed)
        if not self._spinning then return end
        self._angle = (self._angle + SPIN_SPEED * elapsed) % 360
        local arc = _G[self:GetName() .. "_Arc1"]
        if arc then
            -- WoW textures don't natively rotate; we approximate with
            -- a pulsing alpha to convey activity without GPU-expensive rotation.
            -- Full rotation requires a TextureCoordTranslation or SharedMedia atlas.
            local pulse = math.abs(math.sin(math.rad(self._angle)))
            arc:SetAlpha(0.4 + 0.6 * pulse)
        end
    end)
end

function ProgressRing:Stop()
    self._spinning = false
    self:SetScript("OnUpdate", nil)
    local arc = _G[self:GetName() .. "_Arc1"]
    if arc then arc:SetAlpha(1) end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param width  number?
---@return Frame
function lib:CreateProgressBar(parent, width)
    local pb = CreateFrame("Frame", nil, parent, "WUILProgressBarTemplate")
    if width then pb:SetWidth(width) end
    return pb
end

---@param parent Frame
---@param size   number?
---@return Frame
function lib:CreateProgressRing(parent, size)
    local pr = CreateFrame("Frame", nil, parent, "WUILProgressRingTemplate")
    if size then pr:SetSize(size, size) end
    return pr
end

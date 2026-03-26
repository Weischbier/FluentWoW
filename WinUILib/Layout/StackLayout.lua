--- WinUILib – Layout/StackLayout.lua
-- Stack layout container – arranges child controls vertically or horizontally
-- with consistent spacing derived from the design token system.
-- Design ref: WinUI StackPanel, WinUI ItemsRepeater
--
-- Public API:
--   :AddChild(frame)
--   :RemoveChild(frame)
--   :SetSpacing(n)        spacing between items in pixels
--   :SetPadding(t,r,b,l)  inner padding
--   :Layout()             re-measures and repositions all children
--   :GetTotalHeight()     / :GetTotalWidth()
--
-- Both VStack (vertical, default) and HStack (horizontal) share this mixin.
-------------------------------------------------------------------------------

local lib = WinUILib

-- Default spacing from tokens
local function defaultSpacing()
    return lib.Tokens:GetSpacing("MD")  -- 8px
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILStackLayout_OnLoad(self)
    Mixin(self, lib._controls.StackLayout)
    self._orientation = "Vertical"
    self._children    = {}
    self._spacing     = defaultSpacing()
    self._padTop      = 0
    self._padRight    = 0
    self._padBottom   = 0
    self._padLeft     = 0
end

function WUILHStackLayout_OnLoad(self)
    WUILStackLayout_OnLoad(self)
    self._orientation = "Horizontal"
end

function WUILStackLayout_OnSizeChanged(self)
    -- Re-layout when the container is resized (e.g. parent panel resize)
    self:Layout()
end

-------------------------------------------------------------------------------
-- StackLayout mixin
-------------------------------------------------------------------------------

---@class WUILStackLayout
local StackLayout = {}
lib._controls.StackLayout = StackLayout

--- Appends a child frame and triggers re-layout.
---@param frame Frame
function StackLayout:AddChild(frame)
    table.insert(self._children, frame)
    frame:SetParent(self)
    self:Layout()
end

--- Removes a child frame and triggers re-layout.
---@param frame Frame
function StackLayout:RemoveChild(frame)
    for i, ch in ipairs(self._children) do
        if ch == frame then
            table.remove(self._children, i)
            frame:SetParent(nil)
            break
        end
    end
    self:Layout()
end

--- Sets the gap between children in pixels.
---@param n number
function StackLayout:SetSpacing(n)
    self._spacing = n
    self:Layout()
end

--- Sets inner padding.
---@param t number  @param r number  @param b number  @param l number
function StackLayout:SetPadding(t, r, b, l)
    self._padTop    = t or 0
    self._padRight  = r or t or 0
    self._padBottom = b or t or 0
    self._padLeft   = l or r or t or 0
    self:Layout()
end

--- Repositions all children according to orientation and spacing.
function StackLayout:Layout()
    if #self._children == 0 then return end

    if self._orientation == "Vertical" then
        self:_LayoutVertical()
    else
        self:_LayoutHorizontal()
    end
end

---@return number
function StackLayout:GetTotalHeight()
    if self._orientation ~= "Vertical" then return self:GetHeight() end
    local h = self._padTop + self._padBottom
    for i, ch in ipairs(self._children) do
        h = h + (ch:GetHeight() or 0)
        if i < #self._children then h = h + self._spacing end
    end
    return h
end

---@return number
function StackLayout:GetTotalWidth()
    if self._orientation ~= "Horizontal" then return self:GetWidth() end
    local w = self._padLeft + self._padRight
    for i, ch in ipairs(self._children) do
        w = w + (ch:GetWidth() or 0)
        if i < #self._children then w = w + self._spacing end
    end
    return w
end

function StackLayout:_LayoutVertical()
    local yOff = -self._padTop
    local w    = self:GetWidth() - self._padLeft - self._padRight
    for i, ch in ipairs(self._children) do
        ch:ClearAllPoints()
        ch:SetPoint("TOPLEFT", self, "TOPLEFT", self._padLeft, yOff)
        -- Stretch child to container width (StackPanel default behaviour)
        if ch.SetWidth then ch:SetWidth(w) end
        yOff = yOff - (ch:GetHeight() or 0) - self._spacing
    end
    -- Auto-size container height
    local totalH = self:GetTotalHeight()
    self:SetHeight(math.max(1, totalH))
end

function StackLayout:_LayoutHorizontal()
    local xOff = self._padLeft
    local h    = self:GetHeight() - self._padTop - self._padBottom
    for i, ch in ipairs(self._children) do
        ch:ClearAllPoints()
        ch:SetPoint("LEFT", self, "LEFT", xOff, 0)
        if ch.SetHeight then ch:SetHeight(h) end
        xOff = xOff + (ch:GetWidth() or 0) + self._spacing
    end
    local totalW = self:GetTotalWidth()
    self:SetWidth(math.max(1, totalW))
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

--- Creates a vertical StackLayout frame.
---@param parent  Frame
---@param spacing number?
---@return Frame
function lib:CreateVStack(parent, spacing)
    local s = CreateFrame("Frame", nil, parent, "WUILStackLayoutTemplate")
    if spacing then s:SetSpacing(spacing) end
    return s
end

--- Creates a horizontal StackLayout frame.
---@param parent  Frame
---@param spacing number?
---@return Frame
function lib:CreateHStack(parent, spacing)
    local s = CreateFrame("Frame", nil, parent, "WUILHStackLayoutTemplate")
    if spacing then s:SetSpacing(spacing) end
    return s
end

--- WinUILib-Gallery – Pages/LayoutPage.lua
-- Demonstrates StackLayout (VStack / HStack), TabView, ScrollFrame.
-------------------------------------------------------------------------------

local WUIL    = WinUILib
local Gallery = WinUILibGallery

Gallery:RegisterPage("layout", "Layout & Navigation", function(parent)

    local scroll = WUIL:CreateScrollFrame(parent)
    scroll:SetAllPoints()
    local content = scroll:GetScrollChild()
    content:SetWidth(parent:GetWidth() - 32)
    content:SetHeight(900)

    local function Hdr(text, anchor, yOff)
        local h = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        h:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -16)
        h:SetText(text)
        h:SetTextColor(0.95, 0.95, 0.97)
        return h
    end
    local function Note(text, anchor, yOff)
        local d = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        d:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -4)
        d:SetPoint("RIGHT", content, "RIGHT", -24, 0)
        d:SetText(text)
        d:SetTextColor(0.68, 0.68, 0.72)
        d:SetWordWrap(true)
        return d
    end

    -- ── VStack ───────────────────────────────────────────────────────────────
    local topRef = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    topRef:SetPoint("TOPLEFT", content, "TOPLEFT", 24, -16)
    topRef:SetText("VStack (StackLayout, Vertical)")
    topRef:SetTextColor(0.95, 0.95, 0.97)
    local n1 = Note(
        "Children are arranged top-to-bottom with uniform spacing.  "
        .. "The container auto-sizes to its content height.",
        topRef)

    local vstack = WUIL:CreateVStack(content, 8)
    vstack:SetPoint("TOPLEFT", n1, "BOTTOMLEFT", 0, -12)
    vstack:SetWidth(300)

    for i = 1, 4 do
        local btn = WUIL:CreateButton(vstack, "Subtle", "Stack Item " .. i)
        btn:SetHeight(32)
        vstack:AddChild(btn)
    end

    -- ── HStack ───────────────────────────────────────────────────────────────
    local h2  = Hdr("HStack (StackLayout, Horizontal)", vstack, -16)
    local n2  = Note("Children arranged left-to-right.", h2)

    local hstack = WUIL:CreateHStack(content, 8)
    hstack:SetPoint("TOPLEFT", n2, "BOTTOMLEFT", 0, -12)
    hstack:SetHeight(36)

    for i = 1, 4 do
        local btn = WUIL:CreateButton(hstack, "Subtle", "H" .. i)
        btn:SetWidth(60)
        hstack:AddChild(btn)
    end

    -- ── TabView ──────────────────────────────────────────────────────────────
    local h3 = Hdr("TabView", hstack, -16)
    local n3 = Note(
        "Horizontal tab strip with content panels.  Tabs can be selected, "
        .. "and panels fade between each other.",
        h3)

    local tabs = WUIL:CreateTabView(content, 460, 200)
    tabs:SetPoint("TOPLEFT", n3, "BOTTOMLEFT", 0, -12)

    -- Tab 1
    local idx1 = tabs:AddTab("General")
    local pf1  = tabs:GetContentFrame(idx1)
    if pf1 then
        local lbl = pf1:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("CENTER")
        lbl:SetText("General settings would go here.")
        lbl:SetTextColor(0.68, 0.68, 0.72)
    end

    -- Tab 2
    local idx2 = tabs:AddTab("Appearance")
    local pf2  = tabs:GetContentFrame(idx2)
    if pf2 then
        local ts = WUIL:CreateToggleSwitch(pf2, "Dark Mode", "Light Mode")
        ts:SetPoint("CENTER")
        ts:SetWidth(200)
        ts:SetOn(true)
    end

    -- Tab 3
    local idx3 = tabs:AddTab("About")
    local pf3  = tabs:GetContentFrame(idx3)
    if pf3 then
        local lbl = pf3:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("CENTER")
        lbl:SetText("WinUILib v1.0.0  •  MIT License")
        lbl:SetTextColor(0.68, 0.68, 0.72)
    end
end)

--- WinUILib-Gallery – Pages/ButtonPage.lua
-- Demonstrates Button, IconButton, ToggleButton, and related states.
-- Each section mirrors the WinUI Gallery "Buttons" page structure.
-------------------------------------------------------------------------------

local WUIL    = WinUILib
local Gallery = WinUILibGallery

Gallery:RegisterPage("buttons", "Buttons", function(parent)
    local T = WUIL.Tokens

    -- Helper: section header
    local function Header(frame, text, y)
        local h = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        h:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, y)
        h:SetText(text)
        h:SetTextColor(0.95, 0.95, 0.97)
        return h
    end

    -- Helper: description
    local function Desc(frame, text, anchor, yOff)
        local d = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        d:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -4)
        d:SetPoint("RIGHT", frame, "RIGHT", -24, 0)
        d:SetText(text)
        d:SetTextColor(0.68, 0.68, 0.72)
        d:SetWordWrap(true)
        return d
    end

    -- Scroll container
    local scroll = WUIL:CreateScrollFrame(parent)
    scroll:SetAllPoints()
    local content = scroll:GetScrollChild()
    content:SetWidth(parent:GetWidth() - 32)
    content:SetHeight(1)

    -- ── Section 1: Standard Button variants ─────────────────────────────────
    local h1 = Header(content, "Button", -16)
    local d1 = Desc(content,
        "Use a Button to trigger an immediate action.  Choose Accent for primary "
        .. "actions, Subtle for secondary, and Destructive for irreversible actions.",
        h1, -4)

    local btnAccent = WUIL:CreateButton(content, "Accent", "Accent Button")
    btnAccent:SetPoint("TOPLEFT", d1, "BOTTOMLEFT", 0, -12)
    btnAccent:SetWidth(160)
    btnAccent.OnActivated = function(self)
        WUIL:Debug("Accent button clicked")
    end

    local btnSubtle = WUIL:CreateButton(content, "Subtle", "Subtle Button")
    btnSubtle:SetPoint("LEFT", btnAccent, "RIGHT", 8, 0)
    btnSubtle:SetWidth(160)

    local btnDestructive = WUIL:CreateButton(content, "Destructive", "Delete")
    btnDestructive:SetPoint("LEFT", btnSubtle, "RIGHT", 8, 0)
    btnDestructive:SetWidth(120)

    local btnDisabled = WUIL:CreateButton(content, "Subtle", "Disabled")
    btnDisabled:SetPoint("LEFT", btnDestructive, "RIGHT", 8, 0)
    btnDisabled:SetWidth(120)
    btnDisabled:SetEnabled(false)

    -- ── Section 2: ToggleButton ─────────────────────────────────────────────
    local h2 = Header(content, "ToggleButton", -130)
    local d2 = Desc(content,
        "ToggleButton maintains pressed/unpressed state.  Useful for filter chips, "
        .. "view toggles, and toolbar actions.",
        h2, -4)

    local toggle1 = WUIL:CreateToggleButton(content, "Bold")
    toggle1:SetPoint("TOPLEFT", d2, "BOTTOMLEFT", 0, -12)
    toggle1:SetWidth(80)
    toggle1.OnToggled = function(self, checked)
        WUIL:Debug("ToggleButton Bold: " .. tostring(checked))
    end

    local toggle2 = WUIL:CreateToggleButton(content, "Italic")
    toggle2:SetPoint("LEFT", toggle1, "RIGHT", 4, 0)
    toggle2:SetWidth(80)

    local toggle3 = WUIL:CreateToggleButton(content, "Underline")
    toggle3:SetPoint("LEFT", toggle2, "RIGHT", 4, 0)
    toggle3:SetWidth(100)

    -- ── Section 3: States demo ──────────────────────────────────────────────
    local h3 = Header(content, "Button States", -230)
    local d3 = Desc(content,
        "Hover over and click the buttons to observe state transitions driven "
        .. "by the Visual State Machine.",
        h3, -4)

    local stateLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    stateLabel:SetPoint("TOPLEFT", d3, "BOTTOMLEFT", 0, -16)
    stateLabel:SetText("Current state: Normal")
    stateLabel:SetTextColor(0.05, 0.55, 0.88)

    local stateBtn = WUIL:CreateButton(content, "Subtle", "Interact With Me")
    stateBtn:SetPoint("TOPLEFT", stateLabel, "BOTTOMLEFT", 0, -8)
    stateBtn:SetWidth(200)
    local origOnStateChanged = stateBtn.OnStateChanged
    stateBtn.OnStateChanged = function(self, new, prev)
        stateLabel:SetText("Current state: " .. new)
        if origOnStateChanged then origOnStateChanged(self, new, prev) end
    end

    -- Resize scroll child to fit content
    C_Timer.After(0.05, function()
        content:SetHeight(math.max(400, stateBtn:GetBottom()
                                        and (content:GetTop() - stateBtn:GetBottom() + 24)
                                        or 400))
    end)
end)

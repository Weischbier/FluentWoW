--- FluentWoW-Gallery -- Pages/TextBlockPage.lua
-- Mirrors WinUI Gallery TextBlockPage with typography styles.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("TextBlock", function(parent, item)
    local _, _, stack, refresh = Gallery:CreateDemoPage(parent)

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Title")
    header:SetText(item.title)
    stack:AddChild(header)

    local desc = lib:CreateTextBlock(stack)
    desc:SetText(item.description)
    desc:SetColorKey("Color.Text.Secondary")
    desc:SetWrapping(true)
    desc:SetWidth(680)
    stack:AddChild(desc)

    ---------------------------------------------------------------------------
    -- Example 1: TextBlock with typography ramp
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "All TextBlock typography styles.",
        exampleHeight = 320,
        noOutput = true,
        noOptions = true,
    })

    local styles = { "Display", "Header", "Title", "Subtitle", "Body", "BodyBold", "Caption", "Mono" }
    local prevAnchor = ex1.example
    local prevPoint = "TOPLEFT"
    local prevYOff = -16

    for _, style in ipairs(styles) do
        local label = lib:CreateTextBlock(ex1.example)
        label:SetStyle("Caption")
        label:SetColorKey("Color.Text.Tertiary")
        label:SetText(style)
        label:SetPoint("TOPLEFT", prevAnchor, prevPoint == "TOPLEFT" and "TOPLEFT" or "BOTTOMLEFT", prevPoint == "TOPLEFT" and 16 or 0, prevYOff)

        local sample = lib:CreateTextBlock(ex1.example)
        sample:SetStyle(style)
        sample:SetText("The quick brown fox jumps.")
        sample:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)

        prevAnchor = sample
        prevPoint = "BOTTOMLEFT"
        prevYOff = -12
    end

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Wrapping text
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "TextBlock with text wrapping enabled.",
        exampleHeight = 120,
        noOutput = true,
        noOptions = true,
    })

    local wrap = lib:CreateTextBlock(ex2.example)
    wrap:SetStyle("Body")
    wrap:SetWrapping(true)
    wrap:SetWidth(380)
    wrap:SetText("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
    wrap:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 16, -16)

    stack:AddChild(ex2.block)

    refresh()
end)

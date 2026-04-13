--- FluentWoW-Gallery -- Pages/CommandBarPage.lua
-- Mirrors WinUI Gallery CommandBarPage.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local _T = lib.Tokens
local Icons = lib.Icons
local Gallery = lib._gallery

Gallery:RegisterControlPage("CommandBar", function(parent, item)
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
    -- Example 1: Basic CommandBar
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A CommandBar with common commands.",
        exampleHeight = 100,
        noOptions = true,
    })

    local cb = lib:CreateCommandBar(ex1.example)
    cb:SetPoint("TOPLEFT", ex1.example, "TOPLEFT", 12, -12)
    cb:SetPoint("RIGHT", ex1.example, "RIGHT", -12, 0)

    ex1.outputLabel:SetText("")
    cb:SetCommands({
        { key = "add",      icon = Icons.Add,        label = "Add",      tooltip = "Add new item",   onClick = function() ex1.outputLabel:SetText("Add clicked") end },
        { key = "search",   icon = Icons.Search,     label = "Search",   tooltip = "Search items",   onClick = function() ex1.outputLabel:SetText("Search clicked") end },
        { key = "settings", icon = Icons.Settings,   label = "Settings", tooltip = "Open settings",  onClick = function() ex1.outputLabel:SetText("Settings clicked") end },
        { key = "done",     icon = Icons.CheckMark,  label = "Done",     tooltip = "Mark complete",  onClick = function() ex1.outputLabel:SetText("Done clicked") end },
        { key = "cancel",   icon = Icons.Cancel,     label = "Cancel",   tooltip = "Cancel action",  onClick = function() ex1.outputLabel:SetText("Cancel clicked") end },
    })

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: CommandBar with icon-only commands
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A compact CommandBar with icon-only commands.",
        exampleHeight = 100,
        noOutput = true,
        noOptions = true,
    })

    local cb2 = lib:CreateCommandBar(ex2.example)
    cb2:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 12, -12)
    cb2:SetCommands({
        { key = "add",      icon = Icons.Add,        tooltip = "Add",       onClick = function() end },
        { key = "search",   icon = Icons.Search,     tooltip = "Search",    onClick = function() end },
        { key = "settings", icon = Icons.Settings,   tooltip = "Settings",  onClick = function() end },
        { key = "done",     icon = Icons.CheckMark,  tooltip = "Done",      onClick = function() end },
    })

    stack:AddChild(ex2.block)

    refresh()
end)

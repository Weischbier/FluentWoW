--- FluentWoW-Gallery -- Pages/CommandBarPage.lua
-- Mirrors WinUI Gallery CommandBarPage.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
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
        { key = "add",     icon = Icons.Add,     label = "Add",     tooltip = "Add new item",      onClick = function() ex1.outputLabel:SetText("Add clicked") end },
        { key = "edit",    icon = Icons.Edit,     label = "Edit",    tooltip = "Edit selected item", onClick = function() ex1.outputLabel:SetText("Edit clicked") end },
        { key = "delete",  icon = Icons.Delete,   label = "Delete",  tooltip = "Delete item",        onClick = function() ex1.outputLabel:SetText("Delete clicked") end },
        { key = "share",   icon = Icons.Share,    label = "Share",   tooltip = "Share item",         onClick = function() ex1.outputLabel:SetText("Share clicked") end },
        { key = "refresh", icon = Icons.Refresh,  label = "Refresh", tooltip = "Refresh list",       onClick = function() ex1.outputLabel:SetText("Refresh clicked") end },
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
        { key = "copy",  icon = Icons.Copy,  tooltip = "Copy",  onClick = function() end },
        { key = "save",  icon = Icons.Save,  tooltip = "Save",  onClick = function() end },
        { key = "sort",  icon = Icons.Sort,  tooltip = "Sort",  onClick = function() end },
        { key = "filter", icon = Icons.Filter, tooltip = "Filter", onClick = function() end },
    })

    stack:AddChild(ex2.block)

    refresh()
end)

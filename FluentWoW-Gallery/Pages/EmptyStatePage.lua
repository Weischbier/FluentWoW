--- FluentWoW-Gallery -- Pages/EmptyStatePage.lua
-- EmptyState control demonstration.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local _T = lib.Tokens
local Icons = lib.Icons
local Gallery = lib._gallery

Gallery:RegisterControlPage("EmptyState", function(parent, item)
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
    -- Example 1: Basic EmptyState
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "An EmptyState with icon, title, and description.",
        exampleHeight = 220,
        noOutput = true,
        noOptions = true,
    })

    local empty1 = lib:CreateEmptyState(ex1.example)
    empty1:SetIcon(Icons.FolderOpen)
    empty1:SetTitle("No items found")
    empty1:SetDescription("Try adjusting your search or filters to find what you're looking for.")
    empty1:SetPoint("CENTER")

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: EmptyState with action button
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "An EmptyState with an action control.",
        exampleHeight = 240,
        noOptions = true,
    })

    local empty2 = lib:CreateEmptyState(ex2.example)
    empty2:SetIcon(Icons.Search)
    empty2:SetTitle("No results")
    empty2:SetDescription("Your search returned no results.")
    empty2:SetPoint("CENTER")

    local retryBtn = lib:CreateButton(ex2.example, nil, "Accent")
    retryBtn:SetText("Clear search")
    retryBtn:SetOnClick(function()
        ex2.outputLabel:SetText("Action button clicked!")
    end)
    empty2:SetActionControl(retryBtn)

    ex2.outputLabel:SetText("")

    stack:AddChild(ex2.block)

    refresh()
end)

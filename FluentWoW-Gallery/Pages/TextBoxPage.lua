--- FluentWoW-Gallery -- Pages/TextBoxPage.lua
-- Mirrors WinUI Gallery TextBoxPage: simple, header, read-only, multi-line, search.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local _T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("TextBox", function(parent, item)
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
    -- Example 1: Simple TextBox
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A simple TextBox.",
        exampleHeight = 120,
        noOptions = true,
    })

    local tb1 = lib:CreateTextBox(ex1.example)
    tb1:SetPlaceholder("Type here...")
    tb1:SetPoint("TOPLEFT", ex1.example, "TOPLEFT", 16, -16)

    ex1.outputLabel:SetText("")
    tb1:SetOnTextChanged(function(_, text)
        ex1.outputLabel:SetText("Text: " .. text)
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: TextBox with header
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A TextBox with a header.",
        exampleHeight = 140,
    })

    local tb2 = lib:CreateTextBox(ex2.example)
    tb2:SetHeader("Name")
    tb2:SetPlaceholder("Enter your name")
    tb2:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 16, -16)

    ex2.outputLabel:SetText("")
    tb2:SetOnEnterPressed(function(_, text)
        ex2.outputLabel:SetText("Submitted: " .. text)
    end)

    local readonlyCheck = lib:CreateCheckBox(ex2.options)
    readonlyCheck:SetText("Read only")
    readonlyCheck:SetPoint("TOPLEFT", ex2.optionsAnchor, "BOTTOMLEFT", 0, -8)
    readonlyCheck:SetOnChanged(function(_, checked)
        tb2:SetReadOnly(checked)
    end)

    stack:AddChild(ex2.block)

    ---------------------------------------------------------------------------
    -- Example 3: Multi-line TextBox
    ---------------------------------------------------------------------------
    local ex3 = Gallery:CreateControlExample(stack, {
        headerText = "A multi-line TextBox.",
        exampleHeight = 200,
        noOutput = true,
        noOptions = true,
    })

    local tb3 = lib:CreateTextBox(ex3.example)
    tb3:SetHeader("Description")
    tb3:SetPlaceholder("Enter a longer description...")
    tb3:SetMultiline(true, 120)
    tb3:SetPoint("TOPLEFT", ex3.example, "TOPLEFT", 16, -16)
    tb3:SetPoint("RIGHT", ex3.example, "RIGHT", -16, 0)

    stack:AddChild(ex3.block)

    ---------------------------------------------------------------------------
    -- Example 4: SearchBox
    ---------------------------------------------------------------------------
    local ex4 = Gallery:CreateControlExample(stack, {
        headerText = "A SearchBox with placeholder.",
        exampleHeight = 120,
        noOptions = true,
    })

    local sb = lib:CreateSearchBox(ex4.example)
    sb:SetPlaceholder("Search something...")
    sb:SetPoint("TOPLEFT", ex4.example, "TOPLEFT", 16, -16)

    ex4.outputLabel:SetText("")
    sb:SetOnTextChanged(function(_, text)
        ex4.outputLabel:SetText("Query: " .. text)
    end)

    stack:AddChild(ex4.block)

    refresh()
end)

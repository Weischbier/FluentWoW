--- FluentWoW-Gallery -- Pages/SkeletonPage.lua
-- Skeleton shimmer placeholder demonstration.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("Skeleton", function(parent, item)
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
    -- Example 1: Skeleton shapes
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "Skeleton shapes: rect, circle, and line.",
        exampleHeight = 180,
        noOutput = true,
    })

    local rectSkel = lib:CreateSkeleton(ex1.example)
    rectSkel:SetShape("rect")
    rectSkel:SetSize(200, 80)
    rectSkel:SetActive(true)
    rectSkel:SetPoint("TOPLEFT", ex1.example, "TOPLEFT", 16, -16)

    local circleSkel = lib:CreateSkeleton(ex1.example)
    circleSkel:SetShape("circle")
    circleSkel:SetSize(60, 60)
    circleSkel:SetActive(true)
    circleSkel:SetPoint("LEFT", rectSkel, "RIGHT", 24, 0)

    local lineSkel1 = lib:CreateSkeleton(ex1.example)
    lineSkel1:SetShape("line")
    lineSkel1:SetSize(180, 12)
    lineSkel1:SetActive(true)
    lineSkel1:SetPoint("TOPLEFT", rectSkel, "BOTTOMLEFT", 0, -20)

    local lineSkel2 = lib:CreateSkeleton(ex1.example)
    lineSkel2:SetShape("line")
    lineSkel2:SetSize(140, 12)
    lineSkel2:SetActive(true)
    lineSkel2:SetPoint("TOPLEFT", lineSkel1, "BOTTOMLEFT", 0, -8)

    local activeCheck = lib:CreateCheckBox(ex1.options)
    activeCheck:SetText("Active")
    activeCheck:SetChecked(true)
    activeCheck:SetPoint("TOPLEFT", ex1.optionsAnchor, "BOTTOMLEFT", 0, -8)
    activeCheck:SetOnChanged(function(_, checked)
        rectSkel:SetActive(checked)
        circleSkel:SetActive(checked)
        lineSkel1:SetActive(checked)
        lineSkel2:SetActive(checked)
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Card skeleton layout
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A skeleton layout mimicking a card.",
        exampleHeight = 160,
        noOutput = true,
        noOptions = true,
    })

    local cardFrame = Gallery:CreateSurface(ex2.example)
    cardFrame:SetSize(300, 120)
    cardFrame:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 16, -16)

    local avatar = lib:CreateSkeleton(cardFrame)
    avatar:SetShape("circle")
    avatar:SetSize(48, 48)
    avatar:SetActive(true)
    avatar:SetPoint("TOPLEFT", cardFrame, "TOPLEFT", 12, -12)

    local nameLine = lib:CreateSkeleton(cardFrame)
    nameLine:SetShape("line")
    nameLine:SetSize(140, 14)
    nameLine:SetActive(true)
    nameLine:SetPoint("TOPLEFT", avatar, "TOPRIGHT", 12, 0)

    local detailLine = lib:CreateSkeleton(cardFrame)
    detailLine:SetShape("line")
    detailLine:SetSize(100, 10)
    detailLine:SetActive(true)
    detailLine:SetPoint("TOPLEFT", nameLine, "BOTTOMLEFT", 0, -8)

    local bodyLine1 = lib:CreateSkeleton(cardFrame)
    bodyLine1:SetShape("line")
    bodyLine1:SetSize(260, 10)
    bodyLine1:SetActive(true)
    bodyLine1:SetPoint("TOPLEFT", avatar, "BOTTOMLEFT", 0, -16)

    local bodyLine2 = lib:CreateSkeleton(cardFrame)
    bodyLine2:SetShape("line")
    bodyLine2:SetSize(220, 10)
    bodyLine2:SetActive(true)
    bodyLine2:SetPoint("TOPLEFT", bodyLine1, "BOTTOMLEFT", 0, -6)

    stack:AddChild(ex2.block)

    refresh()
end)

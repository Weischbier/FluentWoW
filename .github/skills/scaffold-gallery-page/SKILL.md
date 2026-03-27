---
name: scaffold-gallery-page
description: >
  Create or update a FluentWoW-Gallery page to showcase a control family.
  Produces the Lua page file, registers it in Gallery.lua, and updates the TOC.
---

# scaffold-gallery-page

## When to Use

- After a new control has been scaffolded and is working
- When adding a new variant or example to an existing Gallery page
- To create a dedicated page for a control family

## Prerequisites

1. The control must already be created (XML, Lua, TOC, factory method)
2. Read an existing page for reference: `FluentWoW-Gallery/Pages/ButtonPage.lua`

## Inputs

| Input | Required | Description |
|---|---|---|
| `pageName` | Yes | e.g., `NavigationViewPage` |
| `controlNames` | Yes | Controls to demo, e.g., `NavigationView, BreadcrumbBar` |
| `isNewPage` | Yes | `true` for new page, `false` for adding to existing |

## Steps

### 1. Read Existing Pattern

Read `FluentWoW-Gallery/Pages/ButtonPage.lua` for the canonical page pattern:
- Page setup function
- Section creation with TextBlock headers
- Control instantiation via factory methods
- StackLayout arrangement

Also reference the WinUI Gallery XAML source for the equivalent page:
- `.help/.sources/WinUI-Gallery-main/fwow/Samples/ControlPages/{controlName}Page.xaml`
- Match demo structure and variants as closely as possible

### 2. Create Page File

Create `FluentWoW-Gallery/Pages/{pageName}.lua`:
- Use StackLayout for top-level arrangement
- Add TextBlock section headers
- Create all variants of each control
- Show enabled + disabled states
- Add interactive callbacks that print to chat (for testing)

### 3. Register in Gallery

Update `FluentWoW-Gallery/Gallery.lua`:
- Add sidebar navigation entry for the new page
- Maintain alphabetical order in the sidebar

### 4. Update TOC

Add to `FluentWoW-Gallery/FluentWoW-Gallery.toc`:
```
Pages/{pageName}.lua
```

## Outputs

| Output | Path |
|---|---|
| Page file | `FluentWoW-Gallery/Pages/{pageName}.lua` |
| Gallery.lua | Modified — sidebar entry added |
| TOC | Modified — page listed |

## Failure Modes

| Failure | Recovery |
|---|---|
| Control factory method missing | Run `scaffold-control` first |
| Gallery.lua pattern unclear | Read `Gallery.lua` fully; look for page registration pattern |

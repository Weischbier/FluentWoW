---
name: assess-portability
description: >
  Assess whether a WinUI control can be ported to WoW and update the Portability Matrix.
  Reads XAML source, specs, and WoW API to produce a rating and strategy.
---

# assess-portability

## When to Use

- Before porting any control not yet assessed in `.docs/PortabilityMatrix.md`
- When the user requests a portability review for a specific control

## Prerequisites

1. Access to `.help/.sources/WinUI-Gallery-main/fwow/Samples/ControlPages/`
2. Access to `.help/.sources/microsoft-ui-xaml-main/specs/` (when available)
3. wow-api MCP server available for WoW API verification

## Inputs

| Input | Required | Description |
| --- | --- | --- |
| `controlName` | Yes | WinUI control name, e.g., `TreeView` |

## Steps

### 1. Read WinUI Source

- Open `.help/.sources/WinUI-Gallery-main/fwow/Samples/ControlPages/{controlName}Page.xaml`
- Open the `.xaml.cs` code-behind if it exists
- Optionally read the spec: `.help/.sources/microsoft-ui-xaml-main/specs/{controlName}/`
- View design images: `.help/.sources/WinUI-Gallery-main/fwow/Assets/Design/` for visual measurements
- Read `.docs/DesignSpecs.md` for already-extracted pixel measurements
- Identify: visual states, properties, events, child elements, data binding, animations

### 2. Identify WoW Barriers

Check each feature against WoW capabilities:
- **Data binding** → Not available; manual property setters needed
- **XAML triggers / VisualStateManager** → StateMachine replaces this
- **Connected animations** → Not available; simple Motion presets only
- **System resources** → Token system replaces this
- **Nested ScrollViewers** → Limited; WoW ScrollFrame is basic
- **Multi-window** → Not possible; single UI layer
- **Drag-and-drop** → Partial; WoW has basic drag support for specific widget types
- **RichTextBlock / hyperlinks** → Limited; SimpleHTML or FontString only
- **TreeView with data** → Manual tree building required

### 3. Verify WoW APIs

Use MCP tools:
- `mcp_wow-api_get_widget_methods` — check base widget capabilities
- `mcp_wow-api_search_api` — search for relevant functions
- `mcp_wow-api_get_event` — check for useful WoW events

### 4. Rate Portability

| Rating | Meaning | Action |
| --- | --- | --- |
| ✅ Direct | All features map cleanly | Port as-is |
| ⚠️ Adapted | Core features portable, some adapted/dropped | Port with documented compromises |
| ❌ Not viable | Core functionality impossible in WoW | Skip; document why |

### 5. Update Matrix

Update `.docs/PortabilityMatrix.md`:
- Set the status column
- Add the WoW strategy/notes
- Record any feature gaps

## Outputs

| Output | Description |
| --- | --- |
| Rating | ✅, ⚠️, or ❌ |
| Strategy | How to implement in WoW (widget type, compromises) |
| Matrix update | `.docs/PortabilityMatrix.md` row updated |

## Failure Modes

| Failure | Recovery |
| --- | --- |
| XAML file not found in `.help/.sources/` | Search for alternate naming; control may be in a subfolder or named differently |
| MCP server unavailable | Fall back to `.help/.helper/AddOns/Blizzard_*` and ketho.wow-api annotations |

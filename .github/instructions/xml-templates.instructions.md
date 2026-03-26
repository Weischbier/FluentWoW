---
applyTo: "**/*.xml"
---

# XML Template Rules

## Naming

- Template name: `WUIL<ControlName>Template`
- Always set `virtual="true"` on the template
- Child frames: `$parent_<PartName>` (e.g., `$parent_Label`, `$parent_Overlay`, `$parent_Thumb`)
- Always include `parentKey` attribute matching the part name

## Structure

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
    <Frame name="WUIL<Name>Template" virtual="true" inherits="BackdropTemplate">
        <Size x="200" y="32"/>
        <Layers>
            <Layer level="ARTWORK">
                <FontString name="$parent_Label" parentKey="Label"
                    inherits="GameFontNormal" justifyH="LEFT">
                    <Anchors>
                        <Anchor point="LEFT" x="12" y="0"/>
                    </Anchors>
                </FontString>
            </Layer>
        </Layers>
        <Scripts>
            <OnLoad function="WUIL<Name>_OnLoad"/>
        </Scripts>
    </Frame>
</Ui>
```

## Prohibited in XML

- **No inline Lua** — all behavior goes in the `.lua` file
- **No hardcoded colors** — use neutral values; Lua applies tokens at runtime
- **No `inherits` from secure templates** — prevents taint (unless explicitly needed and combat-guarded)

## Widget Type Selection

| Use Case | WoW Widget | Notes |
|---|---|---|
| Clickable control | `Button` | Has native OnClick |
| Text input | `EditBox` | WoW's only text input |
| Range input | `Slider` | Native slider widget |
| Scrollable area | `ScrollFrame` | Native scroll support |
| Container/layout | `Frame` | General-purpose |
| Status bar | `StatusBar` | Built-in fill behavior |

## Load Order

In the TOC file, XML files MUST be listed before their corresponding Lua files:
```
Controls/MyControl/MyControl.xml
Controls/MyControl/MyControl.lua
```

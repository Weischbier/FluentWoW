# WinUILib — Design Specifications

> Pixel-accurate measurements extracted from the WinUI Gallery design reference images
> and spec catalog from `.help/.sources/microsoft-ui-xaml-main/specs/`.
>
> **Rule: Every spacing, padding, margin, gap, and size value in WinUILib controls
> MUST match the WinUI spec pixel values exactly.** No approximations.

---

## 1. Spec File Catalog

All WinUI specification documents available in `.help/.sources/microsoft-ui-xaml-main/specs/`:

| Spec | Path | Relevance |
|---|---|---|
| InfoBadge | `specs/InfoBadge/InfoBadge-spec.md` | ⚠️ Portable — dot (4×4), icon/numeric (16×16) |
| ScrollView | `specs/ScrollingControls/ScrollView.md` | ⚠️ Reference — WoW uses native ScrollFrame |
| ScrollPresenter | `specs/ScrollingControls/ScrollPresenter.md` | ⚠️ Reference — low-level scroll engine |
| ColorPicker | `specs/ColorPicker/ColorPicker.Orientation.md` | ⚠️ Adapted — complex widget |
| CalendarView | `specs/CalendarView/CalendarViewSpec1.md` | ❌ Not viable — too complex for WoW |
| TitleBar | `specs/TitleBar/titleBar-dev-spec.md` | ⚠️ Adapted — WoW has no window chrome |
| TitleBar (functional) | `specs/TitleBar/titlebar-functional-spec.md` | Reference only |
| TitleBar (draggable) | `specs/TitleBar/titleBar-content-draggable-spec.md` | Reference only |
| WrapPanel | `specs/WCT/Primitives/WrapPanel.md` | ✅ Portable — layout container |
| SplitMenuFlyoutItem | `specs/SplitMenuFlyoutItem/SplitMenuFlyoutItem-spec.md` | ⚠️ Adapted |
| AnimatedVisualPlayer | `specs/AnimatedVisualPlayer Spec.md` | ❌ Not viable — Lottie/Composition |
| Popup Layout Props | `specs/Popup-AdditionalLayoutProperties-Spec.md` | Reference — popup positioning |
| CustomCondition | `specs/CustomCondition/CustomCondition-Spec.md` | Reference — VSM conditions |
| DateTimePicker Visual | `specs/DateTimePicker-Visual-Updates-Spec.md` | ⚠️ Adapted |
| AppWindow | `specs/appwindow-spec.md` | ❌ Not viable — desktop windowing |
| NavView OpenPaneLength | `specs/NavigationViewTemplateSettings-OpenPaneLength.md` | ✅ Portable — NavigationView sizing |
| FooterMenuItemTemplate | `specs/FooterMenuItemTemplate-spec.md` | ✅ Portable — NavigationView footer |
| SystemBackdrop | `specs/SystemBackdropElement_Spec.md` | Reference — Mica/Acrylic backdrop |
| XAML Backdrop API | `specs/xaml-backdrop-api.md` | Reference — backdrop theming |
| Resource References | `specs/xaml-resource-references-tracing-spec.md` | Reference — resource resolution |

## 2. Design Image Pixel Measurements

Source images: `.help/.sources/WinUI-Gallery-main/WinUIGallery/Assets/Design/`

### 2.1 Cards (Cards.dark.png / Cards.light.png)

The "Cards" image shows a **SettingsCard / content card** layout with exact pixel annotations.

#### Card-Level Measurements

| Measurement | Value (px) | Token Mapping | Notes |
|---|---|---|---|
| Title top margin (above card) | 40 | — | Spacing from section title to first card |
| Card-to-card vertical gap | 36 | — | Gap between stacked cards |
| Card internal top padding | 12 | `Spacing.LG` | From card top edge to subtitle |
| Card internal bottom padding | 16 | `Spacing.XL` | From last element to card bottom edge |
| Card internal left padding | 16 | `Spacing.XL` | From card left edge to content |
| Card internal right padding | 16 | `Spacing.XL` | From content to card right edge |

#### Content-Area Measurements

| Measurement | Value (px) | Token Mapping | Notes |
|---|---|---|---|
| Subtitle to body text gap | 16 | `Spacing.XL` | Below subtitle+caption to body text |
| Icon-to-subtitle gap | 12 | `Spacing.LG` | From icon right edge to subtitle text |
| Body text to content area gap | 16 | `Spacing.XL` | Body text to media/content rectangle |
| Footer/action bar height (text row) | — | — | Contains radio/text action row |
| Action icon-to-text gap | 8 | `Spacing.MD` | Radio button circle to "Text" label |

#### Summary: Card Padding Box

```
┌──────────────────────────────────────┐
│ 12px top                             │
│  ┌──────────────────────────────┐    │
│  │ [Icon] 12px [Subtitle]      │    │ 16px right
│  │         [Caption]            │    │
│  │                              │    │
│  │ 16px gap                     │    │
│  │                              │    │
│  │ Body text...                 │    │
│  │                              │    │
│  │ 16px gap                     │    │
│  │                              │    │
│  │ [ Content Area ]             │    │
│  │                              │    │
│  │ [○ Text]   8px icon-to-text  │    │
│  └──────────────────────────────┘    │
│ 16px bottom                          │
│ 16px left                            │
└──────────────────────────────────────┘
```

### 2.2 ContentDialog (Dialog.dark.png / Dialog.light.png)

The "Dialog" image shows a **ContentDialog** with exact pixel annotations for all spacing.

#### Dialog-Level Measurements

| Measurement | Value (px) | Token Mapping | Notes |
|---|---|---|---|
| Title top padding | 32 | `Spacing.XXXL` | From dialog top edge to title baseline area |
| Title to body text gap | 24 | `Spacing.XXL` | From title bottom to body text top |
| Body text to "Learn more" link gap | 20 | — | Between paragraph and link |
| Form field section gap | 16 | `Spacing.XL` | Between form field rows |
| Form field label (Header) to input gap | — | — | "Header" label sits directly above input |
| Input field internal left padding | — | — | Text "Text" left-aligned inside field |
| Button row top gap | 24 | `Spacing.XXL` | From last content to button row |
| Button row bottom padding | 24 | `Spacing.XXL` | From button row bottom to dialog edge |
| Inter-button gap | 8 | `Spacing.MD` | Between OK and Cancel buttons |
| Form field gap (side-by-side) | 24 | `Spacing.XXL` | Horizontal gap between two form fields |
| Input with suffix button gap | 8 | `Spacing.MD` | Input field to adjacent "Text" button |
| Dropdown (ComboBox) min height | 12 | `Spacing.LG` | Section labeled "12" above small dropdown |

#### Summary: ContentDialog Padding Box

```
┌──────────────────────────────────────────┐
│ 32px top                                 │
│                                          │
│  Title                                   │
│                                          │
│ 24px gap                                 │
│                                          │
│  Body text paragraph...                  │
│  "Learn more" link                       │
│                                          │
│ 20px gap                                 │
│                                          │
│  Short body text                         │
│  "Learn more" link                       │
│                                          │
│  Header          Header                  │
│  [  Text  ] 24px [Text      v]           │
│                                          │
│ 16px gap                                 │
│                                          │
│  Header                                  │
│  [  Text          ] 8px [Text]           │
│                                          │
│ 12px gap                                 │
│                                          │
│  Header                                  │
│  [Text  v]                               │
│                                          │
│ 24px gap                                 │
│                                          │
│  [    OK    ] 8px [   Cancel   ]         │
│                                          │
│ 24px bottom                              │
└──────────────────────────────────────────┘
```

### 2.3 Geometry (Geometry.dark.png / Geometry.light.png)

The "Geometry" image shows a **standard content panel/dialog** with rounded corners. No pixel annotations — this is a visual reference for the card/dialog shape with:
- Title text + body text + two buttons (primary accent + secondary)
- Rounded corners (matches `Radii.LG`)
- Button row at bottom, side by side
- Card shadow/elevation effect

### 2.4 Typography (Typography.dark.png / Typography.light.png)

The "Typography" image shows a **Windows Settings page** (Power & battery). This is a visual reference for:
- Settings page layout with breadcrumb header ("System > Power & battery")
- Settings card list with icon + title + description + trailing control
- SettingsExpander with chevron (Screen and sleep)
- SettingsCard with ComboBox action control (Power mode)
- Section header text style ("Power")

## 3. Pixel-Fidelity Rule

**This is a non-negotiable design rule for all WinUILib controls.**

Every control MUST match the WinUI spec pixel measurements exactly:
- Padding, margin, gap, and size values from Section 2 above
- Sizes from individual control specs in the catalog (Section 1)
- Values come from tokens where a token exists (see Token Mapping columns)
- Where no token exists, use the literal pixel value and document it

### Verification Checklist

When implementing or reviewing a control, verify:
- [ ] Internal padding matches spec (top, right, bottom, left)
- [ ] Inter-element gaps match spec
- [ ] Icon sizes match spec
- [ ] Minimum sizes match spec
- [ ] Font sizes match spec type ramp
- [ ] Corner radii match spec

### Token Mapping Quick Reference

| Spec Pixel Value | Token |
|---|---|
| 2px | `Spacing.XS` |
| 4px | `Spacing.SM` |
| 8px | `Spacing.MD` |
| 12px | `Spacing.LG` |
| 16px | `Spacing.XL` |
| 24px | `Spacing.XXL` |
| 32px | `Spacing.XXXL` |
| 40px | — (use literal or add `Spacing.XXXXL`) |
| 36px | — (use literal or add `Spacing.InterCard`) |

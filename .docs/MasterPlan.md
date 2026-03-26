# WinUILib — Master Plan

> Root orchestration document. Single source for project status, porting progress, phase tracking, and source-of-truth hierarchy.

---

## 1. Mission

Port the spirit, quality bar, and design language of WinUI 3 + WinUI Gallery + Windows Community Toolkit into the World of Warcraft addon ecosystem as a reusable, token-driven, combat-safe UI framework library.

## 2. Source-of-Truth Hierarchy

| Rank | Source | Authority | Scope |
|---|---|---|---|
| 1 | WoW API runtime (`.help/.helper/AddOns/Blizzard_*` + wow-api MCP) | Platform truth | Frame API, combat lockdown, taint rules |
| 2 | Design rules (`.docs/DesignRules.md`, ARCHITECTURE.md §16) | Project law | Non-negotiable coding constraints |
| 3 | ARCHITECTURE.md | Project truth | Module boundaries, token system, control catalog, roadmap |
| 4 | WinUI specs (`.help/.sources/microsoft-ui-xaml-main/specs/`) | Design reference | Control behavior, visual design |
| 5 | WinUI Gallery (`.help/.sources/WinUI-Gallery-main/`) | Implementation reference | XAML samples, Gallery pages |
| 6 | Ace3 / community libs (`.help/.helper/Libs/`) | Compatibility reference | Integration patterns |
| 7 | User (Danny) | Supreme override | Any decision |

**Conflict resolution**: If sources disagree, higher-ranked source wins. If WoW API makes a WinUI behavior impossible, document the divergence in the control's Lua file header and in the Portability Matrix.

## 3. Phase Status

| Phase | Name | Status |
|---|---|---|
| 0 | Research & feasibility | ✅ Complete |
| 1 | Core runtime + tokens + MVP controls | ✅ Complete (19 controls) |
| 2 | Navigation + advanced layout | 🔲 Not started |
| 3 | Advanced controls + motion polish | 🔲 Not started |
| 4 | Gallery + docs expansion | 🔲 Not started |
| 5 | Hardening + adoption prep | 🔲 Not started |

## 4. Control Inventory

### Implemented (Phase 1)

| Control | Template | Folder | Gallery Page | Status |
|---|---|---|---|---|
| Button (Accent/Subtle/Destructive) | `WUILButtonTemplate` | `Controls/Button/` | `ButtonPage.lua` | ✅ |
| IconButton | `WUILIconButtonTemplate` | `Controls/Button/` | `ButtonPage.lua` | ✅ |
| ToggleButton | `WUILToggleButtonTemplate` | `Controls/Button/` | `ButtonPage.lua` | ✅ |
| CheckBox | `WUILCheckBoxTemplate` | `Controls/CheckBox/` | `InputPage.lua` | ✅ |
| RadioButton | `WUILRadioButtonTemplate` | `Controls/RadioButton/` | `InputPage.lua` | ✅ |
| ToggleSwitch | `WUILToggleSwitchTemplate` | `Controls/ToggleSwitch/` | `InputPage.lua` | ✅ |
| TextBlock | `WUILTextBlockTemplate` | `Controls/TextBlock/` | `InputPage.lua` | ✅ |
| TextBox | `WUILTextBoxTemplate` | `Controls/TextBox/` | `InputPage.lua` | ✅ |
| SearchBox | `WUILSearchBoxTemplate` | `Controls/TextBox/` | `InputPage.lua` | ✅ |
| Slider | `WUILSliderTemplate` | `Controls/Slider/` | `InputPage.lua` | ✅ |
| ComboBox | `WUILComboBoxTemplate` | `Controls/ComboBox/` | `InputPage.lua` | ✅ |
| ProgressBar | `WUILProgressBarTemplate` | `Controls/ProgressBar/` | `FeedbackPage.lua` | ✅ |
| ProgressRing | `WUILProgressRingTemplate` | `Controls/ProgressBar/` | `FeedbackPage.lua` | ✅ |
| InfoBar | `WUILInfoBarTemplate` | `Controls/InfoBar/` | `FeedbackPage.lua` | ✅ |
| ContentDialog | `WUILContentDialogTemplate` | `Controls/ContentDialog/` | `FeedbackPage.lua` | ✅ |
| Expander | `WUILExpanderTemplate` | `Controls/Expander/` | `FeedbackPage.lua` | ✅ |
| TabView | `WUILTabViewTemplate` | `Controls/TabView/` | `LayoutPage.lua` | ✅ |
| ScrollFrame | `WUILScrollFrameTemplate` | `Controls/ScrollFrame/` | `LayoutPage.lua` | ✅ |
| StackLayout (VStack/HStack) | `WUILStackLayoutTemplate` | `Layout/` | `LayoutPage.lua` | ✅ |
| SettingsCard | `WUILSettingsCardTemplate` | `Settings/` | `SettingsPage.lua` | ✅ |
| SettingsExpander | `WUILSettingsExpanderTemplate` | `Settings/` | `SettingsPage.lua` | ✅ |

### Porting Queue (from `.help/.sources/WinUI-Gallery-main/`)

See `.docs/PortabilityMatrix.md` for the full assessment of all 107 WinUI Gallery controls, including portability ratings, WoW strategies, and blockers.

## 5. Key Documents

| Document | Purpose |
|---|---|
| `.docs/MasterPlan.md` | This file — root orchestration |
| `.docs/DesignRules.md` | 10 non-negotiable rules + combat safety |
| `.docs/ControlPortingGuide.md` | Step-by-step porting workflow |
| `.docs/PortabilityMatrix.md` | Per-control portability assessment |
| `.docs/TokenReference.md` | Complete token catalog |
| `.docs/ReviewMaster.md` | Code review orchestration |
| `.docs/AuditMaster.md` | Codebase audit orchestration |
| `.docs/DebugMaster.md` | WoW runtime debugging playbooks |
| `.docs/ReleaseMaster.md` | Release and packaging workflow |
| `ARCHITECTURE.md` | Full architecture reference (public) |
| `README.md` | Consumer quick start (public) |
| `CHANGELOG.md` | Release history (public) |

## 6. Agent Registry

| Agent | Role | Primary Docs |
|---|---|---|
| `control-builder` | Port WinUI controls to WoW XML+Lua | ControlPortingGuide, PortabilityMatrix |
| `token-builder` | Create/modify tokens and themes | TokenReference, DesignRules |
| `reviewer` | Review changes against design rules | ReviewMaster, DesignRules |
| `auditor` | Sweep codebase for rule violations | AuditMaster, DesignRules |
| `debugger` | Investigate WoW runtime issues | DebugMaster |
| `docs-builder` | Maintain docs, catalog, changelog | MasterPlan, ControlPortingGuide |

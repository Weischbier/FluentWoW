---
name: wiki-builder
description: >
  Create, update, and maintain the FluentWoW GitHub Wiki.
  Ensures all wiki pages stay accurate and synchronized with the
  implementation, token system, control APIs, and internal documentation.
---

# wiki-builder

## Role

You are the Wiki Builder — responsible for keeping the FluentWoW GitHub Wiki accurate, complete, and synchronized with the codebase. The wiki is the **public-facing documentation** for addon developers consuming FluentWoW.

## Managed Pages

All files live in `wiki/` at the repository root.

### Navigation

| Page | Purpose |
|---|---|
| `Home.md` | Landing page, feature summary, quick-nav table |
| `_Sidebar.md` | GitHub Wiki sidebar navigation structure |

### Getting Started & Reference

| Page | Purpose | Update Triggers |
|---|---|---|
| `Getting-Started.md` | Installation, TOC dependency, first-control tutorial | New factory methods, API changes |
| `API-Reference.md` | Quick-ref table of all factory methods + modules | Any factory added/removed/renamed |
| `Controls-Overview.md` | Catalog of all controls with templates + status | Control added/removed, status change |

### Control Pages

| Page | Controls Covered | Update Triggers |
|---|---|---|
| `Button.md` | Button (Accent/Subtle/Destructive), IconButton, ToggleButton | Button API changes, new variants |
| `Input-Controls.md` | CheckBox, RadioButton, ToggleSwitch, TextBox, SearchBox, Slider, ComboBox | Input control API changes |
| `Feedback-Controls.md` | ProgressBar, ProgressRing, InfoBar, ContentDialog | Feedback control API changes |
| `Navigation-Controls.md` | MainFrame, TabView, Expander, ScrollFrame | Nav control API changes |
| `Layout.md` | StackLayout (VStack/HStack) | Layout API changes, new layout primitives |
| `Settings-Controls.md` | SettingsCard, SettingsExpander | Settings control API changes |

### Framework Pages

| Page | Purpose | Update Triggers |
|---|---|---|
| `Token-System.md` | Token architecture, resolution, complete reference | Token added/removed/renamed, value changes |
| `Theming.md` | Dark/Light themes, custom themes, overrides, persistence | New themes, API changes |
| `Motion-and-Animation.md` | Tween API, presets, easing functions | New presets, API changes |
| `Core-Modules.md` | EventBus, StateMachine, FramePool, Utils | Module API changes |
| `Icons.md` | Segoe Fluent Icons glyph map, sizing | New icons, font changes |

### Supplementary Pages

| Page | Purpose | Update Triggers |
|---|---|---|
| `Gallery.md` | Gallery addon usage, page registration | New gallery pages |
| `Design-Principles.md` | WinUI→WoW translation matrix, design rules | Rule changes (rare) |
| `FAQ.md` | Common issues, combat lockdown, debugging | New known issues, pattern changes |

## Source-of-Truth Hierarchy

1. **Codebase** — always read the actual Lua/XML implementation files
2. **Existing wiki pages** — understand current state before editing
3. **ARCHITECTURE.md** — structural overview and module boundaries
4. **CHANGELOG.md** — version history and recent changes
5. **`.docs/` files** — internal specs (DesignRules, TokenReference, PortabilityMatrix)

## Workflow

### When a New Control Is Added

1. Read the new control's `.lua` and `.xml` files to extract the full public API
2. Determine which wiki page the control belongs to (or create a new page if it's a new category)
3. Add the control to the appropriate control page with:
   - Factory method and signature
   - Creation example with code block
   - Complete API table (methods, parameters, returns, description)
   - Callbacks table
   - Visual states
   - Any special notes (combat safety, animation, etc.)
4. Update `Controls-Overview.md` — add row to the appropriate category table
5. Update `API-Reference.md` — add factory method to the reference table
6. Update `Getting-Started.md` if the control is commonly used in tutorials
7. Update `_Sidebar.md` if a new page was created
8. Update `Home.md` control count and feature summary if needed

### When Tokens Change

1. Read `Tokens/DefaultTheme.lua` and `Tokens/LightTheme.lua` for current values
2. Update `Token-System.md` — add/remove/modify token entries in the reference tables
3. Update `Theming.md` if the change affects theme structure or examples
4. Check all control pages for code examples referencing changed token keys

### When a Control's API Changes

1. Read the control's `.lua` file to confirm the new API surface
2. Update the relevant control page (method table, examples, notes)
3. Update `API-Reference.md` if factory signature changed
4. Update `FAQ.md` if the change resolves or creates a known issue

### When a New Gallery Page Is Added

1. Update `Gallery.md` — add row to the pages table
2. Ensure the featured controls are documented in their respective wiki pages

### When a Theme Is Added or Modified

1. Read the theme `.lua` file
2. Update `Theming.md` — document the new theme in the built-in themes table
3. Update `Token-System.md` if the theme introduces new token categories

## Content Rules

### Style

- **Consumer-facing** — write for addon developers consuming FluentWoW, not framework maintainers
- **Code-first** — every control page must have working creation examples
- **Complete API tables** — method, parameters, returns, description columns
- **Consistent structure** — every control section follows: Creation → API → Callbacks → Visual States → Notes
- **Cross-link** — link related pages using `[Page Title](Page-Name)` wiki syntax
- **Markdown tables** — use tables for inventories, API references, token lists
- **Code blocks** — use `lua` fenced code blocks for all examples

### Accuracy

- **Never guess APIs** — always read the actual `.lua` file before documenting a method
- **Verify factory signatures** — check parameter order and types against the actual `function lib:Create*` definition
- **Verify token keys** — check token names against `DefaultTheme.lua`
- **Match code examples to current API** — no stale method names or signatures

### Completeness

- Every public factory method must appear in `API-Reference.md`
- Every control must appear in `Controls-Overview.md`
- Every token must appear in `Token-System.md`
- Every control's full method table must be in its category page
- Callback setters must list the callback signature (parameter names and types)

## Verification Checklist

After any wiki update, verify:

- [ ] `Controls-Overview.md` control count matches actual `Controls/` directory
- [ ] `API-Reference.md` factory list matches all `function lib:Create*` in codebase
- [ ] `Token-System.md` token list matches `DefaultTheme.lua`
- [ ] `_Sidebar.md` lists all wiki pages
- [ ] `Home.md` feature count is accurate
- [ ] No broken `[text](Page-Name)` links between pages
- [ ] All code examples use current method names and signatures
- [ ] No stale control names, removed methods, or outdated parameters

## Adding a New Wiki Page

1. Create `wiki/{Page-Name}.md` using kebab-case naming
2. Add the page to `_Sidebar.md` in the appropriate section
3. Add a link from `Home.md` quick-nav table
4. Cross-link from related pages

## Summary

<!-- Brief description of what this PR does -->

## Changes

<!-- List the changes made -->

-

## Design Rules Checklist

- [ ] **Rule 1** — No secure frames / SecureActionButtonTemplate
- [ ] **Rule 2** — Token-only color and spacing (no hardcoded values)
- [ ] **Rule 3** — Relative anchoring via SetPoint (no absolute positions)
- [ ] **Rule 4** — Combat-safe (InCombatLockdown guards where needed)
- [ ] **Rule 5** — StateMachine for all visual-state controls
- [ ] **Rule 6** — No OnUpdate orphans (nil handler when done)
- [ ] **Rule 7** — FramePool for dynamic child frames
- [ ] **Rule 8** — Global namespace via FluentWoW table only
- [ ] **Rule 9** — Version negotiation untouched (or explicitly reviewed)
- [ ] **Rule 10** — Public API stability (no breaking changes without deprecation)

## Testing

- [ ] Works at UI scale 0.64
- [ ] Works at UI scale 1.5
- [ ] No lua errors in `/run BugSack` or error frame
- [ ] Gallery page demonstrates the change (if applicable)

## Documentation

- [ ] ARCHITECTURE.md updated (if structural change)
- [ ] CHANGELOG.md updated
- [ ] PortabilityMatrix updated (if new control)
- [ ] MasterPlan updated (if new control)

# S21.2 — UX Polish Bundle Sprint Plan

**Sprint:** S21.2
**Arc:** Arc B — Content & Feel (S21)
**Issues:** brott-studio/battlebrotts-v2#103, #104, #107
**Author:** Ett (Sprint Planner)
**Date:** 2026-04-23
**Design source:** `studio-framework/design/2026-04-23-s21.2-ux-bundle.md` (Gizmo, PR #55, branch `design/s21.2-ux-bundle`, auto-merge enabled)
**Vision doc:** `docs/kb/ux-vision.md` (Eve-from-WALL-E pillars)
**Predecessor sub-sprint:** S21.1 (Bronze content, Grade A−, audit `studio-audits` blob `f01152c1`)

---

## Scope

- **Issues bundled:** #103 (visible-by-default tooltips), #104 (UI overlap fix at full inventory/loadout), #107 (first-encounter HUD explanations)
- **Single PR against `brott-studio/battlebrotts-v2/main`** (no split — see §Split decision)
- **Implementation order:** #104 → #103 → #107 (per Gizmo's design doc, "Recommended Nutts implementation order" + #103 caption-height pressure forcing #104 scroll wrapper)
- **Out of scope:** anything in Gizmo design doc §"Out of scope for S21.2" (tooltip content quality beyond the 6 critical conversions, random-event popup redesign, league-progression-path surfacing, motion-curve audit, audio, combat-screen content changes)

---

## Tasks

### T1 — #104 ScrollContainer wrapper (BrottbrainScreen tray + OpponentSelectScreen list)

**Nutts spec — ships:**
- `BrottbrainScreen`: insert `ScrollContainer` named `TrayScroll` at position `(0, 365)` size `(1280, 280)`, vertical-only (`SCROLL_MODE_AUTO`), `horizontal_scroll_mode = SCROLL_MODE_DISABLED`, `follow_focus = true`. Move WHEN/THEN tray content (`tray_hdr`, trigger row + buttons, action row + buttons) into a `Control` content child sized `Vector2(1260, computed_height)`. Footer buttons (back at `(20, 650)`, Fight! at `(1050, 650)`) stay siblings of `TrayScroll` — **not children**.
- `OpponentSelectScreen`: insert `ScrollContainer` named `ListScroll` at position `(0, 60)` size `(1280, 580)`. Move opponent panel for-loop content into a `Control` content child sized `Vector2(1260, 40 + count * 130)`. Back button stays sibling at `(20, 650)`.
- Existing `card_scroll` in BrottbrainScreen (S17.4-002) untouched. `LoadoutScreen` / `ShopScreen` (already scrolled in S17.1-002 / S17.1-001) untouched.
- Files touched: `godot/ui/brottbrain_screen.gd`, `godot/ui/brottbrain_screen.tscn`, `godot/ui/opponent_select_screen.gd`, `godot/ui/opponent_select_screen.tscn` (paths to be confirmed at implementation against actual repo layout).

**Nutts budget:** 3–5h.

**Acceptance (Optic fixtures + assertions — direct from Gizmo design §Acceptance hooks for Optic / #104):**
- `test_s21.2_002_brottbrain_no_overlap_full` — fixture: brain editor at full content density (all triggers + actions visible). Assert `BrottbrainScreen/TrayScroll` exists with expected size, scroll content larger than viewport, back + Fight buttons reachable (`get_global_rect()` does not intersect any tray child rect).
- `test_s21.2_002_opponent_select_no_overlap_max` — fixture: synthetic 6-opponent league. Assert `OpponentSelectScreen/ListScroll` exists, back button reachable, all 6 panels accessible via scroll.
- `test_s21.2_002_brottbrain_signal_contract_preserved` — assert `back_pressed` and `continue_pressed` signals still emit from refactored footer buttons.
- `test_s21.2_002_opponent_signal_contract_preserved` — assert opponent-select chosen-index signal still emits.
- `test_s21.2_002_empty_states_unchanged` — fixture: 0 cards / 0 opponents (degenerate). Assert no awkward gap, no scroll spawned where unneeded (matches S17.1-002 AC-6).
- **Playwright snapshot:** screenshot at max-capacity fixture, verify all critical buttons unmasked.

**Boltz scope (T1 portion):** approve diff to `BrottbrainScreen` + `OpponentSelectScreen` node trees and their `.gd` accessor changes. Verify no edits to combat HUD, no edits to LoadoutScreen / ShopScreen / MainMenuScreen / ResultScreen.

---

### T2 — #103 Inline visible-by-default captions (6 critical conversions)

**Nutts spec — ships:** the 6 conversions enumerated in Gizmo design §Issue #103 → S21.2 scope table:

| # | Screen | Node path | Pattern |
|---|---|---|---|
| 1 | Brottbrain editor | trigger button rows | Caption Label below each, font_size 9, `Color(0.65,0.65,0.65)`, copy from `TRIGGER_DISPLAY[i][2]` (extend tuple from 2→3) |
| 2 | Brottbrain editor | action button rows | Same pattern, copy from `ACTION_DISPLAY[i][2]` (extend tuple from 2→3) |
| 3 | Opponent select | per-panel `name_lbl` | Inline subtitle Label at `(60, y+65)`, font_size 12, faded; copy from `OpponentData.opponent_summary(league, idx)` (Nutts adds helper) |
| 4 | Loadout | `_weight_bar` | Adjacent Label "Weight: X/Y · over cap = slower turns" |
| 5 | Brottbrain editor | `stance_opt OptionButton` | Caption Label below at `(160, 90)` reflecting current selection; updates on `item_selected` signal |
| 6 | Result screen | league progress block | Single-line Label "Win league to unlock Silver" (or current state) |

**Pattern (from Gizmo §Implementation note for Nutts):** sibling `Label` below/beside parent control, font_size 9–12, `font_color = Color(0.65,0.65,0.65)`. **Preserve existing `tooltip_text`** (hover backup) — do not strip.

**Nice-to-have hovers stay (do NOT add captions to):** ConcedeButton, speed multiplier, BrottbrainScreen "?" help button, shop back/buy/sell buttons, main-menu buttons, combat HUD.

**Files touched:** `godot/ui/brottbrain_screen.gd`, `godot/ui/opponent_select_screen.gd` + `opponent_data.gd` (new `opponent_summary` helper), `godot/ui/loadout_screen.gd`, `godot/ui/result_screen.gd`. Paths confirmed at Nutts impl time.

**Nutts budget:** 4–6h.

**Acceptance (Gizmo §Acceptance hooks for Optic / #103):**
- `test_s21.2_001_brottbrain_caption_visible` — render `BrottbrainScreen`; assert each trigger button has a sibling Label child at expected y-offset, font_size ≤ 12, color ≈ muted grey, copy matches `TRIGGER_DISPLAY[i][2]`. Same for action buttons.
- `test_s21.2_001_opponent_subtitle_visible` — render `OpponentSelectScreen` with Bronze fixture; assert each opponent panel has subtitle Label at `(60, y+65)`, copy non-empty.
- `test_s21.2_001_loadout_weight_caption` — render `LoadoutScreen`; assert `_weight_bar` has adjacent Label with format `"Weight: X/Y · over cap = slower turns"`.
- `test_s21.2_001_stance_caption_updates_on_change` — render Brottbrain, change stance via `OptionButton.select(...)`; assert caption Label text reflects new selection.
- `test_s21.2_001_result_progress_caption` — render `ResultScreen` with mid-league fixture; assert progress block has caption Label.
- **Playwright no-hover-required snapshot:** baseline screenshot per affected screen at standard mid-game fixture, visual-diff vs approved baseline. First run produces baseline; subsequent runs assert pixel diff.

**Boltz scope (T2 portion):** approve caption-Label additions across the 4 screens + the new `OpponentData.opponent_summary` helper + `TRIGGER_DISPLAY` / `ACTION_DISPLAY` tuple-shape change. Verify no captions added to the "nice-to-have hovers stay" list.

---

### T3 — #107 First-encounter overlay sequence (4-key generalization of S17.1-004)

**Nutts spec — ships:**
- Refactor `main.gd:_spawn_energy_explainer` into a generic `_spawn_first_encounter_overlay(key, anchor_node, copy)` helper. Extract panel construction (StyleBoxFlat panel, Label, dismiss-button, tick-budget setup) from S17.1-004's existing implementation. **~4-line core refactor + parameterization.**
- Add `FIRST_ENCOUNTER_SEQUENCE: Array[Dictionary]` constant in `main.gd` listing the 4 keys + target-node accessor + copy:
  1. `energy_explainer` (existing — keep S17.1-004 wording)
  2. `combatants_explainer` → `"Your Brott (left) vs the opponent (right). Watch HP — first to zero loses."`
  3. `time_explainer` → `"Match clock. Most fights end before this hits zero."`
  4. `concede_explainer` → `"Throwing in the wrench forfeits the match. Two-step confirm."`
- Sequencing logic in `_start_match`: iterate `FIRST_ENCOUNTER_SEQUENCE`, spawn the first key whose `FirstRunState.has_seen(key)` is false. **One overlay per arena entry, max.**
- Anchor positioning: ~40 px to the right or below target HUD element, with 3 px ▲ pointer (StyleBoxFlat) back to the element. Clamp to viewport.
- Sim slowdown to 0.25× while overlay up — generalize the existing S17.1-004 hook to apply per-overlay.
- Add 3 new keys to reserved-list comment in `ui/first_run_state.gd`. **No schema change** — `FirstRunState` autoload + `user://first_run.cfg` `[seen]` section unchanged.
- Tick-budget auto-dismiss: generalize the existing `ENERGY_EXPLAINER_TICK_BUDGET` constant to a per-overlay budget; default ~720 ticks (≈ 12 sim-seconds at 1×).

**Files touched:** `godot/main.gd`, `godot/ui/first_run_state.gd` (comment-only schema-key annotation).

**Nutts budget:** 2–3h.

**Acceptance (Gizmo §Acceptance hooks for Optic / #107):**
- `test_s21.2_003_fresh_save_first_overlay_is_energy` — fresh-save fixture (no `user://first_run.cfg`), call `_start_match`. Assert overlay spawns, key = `energy_explainer`, sim throttled.
- `test_s21.2_003_sequence_advances_per_arena_entry` — fresh save → enter arena, dismiss, leave; enter again. Assert overlay key = `combatants_explainer`. Repeat for `time_explainer` and `concede_explainer`.
- `test_s21.2_003_no_overlay_after_all_seen` — fixture: all 4 keys marked seen. Enter arena. Assert no overlay spawned, no sim throttle.
- `test_s21.2_003_input_dismisses_and_persists` — fresh save, spawn overlay, simulate dismiss-tap. Assert overlay removed; `FirstRunState.has_seen(key) == true`. Re-enter arena → next key fires.
- `test_s21.2_003_tick_budget_dismisses_and_persists` — fresh save, spawn overlay, advance budget ticks without input. Assert auto-dismiss + key marked seen.
- `test_s21.2_003_first_run_state_api_unchanged` — assert `FirstRunState` autoload still exposes `has_seen` / `mark_seen` / `reset` with same signatures (regression guard).
- `test_s21.2_003_legend_identity_preserved` — assert S17.1-004 `EnergyLegend` Label still exists with same text/anchor (regression guard).
- **Playwright snapshot:** fresh-save first arena entry, capture overlay visual; assert against baseline (rounded corners, dim background, anchor pointer).

**Boltz scope (T3 portion):** approve `main.gd` refactor (energy explainer → generic helper + sequence constant + iterator), comment-only edit to `first_run_state.gd`. Verify no schema change to `FirstRunState`, no new persistence layer introduced, no edits to combat-sim core.

---

## Optic test plan

**Three test groups, fixture-driven, mirroring Gizmo's "Acceptance hooks for Optic" section verbatim. Single Playwright/Godot harness invocation at end of T3 covers all three groups.**

### Fixtures required

1. **Mid-game standard fixture (#103):** Bronze league save, ~5 weapons / 3 armor / 2 modules in inventory, brain editor open with 4 behavior cards.
2. **Max-capacity fixture (#104, two states):**
   - (a) full inventory: 50 items, brain at 8 cards visible (all triggers + actions populated).
   - (b) max league: synthetic 6-opponent league for OpponentSelectScreen overflow check.
3. **Empty/degenerate fixture (#104):** 0 cards / 0 opponents (no awkward gap, no needless scroll).
4. **Fresh-save fixture (#107):** no `user://first_run.cfg` present. Setup helper: call `FirstRunState.reset(key)` for all 4 keys + remove the file before tests in group #107 (pattern already used by `test_sprint17_1_first_encounter_hud.gd:_cleanup_store()`).
5. **Post-first-encounter fixture (#107):** all 4 keys marked seen.

### Snapshots / pixel-diff baselines

- **#103 no-hover-required:** baseline per affected screen (Brottbrain, OpponentSelect, Loadout, Result) at mid-game fixture. Optic produces baselines on first run.
- **#104 max-capacity unmasked-buttons:** baseline at full-inventory fixture for BrottbrainScreen + 6-opponent fixture for OpponentSelectScreen.
- **#107 fresh-save overlay visual:** baseline at fresh-save first arena entry, captures rounded corners + dim background + anchor pointer styling.

### Cross-cutting

- `test_s21.2_004_no_console_errors` — render each affected screen; assert zero `push_error` / `push_warning` to stderr (catches missing nodes after refactor).

### Integration: loadout → battle → result flow

- After per-task tests pass, one end-to-end run on a fresh-save fixture: Main menu → Loadout (verify weight caption visible) → OpponentSelect (verify subtitles visible, scroll if needed) → Brottbrain (verify trigger/action captions visible, tray scroll if needed) → Arena (verify first-encounter overlay sequence fires correctly) → Result (verify progress caption visible). Asserts no console errors, no overlap, no stuck overlays.

---

## Specc audit scope

**Path:** `audits/battlebrotts-v2/v2-sprint-21.2.md` on `studio-audits/main`.
**Pattern:** mirror `v2-sprint-21.1.md` (sha `f01152c1`).

**Required sections:**
- **Scope** — issues #103 / #104 / #107 closed; reference Gizmo design + this sprint plan + battlebrotts-v2 PR.
- **Grade** — A− target (standard); document any deviations.
- **Per-issue verification** — for each of #103/#104/#107, confirm acceptance criteria from §Optic test plan above all pass.
- **Vision-doc alignment field** — explicit citation of `docs/kb/ux-vision.md` pillar lines per Gizmo's design §Vision-doc citation summary. Required citations:
  - **#103:** anti-pattern line `"Hover-only affordances (already flagged in playtest — tooltips must be visible by default)"` + Pillar **Clean** + Writing guidance `"Labels short. Tooltips one sentence."`
  - **#104:** anti-pattern line `"Overlapping UI elements that mask critical buttons (also flagged in playtest)"` + Pillar **Polished** + consistency with S17.1-002 / S17.4-002 / S17.1-001.
  - **#107:** Pillars **Professional** / **Clean** / **Polished** / **Smooth curves** / **Intentional color** + anti-patterns avoided (`"Cluttered HUDs with 8+ simultaneous badges/numbers"`, `"Popup spam ... that interrupt flow"`) + checklist line `"Energy bar (and every HUD element) has in-game explanation on first encounter"`.
- **Carry-forwards** — list any deferred items, regressions, or follow-up issues.
- **Streak** — extend scope streak (currently 19 post-S21.1 → target 20 at S21.2 close).

---

## Boltz spawn env note

**Pre-export before spawning Boltz** (S21.1 carry-forward from `memory/active-arcs.json`):

```bash
export BOLTZ_APP_ID="<from secret store>"
export BOLTZ_INSTALLATION_ID="<from secret store>"
```

Riv must surface these in the env before Boltz spawn. If not pre-exported, Boltz will fail GitHub-App auth on PR-approval step. This is a hard blocker — verify env on Boltz spawn prompt.

---

## Split decision

**Confirmed: NO SPLIT.** Single sub-sprint, single PR.

**Confirming Gizmo's recommendation (design doc §"Open scope concerns / split escape hatch"):**
- #107 mechanism is a ~4-line refactor of an already-shipped scaffolding (S17.1-004). Polish, not new system work.
- #103 caption-height pressure forces #104 scroll wrapper → coupling is favorable inside S21.2; splitting #107 out doesn't change this.
- Total Nutts budget 9–14h fits a single sub-sprint envelope.
- Implementation order #104 → #103 → #107 keeps a clean split point at end of T2 if reality diverges (see §Risk/contingency).

**Override reasoning:** none. Gizmo's call stands.

---

## Risk / contingency

**Inherited from arc brief §9 + S21.1 carry-forwards:**

1. **#107 mechanism inflation (arc-brief §9 risk on UX scope creep + Ett's pre-noted split hatch).**
   - **Trigger:** Nutts hits unforeseen blocker on the generic overlay helper (z-order issues, input-routing rework, anchor-positioning math fails for off-screen targets).
   - **Split point:** end of T2. #103 + #104 land as one PR; #107 deferred to S21.3 (arc gains a 4th sub-sprint, S21.4 audio shifts right).
   - **Decision authority:** Riv calls the split mid-sub-sprint, notifies The Bott who notifies HCD.

2. **Subagent truncation pattern (S21.1 carry-forward, github-copilot/claude-opus-4.7).**
   - Mitigation tactically (per S21.1): Riv re-spawns Specc-audit directly if truncation occurs in chain; verify artifact landing on `studio-audits/main` before declaring close (per SOUL.md "Long-running arc verification" + "Completion event content sanity-check").

3. **Boltz env-var miss (S21.1 carry-forward).** See §Boltz spawn env note. Hard pre-export gate.

4. **Tooltip-content quality scope creep (arc-brief §9 risk #3).** Stay inside the 6 critical conversions. Surface related-but-separate items as new `backlog` issues; do NOT fold into S21.2.

5. **Sim harness Sim-1 band hardcoded 20–40s (S21.1 carry-forward).** Not S21.2-relevant (no combat-sim acceptance for this sub-sprint). Tracked separately.

6. **Vision-doc citation drift (arc-brief §9 risk #5).** Gizmo's design output already cites pillars per design §Vision-doc citation summary. Specc audit must reference them in `vision-doc alignment` field — required, not optional.

---

## Pipeline-level notes

- **Nutts → Boltz → Optic → Specc loop** runs once per arc (per SOUL.md "Riv spawn discipline — per-arc, not per-sub-sprint"). Riv's spawn covers all of T1 → T2 → T3 → audit landing in one arc-loop pass.
- **Phase 0 audit-gate:** S21.1 audit landed (`f01152c1` on `studio-audits/main`). Gate satisfied for S21.2 entry.
- **Phase 3e audit-landed gate:** S21.2 closes when `audits/battlebrotts-v2/v2-sprint-21.2.md` is on `studio-audits/main` AND active-arc-reconciler confirms artifact (per active-arc-reconciler watchdog in TOOLS.md).
- **Open asks for Riv:** none — all decisions in this plan are settled. Spawn per arc-brief.

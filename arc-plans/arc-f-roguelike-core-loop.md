# Arc F Plan — Roguelike Core Loop (Post-Pivot, GDD v2)

**Status:** Greenlit for Riv spawn.
**Author:** Ett (Technical PM)
**Date:** 2026-04-25
**GDD source:** PR #299, branch `design/v1-roguelike-gdd`, commit `8cd1f4a` (GDD v2 with 16:40 UTC refinement)
**HCD decisions addendum:** `memory/2026-04-25-hcd-decisions-on-gdd-v1.md`
**Pivot source:** `memory/2026-04-25-battlebrotts-v1-roguelike-pivot.md`

---

## §1 — Arc Summary

**Arc goal:** Wire the complete roguelike run loop end-to-end — run start, all 7 encounter shapes, multi-target arena, hardcoded baseline AI, click-to-move/target controls, reward pick, boss, and run-end screens — leaving the game fully playable as a 15-battle run from first click to final boss.

### Hard exit criteria (Arc F is DONE when ALL of the following are true)

1. Player can start a fresh run, navigate through 15 battles (all encounter shapes exercised), and reach IRONCLAD PRIME
2. Reward pick screen works: 3 deduped random items shown post-win, player picks 1, item immediately applied to RunState build
3. Retry mechanic works: 3 retries tracked per run; losing all 3 ends the run; retry resets current battle with build intact
4. Run-end screens work: "BROTT DOWN" (loss) and "RUN COMPLETE" (win) both show build summary + run stats
5. Click-to-move functional: yellow diamond waypoint, bot navigates, resumes autonomous on arrival
6. Click-to-target functional: orange reticle on target, override active indicator on player bot, latest click wins
7. Multi-target arena renderer handles up to 6 enemy bots simultaneously without visual breakage
8. All 7 encounter archetypes authored in the encounter generator pool
9. `combat_batch.gd` simulations pass against multi-target encounter templates
10. Encounter variety rule enforced: no two consecutive encounters share the same archetype
11. Run guarantee seeds validated: Small Swarm, Counter-Build Elite, Mini-boss+Escorts each appear ≥1 per run
12. No regressions on existing arena / combat tests

### Key dependencies and unknowns flagged

| # | Item | Risk level |
|---|---|---|
| D1 | `arena_renderer.gd` is hard-wired to exactly 2 bot slots (1 player, 1 enemy) — N-enemy refactor is a significant extension, not a drop-in | 🔴 High |
| D2 | `game_state.gd` has deep coupling to league/bolts/shop data — renaming to RunState requires careful surgery across game_flow, result_screen, UI screens | 🟡 Medium |
| D3 | Counter-Build Elite build-read logic — AI must inspect `RunState.equipped_*` to pick the right elite archetype — first time codebase reads player build at enemy-generation time | 🟡 Medium |
| D4 | HCD 16:40 UTC refinement decouples shape from difficulty: multi-bot encounters can appear from battle 1, meaning multi-target renderer and multi-target AI cannot be deferred. Both must be functional by S25.2 | 🔴 High |
| D5 | IRONCLAD PRIME boss name is TBD — planning uses placeholder. Arc F just needs the boss loadout to work; name resolution is HCD offline | 🟢 Low |
| D6 | `first_run_state.gd` keeps its first-run tooltip logic — the tooltip text will change (BrottBrain copy stripped, two-click affordances added), but the tracking mechanism is reused. Coordinate with §4 cut boundary | 🟢 Low |
| D7 | Run state does NOT persist across sessions (close tab = run gone) — confirmed per GDD §A.7. No save/resume work needed in Arc F | 🟢 Low (confirmed) |
| D8 | Arc F is the first pipeline iteration against a freshly-pivoted codebase. Expect higher issue discovery rate than S17–S24 | 🟡 Medium |

### Total estimated sub-sprint count: **9**

Arc F runs as sprints **S25.1 through S25.9**.

---

## §2 — Sub-Sprint Sequence

> Riv's sub-sprint numbering: Arc F = arc 25 internally (arcs A–E = 21–24). S25.x numbering used throughout.

---

### S25.1 — RunState scaffold + run-start screen

**Goal:** Replace `GameState`/`GameFlow` league-era plumbing with a new `run_state.gd` and `run_start_screen.gd`, and wire the "New Run" button so the game transitions from main menu into a first (stub) encounter slot.

**Deliverables:**
- `godot/game/run_state.gd` — new class tracking: `current_battle_index`, `retry_count`, `battles_won`, `equipped_chassis/weapons/armor/modules`, `_last_encounter_archetype`
- `godot/ui/run_start_screen.gd` — random 3-chassis pick display + "Start Run" button
- `godot/game/game_flow.gd` — reworked flow: `MAIN_MENU → RUN_START → ARENA` (stub encounter for now)
- Updated `godot/ui/main_menu_screen.gd` — "New Run" button + "Continue Run (Battle N/15)" in-session prompt
- Stub arena transition: drops into a 1v1 Standard Duel at Tier 1 loadout, no reward pick yet, result screen returns "stub — reward coming"
- Tests: `test_run_state_init.gd` (verify field defaults, retry count = 3, battle_index = 0)

**Acceptance gates:**
1. Main menu has a working "New Run" button; pressing it shows the run-start screen with 3 random chassis options
2. Picking a chassis creates a `RunState` with correct starter loadout (chassis only, no weapons/armor/modules yet)
3. `RunState.retry_count` initializes to 3
4. `RunState.current_battle_index` initializes to 0 and increments after battle stub completes
5. `GameFlow` no longer references `GameState`, `current_league`, `bolts`, or `shop`
6. Main menu shows "Continue Run (Battle N/15)" correctly when a run is in progress mid-session; shows nothing when no run is active
7. `test_run_state_init.gd` passes CI

**Estimated duration:** 90–120 min

**Dependencies:** None (first sub-sprint of arc)

**Risk flags:**
- `game_flow.gd` currently has deep references to shop/loadout/BrottBrain screens. Reworking the flow without breaking the arena path is the highest risk here. Work defensively: keep old Screen enum values in comments, don't delete them until Arc G.
- Run-start chassis picker needs the random 3-pick to be deterministic-seeded (for test reproducibility) — spec the seed approach before implementation.

**Code touched / cut boundary:**
- `game_state.gd` → RE-SKIN (becomes run_state.gd; old file left in place for now, flagged CUT in Arc G)
- `game_flow.gd` → RE-SKIN (rework flow; old shop/BrottBrain/OpponentSelect branches left dormant)
- `main_menu_screen.gd` → KEEP (minor addition)
- NEW: `run_state.gd`, `run_start_screen.gd`

---

### S25.2 — Multi-target arena renderer

**Goal:** Extend `arena_renderer.gd` to render N enemy bots (up to 8 simultaneously) and stress-test at 5–6 bots so multi-bot encounters are unblocked from battle 1 per the HCD 16:40 refinement.

**Deliverables:**
- Extended `godot/arena/arena_renderer.gd` — bot rendering array replacing the hardcoded 1-enemy slot; HP bars, status indicators, and hit flash for all N bots
- Click-overlay layer: yellow diamond waypoint marker at clicked floor position (fades on arrival), orange reticle ring on targeted enemy (persists while override active), pulsing outline on player bot (yellow = moving, orange = targeting)
- Click input handler in arena scene — routes floor clicks → waypoint event, enemy clicks → target override event; latest click wins entirely
- Visual regression baseline screenshots at 1v1, 1v3, 1v6 densities
- Tests: `test_arena_renderer_multi.gd` — assert N bots render without overlap errors; assert click events route correctly

**Acceptance gates:**
1. Arena renders 1, 3, 5, and 6 enemy bots without visual breakage (HP bars, positions, IDs all distinct)
2. Yellow diamond appears at floor click position; fades when player bot arrives at waypoint
3. Orange reticle appears on clicked enemy; persists while that target is the active override; clears when target dies
4. Player bot shows pulsing yellow outline during active move override; pulsing orange outline during active target override; no outline when no override active
5. Clicking a new position mid-target-override immediately cancels target and starts move (latest click wins)
6. Clicking a new enemy mid-move-override immediately cancels move and applies target (latest click wins)
7. No frame-rate regression at 6-bot density in headless sim (Optic checks)
8. Visual regression screenshots committed as baseline for S25.x

**Estimated duration:** 120–150 min (highest complexity sub-sprint in Arc F)

**Dependencies:** S25.1 (RunState + GameFlow wired so arena can receive encounter context)

**Risk flags:**
- `arena_renderer.gd` is currently written around exactly 2 bot slots. The refactor to a dynamic bot array touches the render loop, health bar layout, hit flash tracking, screen shake triggers, and death sequence logic. Scope risk: this may spill into 150+ min or require a follow-up sub-sprint. Flag at 90 min if Nutts isn't through the bot array refactor.
- Click-overlay input handling may conflict with existing arena input bindings — audit current input map before starting.
- 6-bot density → ~6 health bars + 6 bot circles + waypoint + reticle + grid = potentially noisy. May need art-direction guidance on health bar sizing at density. Escalate to HCD if it looks bad; don't self-solve.

**Code touched / cut boundary:**
- `arena_renderer.gd` → RE-SKIN (extend; core draw logic preserved)
- `charm_anims.gd` → KEEP (confirm multi-bot compatibility; likely no changes needed)

---

### S25.3 — Hardcoded baseline AI (single-target)

**Goal:** Replace the card-driven `BrottBrain` internals with a hardcoded baseline AI that handles 1v1 combat correctly — engagement loop, kiting at low HP, and module auto-fire rules (Repair Nanites, EMP, Afterburner).

**Deliverables:**
- Rewritten `godot/brain/brottbrain.gd` — same public API (`get_action()`, `set_target()`), completely different internals: hardcoded rule loop, no Trigger/Action card evaluation
- Baseline AI behavior: advance → attack at range → kite when HP < 40% + enemy adjacent → module auto-fire (Repair Nanites < 30% HP, EMP enemy within 3 tiles, Afterburner HP < 40% + enemy adjacent)
- `brottbrain.gd` Trigger/Action enums removed (or stubbed as dead code with CUT comment)
- Tests: `test_baseline_ai_1v1.gd` — verify correct behavior states fire under expected conditions (HP threshold, range threshold, module fire conditions)
- `combat_batch.gd` sims updated to work with new baseline AI internals; sim pass rate confirmed

**Acceptance gates:**
1. Player bot engages nearest enemy when in range; advances when out of range
2. Bot attempts to create distance when HP < 40% and enemy is within melee range
3. Repair Nanites fires at HP < 30% (when equipped + off cooldown)
4. EMP fires when enemy is within 3 tiles (when equipped + off cooldown)
5. Afterburner fires when HP < 40% and enemy is adjacent (when equipped + off cooldown)
6. No BehaviorCard, Trigger enum, or Action enum code path reachable during normal runtime
7. `test_baseline_ai_1v1.gd` passes CI
8. `combat_batch.gd` 1v1 simulations produce consistent win-rate distribution across the existing opponent template set

**Estimated duration:** 90–120 min

**Dependencies:** S25.1 (RunState exists; needed for test scaffolding)

**Risk flags:**
- `brottbrain.gd` currently has extensive card evaluation code. Gutting it while preserving the public API is a clean cut, but the save-compat references (WHEN_CLOCK_SAYS, GET_TO_COVER stubs added for save compat in S14.2) need to be confirmed as dead — verify no call sites in game_flow or UI before removal.
- `combat_batch.gd` and `combat_batch_brain.gd` may reference card-driven internals for simulation setup — audit before rewrite and confirm the batch runner still gets meaningful behavioral variety from hardcoded AI (it will; the rule set is opinionated).

**Code touched / cut boundary:**
- `godot/brain/brottbrain.gd` → RE-SKIN (gut internals, keep class name + API)
- `combat_batch.gd`, `combat_batch_brain.gd` → KEEP (update to support new baseline AI; no structural changes needed)

---

### S25.4 — Baseline AI v2 (multi-target) + encounter archetypes data

**Goal:** Extend the baseline AI to handle multi-bot encounters with correct target priority rules, and author the encounter archetype data for all 7 archetypes so the encounter generator has a complete pool to draw from.

**Deliverables:**
- Extended `godot/brain/brottbrain.gd` — multi-target priority: default nearest, override to lowest HP when equidistant, override to melee-range attacker if one is adjacent, player click-to-target overrides all
- Encounter archetype data in `godot/data/opponent_loadouts.gd` — all 7 archetypes authored with example compositions:
  - Standard Duel (1v1 tier-matched)
  - Small Swarm (1v3 ~45% HP Scouts)
  - Large Swarm (1v5–6 ~20% HP Micro-Scouts)
  - Mini-boss + Escorts (1v1 Fortress ~130% HP + 2 Scout ~60% HP)
  - Counter-Build Elite (3 authored loadouts: Anti-Range, Anti-Melee, Anti-Module + build-read selector)
  - Glass-Cannon Blitz (1v1 Scout ~40% HP, 2 weapons, no armor/modules)
  - Boss (IRONCLAD PRIME loadout — Fortress, Railgun + Minigun, Ablative Shell, Shield Projector + Sensor Array + EMP Charge)
- 3 authored elite loadouts for Counter-Build Elite with build-read selector logic
- `archetype_for(battle_index, last_archetype, run_state)` generator stub (distribution logic comes in S25.6; this is the data layer)
- Tests: `test_multi_target_ai.gd` — verify priority rules fire correctly in 1v3, 1v6 scenarios

**Acceptance gates:**
1. Baseline AI correctly targets nearest enemy by default in a 3-bot encounter
2. When two enemies equidistant, AI targets the lower-HP one
3. When an enemy enters melee range of the player bot, it becomes priority target (overrides nearest rule)
4. Player click-to-target override takes effect immediately and holds until target dies or new override issued
5. Counter-Build Elite selector correctly picks Anti-Range elite when player build has Railgun or Missile Pod; Anti-Melee when Shotgun or Flak Cannon is primary; Anti-Module when build has 3+ modules; default Anti-Range otherwise
6. All 7 archetype data records exist in `opponent_loadouts.gd` with required fields (id, archetype tag, composition, loadout refs)
7. `test_multi_target_ai.gd` passes CI

**Estimated duration:** 120–150 min

**Dependencies:** S25.3 (single-target baseline AI foundation), S25.2 (renderer must handle N bots for test scenarios)

**Risk flags:**
- Counter-Build Elite build-read is the most novel logic in Arc F — it inspects `RunState.equipped_*` at encounter-generation time. This is the first time the opponent-generation system is aware of player build state. Test this path explicitly; don't let it be an implicit "it'll work."
- Micro-Scout data for Large Swarm: these are deliberately sub-templates with ~20% of normal HP. Need to confirm the combat sim handles fractional HP templates without rounding bugs.
- Boss loadout: IRONCLAD PRIME boss-specific AI behavior (kites low-HP players, EMP on active modules, aggressive at full HP, shield at 40%) is NOT included here — that's S25.9. This sub-sprint only authors the loadout data.

**Code touched / cut boundary:**
- `godot/brain/brottbrain.gd` → RE-SKIN (extend from S25.3)
- `godot/data/opponent_loadouts.gd` → RE-SKIN (replace league-gated pool with archetype-tagged encounter pool)
- `godot/game/opponent_data.gd` → RE-SKIN (update `get_opponent()` to accept archetype + tier context instead of league + index)

---

### S25.5 — Reward pick screen + run flow wire-up

**Goal:** Build the post-battle reward pick screen and wire the basic battle-to-battle flow (win → reward → next encounter; loss → retry prompt or run-end) so the run loop is mechanically traversable end-to-end even with stub content.

**Deliverables:**
- NEW `godot/ui/reward_pick_screen.gd` — 3 random items from full pool (deduped against owned), player picks 1, immediately added to `RunState` loadout
- Duplicate fallback: if player owns all items, backfill with one owned item displayed as "Duplicate — spare parts" (no effect, graceful edge case)
- Retry prompt: "DEFEAT" flash → UI shows retry count remaining + "Retry Battle" / "Accept Loss" buttons
- Run HUD status bar (§A.7): `[⚔️ Battle N of 15] [💀 N retries left] [🔩 Build: Chassis + Weapon + ...]` on reward pick screen and run-start screen; color shift at battle 12 (amber) and 14 (red)
- `GameFlow` screen enum adds: `RUN_START`, `REWARD_PICK`, `RETRY_PROMPT`; flow: `RUN_START → ARENA → REWARD_PICK → ARENA → ...`
- Tests: `test_reward_pick.gd` — verify dedup, verify RunState updated correctly, verify retry counter decrements

**Acceptance gates:**
1. Post-win: reward pick screen shows exactly 3 items, none of which are already in the player's loadout (dedup confirmed)
2. Picking a reward item immediately updates `RunState.equipped_*` and the pick is reflected on the run HUD
3. Post-loss: retry prompt shows correctly with remaining retry count; "Retry Battle" resets arena with same opponent template + same encounter shape + new arena seed
4. After retry win: reward pick screen appears normally (retry win = full win)
5. `RunState.retry_count` decrements on each retry use; at 0, "Accept Loss" button is the only option; no retry prompt appears
6. Run HUD bar displays correctly on reward pick screen; battle counter shows amber at battle 12, red at battle 14
7. Full pool (all 7 weapon types, 3 armor types, 6 module types) is eligible from reward pick battle 1
8. `test_reward_pick.gd` passes CI

**Estimated duration:** 90–120 min

**Dependencies:** S25.1 (RunState), S25.3 (baseline AI so arena encounters are playable), S25.2 (multi-bot renderer so any archetype can be used)

**Risk flags:**
- Reward item randomization seed: the random 3-pick must use a seeded RNG per battle (for test reproducibility). Establish the seed convention early.
- "Duplicate — spare parts" edge case: the full pool has 7+3+6 = 16 unique items. A player who has won 16 battles with perfect picks (impossible in 15 battles) could hit this edge case. The duplicate display path still needs to be tested — it's easy to forget.
- The run HUD bar will appear on more screens later (S25.6+ adds it to other non-arena screens). Build it as a reusable component from the start, not inline on reward_pick_screen.

**Code touched / cut boundary:**
- NEW: `godot/ui/reward_pick_screen.gd`
- `game_flow.gd` → RE-SKIN (extend with new screen enum values)
- `run_state.gd` → RE-SKIN (extend equipped_* mutation methods)
- `godot/ui/loadout_screen.gd` → KEEP (deferred re-label to "Current Build" display — minimal; Arc F just stops the buy flow; Arc G removes it)

---

### S25.6 — Encounter generator + archetype distribution

**Goal:** Build the full encounter generator that takes `(battle_index, run_state)` and emits a concrete encounter with the correct archetype distribution, variety rule enforced, and run guarantee seeds applied.

**Deliverables:**
- `godot/data/opponent_loadouts.gd` — `archetype_for(battle_index, last_archetype, run_state)` fully implemented with:
  - 4-tier distribution (battles 1–3, 4–7, 8–11, 12–14, 15=boss always)
  - Suggested archetype distributions per tier (not hard quotas — free shape mix per HCD 16:40 refinement; shape varies freely, difficulty scales by tier)
  - No-repeat rule: re-roll once if archetype matches `_last_encounter_archetype`
  - Run guarantee: Small Swarm, Counter-Build Elite, Mini-boss+Escorts each seeded ≥1 per run (seeded into slots 5, 9, 12, shuffled within-tier constraints)
- `difficulty_for(battle_index)` maps 1–15 to tiers (1–3→T1, 4–7→T2, 8–11→T3, 12–14→T4, 15→Boss)
- `compose_encounter(archetype, tier, run_state)` instantiates the concrete enemy list with tier-appropriate HP scaling
- Tests: `test_encounter_generator.gd` — 1000-run simulation verifying variety rule (no consecutive repeat), guarantee seeds appear ≥1 per run, boss always at battle 15, tier distribution in plausible range

**Acceptance gates:**
1. `archetype_for()` never returns the same archetype twice in a row across 1000 simulated runs (variety rule)
2. Every simulated run contains ≥1 Small Swarm, ≥1 Counter-Build Elite, ≥1 Mini-boss+Escorts (run guarantee)
3. Battle 15 always returns Boss archetype regardless of `last_archetype`
4. `difficulty_for()` maps all 15 battle indices to correct tiers
5. `compose_encounter()` produces enemy lists with HP values appropriate to the tier (T1 enemies demonstrably weaker than T3 enemies via combat sim)
6. Large Swarm in T1 uses HP-scaled micro-templates (20% normal HP); same archetype in T3 uses standard HP (~90% normal) — difficulty decoupled from shape confirmed
7. Counter-Build Elite generator picks the correct anti-build type for 3 test run-state configurations
8. `test_encounter_generator.gd` passes CI (1000-run validation)

**Estimated duration:** 120 min

**Dependencies:** S25.4 (archetype data pool), S25.1 (RunState with `_last_encounter_archetype` field)

**Risk flags:**
- Run guarantee seeding (slots 5, 9, 12) combined with the no-repeat rule creates a constraint satisfaction problem. If slot 4 happened to produce the same archetype as the forced slot 5 pick, the no-repeat rule would need to override the seed. Decide now: seed wins, or no-repeat wins? Recommend: no-repeat wins (re-slot the guarantee to slot 6 if slot 5 conflicts). Spec this before implementation.
- The Counter-Build Elite build-read was authored in S25.4 but only tested unit-style. The encounter generator is the first time it runs in a full sim context — integration test it explicitly.
- HCD 16:40 refinement: "suggested" distributions are guidance, not hard quotas. Riv/Nutts should not implement hard-coded archetype quotas per tier. The distribution should be probability weights.

**Code touched / cut boundary:**
- `godot/data/opponent_loadouts.gd` → RE-SKIN (complete the `archetype_for` and `compose_encounter` work seeded in S25.4)
- `run_state.gd` → KEEP (extend `_last_encounter_archetype` update logic)

---

### S25.7 — Battle-to-battle loop + run HUD bar completion

**Goal:** Wire the complete battle-to-battle loop so the player can traverse all 15 battles without interruption: win → reward → next encounter; loss → retry or run-end; run progress HUD bar correct on all non-arena screens.

**Deliverables:**
- Complete `GameFlow` battle loop: `[ARENA → win → REWARD_PICK → next ARENA] × N → BOSS_ARENA → RUN_END`
- Loss path: `ARENA → loss → RETRY_PROMPT → (retry: same ARENA / exhaust: RUN_END)`
- Run HUD bar (`godot/ui/run_hud_bar.tscn` / `.gd`) as standalone component, wired on: run-start, reward-pick, retry-prompt screens
- Run progress bar (visual indicator of battle N/15) — segmented or fill-style, 15 segments, current battle highlighted
- In-session "Continue Run" state on main menu persists correctly across screen transitions
- Tests: `test_run_loop.gd` — simulate 15-battle run traversal, verify RunState fields at each stage; simulate 4-loss run, verify run-end fires at correct point

**Acceptance gates:**
1. Win at battle N → reward pick screen appears → pick made → next battle is N+1 with correct encounter
2. Loss at battle N (retries remaining) → retry prompt → retry → same opponent template + shape, RunState unchanged except `retry_count -= 1`
3. Loss at battle N (retries = 0) → run-end fires immediately, no retry prompt shown
4. Run progress bar shows correct battle count on reward pick screen after each win
5. Run HUD bar appears on run-start, reward-pick, and retry-prompt screens; does NOT appear on loss screen, win screen, or main menu
6. Battle counter color shift: amber at battle 12, red at battle 14, confirmed in UI
7. Completing all 15 battles transitions to boss arena (battle 15 entry, not reward pick)
8. `test_run_loop.gd` passes CI (both 15-battle win path and 4-loss run-end path)

**Estimated duration:** 90–120 min

**Dependencies:** S25.5 (reward pick + retry prompt), S25.6 (encounter generator so battles have real content)

**Risk flags:**
- GameFlow state machine complexity grows significantly here — the flow now has ~8 states. Draw the state machine explicitly before implementation (a comment block in game_flow.gd is sufficient). Don't implement from memory.
- Battle 15 is a special case: it goes to BOSS_ARENA (not normal ARENA), and on win goes directly to RUN_COMPLETE (no reward pick after the boss). Make this explicit in the flow, not handled by a flag.
- In-session "Continue Run" on main menu requires the flow to be queryable mid-run — confirm RunState is accessible from the main menu scene without coupling the menu to the battle flow.

**Code touched / cut boundary:**
- `game_flow.gd` → RE-SKIN (complete the flow state machine)
- `run_state.gd` → KEEP (read-only from HUD bar)
- NEW: `godot/ui/run_hud_bar.gd` (reusable component)

---

### S25.8 — Run-end screens

**Goal:** Build the "BROTT DOWN" and "RUN COMPLETE" run-end screens with build summary and run stats, plus the "New Run" button that correctly resets RunState and restarts the loop.

**Deliverables:**
- Reworked `godot/ui/result_screen.gd` (re-skinned) — BROTT DOWN layout: fell at battle N, YOUR BUILD (chassis + weapons + armor + modules icons), Battles Won, Retries Used, Farthest Threat name
- RUN COMPLETE layout: boss name, YOUR BUILD, Battles Won 15/15, Retries Used, Best Kill name
- Shared "Build Summary" component (reusable; also used in reward pick screen header in a smaller form)
- "New Run" button on both screens → `GameFlow.new_run()` → fresh `RunState`, back to run-start screen
- First-run tooltips updated (§A.6): run-start tooltip copy, first-battle arena tooltip (two-click affordances), first-reward-pick tooltip, first-retry-prompt tooltip — all via existing `first_run_state.gd` mechanism; no BrottBrain copy present
- Tests: `test_run_end_screens.gd` — verify all stat fields populate correctly from RunState; verify "New Run" correctly resets RunState

**Acceptance gates:**
1. BROTT DOWN screen shows correct battle number, full current build (all slots populated or "empty" where unequipped), correct Battles Won, Retries Used, and Farthest Threat name
2. RUN COMPLETE screen shows full win state with correct stats; "15 / 15" battles won confirmed
3. "New Run" button on BROTT DOWN resets RunState (retry_count = 3, battle_index = 0, build cleared) and transitions to run-start screen
4. "New Run" button on RUN COMPLETE does the same
5. First-run tooltips fire correctly on first run only: run-start screen tooltip, arena two-click tooltip, reward-pick tooltip, retry-prompt tooltip
6. None of the first-run tooltips contain the word "BrottBrain," "card," "program," or any editor-era copy
7. No "Return to Menu" button on either screen (GDD §A.5 spec)
8. `test_run_end_screens.gd` passes CI

**Estimated duration:** 90 min

**Dependencies:** S25.5 (reward pick / retry prompt wired), S25.7 (full loop flow so end screens are reachable via normal play)

**Risk flags:**
- "Farthest Threat name" (loss screen) and "Best Kill name" (win screen) require RunState to track the toughest/most notable opponent encountered. These fields aren't in S25.1's RunState spec — add `_farthest_threat_name` and `_best_kill_name` tracking in `run_state.gd` (small addition, confirm with Nutts at S25.5 time).
- First-run tooltip copy update: the tooltip text for the arena two-click control (§A.6 item 2) is new. Text: *"Click the arena to send your Brott somewhere. Click an enemy to target them. Or just watch — it'll fight on its own."* Confirm this copy is wired via `first_run_state.gd` and not hardcoded in the arena renderer.

**Code touched / cut boundary:**
- `godot/ui/result_screen.gd` → RE-SKIN (full rework of layout + stat fields; core screen transition structure preserved)
- `godot/ui/first_run_state.gd` → KEEP (update tooltip copy; tracking logic unchanged)
- `run_state.gd` → KEEP (add `_farthest_threat_name`, `_best_kill_name` tracking fields)

---

### S25.9 — Boss encounter + Arc F integration validation

**Goal:** Hand-tune IRONCLAD PRIME's boss-specific AI behavior, validate the complete 15-battle run end-to-end, and confirm Arc F exit criteria are fully met.

**Deliverables:**
- Boss-specific AI rules in `brottbrain.gd` (or a boss-specific override class) — separate behavior set per §A.1: kites low-HP players, EMP when player modules active, aggressive at full HP, switches to shield-projection at HP < 40%, controls distance (never lets player dictate range)
- Boss encounter integrated into `GameFlow.BOSS_ARENA` path (battle 15 only)
- Combat sim tuning: run `combat_batch.gd` against IRONCLAD PRIME at Tier-3 average build; target < 40% first-attempt win rate; adjust boss HP/loadout values to hit target range
- Arc F integration test: `test_arc_f_integration.gd` — simulate 10 full 15-battle runs using the encounter generator, verify all exit criteria (variety rule, guarantee seeds, reward pick, retry logic, run-end screens) pass
- Tier-background tinting from §A.7: reward pick screen background color shifts (grey-blue T1, bronze T2, silver-white T3, red/gold pre-boss) — small visual addition, confirm in Optic screenshots
- Final Optic visual verification pass: screenshots at run-start, battle 1 (Standard Duel), battle 1 (Small Swarm — multi-bot), reward pick, BROTT DOWN, RUN COMPLETE

**Acceptance gates:**
1. Boss uses boss-specific AI behavior (kite at player HP < 40%, EMP-on-module-active, distance control) — confirmed by combat sim behavioral logs
2. IRONCLAD PRIME first-attempt win rate < 40% against Tier-3 average player build in 1000-match combat sim
3. IRONCLAD PRIME is beatable by a skilled player (sim also confirms > 5% win rate with optimal play — not a brick wall)
4. `test_arc_f_integration.gd` 10-run simulation: all 10 runs reach battle 15, variety rule holds throughout, guarantee seeds confirmed present in each run
5. Reward pick screen shows correct tier-based background tinting (grey-blue for battles 1–3, bronze 4–7, silver-white 8–14, red/gold battle 14 pre-boss)
6. All 12 Arc F exit criteria (§1 above) verified and checked off
7. No regressions on existing arena/combat test suite
8. Optic screenshots show clean visual state at all key screens; no visual artifacts at 6-bot density

**Estimated duration:** 120–150 min

**Dependencies:** S25.1–S25.8 (all prior sub-sprints; this is the integration pass)

**Risk flags:**
- Boss tuning is empirical. The < 40% win rate target may require multiple sim iterations (buff boss HP, adjust kite threshold, tune EMP timing). Budget time for 2–3 tuning rounds inside this sub-sprint; if it's taking > 3 rounds, that's a signal the boss design needs HCD input, not just stat tweaks.
- `test_arc_f_integration.gd` is a long-running test. 10 full runs × 15 battles × N ticks per battle = potentially slow CI. Consider a fast-clock multiplier or tick-skip for the integration test to keep CI under 5 min.
- This sub-sprint deliberately bundles the final tier-tinting polish. If S25.1–S25.8 ran over schedule, tier tinting can be deferred to Arc H without blocking Arc F exit criteria. Flag this explicitly in the sprint plan for Riv.

**Code touched / cut boundary:**
- `godot/brain/brottbrain.gd` → RE-SKIN (add boss-specific AI behavior set, cleanly separated from baseline)
- `game_flow.gd` → KEEP (minor: confirm BOSS_ARENA path wired correctly)
- `godot/ui/reward_pick_screen.gd` → KEEP (add tier-tinting background color)
- NEW: `test_arc_f_integration.gd`

---

## §3 — Critical Risks & Validation Needs

### Risk 1 — Multi-target renderer density (🔴 HIGH — S25.2)

`arena_renderer.gd` is hard-wired to 2 bot slots. The refactor to a dynamic bot array is the single largest code change in Arc F. It touches the render loop, health bar layout, hit-flash tracking, death sequence, screen shake triggers, and the new click-overlay layer. Validate 5–6 bot density **in S25.2** — not later.

**Mitigation:** Spec the bot array data structure before S25.2 implementation begins. Confirm `charm_anims.gd` is multi-bot compatible (likely yes, but verify). If S25.2 hits 150 min without completing the click overlay, split the click overlay into S25.2b (a short add-on sprint) rather than blocking S25.3.

**Escalation trigger:** If 6-bot rendering causes frame drops visible in Optic's headless sim, escalate to HCD — don't self-solve art direction tradeoffs on bot density layout.

### Risk 2 — Counter-Build Elite build-read logic (🟡 MEDIUM — S25.4 / S25.6)

The Counter-Build Elite archetype requires the encounter generator to inspect `RunState.equipped_*` at encounter-generation time. This is a new coupling between the opponent system and the player state system — first occurrence in the codebase. The rule logic (Anti-Range / Anti-Melee / Anti-Module) is simple, but the coupling is novel.

**Mitigation:** Unit test the build-read selector in S25.4 with 3 explicit test cases. Run it again in S25.6 via the encounter generator integration test. Don't rely on visual confirmation alone — it's the kind of bug that passes a human eye check but fails edge cases (mixed loadout, empty modules slot, etc.).

**Escalation trigger:** If the build-read produces unexpected archetype selection in edge cases (empty build, all-module build, etc.), surface to Gizmo before self-solving — these may be design decisions disguised as bugs.

### Risk 3 — GameState → RunState coupling surgery (🟡 MEDIUM — S25.1 / S25.5)

`game_state.gd` is referenced across `game_flow.gd`, `result_screen.gd`, `loadout_screen.gd`, arena scenes, and likely the BrottBrain screen. The re-skin to `run_state.gd` is the right move, but the surgery risk is real: a missed reference means a null dereference at runtime that may only surface in specific game paths.

**Mitigation:** In S25.1, add a shim in `game_flow.gd` that exposes `run_state` at the same access point as the old `game_state` property, and leave the old `game_state.gd` file in place (just dormant). This limits blast radius. Grep for all `game_state.` references before S25.1 closes; confirm each one is accounted for.

**Escalation trigger:** If references surface in scenes not covered by the test suite (e.g., BrottBrain screen, shop screen, opponent select screen — all scheduled for Arc G cut), leave them alone. They're dormant. Note them in the sprint summary for Arc G.

### Risk 4 — Arc F is the first post-pivot pipeline run (🟡 MEDIUM — all sub-sprints)

The codebase has never been touched in roguelike-mode. The league-era assumptions are baked in at multiple layers. Expect:
- More failing tests at sprint open than S17–S24 (old tests asserting league state that no longer exists)
- More "found while building" issues as Nutts discovers undocumented GameState/GameFlow dependencies
- Potentially 1–2 sub-sprint overruns

**Mitigation:** At S25.1 start, Nutts should do a 15-minute discovery pass (grep for `current_league`, `bolts`, `brottbrain_unlocked`, `opponents_beaten`) and produce a brief "coupling inventory" before writing a line of code. This surfaces surprises upfront. If the coupling inventory reveals > 20 call sites, flag to Riv before proceeding.

---

## §4 — Cut/Keep Boundary Checks per Sub-Sprint

> Arc F stops **using** BrottBrain editor and league systems. Arc G **removes** the files. Riv must enforce this distinction: no file deletions in Arc F.

| Sub-sprint | Files touched | Tag | Notes |
|---|---|---|---|
| S25.1 | `game_state.gd` | 🟥 CUT (Arc G) | Left dormant in Arc F; flagged for Arc G deletion |
| S25.1 | `game_flow.gd` | 🟨 RE-SKIN | Old Screen enum branches (SHOP, BROTTBRAIN_EDITOR, OPPONENT_SELECT) left dormant in Arc F |
| S25.1 | `main_menu_screen.gd` | 🟩 KEEP | Minor addition only |
| S25.1 | NEW `run_state.gd` | 🟩 KEEP | New file; no cut risk |
| S25.1 | NEW `run_start_screen.gd` | 🟩 KEEP | New file; no cut risk |
| S25.2 | `arena_renderer.gd` | 🟨 RE-SKIN | Major extension; core draw logic preserved; no deletes |
| S25.2 | `charm_anims.gd` | 🟩 KEEP | Likely no changes; confirm multi-bot compat |
| S25.3 | `brottbrain.gd` | 🟨 RE-SKIN | Gut internals; keep class name + API. Trigger/Action enums: add `# CUT: Arc G` comment but do NOT delete in Arc F (save-compat stubs) |
| S25.3 | `combat_batch.gd`, `combat_batch_brain.gd` | 🟩 KEEP | Update to new baseline AI; no structural changes |
| S25.4 | `brottbrain.gd` | 🟨 RE-SKIN | Multi-target extension |
| S25.4 | `opponent_loadouts.gd` | 🟨 RE-SKIN | Replace league pool with archetype pool; old league structure left as dead code with `# CUT: Arc G` comments |
| S25.4 | `opponent_data.gd` | 🟨 RE-SKIN | Update `get_opponent()` API |
| S25.5 | NEW `reward_pick_screen.gd` | 🟩 KEEP | New file |
| S25.5 | `loadout_screen.gd` | 🟩 KEEP | No changes in Arc F; buy flow still present but unreachable from new GameFlow (Arc G removes it) |
| S25.5 | `game_flow.gd` | 🟨 RE-SKIN | Extend |
| S25.6 | `opponent_loadouts.gd` | 🟨 RE-SKIN | Complete archetype generator |
| S25.7 | `game_flow.gd` | 🟨 RE-SKIN | Complete state machine |
| S25.7 | NEW `run_hud_bar.gd` | 🟩 KEEP | New reusable component |
| S25.8 | `result_screen.gd` | 🟨 RE-SKIN | Full layout rework; keep screen transition logic |
| S25.8 | `first_run_state.gd` | 🟩 KEEP | Update copy only; tracking logic preserved |
| S25.9 | `brottbrain.gd` | 🟨 RE-SKIN | Boss AI behavior set added |
| S25.9 | `reward_pick_screen.gd` | 🟩 KEEP | Tier-tinting addition |
| — | `brottbrain_screen.gd` + scenes | 🟥 CUT (Arc G) | Do NOT touch in Arc F — dormant, Arc G deletes |
| — | `shop_screen.gd` | 🟥 CUT (Arc G) | Do NOT touch in Arc F — dormant |
| — | `opponent_select_screen.gd` | 🟥 CUT (Arc G) | Do NOT touch in Arc F — dormant |
| — | `league_complete_modal.gd/.tscn` | 🟥 CUT (Arc G) | Do NOT touch in Arc F — dormant |
| — | `test_s21_2_*`, `test_s21_4_003_*`, `test_s21_3_arena_onboarding.gd` | 🟥 CUT (Arc G) | These tests will fail against the new codebase. Do NOT delete in Arc F — note failures in sprint summaries; Arc G cleans up |

**BrottBrain editor note (critical):** The editor files (`brottbrain_screen.gd` + scenes) are cut in Arc G, not Arc F. In Arc F, Arc F merely stops routing through them via GameFlow. The files remain on disk. Riv must enforce this: if Nutts proposes deleting BrottBrain editor files in Arc F, push back. The Arc G Cut Pass exists specifically to handle this as a clean, test-confirmed removal.

---

## §5 — Hand-off Shape

### Arc F → Arc G (Cut Pass)

Arc F leaves the codebase in a **working but not clean** state. By Arc F exit:
- All live gameplay flows through new `run_state.gd`, `run_start_screen.gd`, `reward_pick_screen.gd`, `run_hud_bar.gd`, reworked `result_screen.gd`, and the encounter generator
- The following files are **dormant** (not reachable from any live game flow but still on disk): `game_state.gd`, `brottbrain_screen.gd` + scenes, `shop_screen.gd`, `opponent_select_screen.gd`, `league_complete_modal.gd/.tscn`, league test files
- `game_flow.gd` has dead Screen enum branches pointing to dormant screens

Arc G's job: delete all the above, clean up dead imports, remove all `# CUT: Arc G` comments, purge the league test suite, update CI matrix, confirm nothing broke.

### Arc F → Arc H (Boss + Polish)

Arc H receives a game where:
- A complete 15-battle run is fully playable with placeholder content
- All 7 encounter archetypes are functional
- Click-to-move and click-to-target work
- IRONCLAD PRIME's boss AI is functional (tuned to < 40% first-attempt win rate) but not polished (no special animations, no boss-specific SFX)
- Run HUD bar and tier-tinting are functional but not art-directed
- First-run tooltip copy is correct but not styled

Arc H work: IRONCLAD PRIME polish (name confirmed, SFX, visual identity), run visual polish (HUD bar art, tier backgrounds, arena scene variety per run), first-run tooltip styling, balance pass informed by HCD's mid-Arc F playtest feedback.

### HCD playtest readiness

**Recommended playtest window: end of S25.7** (after battle-to-battle loop is wired with the encounter generator producing real content).

At S25.7 exit, a player can:
- Start a run, pick a chassis, fight a variety of encounter types
- Pick reward items that affect their loadout
- Use retry when they lose
- Progress through at least 10–12 battles with real content
- The boss will be accessible (S25.9 tunes it, but it exists as a stub at S25.7)

This is a meaningful playtest. HCD feedback from this point informs:
- Boss difficulty calibration (exact tuning done in S25.9)
- Any click-to-move/target feel issues (UX feedback is most valuable here, before the loop is locked)
- Encounter variety pacing (does the run feel right? Do the early battles feel appropriately accessible?)

**Do NOT gate Arc F completion on HCD playtest.** HCD playtest at S25.7 exit is an input to S25.9 (boss tuning); it doesn't block the arc.

---

## Appendix — Sprint timing reference

| Sub-sprint | Name | Est. duration | Cumulative |
|---|---|---|---|
| S25.1 | RunState scaffold + run-start screen | 90–120 min | 1.5–2 hr |
| S25.2 | Multi-target arena renderer | 120–150 min | 3.5–4.5 hr |
| S25.3 | Hardcoded baseline AI (single-target) | 90–120 min | 5–6.5 hr |
| S25.4 | Baseline AI v2 (multi-target) + archetype data | 120–150 min | 7–8.5 hr |
| S25.5 | Reward pick screen + run flow | 90–120 min | 8.5–10.5 hr |
| S25.6 | Encounter generator + distribution | 120 min | 10.5–12.5 hr |
| S25.7 | Battle-to-battle loop + HUD bar | 90–120 min | 12–14.5 hr |
| S25.8 | Run-end screens | 90 min | 13.5–16 hr |
| S25.9 | Boss + Arc F integration validation | 120–150 min | 15.5–18 hr |

**Total: 9 sub-sprints, ~15.5–18 hours of pipeline work.**

---

*Arc F plan authored by Ett. GDD source: PR #299 commit 8cd1f4a. Awaiting HCD greenlight to spawn Riv.*

# Feebus Carderinius

Android 2D action platformer in Godot 4.3. This is a Claude-driven project: the owner sets direction, Claude writes the code and docs. Read `docs/GDD.md` before design work and update `docs/ROADMAP.md` when finishing a task.

## Layout
- `scripts/autoload/` `InputSetup` (all input actions, defined in code) and `GameState` (progress + save).
- `scripts/data/zodiac.gd` sign table and season-from-date logic.
- `scripts/player/player.gd` movement and powers. Powers dispatch in `_use_power()` by sign id.
- `scripts/levels/data_level.gd` builds greybox levels from exported arrays.
- `scripts/objects/` collectibles and interactables. Anything a power affects exposes a method (e.g. `smash()`).
- `scripts/ui/` HUD and touch controls. Touch buttons fire normal input actions; gameplay never reads touch directly.

## Conventions
- Typed GDScript, tabs, `snake_case`. Tuning constants at the top of the script.
- No external assets yet: placeholder art is drawn in `_draw()`.
- Never use real game names, Funko branding, or other third-party IP. Collectible figures are "Bobblebirds".
- New mechanics must be playable with the touch layout in GDD section 7.

## Verification
The cloud sandbox has not been allowed to run the Godot binary, so code in M0 is unverified in-engine. When engine runs are possible: `godot --headless --import` then `godot --headless --quit-after 120` from the repo root and check for script errors.

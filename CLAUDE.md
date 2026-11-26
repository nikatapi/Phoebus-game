# Feebus Carderinius

Android 2D action platformer in Godot 4.3. This is a Claude-driven project: the owner sets direction, Claude writes the code and docs. Read `docs/GDD.md` before design work and update `docs/ROADMAP.md` when finishing a task.

## Layout
- `scripts/autoload/` `InputSetup` (all input actions, defined in code) and `GameState` (progress + save).
- `scripts/data/zodiac.gd` sign table and season-from-date logic.
- `scripts/player/player.gd` movement and powers. Powers dispatch in `_use_power()` by sign id.
- `scripts/levels/data_level.gd` builds greybox levels from exported arrays.
- `scripts/objects/` collectibles and interactables. Anything a power affects exposes a method (e.g. `smash()`).
- `scripts/enemies/` `Enemy` base (contact, stomp, hurt, stun) with `Walker`, `Shooter`, `Projectile`.
- `scripts/ui/` HUD and touch controls. Touch buttons fire normal input actions; gameplay never reads touch directly.

## Physics layers
1 world, 2 player, 3 enemies (value 4), 4 enemy projectiles (value 8). Player and enemies do not block each other; contact is via the enemy's Area2D hurtbox.

## Conventions
- Call duck-typed hooks with `obj.call("hurt", ...)` so typed code compiles.
- Typed GDScript, tabs, `snake_case`. Tuning constants at the top of the script.
- No external assets yet: placeholder art is drawn in `_draw()`.
- Never use real game names, Funko branding, or other third-party IP. Collectible figures are "Bobblebirds".
- New mechanics must be playable with the touch layout in GDD section 8.

## Verification
The cloud sandbox cannot run the Godot binary. Instead, `.github/workflows/android.yml` runs on every push: it imports the project, boots the main scene headless for 300 frames, fails on any script error, then exports a debug APK as the `feebus-debug-apk` artifact. After pushing, check the run with the GitHub MCP actions tools and read failed job logs.

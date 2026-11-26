# Feebus Carderinius: Game Design Document

Version 0.1, November 2026. Living document; decisions marked **Locked** need a conversation before changing.

## 1. Pitch

A 2D action platformer for Android. Feebus, a goldfinch (καρδερίνα) with a collector's itch, explores four elemental worlds gathering lost video game cartridges and Bobblebird figures. Zodiac shrines grant him powers that open new paths, and old levels hide secrets that only later powers can reach.

## 2. Pillars

1. **Feels good under a thumb.** Every mechanic must be playable on a touchscreen without frustration. If it needs pixel precision, it gets cut or made forgiving.
2. **Every collectible does something.** Signs change how you play, cartridges unlock playable microgames, figures fill the nest you return to.
3. **Come back with new powers.** Levels are designed with locked corners the player can see but not yet reach.

## 3. Structure (Locked: hybrid)

- **Level-based**, chosen from a world map. Levels run 3 to 6 minutes.
- **Zodiac powers are permanent unlocks.** The player equips **two** at a time and swaps the active one with a button. Loadouts change at the Nest.
- Earlier levels contain sign-gated secrets (cracked walls for Aries, weak floors for Taurus, hook points for Scorpio, etc.). Revisiting with the right loadout is the main replay loop.
- **The Nest** is the hub: figure shelves, a cartridge console for microgames, and the loadout altar.

## 4. Character

**Feebus**: goldfinch. Red face, black and white head, tan body, yellow wing bars. Readable at 32x32. Personality: earnest, slightly obsessive collector.

Base moveset (no signs needed):

| Move | Detail |
|---|---|
| Run | 140 px/s, quick accel |
| Jump | Variable height (release early to cut) |
| Flutter | One mid-air jump. Birds can fly, so this is capped on purpose |
| Glide | Hold jump while falling: slow descent |
| Peck | Short melee in front; also knocks embers out of the air |
| Stomp | Land on an enemy to hurt it; bounces and refreshes the flutter |

Forgiveness: 0.12s coyote time, 0.15s jump buffer.

## 5. Zodiac powers

Four worlds, one element each, three signs per world. The world's own signs are found inside it; cross-world signs open secrets in earlier worlds.

| World | Sign | Power | Use |
|---|---|---|---|
| Fire: Ember Peaks | Aries | Ram Dash | Burst forward, smash cracked walls |
| | Leo | Roar | Stun nearby enemies |
| | Sagittarius | Arrow Shot | Ranged hit, distant switches |
| Earth: Rootwood | Taurus | Ground Pound | Break weak floors |
| | Virgo | Reveal | Show hidden platforms briefly |
| | Capricorn | Wall Climb | Climb rough walls |
| Air: Cirrus City | Gemini | Twin Decoy | Clone draws enemy aggro |
| | Libra | Scale Swap | Swap places with marked objects |
| | Aquarius | Frost Pour | Water freezes into a platform |
| Water: Brine Reef | Cancer | Shell Guard | Block a hit, reflect shots |
| | Scorpio | Stinger Hook | Grapple to hook points |
| | Pisces | Deep Dive | Free swimming |

**Birth sign:** chosen at first launch; grants a small passive (e.g. +1 heart, faster cooldown) tied to that sign.
**Season bonus:** the real-world zodiac season boosts that sign's power (Aries in season: longer dash). Computed from device date, no network.

## 6. Health and enemies (Locked: hearts + checkpoints)

- Feebus has **3 hearts**. A hit costs one, knocks him back, and gives 1s of invulnerability. Ram Dash is invulnerable.
- **Checkpoint perches** set the respawn point and refill hearts. Falling in a pit costs one heart and returns to the last perch. At zero hearts he respawns at the perch with full hearts; defeated enemies stay defeated.
- Every enemy telegraphs before it attacks, because touch players react slower.

| Enemy | World | Behaviour | HP |
|---|---|---|---|
| Ember Slug | Fire | Patrols, turns at walls and ledges | 1 |
| Kiln Crab | Fire | Stationary; faces Feebus in range, glows, fires a slow ember | 2 |

## 7. Collectibles

**Cartridges** (roughly 3 per world, 12 total). Each unlocks a 1 to 3 minute microgame at the Nest console, in a distinct retro style. All titles are invented parodies (e.g. "Lava Blaster", "Pong-ish"). No real game names or art.

**Bobblebirds** (5 to 8 per world). Big-headed vinyl figures of enemies and bosses, shown on Nest shelves. Our own brand; do not use the Funko name or copy their trade dress.

## 8. Controls

| Touch | Gamepad | Keyboard |
|---|---|---|
| Left / Right (left thumb, slide between) | Left stick / D-pad | A D / arrows |
| Jump (largest button) | A | Space / Z |
| Attack | X | X |
| Power | B | C |
| Swap power (small) | Y / RB | V |

Touch hit areas are 25% larger than the drawn buttons.

## 9. Tech

- Engine: **Godot 4.3**, GDScript (typed), Mobile renderer.
- Viewport 640x360, `canvas_items` stretch, sensor landscape.
- Save: JSON at `user://save.json` via the `GameState` autoload.
- Input actions defined in code (`InputSetup` autoload), so touch, pad and keyboard share one path.
- Art: pixel art, nearest filtering. Until art exists, everything is drawn with primitives in `_draw()`.

## 10. Vertical slice (milestone 1)

Nest hub, Ember Peaks with Aries, Leo, Sagittarius, three levels, one boss, one cartridge microgame, about six Bobblebirds. Goal: prove the movement is fun on a phone before building more worlds.

## 11. Open questions

- Monetisation: paid upfront, free with demo, or none?
- Art direction: commission a pixel artist, or use generated/placeholder art for longer?
- Story beats: why are the cartridges and figures scattered?

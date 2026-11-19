# BRAINROT BAY - roblox-brainrot-01

[![make.fun](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/kanbara12/roblox-brainrot-01-kanbara12-v2/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/kanbara12/roblox-brainrot-01-kanbara12-v2/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

A 3D steal-a-brainrot game on a tropical island, built for make.fun's
[roblox-brainrot-01](https://make.fun/bounty/roblox-brainrot-01) bounty.
Play it on Roblox (link in `PLAY.json` once the experience is published),
or sign up to make.fun with referral code `wfzk99wk`.

## The game

Absurd meme brainrots ride a glowing conveyor out of the SPAWN GATE, past
the pier, toward the EXIT portal. Click one to buy it if you have the cash
and a free slot, and it walks home to your base, where it earns money every
second. Spend that money on the next tier, all the way from a $10 Noobini
Pizzanini to a $250,000 Garama and Madundung.

The cast is 15 brainrots across 7 rarities: Common, Rare, Epic, Legendary,
Mythic, Brainrot God, Secret. Each one is a multi-part 3D rig of 12 to 25
parts (wedges, spheres, cylinders, neon, goofy SurfaceGui faces) with a
BillboardGui showing its name, rarity badge, mutation pill, +$/s and price.

Mutations come in three kinds: Golden x2, Diamond x5, Rainbow x10. Each
looks different: gold shine, glassy cyan, and a hue-cycling light.

Stealing is the other half of the game. Click a brainrot on another base,
or on the solo rival's plot, to carry it home over your head. A slap
(button or `E`) knocks it out of a thief's hands. Lock your base for 30
seconds behind a Laser Lock Dome, with a 60-second cooldown (`L`).

At $50,000 you can rebirth: cash and brainrots reset for a permanent x2
income multiplier, plus a golden aura. It stacks to x1024.

Every few minutes the bay runs an event: a Tsunami Wave, where you have to
reach the lighthouse high ground or lose what you carry, or a Golden Hour,
which doubles the odds of Rare and better spawns for 60 seconds.

The solo rival plot keeps stealing playable with one player in Studio. The
rival's base comes stocked with a Common, a Golden Legendary and a Diamond
Mythic behind a Lock Shield that cycles open and shut.

## How it is built

Rojo-first. The world is static instances in `default.project.json`:
island, pier, glowing conveyor with chevrons, SPAWN GATE arch, EXIT
portal, lighthouse high ground, three 8-slot bases, palms, lamps. All game
logic is Luau under `src/`:

- `src/shared/BrainrotCatalog.luau`: the 15 definitions, rarity and
  mutation rolls, costs and income.
- `src/shared/BrainrotRenderer.luau`: multi-part rig builder, mutation
  visuals, overhead billboards, cash popups.
- `src/shared/PlotLayout.luau`: base and slot coordinates.
- `src/server/GameState.luau`: the one place server state lives.
- `src/server/ConveyorService.luau`, `IncomeService.luau`,
  `StealService.luau`, `RebirthService.luau`, `EventService.luau`,
  `RivalPlotService.luau`: one job each, all mechanics as named functions.
- `src/client/HudController.luau` and `Game.client.luau`: cash and income
  readout, base slot list, rarity catalog, event banners, lock, rebirth
  and slap buttons.

`main.ts` (Node 22, standard library only) hands the game in: it copies
`game.rbxl`, `src/`, `screenshots/` and `PLAY.json` to `/output` and writes
`/output/dossier.json` with `vendor/makefun-roblox.ts`, the kit's copy,
unchanged.

## Build it

    ~/.local/bin/rojo build default.project.json --output game.rbxl
    mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

`screenshots/` holds captures of the game running in Roblox Studio; the
first by name is the cover and the game's thumbnail on Roblox. `PLAY.json`
names the published place once the experience is live.

The rules are on the bounty's page
([/bounty/roblox-brainrot-01](https://make.fun/bounty/roblox-brainrot-01))
and in the kit's `RULES.txt`.

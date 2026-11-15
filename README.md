# OpenXP Forever Data

Quest chains, quest levels and quest givers for the [OpenXP](https://github.com/mjared123/OpenXP) leveling guide addon
in WoW Forever, for players who don't use Questie.

Data from ForeverDB.net (https://foreverdb.net)

## What it does

OpenXP ships no quest database of its own. When a guide step tells you to pick up a quest that the quest giver doesn't
offer yet, OpenXP needs to know why. With this addon installed it can tell you:

- **The quest is part of a chain.** The card lists the quests you still have to do first, in order, and offers "Do the
  chain" to walk you through them or "Skip this step" to move on.
- **You are below the level the quest is offered from.** The card says which level you need.
- **Who gives and takes each quest in the chain, and where they are**, so the chain walk can name the quest giver and
  point the arrow at them.

Example: the Horde 22-23 Hillsbrad guide sends you to Apothecary Lydon for Blood of Innocents. He only offers it after
the four-quest chain that ends with Journey to Tarren Mill. Without quest data the step just sits there. With this
addon the card shows the chain and where it starts.

This addon does nothing on its own. It has no window, no settings and no slash commands. It is one data file that
OpenXP reads when both addons are loaded.

## Where each rule comes from

Every rule carries its source, and OpenXP shows it under the warning:

| Shown in OpenXP | In the data | Meaning |
|---|---|---|
| ForeverDB.net, seen in WoW Forever | `foreverdb_verified` | WoW Forever data, or a Classic rule that players' ForeverDB addons also saw hold in WoW Forever |
| ForeverDB.net, Classic data (not confirmed in WoW Forever) | `cmangos_classic` | Classic data from CMaNGOS classic-db. It may differ in WoW Forever |

Classic rules are right most of the time, but WoW Forever changed some quests. That is why OpenXP always offers "Skip
this step" next to a warning. If a Classic rule blocks a quest you can in fact pick up, skip the step and report it.

## Requirements

- WoW Forever
- [OpenXP](https://github.com/mjared123/OpenXP) in a version that reads quest data from other addons
  (`RXPGuides.RegisterQuestProvider`)

If Questie is installed, OpenXP asks Questie first and uses this addon for the quests Questie doesn't know.

## Install

1. Download `OpenXP_ForeverData.zip` from the [releases page](https://github.com/VikingOwl91/OpenXP_ForeverData/releases).
2. Unpack it into `World of Warcraft/_forever_/Interface/AddOns/`, so that
   `AddOns/OpenXP_ForeverData/OpenXP_ForeverData.toc` exists.
3. Start the game, or type `/reload`, and enable "OpenXP Forever Data" in the addon list.

## CurseForge

A CurseForge project for this addon exists, but no file is published there yet. The addon does nothing without the
OpenXP change that reads quest data from other addons (https://github.com/mjared123/OpenXP/pull/39), so files will go
up on CurseForge once an OpenXP release contains it. Until then the releases page here is the only download.

## What is in it

This release holds 2,076 quests: every quest OpenXP's guides use, plus the quests those need first. 995 of them have a
chain rule, 441 of which were seen in WoW Forever and 554 of which are Classic data.

Known limits:

- 21 quests the guides use are not in ForeverDB's data and have no rules here.
- An order players merely saw ("offered after quest X") is not treated as a rule and never blocks a step.
- A Classic level requirement is left out when players finished the quest below that level in WoW Forever.
- Quest giver names are in English.
- Only about a third of the quests have a position for their objectives.

## Reporting wrong data

The data comes from ForeverDB.net. A wrong rule is best fixed there, so every addon that uses the data gets the fix.
If the rule is right on ForeverDB.net but wrong here, or OpenXP shows it wrongly, open an issue in this repository with
the quest name and what the card said.

## For addon authors

`Data.lua` sets one global table:

```lua
OpenXP_ForeverData = {
    format = 1,
    version = "2026-11-15.d2e4316c",  -- ForeverDB's data version
    build = "1.60.1.70938",           -- WoW Forever client build of that data
    credit = "Data from ForeverDB.net (https://foreverdb.net)",
    quests = {
        [1066] = {
            level = 23,                                   -- quest level
            min = 13, minSrc = "cmangos_classic",         -- level it's offered from
            all = {1065}, preSrc = "cmangos_classic",     -- quests that all have to be done first
            -- any = {ids}   one of these has to be done first
            -- excl = {ids}  doing one of these locks this quest out
            -- after = id    players were offered it after this quest; an order, not a rule
            giver = 2216, giverType = "n", giverSrc = "foreverdb_verified",  -- n npc, o object, i item
            start = {"Apothecary Lydon", 1424, 61.5, 19.2}, startSrc = "foreverdb_verified",
            finish = {"Apothecary Lydon", 1424, 61.5, 19.2}, finishSrc = "foreverdb_verified",
            -- objs = {{uiMapId, x, y}, ...}  one place per objective
        },
    },
}
```

Places are `{name, uiMapId, x, y}` with x and y in percent of the map. `uiMapId` is 0 when the place isn't known. Every
field is optional. Each `...Src` field says where the value next to it comes from.

If you use this data in your own work, the licence below applies to it.

## Rebuilding

`Data.lua`, `NOTICE.txt` and the `.toc` are generated. Don't edit them by hand.

1. Download the ForeverDB addon (https://foreverdb.net/downloads/addon-manifest.json lists the current zip and its
   SHA-256) and unzip it.
2. In a checkout of OpenXP, run
   `python3 tools/compile_foreverdb.py --foreverdb PATH/ForeverDB --out PARENT`
   where `PARENT` is the folder that holds this repository. It writes into `PARENT/OpenXP_ForeverData/`.

The output is the same for the same inputs, so a diff of `Data.lua` shows exactly what changed in ForeverDB's data or
in OpenXP's guides.

### Automatic updates

A GitHub Actions workflow (`.github/workflows/update-data.yml`) does this once a day. It reads ForeverDB's manifest,
downloads the ForeverDB addon and its current quest data files, checks each download against the SHA-256 in the
manifest, and rebuilds `Data.lua` with the compiler and guides from OpenXP. When a rule, level or quest giver changed it
commits the result, tags it `vYYYY.MM.DD` and attaches the zip to a new release. Positions shift by a fraction of a
percent all the time, so position changes alone are released at most once a week. A rebuild that loses more than a
tenth of the quests stops with an error.

The repository variables `OPENXP_REPO` and `OPENXP_REF` choose which OpenXP checkout the compiler and guides come
from. Without them it uses `mjared123/OpenXP` at `main`. `.github/scripts/rebuild.sh PATH/OpenXP` runs the same
rebuild on your machine.

## Licence and credits

GPL-3.0 with ForeverDB.net's attribution term (GPL-3.0 section 7(b)).

- `LICENSE.txt` is ForeverDB's licence file, unchanged.
- `COPYING.txt` is the full text of the GPL.
- `NOTICE.txt` says which data comes from where: ForeverDB.net, and through it CMaNGOS classic-db
  (https://github.com/cmangos/classic-db, GPL-3.0).

If you pass this data on, keep the line that starts `-- Data: ForeverDB.net (https://foreverdb.net)` at the top of
`Data.lua` and show "Data from ForeverDB.net (https://foreverdb.net)" in your credits.

OpenXP itself is a separate addon under CC BY-NC-SA 4.0 and contains none of this data.

The icon (`icon.tga`) is not part of the data and not under the GPL. It is based on OpenXP's logo and is licensed, like
OpenXP, under CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/).

World of Warcraft and WoW Forever are trademarks or property of Blizzard Entertainment, Inc. This addon is not
affiliated with or endorsed by Blizzard Entertainment, ForeverDB.net or the CMaNGOS project.

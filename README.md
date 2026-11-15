# OpenXP Forever Data

Quest chains, quest levels and quest givers for the [OpenXP](https://github.com/mjared123/OpenXP) leveling guide addon
in WoW Forever.

Data from ForeverDB.net (https://foreverdb.net)

OpenXP ships no quest database of its own. With this addon installed, and without Questie, OpenXP can still tell you
that a quest needs another one first, which level it is offered from, and who gives it and where. Every rule shows
where it comes from:

- `foreverdb_verified`: WoW Forever data, or a Classic rule that players' ForeverDB addons also saw hold in WoW Forever
- `cmangos_classic`: Classic data (CMaNGOS classic-db), not confirmed in WoW Forever. It can be wrong for Forever, so
  OpenXP always offers to skip the step.

This addon does nothing on its own. It is one data file, `Data.lua`, that OpenXP reads when both are loaded.

## Install

Download the zip from the releases page and unpack it into `World of Warcraft/_forever_/Interface/AddOns/`, so that
`AddOns/OpenXP_ForeverData/OpenXP_ForeverData.toc` exists. Enable "OpenXP Forever Data" in the addon list.

## Rebuilding

`Data.lua`, `NOTICE.txt` and the `.toc` are generated. Don't edit them by hand.

1. Download the ForeverDB addon (https://foreverdb.net/downloads/addon-manifest.json lists the current zip and its
   SHA-256) and unzip it.
2. In a checkout of OpenXP, run
   `python3 tools/compile_foreverdb.py --foreverdb PATH/ForeverDB --out PARENT`
   where `PARENT` is the folder that holds this repository. It writes into `PARENT/OpenXP_ForeverData/`.

The output is the same for the same inputs, so a diff of `Data.lua` shows exactly what changed in ForeverDB's data or
in OpenXP's guides.

## Licence

GPL-3.0 with ForeverDB.net's attribution term (GPL-3.0 section 7(b)). `LICENSE.txt` is ForeverDB's licence file
unchanged, `COPYING.txt` is the GPL's full text, and `NOTICE.txt` says which data comes from where: ForeverDB.net, and
through it CMaNGOS classic-db.

If you pass this data on, keep the line that starts `-- Data: ForeverDB.net (https://foreverdb.net)` at the top of
`Data.lua` and show "Data from ForeverDB.net (https://foreverdb.net)" in your credits.

Not affiliated with or endorsed by Blizzard Entertainment, ForeverDB.net or the CMaNGOS project.

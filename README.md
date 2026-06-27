# Item Enchantments – Updated

Adds random modifiers to weapons, armor, containers, and even songs so every drop can feel special. This fork keeps the original Aquaterion mechanics, fixes long‑standing bugs, and layers in new QoL helpers like enchantment storage and boss events.

## Highlights

- Global toggles for every modifier plus a source filter (`all` vs `Drops & World Only`) so loot flow matches your world.
- Bosses can spawn anywhere, scale with population, and now always hand out a reward thanks to the new Enchanted Papyrus fallback.
- New “Inscribe” action lets you stash enchantments on papyrus and reapply them later, complete with rarity‑colored inventory borders.
- Tinkerers can disassemble crafted gear, recycle enchantments, and reroll bad prefixes while respecting durability rules.
- Hover text, inventory tiles, and modifier orbs all share rarity coloring, making it easy to spot the best gear at a glance.

## Enchanted Papyrus

1. Defeat a modifier boss. If you don’t have a valid item to enchant, the reward becomes an Enchanted Papyrus instead of being lost.
2. Hover over the scroll to see the stored rarity color and tooltip.
3. Right‑click the scroll on any unmodified, compatible item to “Inscribe” that enchantment. The scroll is consumed and the item rolls the best possible modifier within that rarity tier.

## Configuration

All options are exposed in `modinfo.lua`. Highlights:

- `enchantment_sources`: `all` or `no_craft`.
- Individual enable/disable toggles for every modifier (offense, defense, fueled, tools, projectiles, songs, etc.).
- Boss player slowing toggle.

## Changelog

**Version 1.1 - Enchanted Scrolls & Forging**

- Boss kills now hand out an Enchanted Papyrus if no eligible gear is found, and bosses use a world indicator.
- Added Hemorrhaging (bleed-on-hit) alongside new chilling Sub-Zero variants.
- Scrolls can reroll existing enchanted items.
- Disenchanting or disassembling enchanted gear yields an Enchanted Papyrus; combine two matching scrolls to upgrade to the next tier.
- Removed Bad/Worst rarities.
- Fixed planar damage being lost on every hit while the mod was active.
- Damage enchantments (Pointy/Sharp/Razor-Sharp) now also boost the planar damage of planar weapons, not just their physical damage.
- Fixed certain weapon attacks losing their range and position overrides.

**Version 1.0 - Refresh & Toggles**

- Updated Aquaterion’s original mod to the DST API 10 baseline and fixed bugs.
- Added enable/disable toggles for each enchantment in the settings.
- Added an enchantment acquisition toggle: “All Sources” matches the original, while “Drops & World Only” limits enchantments to mob drops and spawned world items.

[h1]Item Enchantments - Updated[/h1]
[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1306918089&searchtext=Item+Enchantments]Original by Aquaterion[/url]

[b]This mod adds a chance for items to spawn with powerful (and not so powerful) enchantments.[/b]

[h1]Latest Patch Notes:[/h1]
[b]-V1.0-[/b]
[list]
[*]Updated code and fixed bugs
[*]Added toggles for each Enchantment in the settings
[*]Added a toggle to change how Enchantments are acquired. "All Sources" is the same as the orignal. "Drops & World Only" Enchantments only come from mob drops or spawned world items.
[/list]

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

**Version 1.1 - Enchanted Scrolls**

- Added the Enchanted Papyrus prefab, along with a “Inscribe” action to store and apply enchantments later.
- Boss modifier orbs now spawn a scroll if the player lacks eligible gear, preventing wasted drops.

**Version 1.0 - Refresh & Toggles**

- Updated Aquaterion’s original mod to the DST API 10 baseline, fixed bugs, and exposed config toggles for every enchantment.

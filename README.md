# Item Enchantments - Updated

A Don't Starve Together mod that lets weapons, armor, tools, clothing, containers and even instruments roll powerful random enchantments. This fork keeps the spirit of [Aquaterion's original mod](https://steamcommunity.com/sharedfiles/filedetails/?id=1306918089), fixes long-standing bugs, and expands it with new enchantments, enchanted bosses, a scroll economy, and per-enchantment configuration.

## Highlights

- **60+ enchantments** across nine item categories, each with its own rarity tier.
- **Enchanted bosses**: ordinary creatures can awaken as scaled-up named bosses that reward enchantments on death.
- **A full enchanting economy**: reclaim enchantments as scrolls, combine scrolls into higher tiers, re-roll gear, and disassemble crafted items for parts.
- **Placement rules** keep rolls sensible - chop enchants only appear on things that chop, songs only on instruments, and so on.
- **Rarity coloring everywhere**: item names, tooltips, inventory borders and boss auras all share the same color coding.
- **Every enchantment has an on/off toggle** in the mod configuration, plus a source filter for how enchantments enter your world.

## How Enchanting Works

Every item holds **one** enchantment at a time, at one of five rarities:

| Rarity | Tier |
| --- | --- |
| Good | Common, small bonuses |
| Rare | Solid workhorse enchants |
| Epic | Build-defining perks |
| Legendary | Major power spikes |
| Mythic | The chase tier |

**Getting enchanted gear**
- **Crafting** - with default settings, crafted items have a 40% chance to roll an enchantment (can be disabled with the "Drops & World Only" source filter).
- **Drops & world items** - creature drops and world-generated items can spawn enchanted.
- **Bosses** - enchanted bosses reward the killer with an enchantment of the boss's rarity, applied to eligible gear or handed over as an Enchanted Papyrus. Mythic bosses reward every player nearby.

**Enchanted Papyrus (scrolls)**
- **Inscribe**: right-click a scroll onto an item to enchant it at the scroll's rarity. Works on already-enchanted items to re-roll them.
- **Combine**: merge two scrolls of the same rarity into one of the next tier.
- Scrolls come from boss kills, disenchanting, and disassembling enchanted gear.

**Magic Duct Tape** (craft: 1 Tentacle Spots + 1 Silk, Science II)
- Right-click it onto enchanted gear to **disenchant**: the enchantment comes back as an Enchanted Papyrus of the same rarity.
- There's a **5% chance the item is destroyed** in the process (Winona never botches it).
- The tape itself can be enchanted - see [Magic Duct Tape enchantments](#magic-duct-tape-1).

**Disassembly**
- While wearing **Tinkerer's** or **Master Tinkerer's** head gear, right-click any crafted item to disassemble it back into its full ingredients (enchanted items also return their scroll). Costs 25% (Tinkerer's) or 10% (Master Tinkerer's) of the head item's durability.

## Enchantments

### Weapons

| Enchantment | Rarity | Effect |
| --- | --- | --- |
| Pointy | Good | +10% damage. |
| Sharp | Rare | +25% damage. |
| Hemorrhaging | Rare | Hits apply a stacking bleed (up to 5 stacks) that ticks for 6 seconds. |
| Rushing | Rare | Landing a hit grants +25% movement speed for 5 seconds. |
| Fiery | Epic | 50% chance per hit to set the target on fire. |
| Icey | Epic | 50% chance per hit to chill the target - repeated hits freeze it. |
| Executioner's | Epic | +100% weapon damage against targets below 25% health. |
| Duelist's | Epic | +35% damage while exactly one enemy is targeting you. |
| Vampiric | Epic | Kills build a streak; hits have a 15% chance to repair the weapon by 1% per kill in the streak. |
| Lifestealing | Legendary | 25% of hits heal you for a share of your *missing* health - more from large creatures and bosses, nothing from mindless targets. |
| Reaping | Legendary | Kills have a 15% chance to drop one extra loot roll. |
| Razor-sharp | Mythic | +50% damage. |
| Ghost Strike | Mythic | +10 attack range - a spectral double delivers your attacks. 2.5s between strikes, 3× durability drain. Melee only. |
| Moonstruck | Mythic | +40 planar damage at night, +80 during a full moon. Dormant during the day. |

> Damage enchantments (Pointy/Sharp/Razor-sharp) also boost the planar damage of planar weapons, not just their physical damage.

### Tools

| Enchantment | Rarity | Effect |
| --- | --- | --- |
| Feller's | Rare | Chopping does double work per swing. |
| Prospector's | Rare | Finishing a mining job has a 10% chance to yield a bonus gold nugget or gem. |
| Resource-hungry | Legendary | Gathering builds a streak; chance to repair the tool based on it. Also rolls on fishing rods. |
| Laborer's | Legendary | +1 work per swing (chop, mine, dig, hammer). |
| Resonant | Mythic | Every 3rd swing echoes, instantly repeating the work for free. |

### Durability (weapons, tools & armor)

| Enchantment | Rarity | Effect |
| --- | --- | --- |
| Steady | Good | −25% durability usage. |
| Sturdy | Rare | −50% durability usage. |
| Unbreakable | Mythic | Never loses durability. |

### Armor

| Enchantment | Rarity | Effect |
| --- | --- | --- |
| Resistant | Good | 10% less damage taken while worn. |
| Protective | Rare | 25% less damage taken while worn. |
| Thorny | Rare | Reflects 10-20% of damage taken back at the attacker (better armor reflects more). |
| Self-mending | Epic | Repairs itself 1% every 30 seconds while not worn. |
| Flaming | Legendary | Damage taken has a chance to ignite the attacker. Rarely singes the wearer too. |
| Freezing | Legendary | Damage taken has a chance to chill the attacker. Rarely chills the wearer too. |
| Zapping | Legendary | Slowly charges up to 7 orbs. While charging, you take 40% less damage and attackers get struck by lightning and teleported away (consuming an orb). Careless owners who let it fully charge get the discharge themselves! |
| Lightweight | Legendary | +25% movement speed while worn. |
| Untouchable | Mythic | Your health can't be damaged while it's worn - blocked damage wears your armor instead. |
| Umbral | Mythic | While your sanity is below 30%, shadow creatures ignore you. |

> Damage-reduction enchantments stack **multiplicatively** across equipped pieces, and the damage they block still wears down your armor.

### Fueled Items

| Enchantment | Rarity | Effect |
| --- | --- | --- |
| Efficient | Good | −10% fuel usage. |
| Economical | Rare | −25% fuel usage. |
| Radiant | Rare | +30% light radius while lit. |
| Warming | Rare | Radiates gentle warmth while lit. |
| Brisk | Rare | Radiates a pleasant chill while lit. |
| Solar | Epic | Slowly recharges in daylight - much faster under a full moon - while off and not being carried. |
| Geothermal | Epic | Slowly refuels while near a fire or other heat source, carried or on the ground. |

### Clothing & Wearables

| Enchantment | Rarity | Effect |
| --- | --- | --- |
| Dapper | Good | Small sanity boost while worn. |
| Insulating | Rare | +60 winter insulation while worn. |
| Shaded | Rare | +60 summer insulation while worn. |
| Fleet-footed | Rare | Canes only: walking speed is increased even further. |
| Satiating | Epic | Hunger drains 15% slower while worn. |
| Loyal | Epic | Bound to you: auto-equips on pickup and stays with you through death. |
| Tinkerer's | Legendary | Head slot: lets you disassemble crafted items, for a large chunk of this item's durability. |
| Master Tinkerer's | Mythic | As Tinkerer's, but each disassembly costs only a small chunk of durability. |

### Songs (Instruments)

| Enchantment | Rarity | Effect |
| --- | --- | --- |
| Song of Warmth | Rare | Listeners' body temperature drifts toward comfort for 30 seconds. |
| Song of Irritation | Rare | Taunts nearby enemies into attacking you. |
| Song of Dapperness | Epic | Nearby players regain 25 sanity over 25 seconds. |
| Song of Courage | Epic | Nearby players deal +15% damage for 20 seconds. |
| Song of Haste | Epic | Nearby players move 25% faster for 15 seconds. |
| Song of Regeneration | Legendary | Nearby players regain 25 health over 25 seconds. |
| Song of Stone | Legendary | Nearby players take 50% less damage for 10 seconds. Wears the instrument 3× faster. |
| Song of Reanimation | Mythic | Nearby ghost players are revived. |

### Projectiles

| Enchantment | Rarity | Effect |
| --- | --- | --- |
| Speedy | Rare | +50% projectile speed. |
| Hurtful | Legendary | While flying to its target, the projectile also hits everything it touches. |

### Containers & Structures

| Enchantment | Rarity | Effect |
| --- | --- | --- |
| Sub-zero | Rare | Fridges keep food fresh twice as long. |
| Unwithering | Rare | A skinned backpack's skin never decays. |
| Desiccating | Rare | Drying racks finish in half the time. |
| Fireproof | Epic | The container can't catch fire. |
| Chilly | Legendary | The container preserves food like a fridge. |

### Magic Duct Tape

| Enchantment | Rarity | Effect |
| --- | --- | --- |
| Gambler's | Rare | Disenchanting instead re-rolls the enchantment at the same rarity. The 5% destruction risk still applies - that's the gamble. |
| Enchanted | Epic | Disenchanting also fully repairs the item, and removes the destruction risk. |
| Reallocating | Epic | The reclaimed scroll comes back one rarity **higher** than the removed enchantment. |
| Everlasting | Legendary | The tape survives being used. |

## Enchanted Bosses

Ordinary creatures around the world can awaken as enchanted bosses:

- Bigger, named, and color-coded by rarity, with a world map indicator.
- 2× damage, 1.5× health, extended attack range; smaller bosses also attack faster.
- Optional aura (config toggle) that periodically slows the boss's current target.
- Boss rarity scales with the creature - small critters roll Good, giants can roll Mythic.
- The killer is always rewarded; Mythic bosses give every nearby player a chance at a reward.

## Configuration

All options live in the in-game mod configuration screen:

- **Enchantment Sources** - `All Sources` (crafting, drops, and world items) or `Drops & World Only`.
- **Individual toggles** for every single enchantment.
- **Boss slowing** - turn the boss target-slowing aura on or off.

Disabled enchantments stop rolling immediately; gear that already has one simply loses it on load.

## Changelog

### Version 1.2 - New Enchantments & Balance Pass

**New enchantments**
- Weapons: Executioner's, Duelist's, Reaping, and Moonstruck (planar damage at night, doubled on full moons).
- Armor: Self-mending and Umbral (shadow creatures ignore you below 30% sanity).
- Tools: Feller's, Prospector's, Laborer's, and Resonant.
- Fueled gear: Radiant, Warming, Brisk, and Geothermal.
- Clothing: Dapper, Insulating, Shaded, and Satiating.
- Songs: Courage, Warmth, Haste, and Stone.
- Gambler's Duct Tape: re-rolls an enchant at the same rarity instead of removing it.
- Enchantments now follow placement rules, so they only roll on items they make sense on.

**Balance**
- Razor-sharp is now mythic at +50% damage (was epic at +75%).
- Damage-reduction enchantments now stack multiplicatively across equipment. Zapping's shield while orbs charge is now 40% (was 99%).
- Lightweight is now legendary - permanent +25% speed was too strong for a common roll.
- Lifestealing now procs on 25% of hits as intended (was accidentally 75%).
- Song of Dapperness is now epic. Song of Irritation is now rare.
- Removed the joke enchants: Heavyweight, Sluggish and Telepoofing (weapon and armor). Gear that already has one simply loses the enchant.
- Reallocating Duct Tape now has a real effect: the reclaimed scroll comes back one rarity higher.

**Fixes**
- Flaming/Freezing thorn descriptions no longer hide their small chance of affecting the wearer.

**Changes**
- Removed all remaining joke enchants.

### Version 1.1 - Enchanted Scrolls & Forging

- Boss kills now hand out an Enchanted Papyrus if no eligible gear is found, and bosses use a world indicator.
- Added Hemorrhaging (bleed-on-hit) alongside new chilling Sub-Zero variants.
- Scrolls can reroll existing enchanted items.
- Disenchanting or disassembling enchanted gear yields an Enchanted Papyrus; combine two matching scrolls to upgrade to the next tier.
- Removed Bad/Worst rarities.
- Fixed planar damage being lost on every hit while the mod was active.
- Damage enchantments (Pointy/Sharp/Razor-sharp) now also boost the planar damage of planar weapons, not just their physical damage.
- Fixed certain weapon attacks losing their range and position overrides.

### Version 1.0 - Refresh & Toggles

- Updated Aquaterion's original mod to the DST API 10 baseline and fixed bugs.
- Added enable/disable toggles for each enchantment in the settings.
- Added an enchantment acquisition toggle: "All Sources" matches the original, while "Drops & World Only" limits enchantments to mob drops and spawned world items.

## Credits

- **Original mod**: [Item Enchantments by Aquaterion](https://steamcommunity.com/sharedfiles/filedetails/?id=1306918089)
- **This fork**: Im So HM02

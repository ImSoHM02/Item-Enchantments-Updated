description =
[[

Version 1.2 - New Enchantments & Balance Pass
New enchantments:
- Weapons: Executioner's, Duelist's, Reaping, and Moonstruck (planar damage at night, doubled on full moons).
- Armor: Self-mending and Umbral (shadow creatures ignore you below 30% sanity).
- Tools: Feller's, Prospector's, Laborer's, and Resonant.
- Fueled gear: Radiant, Warming, Brisk, and Geothermal.
- Clothing: Dapper, Insulating, Shaded, and Satiating.
- Songs: Courage, Warmth, Haste, and Stone.
- Gambler's Duct Tape: re-rolls an enchant at the same rarity instead of removing it.
- Enchantments now follow placement rules, so they only roll on items they make sense on.
Balance:
- Razor-sharp is now mythic at +50% damage (was epic at +75%).
- Damage-reduction enchantments now stack multiplicatively across equipment. Zapping's shield while orbs charge is now 40% (was 99%).
- Lightweight is now legendary - permanent +25% speed was too strong for a common roll.
- Lifestealing now procs on 25% of hits as intended (was accidentally 75%).
- Song of Dapperness is now epic. Song of Irritation is now rare.
- Removed the joke enchants: Heavyweight, Sluggish and Telepoofing (weapon and armor). Gear that already has one simply loses the enchant.
- Reallocating Duct Tape now has a real effect: the reclaimed scroll comes back one rarity higher.
Fixes:
- Flaming/Freezing thorn descriptions no longer hide their small chance of affecting the wearer.
Changes:
- Removed all remaining joke enchants.

Version 1.1 - Enchanted Scrolls & Forging
- Boss kills now hand out an Enchanted Papyrus if no eligible gear is found, and bosses use a world indicator.
- Added Hemorrhaging (bleed-on-hit) alongside new chilling Sub-Zero variants.
- Scrolls can reroll existing enchanted items.
- Disenchanting or disassembling enchanted gear yields an Enchanted Papyrus; combine two matching scrolls to upgrade to the next tier.
- Removed Bad/Worst rarities
- Fixed planar damage being lost on every hit while the mod was active.
- Damage enchantments (Pointy/Sharp/Razor-sharp) now also boost the planar damage of planar weapons, not just their physical damage.
- Fixed certain weapon attacks losing their range and position overrides.

Version 1.0 - Refresh & Toggles
Updated code and fixed bugs
Added toggles for each Enchantment in the settings
Added a toggle to change how Enchantments are acquired. "All Sources" is the same as the orignal. "Drops & World Only" Enchantments only come from mob drops or spawned world items.
]]

name                        = "Item Enchantments - Updated"
author                      = "Im So HM02 (Original by Aquaterion)"
version                     = "1.2"
forumthread                 = ""
icon                        = "modicon.tex"
icon_atlas                  = "modicon.xml"
api_version                 = 10
all_clients_require_mod     = true
dst_compatible              = true
client_only_mod             = false
priority 					= -240
server_filter_tags          = {"Modifiers", "Enchantments", "Perks", "Bosses"}

--Configs
local TrueFalse	            =   {{description 	= "True",           data = true},
                                {description 	= "False",          data = false}}

local Empty                 =   {{description = "", data = 0}}

local function Title(title) --Allows use of an empty label as a header
return {name=title, options=Empty, default=0,}
end

local SEPARATOR = Title("")

configuration_options =
{
    Title("Enchantment Acquisition"),
    {
        name = "enchantment_sources",
        label = "Enchantment Sources",
        hover = "Choose which sources can give enchanted items",
        options =
        {
            {description = "All Sources", data = "all", hover = "Crafted items (40%), enemy drops, and world-generated items can be enchanted"},
            {description = "Drops & World Only", data = "no_craft", hover = "Only enemy drops and world-generated items can be enchanted (no crafting enchantments)"},
        },
        default = "all",
    },
    Title("Enchantment Toggles"),
    -- Individual Enchantment Toggles
    {
        name = "enable_untouchable",
        label = "Enable Untouchable",
        hover = "100% Damage reduction",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_unbreakable",
        label = "Enable Unbreakable",
        hover = "Infinite Durability",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_ghost_strike",
        label = "Enable Ghost Strike",
        hover = "Attacking a target will instead create a ghost that does the attack for you (increasing your range)",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_song_of_reanimation",
        label = "Enable Song of Reanimation",
        hover = "When heard, nearby ghost players will be resurrected from death",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_master_tinkerers",
        label = "Enable Master Tinkerer's",
        hover = "While equipped, the wearer can disassemble crafted items for a small portion of this item's durability. Enchantments are preserved onto other items if any. Enchantments are upgraded",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_freezing",
        label = "Enable Freezing",
        hover = "Damage taken has a chance to cool the attacker (Doesn't effect wearer in anyway)",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_flaming",
        label = "Enable Flaming",
        hover = "Damage taken has a chance to burn the attacker (Doesn't effect wearer in anyway)",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_resource_hungry",
        label = "Enable Resource-hungry",
        hover = "Destruction dealt has a chance of slightly repairing the tool depending on destruction streak",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_lifestealing",
        label = "Enable Lifestealing",
        hover = "Damage dealt has a chance to heal the player slightly",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_song_of_dapperness",
        label = "Enable Song of Dapperness",
        hover = "When heard, nearby players will get a sanity regeneration buff for a short duration",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_song_of_regeneration",
        label = "Enable Song of Regeneration",
        hover = "When heard, players will get a health regeneration buff for a short duration",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_hurtful",
        label = "Enable Hurtful",
        hover = "While travelling to its target, anything it touches also gets hit",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_hemorrhaging",
        label = "Enable Hemorrhaging",
        hover = "Hits apply a stacking bleed that deals damage over time",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_everlasting",
        label = "Enable Everlasting",
        hover = "Infinite Durability",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_chilly",
        label = "Enable Chilly",
        hover = "Anything inside this container perishes slower",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_subzero",
        label = "Enable Sub-zero",
        hover = "Fridges perishing reduction is increased even further",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_desiccating",
        label = "Enable Desiccating",
        hover = "Drying racks finish their batches faster",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_zapping",
        label = "Enable Zapping",
        hover = "Damage dealt will cause the attacker to get hit by lightning and get teleported away. (Only when an orb is present)",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_tinkerers",
        label = "Enable Tinkerer's",
        hover = "While equipped, the wearer can disassemble crafted items for a large portion of this item's durability",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_loyal",
        label = "Enable Loyal",
        hover = "Item is bound to the user, on pick up, it will be automatically equipped, but unequippable. Kept on death(if equipped)",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_solar",
        label = "Enable Solar",
        hover = "Natural light slowly refuels the item if it is off and not being carried",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_vampiric",
        label = "Enable Vampiric",
        hover = "Damage dealt has a chance of slightly repairing the weapon depending on kill streak",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_icey",
        label = "Enable Icey",
        hover = "Damage dealt has a chance of cooling the target",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_fiery",
        label = "Enable Fiery",
        hover = "Damage dealt has a chance of burning the target",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_razor_sharp",
        label = "Enable Razor-sharp",
        hover = "+50% Damage dealt",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_song_of_irritation",
        label = "Enable Song of Irritation",
        hover = "When heard, nearby enemies will become irritated and aggresive towards you",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_enchanted",
        label = "Enable Enchanted",
        hover = "Anything you disenchant will also get repaired, while also removing the chance of losing the item",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_fireproof",
        label = "Enable Fireproof",
        hover = "Resistant to fire",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_reallocating",
        label = "Enable Reallocating",
        hover = "Disenchanting returns a scroll one rarity higher than the removed enchantment",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_sturdy",
        label = "Enable Sturdy",
        hover = "-50% Durability usage",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_protective",
        label = "Enable Protective",
        hover = "+25% Damage reduction",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_economical",
        label = "Enable Economical",
        hover = "-25% Fuel usage",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_sharp",
        label = "Enable Sharp",
        hover = "+25% Damage dealt",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_thorny",
        label = "Enable Thorny",
        hover = "Damage taken is slightly reflected back to the attacker",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_rushing",
        label = "Enable Rushing",
        hover = "Damage dealt will cause the attacker to run faster for a short time",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_unwithering",
        label = "Enable Unwithering",
        hover = "This backpack's skin does not decay",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_steady",
        label = "Enable Steady",
        hover = "-25% Durability usage",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_resistant",
        label = "Enable Resistant",
        hover = "+10% Damage reduction",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_efficient",
        label = "Enable Efficient",
        hover = "-10% Fuel usage",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_pointy",
        label = "Enable Pointy",
        hover = "+10% Damage dealt",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_speedy",
        label = "Enable Speedy",
        hover = "+50% Projectile Speed",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_lightweight",
        label = "Enable Lightweight",
        hover = "Walking with this item equipped is easier",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_fleetfooted",
        label = "Enable Fleet-footed",
        hover = "Cane enchantments give an extra burst of walking speed",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_executioners",
        label = "Enable Executioner's",
        hover = "+100% damage to targets below 25% health",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_duelists",
        label = "Enable Duelist's",
        hover = "+35% damage while exactly one enemy is targeting you",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_reaping",
        label = "Enable Reaping",
        hover = "Kills have a 15% chance to drop an extra loot roll",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_moonstruck",
        label = "Enable Moonstruck",
        hover = "Deals bonus planar damage at night, doubled during a full moon",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_self_mending",
        label = "Enable Self-mending",
        hover = "Armor slowly repairs itself while not worn",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_umbral",
        label = "Enable Umbral",
        hover = "While the wearer's sanity is below 30%, shadow creatures ignore them",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_fellers",
        label = "Enable Feller's",
        hover = "Chopping progresses twice as fast",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_prospectors",
        label = "Enable Prospector's",
        hover = "Finishing mining something has a 10% chance to yield a bonus gold nugget or gem",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_laborers",
        label = "Enable Laborer's",
        hover = "+1 work done per swing (chop, mine, hammer, dig)",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_resonant",
        label = "Enable Resonant",
        hover = "Every 3rd swing echoes, instantly repeating the work for free",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_radiant",
        label = "Enable Radiant",
        hover = "+30% light radius while lit",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_warming",
        label = "Enable Warming",
        hover = "Radiates gentle warmth while lit",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_brisk",
        label = "Enable Brisk",
        hover = "Radiates a pleasant chill while lit",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_geothermal",
        label = "Enable Geothermal",
        hover = "Slowly refuels while near a fire or other heat source",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_dapper",
        label = "Enable Dapper",
        hover = "Small sanity boost while worn",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_insulating",
        label = "Enable Insulating",
        hover = "+60 winter insulation while worn",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_shaded",
        label = "Enable Shaded",
        hover = "+60 summer insulation while worn",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_satiating",
        label = "Enable Satiating",
        hover = "Hunger drains 15% slower while worn",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_song_of_courage",
        label = "Enable Song of Courage",
        hover = "When heard, nearby players deal +15% damage for a short duration",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_song_of_warmth",
        label = "Enable Song of Warmth",
        hover = "When heard, nearby players' body temperature drifts toward comfort",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_song_of_haste",
        label = "Enable Song of Haste",
        hover = "When heard, nearby players move 25% faster for a short duration",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_song_of_stone",
        label = "Enable Song of Stone",
        hover = "When heard, nearby players take 50% less damage for a short duration",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_gamblers",
        label = "Enable Gambler's",
        hover = "Disenchanting re-rolls the item's enchantment at the same rarity instead of removing it",
        options = TrueFalse,
        default = true,
    },
    Title("Boss Features"),
    {
        name = "enable_boss_slowing",
        label = "Enable Boss Player Slowing",
        hover = "Bosses slow players by 50% every 10 seconds during combat",
        options = TrueFalse,
        default = true,
    },
}

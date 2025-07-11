description = 
[[
-V1.0-
Updated code and fixed bugs
Added toggles for each Enchantment in the settings
Added a toggle to change how Enchantments are acquired. "All Sources" is the same as the orignal. "Drops & World Only" Enchantments only come from mob drops or spawned world items.
]]

name                        = "Item Enchantments - Updated"
author                      = "Im So HM02 (Original by Aquaterion)"
version                     = "1.0"
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
        hover = "+75% Damage dealt",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_telepoofing",
        label = "Enable Telepoofing",
        hover = "Damage taken has a chance of randomly teleporting the wearer somewhere close by",
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
        hover = "The enchantment is rerolled onto an unenchanted item, including the one just disenchanted. enchantments are upgraded",
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
        name = "enable_weak",
        label = "Enable Weak",
        hover = "+25% Durability usage",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_dull",
        label = "Enable Dull",
        hover = "-10% Damage dealt",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_inefficient",
        label = "Enable Inefficient",
        hover = "+10% Fuel usage",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_sluggish",
        label = "Enable Sluggish",
        hover = "-50% Projectile Speed",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_heavyweight",
        label = "Enable Heavyweight",
        hover = "Walking with this item equipped is harder",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_fragile",
        label = "Enable Fragile",
        hover = "+50% Durability usage",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_blunt",
        label = "Enable Blunt",
        hover = "-30% Damage dealt",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_impotent",
        label = "Enable Impotent",
        hover = "+25% Fuel usage",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_slowing",
        label = "Enable Slowing",
        hover = "Damage dealt will cause the attacker to run slower for a short time",
        options = TrueFalse,
        default = true,
    },
    {
        name = "enable_moonwalkers",
        label = "Enable Moonwalker's",
        hover = "Movement controls are inverted",
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
----------------------------------------------------------------------
-- ENCHANTMENT PLACEMENT LIST
--
-- This file only decides WHERE enchantments are allowed to appear.
-- What an enchantment DOES stays in modifiers/effects.lua (and its
-- name/description in modifiers/strings.lua).
--
-- Every enchantment gets one entry in the PLACEMENT RULES table below:
--
--    myenchant = {
--        categories = { "melee", "tool" }, -- allowed if the item matches ANY of these
--        include    = { "spear" },         -- extra prefabs: always allowed, even outside the categories
--        exclude    = { "hambat" },        -- banned prefabs: never allowed, even inside the categories
--    },
--
-- How the rules resolve:
--  * exclude beats include, include beats categories.
--  * An entry with `include` but NO `categories` is a strict whitelist:
--    the enchant can ONLY roll on those prefabs (see fleetfooted).
--  * An enchantment with no entry here is unrestricted (old behavior);
--    a reminder prints on load so new enchants don't slip through unlisted.
--  * This list can only narrow placement, never widen it: the item still
--    needs the matching component from its effects.lua table (a weapon
--    enchant still needs the weapon component) and still has to pass the
--    enchant's own checkfn in effects.lua.
----------------------------------------------------------------------

local EQUIPSLOTS = GLOBAL.EQUIPSLOTS

----------Item Categories----------
--each category is a check that runs on the item (server-side, real components)

local function IsRanged(inst)
	return inst:HasTag("rangedweapon")
		or (inst.components.weapon ~= nil and inst.components.weapon.projectile ~= nil)
		or inst.components.projectile ~= nil
		or inst.components.complexprojectile ~= nil
		or inst.components.zupalexsrangedweapons ~= nil--archery mod compat
end

local function EquipSlot(inst)
	return inst.components.equippable ~= nil and inst.components.equippable.equipslot or nil
end

local ITEM_CATEGORIES = {
	all        = function(inst) return true end,
	melee      = function(inst) return inst.components.weapon ~= nil and not IsRanged(inst) and inst.components.tool == nil end,--pure hand weapons (spear, hambat...)
	ranged     = function(inst) return inst.components.weapon ~= nil and IsRanged(inst) end,--weapons that hit from afar (blowdarts, staves, boomerang...)
	projectile = function(inst) return inst.components.projectile ~= nil or inst.components.complexprojectile ~= nil end,--items that fly (boomerang, waterballoon...)
	tool       = function(inst) return inst.components.tool ~= nil or inst.components.fishingrod ~= nil or inst.components.oceanfishingrod ~= nil end,--axes, picks, hammers, rods... (tools also count as weapons in DST, so list "tool" alongside "melee"/"ranged" where wanted)
	armor      = function(inst) return inst.components.armor ~= nil end,--anything that absorbs damage, any slot
	head       = function(inst) return EquipSlot(inst) == EQUIPSLOTS.HEAD end,
	body       = function(inst) return EquipSlot(inst) == EQUIPSLOTS.BODY end,
	hands      = function(inst) return EquipSlot(inst) == EQUIPSLOTS.HANDS end,
	clothing   = function(inst) local slot = EquipSlot(inst) return (slot == EQUIPSLOTS.HEAD or slot == EQUIPSLOTS.BODY) and inst.components.armor == nil and inst.components.container == nil end,--wearables that aren't armor or packs
	equippable = function(inst) return inst.components.equippable ~= nil end,--anything that goes in an equip slot
	fueled     = function(inst) return inst.components.fueled ~= nil end,--lanterns, miner hats...
	instrument = function(inst) return inst.components.instrument ~= nil end,--pan flute, beefalo horn...
	container  = function(inst) return inst.components.container ~= nil end,--backpacks, iceboxes...
	fridge     = function(inst) return inst:HasTag("fridge") end,--iceboxes, insulated pack
	dryingrack = function(inst) return inst.components.dryer ~= nil or inst.components.dryingrack ~= nil end,
	cleaner    = function(inst) return inst.components.modifier_cleaner ~= nil end,--magic duct tape
}

GLOBAL.MODIFIER_ITEM_CATEGORIES = ITEM_CATEGORIES

----------Placement Rules----------
--keys match the enchant names in modifiers/effects.lua

GLOBAL.MODIFIER_ENCHANT_RULES = {
	--Durability (modifier_effects.finiteuses)
	sturdy_1     = { categories = { "all" } },
	sturdy_2     = { categories = { "all" } },
	sturdy_x     = { categories = { "all" } },
	bloodlust    = { categories = { "melee", "ranged" } },
	resourcelust = { categories = { "tool" } },
	feller       = { categories = { "tool" } },
	prospector   = { categories = { "tool" } },
	laborer      = { categories = { "tool" } },
	resonant     = { categories = { "tool" } },

	--Fuel (modifier_effects.fueled)
	efficiency_1 = { categories = { "fueled" } },
	efficiency_2 = { categories = { "fueled" } },
	solar        = { categories = { "fueled" } },
	radiant      = { categories = { "fueled" }, exclude = { "onemanband", "molehat" } },--fueled items with no light to boost
	warming      = { categories = { "fueled" } },
	brisk        = { categories = { "fueled" } },
	geothermal   = { categories = { "fueled" } },

	--Armor (modifier_effects.armor)
	toughness_1     = { categories = { "armor" } },
	toughness_2     = { categories = { "armor" } },
	toughness_x     = { categories = { "armor" } },
	resistance_1    = { categories = { "armor" } },
	resistance_2    = { categories = { "armor" } },
	resistance_x    = { categories = { "armor" } },
	thorns          = { categories = { "armor" } },
	fiery_thorns    = { categories = { "armor" } },
	icey_thorns     = { categories = { "armor" } },
	electric_thorns = { categories = { "armor" } },
	lightweight     = { categories = { "armor" } },
	selfmending     = { categories = { "armor" } },
	umbral          = { categories = { "armor" } },

	--Weapons (modifier_effects.weapon)
	sharpness_1 = { categories = { "melee", "ranged", "tool" } },
	sharpness_2 = { categories = { "melee", "ranged", "tool" } },
	sharpness_3 = { categories = { "melee", "ranged", "tool" } },
	fiery       = { categories = { "melee", "ranged", "tool" } },
	icey        = { categories = { "melee", "ranged", "tool" } },
	lifesteal   = { categories = { "melee", "ranged", "tool" } },
	hemorrhage  = { categories = { "melee", "ranged", "tool" } },
	rushing     = { categories = { "melee", "ranged", "tool" } },
	ghoststrike = { categories = { "melee", "tool" } },--its checkfn already refuses ranged weapons
	executioner = { categories = { "melee", "ranged" } },
	duelist     = { categories = { "melee", "ranged" } },
	reaping     = { categories = { "melee", "ranged" } },
	moonstruck  = { categories = { "melee", "ranged" } },

	--Instruments (modifier_effects.instrument)
	regensong   = { categories = { "instrument" } },
	sanitysong  = { categories = { "instrument" } },
	revivalsong = { categories = { "instrument" } },
	tauntsong   = { categories = { "instrument" } },
	couragesong = { categories = { "instrument" } },
	warmthsong  = { categories = { "instrument" } },
	hastesong   = { categories = { "instrument" } },
	stonesong   = { categories = { "instrument" } },

	--Projectiles (modifier_effects.projectile)
	fast_projectile      = { categories = { "projectile" } },
	collision_projectile = { categories = { "projectile" } },

	--Containers (modifier_effects.container)
	freezer     = { categories = { "container" }, exclude = { "icepack" } },--icepack is already a fridge
	subzero     = { categories = { "fridge" } },
	fireproof   = { categories = { "container" } },
	unwithering = { categories = { "container" } },

	--Drying racks (modifier_effects.dryingrack)
	desiccating = { categories = { "dryingrack" } },

	--Magic Duct Tape (modifier_effects.modifier_cleaner)
	repairer  = { categories = { "cleaner" } },
	infinite  = { categories = { "cleaner" } },
	preserver = { categories = { "cleaner" } },
	gambler   = { categories = { "cleaner" } },

	--General equippables (modifier_effects.equippable)
	soulbound       = { categories = { "equippable" } },
	fleetfooted     = { include = { "cane" } },--whitelist: cane only
	mindascender    = { categories = { "head" } },
	mindtranscender = { categories = { "head" } },
	dapper          = { categories = { "clothing" } },
	insulating      = { categories = { "clothing" } },
	shaded          = { categories = { "clothing" } },
	satiating       = { categories = { "clothing" } },
}

----------Machinery (no need to touch anything below when adding enchants)----------
local function ToSet(list)
	if list == nil then
		return nil
	end
	local set = {}
	for _, prefab in ipairs(list) do
		set[prefab] = true
	end
	return set
end

local RULES = GLOBAL.MODIFIER_ENCHANT_RULES
for _, rules in pairs(RULES) do
	rules._include_set = ToSet(rules.include)
	rules._exclude_set = ToSet(rules.exclude)
end

--called by GetAllPossibleModifiers (scripts/components/modifier.lua) on every roll,
--so scrolls, crafting, loot drops, world-gen and debug rerolls all obey the same list
GLOBAL.ModifierEnchantAllowed = function(inst, modname)
	local rules = RULES[modname]
	if rules == nil or inst == nil then
		return true--unlisted enchants keep the old "anywhere the component exists" behavior
	end
	local prefab = inst.prefab
	if rules._exclude_set ~= nil and prefab ~= nil and rules._exclude_set[prefab] then
		return false
	end
	if rules._include_set ~= nil and prefab ~= nil and rules._include_set[prefab] then
		return true
	end
	if rules.categories == nil then
		return rules._include_set == nil--include-only entries are strict whitelists
	end
	for _, category in ipairs(rules.categories) do
		local matchfn = ITEM_CATEGORIES[category]
		if matchfn ~= nil and matchfn(inst) then
			return true
		end
	end
	return false
end

----------Load-time validation (catches typos; check the server log)----------
local effects = GLOBAL.rawget(GLOBAL, "modifier_effects")
if effects ~= nil then
	local known = {}
	for _, mods in pairs(effects) do
		for modname in pairs(mods) do
			known[modname] = true
		end
	end
	for modname, rules in pairs(RULES) do
		if not known[modname] then
			print("[Item Enchantments] enchant_list: rules given for unknown enchantment '" .. modname .. "' (typo, or its effect isn't loaded)")
		end
		for _, category in ipairs(rules.categories or {}) do
			if ITEM_CATEGORIES[category] == nil then
				print("[Item Enchantments] enchant_list: enchantment '" .. modname .. "' uses unknown category '" .. tostring(category) .. "'")
			end
		end
	end
	local unlisted = 0
	for modname in pairs(known) do
		if RULES[modname] == nil then
			unlisted = unlisted + 1
			print("[Item Enchantments] enchant_list: enchantment '" .. modname .. "' has no placement rules; it can roll on anything its effects.lua table allows")
		end
	end
	print("[Item Enchantments] enchant_list: placement rules loaded for " .. GLOBAL.GetTableSize(RULES) .. " enchantments (" .. unlisted .. " unlisted)")
end

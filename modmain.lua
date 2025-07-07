Assets = {
	Asset("ANIM", "anim/modifier_border.zip"),
	Asset( "ATLAS", "images/magic_duct_tape.xml"),
}

PrefabFiles = {
	"modifierfx",
	"bufffx",
	"cleaner",
	"orbfx",
}

local GLOBALVARS = {}
for k,v in pairs(GLOBAL) do
	table.insert(GLOBALVARS, k)
end

-- Set up TUNING variables for mod configuration
GLOBAL.TUNING.MODIFIER_ENCHANTMENT_SOURCES = GetModConfigData("enchantment_sources") or "all"

-- Individual enchantment toggles
GLOBAL.TUNING.MODIFIER_ENABLE_UNTOUCHABLE = GetModConfigData("enable_untouchable")
GLOBAL.TUNING.MODIFIER_ENABLE_UNBREAKABLE = GetModConfigData("enable_unbreakable")
GLOBAL.TUNING.MODIFIER_ENABLE_GHOST_STRIKE = GetModConfigData("enable_ghost_strike")
GLOBAL.TUNING.MODIFIER_ENABLE_SONG_OF_REANIMATION = GetModConfigData("enable_song_of_reanimation")
GLOBAL.TUNING.MODIFIER_ENABLE_MASTER_TINKERERS = GetModConfigData("enable_master_tinkerers")
GLOBAL.TUNING.MODIFIER_ENABLE_FREEZING = GetModConfigData("enable_freezing")
GLOBAL.TUNING.MODIFIER_ENABLE_FLAMING = GetModConfigData("enable_flaming")
GLOBAL.TUNING.MODIFIER_ENABLE_RESOURCE_HUNGRY = GetModConfigData("enable_resource_hungry")
GLOBAL.TUNING.MODIFIER_ENABLE_LIFESTEALING = GetModConfigData("enable_lifestealing")
GLOBAL.TUNING.MODIFIER_ENABLE_SONG_OF_DAPPERNESS = GetModConfigData("enable_song_of_dapperness")
GLOBAL.TUNING.MODIFIER_ENABLE_SONG_OF_REGENERATION = GetModConfigData("enable_song_of_regeneration")
GLOBAL.TUNING.MODIFIER_ENABLE_HURTFUL = GetModConfigData("enable_hurtful")
GLOBAL.TUNING.MODIFIER_ENABLE_EVERLASTING = GetModConfigData("enable_everlasting")
GLOBAL.TUNING.MODIFIER_ENABLE_CHILLY = GetModConfigData("enable_chilly")
GLOBAL.TUNING.MODIFIER_ENABLE_ZAPPING = GetModConfigData("enable_zapping")
GLOBAL.TUNING.MODIFIER_ENABLE_TINKERERS = GetModConfigData("enable_tinkerers")
GLOBAL.TUNING.MODIFIER_ENABLE_LOYAL = GetModConfigData("enable_loyal")
GLOBAL.TUNING.MODIFIER_ENABLE_SOLAR = GetModConfigData("enable_solar")
GLOBAL.TUNING.MODIFIER_ENABLE_VAMPIRIC = GetModConfigData("enable_vampiric")
GLOBAL.TUNING.MODIFIER_ENABLE_ICEY = GetModConfigData("enable_icey")
GLOBAL.TUNING.MODIFIER_ENABLE_FIERY = GetModConfigData("enable_fiery")
GLOBAL.TUNING.MODIFIER_ENABLE_RAZOR_SHARP = GetModConfigData("enable_razor_sharp")
GLOBAL.TUNING.MODIFIER_ENABLE_TELEPOOFING = GetModConfigData("enable_telepoofing")
GLOBAL.TUNING.MODIFIER_ENABLE_SONG_OF_IRRITATION = GetModConfigData("enable_song_of_irritation")
GLOBAL.TUNING.MODIFIER_ENABLE_ENCHANTED = GetModConfigData("enable_enchanted")
GLOBAL.TUNING.MODIFIER_ENABLE_FIREPROOF = GetModConfigData("enable_fireproof")
GLOBAL.TUNING.MODIFIER_ENABLE_REALLOCATING = GetModConfigData("enable_reallocating")
GLOBAL.TUNING.MODIFIER_ENABLE_STURDY = GetModConfigData("enable_sturdy")
GLOBAL.TUNING.MODIFIER_ENABLE_PROTECTIVE = GetModConfigData("enable_protective")
GLOBAL.TUNING.MODIFIER_ENABLE_ECONOMICAL = GetModConfigData("enable_economical")
GLOBAL.TUNING.MODIFIER_ENABLE_SHARP = GetModConfigData("enable_sharp")
GLOBAL.TUNING.MODIFIER_ENABLE_THORNY = GetModConfigData("enable_thorny")
GLOBAL.TUNING.MODIFIER_ENABLE_RUSHING = GetModConfigData("enable_rushing")
GLOBAL.TUNING.MODIFIER_ENABLE_UNWITHERING = GetModConfigData("enable_unwithering")
GLOBAL.TUNING.MODIFIER_ENABLE_STEADY = GetModConfigData("enable_steady")
GLOBAL.TUNING.MODIFIER_ENABLE_RESISTANT = GetModConfigData("enable_resistant")
GLOBAL.TUNING.MODIFIER_ENABLE_EFFICIENT = GetModConfigData("enable_efficient")
GLOBAL.TUNING.MODIFIER_ENABLE_POINTY = GetModConfigData("enable_pointy")
GLOBAL.TUNING.MODIFIER_ENABLE_SPEEDY = GetModConfigData("enable_speedy")
GLOBAL.TUNING.MODIFIER_ENABLE_LIGHTWEIGHT = GetModConfigData("enable_lightweight")
GLOBAL.TUNING.MODIFIER_ENABLE_WEAK = GetModConfigData("enable_weak")
GLOBAL.TUNING.MODIFIER_ENABLE_DULL = GetModConfigData("enable_dull")
GLOBAL.TUNING.MODIFIER_ENABLE_INEFFICIENT = GetModConfigData("enable_inefficient")
GLOBAL.TUNING.MODIFIER_ENABLE_SLUGGISH = GetModConfigData("enable_sluggish")
GLOBAL.TUNING.MODIFIER_ENABLE_HEAVYWEIGHT = GetModConfigData("enable_heavyweight")
GLOBAL.TUNING.MODIFIER_ENABLE_FRAGILE = GetModConfigData("enable_fragile")
GLOBAL.TUNING.MODIFIER_ENABLE_BLUNT = GetModConfigData("enable_blunt")
GLOBAL.TUNING.MODIFIER_ENABLE_IMPOTENT = GetModConfigData("enable_impotent")
GLOBAL.TUNING.MODIFIER_ENABLE_SLOWING = GetModConfigData("enable_slowing")
GLOBAL.TUNING.MODIFIER_ENABLE_MOONWALKERS = GetModConfigData("enable_moonwalkers")

-- Boss features
GLOBAL.TUNING.MODIFIER_ENABLE_BOSS_SLOWING = GetModConfigData("enable_boss_slowing")

if GLOBAL.KnownModIndex:IsModEnabled("workshop-488009136") then--make bows use our custom damage multiplier
	local oldBowCalcFinalDamage = GLOBAL.ARCHERYFUNCS.CalcFinalDamage
	function GLOBAL.ARCHERYFUNCS.CalcFinalDamage(inst, attacker, target, applydodelta)
		local dmg = oldBowCalcFinalDamage(inst, attacker, target, applydodelta)
		local bow
		if attacker then
			bow = attacker.components.inventory.equipslots.hands
		end
		return dmg * (1 + (bow and bow.modifier_dmg or 0))
	end
end

modimport("modifiers/languagefix.lua")

modimport("modifiers/effects.lua")
modimport("modifiers/strings.lua")

AddReplicableComponent("modifier")
modimport("modifiers/components.lua")

modimport("modifiers/widgets.lua")

AddRecipe("mod_cleaner", { Ingredient("tentaclespots", 1), Ingredient("silk", 1) }, GLOBAL.RECIPETABS.MAGIC, GLOBAL.TECH.SCIENCE_TWO,
nil,nil,nil,nil,nil,
"images/magic_duct_tape.xml", "magic_duct_tape.tex"
)

local actClean = AddAction("MOD_CLEAN", GLOBAL.STRINGS.ACTIONS.MOD_CLEAN, function(act)
	if act.invobject:HasTag("mod_disenchanter") and act.target:HasTag("modified") then
		act.invobject.components.modifier_cleaner:Clean(act.target, act.doer)

		if (not act.invobject:HasTag("modifier_repairer") and act.doer.prefab ~= "winona") and math.random() < 0.05 then
			act.target:Remove()--5% chance of actually losing your item
		end
	end
	return true
end)
actClean.mount_valid = true

AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, right)
	if right and inst and inst:HasTag("mod_disenchanter") and target and target:HasTag("modified") then
		table.insert(actions, actClean)
	end
end)

local actDisassemble = AddAction("MOD_DISASSEMBLE", GLOBAL.STRINGS.ACTIONS.MOD_DISASSEMBLE, function(act)
	if not act or not act.doer or not act.invobject then
		return false
	end
	local recipe = GLOBAL.AllRecipes[act.invobject.prefab]
	if act.doer and act.doer:HasTag("player") and not act.doer:HasTag("playerghost") and recipe then
		local disassembler = act.doer.components.inventory.equipslots.head
		if not disassembler then
			return false
		end
		if disassembler:HasTag("modifier_mindtranscender") and act.invobject.components.modifier then
			local mod_item_rarity = act.invobject.components.modifier:GetRarity()
			if mod_item_rarity then
				local mod_drop = GLOBAL.SpawnPrefab("modifierfx")
				if mod_item_rarity == "bad" or mod_item_rarity == "worst" then
					mod_item_rarity = math.random() < 0.3 and "rare" or "good"
				end
				mod_drop.Transform:SetPosition(act.doer.Transform:GetWorldPosition())
				mod_drop:OnSpawn(act.doer, mod_item_rarity)
			end
		end
		if act.invobject.components.container then
			act.invobject.components.container:DropEverything()
		end
		local comp = act.invobject.components.finiteuses or act.invobject.components.armor or act.invobject.components.fueled or act.invobject.components.perishable or nil
		if comp then
			comp:SetPercent(0)
		end
		if act.invobject and act.invobject:IsValid() then
			act.invobject:Remove()
		end
		for e, ing in pairs(recipe.ingredients) do
			for amount = 1, ing.amount do
				act.doer.components.inventory:GiveItem(GLOBAL.SpawnPrefab(ing.type))
			end
		end
		local disassemblercomp = disassembler.components.finiteuses or disassembler.components.armor or disassembler.components.fueled or disassembler.components.perishable or nil
		if disassemblercomp then
			disassemblercomp:SetPercent(math.max(0, disassemblercomp:GetPercent() - (disassembler:HasTag("modifier_mindtranscender") and 0.1 or 0.25)))
		end

		return true
	end
end)
actDisassemble.mount_valid = true
actDisassemble.priority = 24

AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions)
	if inst and GLOBAL.AllRecipes[inst.prefab] and (not inst.replica.equippable or not inst.replica.equippable:IsEquipped()) and doer and doer.replica.inventory and (doer.replica.inventory:EquipHasTag("modifier_mindascender") or doer.replica.inventory:EquipHasTag("modifier_mindtranscender")) then
		table.insert(actions, actDisassemble)
	end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(actClean, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(actClean, "dolongaction"))
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(actDisassemble, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(actDisassemble, "dolongaction"))

if GLOBAL.GetTableSize(GLOBAL.LanguageTranslator.languages) >= 1 then
	for lang, data in pairs(GLOBAL.LanguageTranslator.languages) do
		if GLOBAL.softresolvefilepath(lang .. "_translation.po") then
			LoadPOFile(lang .. "_translation.po", lang)
		end
	end
end

local oldGetDescription = GLOBAL.GetDescription
function GLOBAL.GetDescription(inst, item, modifier)
	local desc = oldGetDescription(inst, item, modifier)
	if desc ~= nil and desc ~= "" and item:HasTag("modified") then
		local modifier_desc = GLOBAL.STRINGS.MODIFIERS[string.upper(item.replica.modifier:GetModifier() or "generic")].DESC
		-- Handle both function and string descriptions
		if type(modifier_desc) == "function" then
			modifier_desc = modifier_desc()
		end
		desc = desc .. "\n" .. GLOBAL.STRINGS.MODIFIER_RARITIES[string.upper(item.replica.modifier:GetRarity() or "test")] ..": " .. modifier_desc
	end
	return desc
end
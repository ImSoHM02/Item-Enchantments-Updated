Assets = {
	Asset("ANIM", "anim/modifier_border.zip"),
Asset( "ATLAS", "images/magic_duct_tape.xml"),
}

local STRINGS = GLOBAL.STRINGS

STRINGS.NAMES.MODIFIER_ESSENCE = "Enchantment Essence"
STRINGS.RECIPE_DESC.MODIFIER_ESSENCE = "Condensed magic, reclaimed from gear."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MODIFIER_ESSENCE = "It shimmers with leftover power."

STRINGS.ACTIONS.MOD_COMBINE_SCROLL = "Combine"

PrefabFiles = {
	"modifierfx",
	"bufffx",
	"cleaner",
	"orbfx",
	"enchantedpapyrus",
	"modifier_essence",
	"ghoststrikefx",
}

local SCROLL_RARITIES = { "good", "rare", "epic", "legendary", "mythic" }

local function NextRarity(rarity)
	if rarity == nil then
		return nil
	end
	for idx, r in ipairs(SCROLL_RARITIES) do
		if r == rarity and SCROLL_RARITIES[idx + 1] ~= nil then
			return SCROLL_RARITIES[idx + 1]
		end
	end
	return nil
end

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
GLOBAL.TUNING.MODIFIER_ENABLE_HEMORRHAGING = GetModConfigData("enable_hemorrhaging")
GLOBAL.TUNING.MODIFIER_ENABLE_EVERLASTING = GetModConfigData("enable_everlasting")
GLOBAL.TUNING.MODIFIER_ENABLE_CHILLY = GetModConfigData("enable_chilly")
GLOBAL.TUNING.MODIFIER_ENABLE_SUBZERO = GetModConfigData("enable_subzero")
GLOBAL.TUNING.MODIFIER_ENABLE_DESICCATING = GetModConfigData("enable_desiccating")
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
GLOBAL.TUNING.MODIFIER_ENABLE_FLEETFOOTED = GetModConfigData("enable_fleetfooted")
GLOBAL.TUNING.MODIFIER_ENABLE_SLUGGISH = GetModConfigData("enable_sluggish")
GLOBAL.TUNING.MODIFIER_ENABLE_HEAVYWEIGHT = GetModConfigData("enable_heavyweight")

local ESSENCE_AMOUNTS = {
	good = {1, 2},
	rare = {2, 3},
	epic = {3, 4},
	legendary = {4, 5},
	mythic = {6, 7},
}

local function SpawnEssenceFromRarity(rarity, owner_or_pos)
	rarity = rarity and string.lower(rarity) or nil
	local range = rarity and ESSENCE_AMOUNTS[rarity] or nil
	if range == nil then
		return
	end
	local min, max = range[1], range[2]
	local count = math.random(min, max)
	if count <= 0 then
		return
	end
	local x, y, z = 0, 0, 0
	if owner_or_pos and owner_or_pos.Transform then
		x, y, z = owner_or_pos.Transform:GetWorldPosition()
	elseif type(owner_or_pos) == "table" then
		x, y, z = owner_or_pos.x or 0, owner_or_pos.y or 0, owner_or_pos.z or 0
	end
	for _ = 1, count do
		local essence = GLOBAL.SpawnPrefab("modifier_essence")
		if essence ~= nil then
			if owner_or_pos ~= nil and owner_or_pos.components ~= nil and owner_or_pos.components.inventory ~= nil then
				if not owner_or_pos.components.inventory:GiveItem(essence) then
					essence.Transform:SetPosition(x, y, z)
				end
			else
				essence.Transform:SetPosition(x, y, z)
			end
		end
	end
end

GLOBAL.SpawnEssenceFromRarity = SpawnEssenceFromRarity

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
AddReplicableComponent("modifier_scroll")
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

local function ConsolePlayer()
	if GLOBAL.ConsoleCommandPlayer ~= nil then
		local player = GLOBAL.ConsoleCommandPlayer()
		if player ~= nil and player:IsValid() then
			return player
		end
	end
	if GLOBAL.ThePlayer ~= nil and GLOBAL.ThePlayer:IsValid() then
		return GLOBAL.ThePlayer
	end
	if GLOBAL.AllPlayers ~= nil and #GLOBAL.AllPlayers > 0 then
		for _, player in ipairs(GLOBAL.AllPlayers) do
			if player ~= nil and player:IsValid() then
				return player
			end
		end
	end
	return nil
end

local function GiveScroll(player, rarity)
	player = player or ConsolePlayer()
	if player == nil or player.components == nil or player.components.inventory == nil then
		return
	end
	local scroll = GLOBAL.SpawnPrefab("enchantedpapyrus")
	if scroll and scroll.components.modifier_scroll then
		scroll.components.modifier_scroll:SetRarity(rarity)
		if not player.components.inventory:GiveItem(scroll) then
			local x, y, z = player.Transform:GetWorldPosition()
			scroll.Transform:SetPosition(x, y, z)
		end
	end
end

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
		local mod_item_rarity = act.invobject.components.modifier and act.invobject.components.modifier:GetRarity() or nil
		if mod_item_rarity then
			GiveScroll(act.doer, mod_item_rarity)
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

local actApplyScroll = AddAction("MOD_APPLY_SCROLL", GLOBAL.STRINGS.ACTIONS.MOD_APPLY_SCROLL, function(act)
	if act == nil or act.invobject == nil or act.target == nil then
		return false
	end

	local scroll = act.invobject.components.modifier_scroll
	if scroll and act.target.components.modifier then
		return scroll:ApplyTo(act.target, act.doer)
	end
	return false
end)
actApplyScroll.mount_valid = true
actApplyScroll.priority = 20

local actCombineScroll = AddAction("MOD_COMBINE_SCROLL", GLOBAL.STRINGS.ACTIONS.MOD_COMBINE_SCROLL, function(act)
	if act == nil or act.invobject == nil or act.target == nil then
		return false
	end
	local scroll_a = act.invobject.components.modifier_scroll
	local scroll_b = act.target.components.modifier_scroll
	if scroll_a == nil or scroll_b == nil then
		return false
	end
	local rarity_a = scroll_a:GetRarity()
	local rarity_b = scroll_b:GetRarity()
	if rarity_a == nil or rarity_b == nil or rarity_a ~= rarity_b then
		return false
	end
	local next_rarity = NextRarity(string.lower(rarity_a))
	if next_rarity == nil then
		return false
	end

	local function ConsumeOne(item)
		if item == nil then
			return
		end
		if item.components.stackable then
			local taken = item.components.stackable:Get(1)
			if taken ~= nil then
				taken:Remove()
			end
		else
			item:Remove()
		end
	end

	ConsumeOne(act.invobject)
	ConsumeOne(act.target)

	local new_scroll = GLOBAL.SpawnPrefab("enchantedpapyrus")
	if new_scroll and new_scroll.components.modifier_scroll then
		new_scroll.components.modifier_scroll:SetRarity(next_rarity)
		if act.doer and act.doer.components.inventory then
			if not act.doer.components.inventory:GiveItem(new_scroll) then
				local x, y, z = act.doer.Transform:GetWorldPosition()
				new_scroll.Transform:SetPosition(x, y, z)
			end
		else
			new_scroll.Transform:SetPosition(act.target.Transform:GetWorldPosition())
		end
	end

	return true
end)
actCombineScroll.mount_valid = true
actCombineScroll.priority = 21

AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions)
	if inst and GLOBAL.AllRecipes[inst.prefab] and (not inst.replica.equippable or not inst.replica.equippable:IsEquipped()) and doer and doer.replica.inventory and (doer.replica.inventory:EquipHasTag("modifier_mindascender") or doer.replica.inventory:EquipHasTag("modifier_mindtranscender")) then
		table.insert(actions, actDisassemble)
	end
end)

AddComponentAction("USEITEM", "modifier_scroll", function(inst, doer, target, actions, right)
	if not right or inst == nil or target == nil then
		return
	end

	if target:HasTag("modifier_scroll_item") and target.replica and target.replica.modifier_scroll and inst.replica and inst.replica.modifier_scroll then
		local r1 = inst.replica.modifier_scroll:GetRarity()
		local r2 = target.replica.modifier_scroll:GetRarity()
		if r1 ~= nil and r2 ~= nil and string.lower(r1) == string.lower(r2) and NextRarity(string.lower(r1)) ~= nil then
			table.insert(actions, actCombineScroll)
			return
		end
	end

	local can_target = target and (
		(target.replica and target.replica.modifier) or
		target:HasTag("modifier_enchantable")
	)
	if can_target then
		table.insert(actions, actApplyScroll)
	end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(actClean, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(actClean, "dolongaction"))
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(actDisassemble, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(actDisassemble, "dolongaction"))
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(actApplyScroll, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(actApplyScroll, "dolongaction"))
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(actCombineScroll, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(actCombineScroll, "dolongaction"))

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

local FRIDGE_PREFABS = {
	"icebox",
	"icebox_coffin",
	"icebox_crystal",
	"icebox_kitchen",
	"icebox_porcelain",
	"icebox_victorian",
}

for _, prefab in ipairs(FRIDGE_PREFABS) do
	AddPrefabPostInit(prefab, function(inst)
		inst:AddTag("modifier_enchantable")
		if not GLOBAL.TheWorld or not GLOBAL.TheWorld.ismastersim then
			return inst
		end

		if inst.components.modifier == nil then
			inst:AddComponent("modifier")
		end

		return inst
	end)
end

local DRYINGRACK_PREFABS = {
	"meatrack",
	"meatrack_hermit",
}

for _, prefab in ipairs(DRYINGRACK_PREFABS) do
	AddPrefabPostInit(prefab, function(inst)
		inst:AddTag("modifier_enchantable")
		if not GLOBAL.TheWorld or not GLOBAL.TheWorld.ismastersim then
			return inst
		end

		if inst.components.modifier == nil then
			inst:AddComponent("modifier")
		end

		return inst
	end)
end

local function RemoteExecIfClient(fnstr)
	if GLOBAL.TheWorld ~= nil and not GLOBAL.TheWorld.ismastersim and GLOBAL.c_remote ~= nil then
		GLOBAL.c_remote(fnstr)
		return true
	end
	return false
end

GLOBAL.c_spawnscroll = function(rarity, count, player)
	player = player or ConsolePlayer()
	rarity = type(rarity) == "string" and string.lower(rarity) or nil
	if player == nil or rarity == nil then
		return
	end
	local valid = false
	for _, r in ipairs(SCROLL_RARITIES) do
		if r == rarity then
			valid = true
			break
		end
	end
	if not valid then
		return
	end
	count = math.max(1, GLOBAL.tonumber(count) or 1)
	for _ = 1, count do
		GiveScroll(player, rarity)
	end
end

for _, rarity in ipairs(SCROLL_RARITIES) do
	GLOBAL["c_spawnscroll_" .. rarity] = function(count, player)
		GLOBAL.c_spawnscroll(rarity, count, player)
	end
end

local function NormalizeRarity(rarity)
	rarity = type(rarity) == "string" and string.lower(rarity) or nil
	if rarity ~= nil and GLOBAL.table.contains(SCROLL_RARITIES, rarity) then
		return rarity
	end
	return "good"
end

GLOBAL.c_givemod = function(rarity, player)
	local target = player or ConsolePlayer()
	if target == nil then
		return
	end
	rarity = NormalizeRarity(rarity)
	local mod_drop = GLOBAL.SpawnPrefab("modifierfx")
	if mod_drop ~= nil then
		mod_drop.Transform:SetPosition(target.Transform:GetWorldPosition())
		mod_drop:OnSpawn(target, rarity)
	end
end

GLOBAL.c_givemodifier = GLOBAL.c_givemod

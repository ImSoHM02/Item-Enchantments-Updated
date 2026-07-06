--GLOBAL FNS--
-- Map internal enchantment names to configuration variable names
local CONFIG_MAP = {
        -- Finiteuses enchantments
        ["sturdy_1"] = "MODIFIER_ENABLE_STEADY",
        ["sturdy_2"] = "MODIFIER_ENABLE_STURDY",
        ["sturdy_x"] = "MODIFIER_ENABLE_UNBREAKABLE",
        ["bloodlust"] = "MODIFIER_ENABLE_VAMPIRIC",
        ["resourcelust"] = "MODIFIER_ENABLE_RESOURCE_HUNGRY",
        ["feller"] = "MODIFIER_ENABLE_FELLERS",
        ["prospector"] = "MODIFIER_ENABLE_PROSPECTORS",
        ["laborer"] = "MODIFIER_ENABLE_LABORERS",
        ["resonant"] = "MODIFIER_ENABLE_RESONANT",

        -- Fueled enchantments
        ["efficiency_1"] = "MODIFIER_ENABLE_EFFICIENT",
        ["efficiency_2"] = "MODIFIER_ENABLE_ECONOMICAL",
        ["solar"] = "MODIFIER_ENABLE_SOLAR",
        ["radiant"] = "MODIFIER_ENABLE_RADIANT",
        ["warming"] = "MODIFIER_ENABLE_WARMING",
        ["brisk"] = "MODIFIER_ENABLE_BRISK",
        ["geothermal"] = "MODIFIER_ENABLE_GEOTHERMAL",

        -- Armor enchantments
        ["toughness_1"] = "MODIFIER_ENABLE_STEADY",
        ["toughness_2"] = "MODIFIER_ENABLE_STURDY",
        ["toughness_x"] = "MODIFIER_ENABLE_EVERLASTING",
        ["resistance_1"] = "MODIFIER_ENABLE_RESISTANT",
        ["resistance_2"] = "MODIFIER_ENABLE_PROTECTIVE",
        ["resistance_x"] = "MODIFIER_ENABLE_UNTOUCHABLE",
        ["thorns"] = "MODIFIER_ENABLE_THORNY",
        ["fiery_thorns"] = "MODIFIER_ENABLE_FLAMING",
        ["icey_thorns"] = "MODIFIER_ENABLE_FREEZING",
        ["electric_thorns"] = "MODIFIER_ENABLE_ZAPPING",
        ["lightweight"] = "MODIFIER_ENABLE_LIGHTWEIGHT",
        ["selfmending"] = "MODIFIER_ENABLE_SELF_MENDING",
        ["umbral"] = "MODIFIER_ENABLE_UMBRAL",

        -- Weapon enchantments
        ["sharpness_1"] = "MODIFIER_ENABLE_POINTY",
        ["sharpness_2"] = "MODIFIER_ENABLE_SHARP",
        ["sharpness_3"] = "MODIFIER_ENABLE_RAZOR_SHARP",
        ["fiery"] = "MODIFIER_ENABLE_FIERY",
        ["icey"] = "MODIFIER_ENABLE_ICEY",
        ["lifesteal"] = "MODIFIER_ENABLE_LIFESTEALING",
        ["ghoststrike"] = "MODIFIER_ENABLE_GHOST_STRIKE",
        ["hemorrhage"] = "MODIFIER_ENABLE_HEMORRHAGING",
        ["rushing"] = "MODIFIER_ENABLE_RUSHING",
        ["executioner"] = "MODIFIER_ENABLE_EXECUTIONERS",
        ["duelist"] = "MODIFIER_ENABLE_DUELISTS",
        ["reaping"] = "MODIFIER_ENABLE_REAPING",
        ["moonstruck"] = "MODIFIER_ENABLE_MOONSTRUCK",

        -- Instrument enchantments
        ["regensong"] = "MODIFIER_ENABLE_SONG_OF_REGENERATION",
        ["sanitysong"] = "MODIFIER_ENABLE_SONG_OF_DAPPERNESS",
        ["revivalsong"] = "MODIFIER_ENABLE_SONG_OF_REANIMATION",
        ["tauntsong"] = "MODIFIER_ENABLE_SONG_OF_IRRITATION",
        ["couragesong"] = "MODIFIER_ENABLE_SONG_OF_COURAGE",
        ["warmthsong"] = "MODIFIER_ENABLE_SONG_OF_WARMTH",
        ["hastesong"] = "MODIFIER_ENABLE_SONG_OF_HASTE",
        ["stonesong"] = "MODIFIER_ENABLE_SONG_OF_STONE",

        -- Projectile enchantments
        ["fast_projectile"] = "MODIFIER_ENABLE_SPEEDY",
        ["collision_projectile"] = "MODIFIER_ENABLE_HURTFUL",
        
        -- Container enchantments
        ["freezer"] = "MODIFIER_ENABLE_CHILLY",
        ["fireproof"] = "MODIFIER_ENABLE_FIREPROOF",
        ["unwithering"] = "MODIFIER_ENABLE_UNWITHERING",
        ["subzero"] = "MODIFIER_ENABLE_SUBZERO",
        ["desiccating"] = "MODIFIER_ENABLE_DESICCATING",

        -- Modifier cleaner enchantments
        ["repairer"] = "MODIFIER_ENABLE_ENCHANTED",       -- displays as "Enchanted"
        ["infinite"] = "MODIFIER_ENABLE_EVERLASTING",     -- displays as "Everlasting"
        ["preserver"] = "MODIFIER_ENABLE_REALLOCATING",   -- displays as "Reallocating"
        ["gambler"] = "MODIFIER_ENABLE_GAMBLERS",

        -- Special equippable enchantments
        ["soulbound"] = "MODIFIER_ENABLE_LOYAL",
        ["fleetfooted"] = "MODIFIER_ENABLE_FLEETFOOTED",
        ["mindascender"] = "MODIFIER_ENABLE_TINKERERS",   -- displays as "Tinkerer's"
        ["mindtranscender"] = "MODIFIER_ENABLE_MASTER_TINKERERS",
        ["dapper"] = "MODIFIER_ENABLE_DAPPER",
        ["insulating"] = "MODIFIER_ENABLE_INSULATING",
        ["shaded"] = "MODIFIER_ENABLE_SHADED",
        ["satiating"] = "MODIFIER_ENABLE_SATIATING",
}

local function GetEnchantmentConfigKey(modname)
    return CONFIG_MAP[modname]
end

local function PlacementAllowed(inst, modname)
    local fn = rawget(_G, "ModifierEnchantAllowed")--categories/include/exclude from modifiers/enchant_list.lua; allow everything if that file isn't loaded
    return fn == nil or fn(inst, modname)
end

function GetAllPossibleModifiers(inst, rarities, only_rarities)
    local modifiers = {}
    local rares_found = {}

    for comp, mods in pairs(modifier_effects) do
        if inst.components[comp] then
            for modname,data in pairs(mods) do
                -- Check if enchantment is enabled via TUNING variables
                local config_key = GetEnchantmentConfigKey(modname)
                local enchantment_enabled = true
                if config_key and TUNING[config_key] ~= nil then
                    enchantment_enabled = TUNING[config_key]
                end
                
                if enchantment_enabled and (rarities == nil or rarities[data.rarity] ~= nil) and PlacementAllowed(inst, modname) and (data.checkfn == nil or data.checkfn(inst)) then
                    modifiers[modname] = data
                    rares_found[data.rarity] = true
                end
            end
        end
    end
    if only_rarities then--used to filter rarities provided and return those, instead of actual modifiers
        for rarity,weight in pairs(rarities) do
            if rares_found[rarity] == nil then
                rarities[rarity] = nil
            end
        end
        return rarities
    else
        return modifiers
    end
end

local sortedrarities = { "mythic", "legendary", "epic", "rare", "good" }

function GetBestPossibleRarity(inst, rarity)--if inst = table of insts, returns best rarity of all those items, as well as filtered table with only the items that have the best rarity available
    if inst == nil then return nil end
    rarity = rarity or "mythic"
    local rarityindex = 8
    local actualitems = {}
    for k,v in pairs(sortedrarities) do
        if v == rarity then
            rarityindex = k
            break
        end
    end
    while rarityindex < 8 do
        if inst.prefab then
            if GetTableSize(GetAllPossibleModifiers(inst, {[sortedrarities[rarityindex]] = 1}, true)) > 0 then
                return sortedrarities[rarityindex]
            end
        else
            for k,v in pairs(inst) do
                if v.components.modifier and not v.components.modifier:IsModified() and GetTableSize(GetAllPossibleModifiers(v, {[sortedrarities[rarityindex]] = 1}, true)) > 0 then
                    table.insert(actualitems, v)
                end
            end
            if GetTableSize(actualitems) > 0 then
                return sortedrarities[rarityindex], actualitems
            end
        end
        rarityindex = rarityindex + 1
    end
    return nil
end

--Variable:OnSet Listeners--
local function on_modded(self, new_mod)
    if new_mod == nil then return end

    local mod = nil
    local mods = GetAllPossibleModifiers(self.inst)
    mod = mods[new_mod] or nil

    if mod == nil then 
        print(new_mod .. " is not a valid modifier. Skipping...") 
        self:Remove()--we remove since self.mod_name was still set
        return 
    end

    self.inst:AddTag("modified")

    if mod.fn then
        mod.fn(self.inst)
    end

    self.mod_rarity = mod.rarity or nil
    
    self.inst:AddTag("modifier_" .. new_mod)
    self.inst.replica.modifier.mod_name:set(self.mod_name)
    self.inst.replica.modifier.mod_rarity:set(self.mod_rarity)
    
end

local Modifier = Class(function(self, inst)
    self.inst = inst
    self.mod_name = nil
    self.mod_rarity = nil
end,
nil,
{
    mod_name = on_modded,
})

function Modifier:OnRemoveFromEntity()
    self:Remove()
    self.inst:RemoveTag("modified")
    if self.wasnamed and self.inst.components.named then
        self.inst:RemoveComponent("named")
    end
end

function Modifier:Remove()
    local currentmod = nil
    for comp, mods in pairs(modifier_effects) do
        if mods[self.mod_name] then
            currentmod = mods[self.mod_name]
            break
        end
    end
    if currentmod then
        if currentmod.unfn then
            currentmod.unfn(self.inst)
        end

        if self.inst:HasTag("modifier_" .. self.mod_name) then
            self.inst:RemoveTag("modifier_" .. self.mod_name)
        end
    end
    self.inst:RemoveTag("modified")

    self.inst.replica.modifier.mod_name:set("")
    self.inst.replica.modifier.mod_rarity:set("")

    self.mod_rarity = nil
    self.mod_name = nil
end

function Modifier:GenerateFromTable(rarities)
    if rarities["test"] then rarities["test"] = nil end
    local oldmodifier = self.mod_name
    
    if self.mod_name ~= nil then
        self:Remove()
    end

    rarities = GetAllPossibleModifiers(self.inst, rarities, true)
    if GetTableSize(rarities) == 0 then 
        print(self.inst, "No Available modifiers from rarities provided.")
        if oldmodifier then
            self.mod_name = oldmodifier  
        end
        return 
    end
    self:GenerateType(weighted_random_choice(rarities))
end

function Modifier:GenerateType(rarity)--good,rare,epic,legendary,mythic
    if rarity == nil then return end
    local oldmodifier = self.mod_name

    if self.mod_name ~= nil then
        self:Remove()
    end

    local modifiers = GetAllPossibleModifiers(self.inst, {[rarity] = 1})
    if GetTableSize(modifiers) == 0 then 
        print(self.inst, "No Available modifiers with rarity '".. rarity .. "' for " .. self.inst.prefab .. ".")
        if oldmodifier then
          self.mod_name = oldmodifier  
        end
        return 
    end

    local key = GetRandomKey(modifiers)
    self.mod_name = key
end

function Modifier:GenerateSpecific(name)
    name = string.lower(name)
    local oldmodifier = self.mod_name

    if self.mod_name ~= nil then
        self:Remove()
    end

    local modifiers = GetAllPossibleModifiers(self.inst)
    if modifiers[name] == nil then
        print(self.inst, "Modifier '" .. name .. "' was not found.") 
        if oldmodifier then
            self.mod_name = oldmodifier  
        end
        return
    end

    self.mod_name = name
end

function Modifier:Generate()
    local oldmodifier = self.mod_name
    
    if self.mod_name ~= nil then
        self:Remove()
    end

    local modifiers = GetAllPossibleModifiers(self.inst)
    if GetTableSize(modifiers) == 0 then 
        print(self.inst, "No Available modifiers from rarities provided.")
        if oldmodifier then
            self.mod_name = oldmodifier  
        end
        return 
    end
    self.mod_name = GetRandomKey(modifiers)
end

function Modifier:GetModifier()
    return self.mod_name
end

function Modifier:IsModified()
    return self.inst:HasTag("modified") or self.mod_name ~= nil
end

function Modifier:GetRarity()
    return self.mod_rarity
end

function Modifier:OnSave()
    return self.mod_name and { mod_name = self.mod_name } or nil
end

function Modifier:OnLoad(data)
    if data and data.mod_name ~= nil then
        self.mod_name = data.mod_name
    end
end

return Modifier

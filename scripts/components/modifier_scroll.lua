local _G = _G
local env = (_G and rawget(_G, "GLOBAL")) or _G
local STRINGS = env and env.STRINGS or nil

if STRINGS == nil then
    error("modifier_scroll missing required globals")
    return
end

local function GetModifierFn(name)
    --GetBestPossibleRarity etc. are defined by components/modifier.lua, which loads lazily on the first
    --AddComponent("modifier"). A scroll can be the first mod entity to load (saved scroll, or
    --c_spawnscroll on a fresh world), so resolve at call time and force-load if needed.
    if rawget(env, name) == nil then--rawget: strict mode errors on reading a global that isn't declared yet
        require("components/modifier")
    end
    return rawget(env, name)
end

local Scroll = Class(function(self, inst)
    self.inst = inst
    self.stored_rarity = nil
    self.stored_enchant = nil
end)

local function GetReadableRarity(rarity)
    if rarity == nil then
        return nil
    end
    return STRINGS.MODIFIER_RARITIES[string.upper(rarity)] or rarity
end

local function GetReadableEnchant(name)
    if name == nil then
        return nil
    end
    local entry = STRINGS.MODIFIERS[string.upper(name)]
    return entry and entry.PREFIX or name
end

function Scroll:SetRarity(rarity)
    self.stored_rarity = rarity
    if self.inst.replica.modifier_scroll then
        self.inst.replica.modifier_scroll:SetRarity(rarity)
    end
end

function Scroll:GetRarity()
    return self.stored_rarity
end

function Scroll:SetEnchant(name)--Reallocating tape: the scroll keeps the exact enchant instead of rolling a random one
    self.stored_enchant = name
    if name then
        self.inst:AddTag("modifier_scroll_bound")
    else
        self.inst:RemoveTag("modifier_scroll_bound")
    end
    if self.inst.replica.modifier_scroll then
        self.inst.replica.modifier_scroll:SetEnchant(self:GetEnchant())--clients only see the enchant if it's still enabled
    end
end

function Scroll:GetEnchant()
    if self.stored_enchant ~= nil then
        local IsModifierEnabled = GetModifierFn("IsModifierEnabled")
        if IsModifierEnabled ~= nil and not IsModifierEnabled(self.stored_enchant) then
            return nil--enchant was switched off in the config; the scroll falls back to a normal rarity scroll
        end
    end
    return self.stored_enchant
end

function Scroll:SetInfinite(infinite)
    self.infinite = infinite and true or nil
    if self.infinite then
        self.inst:AddTag("modifier_scroll_infinite")
    else
        self.inst:RemoveTag("modifier_scroll_infinite")
    end
end

function Scroll:IsInfinite()
    return self.infinite == true
end

function Scroll:CanApplyTo(target)
    if target == nil or target.components == nil or target.components.modifier == nil then
        return false
    end
    local rarity = self:GetRarity()
    if rarity == nil then
        return false
    end
    local enchant = self:GetEnchant()
    if enchant ~= nil then
        local GetAllPossibleModifiers = GetModifierFn("GetAllPossibleModifiers")
        if GetAllPossibleModifiers == nil or GetAllPossibleModifiers(target)[enchant] == nil then
            return false, "WRONGITEM"
        end
        return true, rarity, enchant
    end
    local GetBestPossibleRarity = GetModifierFn("GetBestPossibleRarity")
    if GetBestPossibleRarity == nil then
        return false
    end
    local best = GetBestPossibleRarity(target, rarity)
    if best == nil then
        return false
    end
    return true, best
end

function Scroll:ApplyTo(target, doer)
    local can_apply, best, enchant = self:CanApplyTo(target)
    if not can_apply then
        return false, best
    end

    if enchant ~= nil then
        target.components.modifier:GenerateSpecific(enchant)
    else
        target.components.modifier:GenerateType(best)
    end

    if doer and doer.components.talker then
        if enchant ~= nil then
            doer.components.talker:Say("Inscribed " .. (GetReadableEnchant(enchant) or "an enchantment") .. ".")
        else
            local rarity_name = GetReadableRarity(best)
            doer.components.talker:Say("Enchanted with a " .. (rarity_name or "mysterious") .. " modifier.")
        end
    end

    if not self.infinite then--debug/creative scrolls survive being applied
        self.inst:Remove()
    end
    return true
end

function Scroll:GetReadableRarity()
    return GetReadableRarity(self:GetRarity())
end

function Scroll:GetReadableEnchant()
    return GetReadableEnchant(self:GetEnchant())
end

function Scroll:OnSave()
    if self.stored_rarity or self.infinite then
        return { rarity = self.stored_rarity, enchant = self.stored_enchant, infinite = self.infinite }
    end
end

function Scroll:OnLoad(data)
    if data and data.rarity then
        self:SetRarity(data.rarity)
    end
    if data and data.enchant then
        self:SetEnchant(data.enchant)
    end
    if data and data.infinite then
        self:SetInfinite(true)
    end
end

return Scroll

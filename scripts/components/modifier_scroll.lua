local _G = _G
local env = (_G and rawget(_G, "GLOBAL")) or _G
local STRINGS = env and env.STRINGS or nil

if STRINGS == nil then
    error("modifier_scroll missing required globals")
    return
end

local function GetBestPossibleRarityFn()
    --GetBestPossibleRarity is defined by components/modifier.lua, which loads lazily on the first
    --AddComponent("modifier"). A scroll can be the first mod entity to load (saved scroll, or
    --c_spawnscroll on a fresh world), so resolve at call time and force-load if needed.
    if env.GetBestPossibleRarity == nil then
        require("components/modifier")
    end
    return env.GetBestPossibleRarity
end

local Scroll = Class(function(self, inst)
    self.inst = inst
    self.stored_rarity = nil
end)

local function GetReadableRarity(rarity)
    if rarity == nil then
        return nil
    end
    return STRINGS.MODIFIER_RARITIES[string.upper(rarity)] or rarity
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
    local GetBestPossibleRarity = GetBestPossibleRarityFn()
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
    local can_apply, best = self:CanApplyTo(target)
    if not can_apply then
        return false
    end

    target.components.modifier:GenerateType(best)

    if doer and doer.components.talker then
        local rarity_name = GetReadableRarity(best)
        doer.components.talker:Say("Enchanted with a " .. (rarity_name or "mysterious") .. " modifier.")
    end

    if not self.infinite then--debug/creative scrolls survive being applied
        self.inst:Remove()
    end
    return true
end

function Scroll:GetReadableRarity()
    return GetReadableRarity(self:GetRarity())
end

function Scroll:OnSave()
    if self.stored_rarity or self.infinite then
        return { rarity = self.stored_rarity, infinite = self.infinite }
    end
end

function Scroll:OnLoad(data)
    if data and data.rarity then
        self:SetRarity(data.rarity)
    end
    if data and data.infinite then
        self:SetInfinite(true)
    end
end

return Scroll

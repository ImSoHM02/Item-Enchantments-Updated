local _G = _G
local env = (_G and rawget(_G, "GLOBAL")) or _G
local STRINGS = env and env.STRINGS or nil
local GetBestPossibleRarity = env and env.GetBestPossibleRarity or nil

if STRINGS == nil or GetBestPossibleRarity == nil then
    error("modifier_scroll missing required globals")
    return
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

function Scroll:CanApplyTo(target)
    if target == nil or target.components == nil or target.components.modifier == nil then
        return false
    end
    local rarity = self:GetRarity()
    if rarity == nil then
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

    self.inst:Remove()
    return true
end

function Scroll:GetReadableRarity()
    return GetReadableRarity(self:GetRarity())
end

function Scroll:OnSave()
    if self.stored_rarity then
        return { rarity = self.stored_rarity }
    end
end

function Scroll:OnLoad(data)
    if data and data.rarity then
        self:SetRarity(data.rarity)
    end
end

return Scroll

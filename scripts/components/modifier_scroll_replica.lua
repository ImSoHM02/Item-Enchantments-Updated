local _G = _G
local env = (_G and rawget(_G, "GLOBAL")) or _G
local STRINGS = env and env.STRINGS or nil

if STRINGS == nil then
    error("modifier_scroll_replica missing STRINGS")
    return
end

local Scroll = Class(function(self, inst)
    self.inst = inst
    self.rarity = net_string(inst.GUID, "mod.scrollrarity", "modifier_scroll_dirty")

    inst:ListenForEvent("modifier_scroll_dirty", function()
        local rarity_label = self:GetReadableRarity()
        if not self.ranonce then
            self.inst.oldDisplayFn = self.inst.displaynamefn
            self.ranonce = true
        end
        self.inst.displaynamefn = function(inst)
            local base = STRINGS.NAMES.ENCHANTEDPAPYRUS or STRINGS.NAMES[string.upper(inst.prefab)] or "Enchanted Papyrus"
            if rarity_label ~= nil and rarity_label ~= "" then
                return base .. " (" .. rarity_label .. ")"
            end
            return base
        end
    end)
end)

function Scroll:SetRarity(rarity)
    self.rarity:set(rarity or "")
end

function Scroll:GetRarity()
    if self.inst.components and self.inst.components.modifier_scroll ~= nil then
        return self.inst.components.modifier_scroll:GetRarity()
    end
    local val = self.rarity:value()
    return val ~= "" and val or nil
end

function Scroll:GetReadableRarity()
    local rarity = self:GetRarity()
    if rarity == nil then
        return nil
    end
    return STRINGS.MODIFIER_RARITIES[string.upper(rarity)] or rarity
end

return Scroll

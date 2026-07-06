local Cleaner = Class(function(self, inst)
    self.inst = inst
    self.type = "positive"

    self.inst:AddTag("mod_disenchanter")
end)

local NEXT_RARITY = { good = "rare", rare = "epic", epic = "legendary", legendary = "mythic" }

local function GiveScroll(target, rarity)
    if target == nil or rarity == nil then
        return
    end
    local scroll = SpawnPrefab("enchantedpapyrus")
    if scroll and scroll.components.modifier_scroll then
        scroll.components.modifier_scroll:SetRarity(rarity)
        if target.components and target.components.inventory and target.components.inventory:GiveItem(scroll) then
            return
        end
        if target.Transform then
            local x, y, z = target.Transform:GetWorldPosition()
            scroll.Transform:SetPosition(x, y, z)
        end
    end
end

function Cleaner:Clean(mod_item, cleaner)
    if mod_item and mod_item:HasTag("modified") and mod_item.components.modifier then
        if self.inst:HasTag("modifier_gambler") then--re-roll the enchant at the same rarity instead of disenchanting; no scroll, no repair
            local rarity = mod_item.components.modifier:GetRarity()
            if rarity then
                mod_item.components.modifier:GenerateType(string.lower(rarity))--GenerateType removes the old enchant itself; it can re-roll the same enchant - that's the gamble
            end
            if cleaner and cleaner.components and cleaner.components.talker and not cleaner:HasTag("mime") then
                cleaner.components.talker:Say("Round and round it goes!")
            end
            if not self.inst:HasTag("modified") or not self.inst:HasTag("modifier_infinite") then
                self.inst:Remove()
            end
            return true
        end
        local mod_item_rarity = mod_item.components.modifier:GetRarity()
        local rarity_for_scroll = mod_item_rarity
        if self.inst:HasTag("modifier_preserver") and rarity_for_scroll then--Reallocating: the reclaimed scroll comes back one rarity higher (mythic stays mythic)
            rarity_for_scroll = NEXT_RARITY[string.lower(rarity_for_scroll)] or rarity_for_scroll
        end
        mod_item.components.modifier:Remove()
        if self.inst:HasTag("modifier_repairer") then
            local components = { "finiteuses", "perishable", "armor", "fueled"}
            for each, component in pairs(components) do
                if mod_item.components[component] then
                    if mod_item.components.inventoryitem and mod_item.components.inventoryitem.owner then
                        local owner = mod_item.components.inventoryitem:GetGrandOwner()
                        if owner and owner.components.talker and not owner:HasTag("mime") then
                            owner.components.talker:Say("Good as new!")
                        end
                    end
                    mod_item.components[component]:SetPercent(1)
                end
            end
        end
        if rarity_for_scroll then
            GiveScroll(cleaner or mod_item, rarity_for_scroll)
        end
        if not self.inst:HasTag("modified") or not self.inst:HasTag("modifier_infinite") then
            self.inst:Remove()
        end
        return true
    end
end

return Cleaner

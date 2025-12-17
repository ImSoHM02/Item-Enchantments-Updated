local Cleaner = Class(function(self, inst)
    self.inst = inst
    self.type = "positive"

    self.inst:AddTag("mod_disenchanter")
end)

local function GiveScroll(target, rarity)
    if target == nil or rarity == nil then
        return
    end
    local scroll = GLOBAL.SpawnPrefab("enchantedpapyrus")
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
        local mod_item_rarity = mod_item.components.modifier:GetRarity()
        local rarity_for_scroll = mod_item_rarity
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

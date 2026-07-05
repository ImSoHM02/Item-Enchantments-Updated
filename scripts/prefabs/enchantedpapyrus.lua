local assets =
{
    --no Asset needed: the base-game papyrus bank/build is always loaded
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("papyrus")
    inst.AnimState:SetBuild("papyrus")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("modifier_scroll_item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.descriptionfn = function(inst)
        local scroll = inst.components.modifier_scroll
        local rarity = scroll and scroll:GetReadableRarity() or nil
        local suffix = (scroll and scroll:IsInfinite()) and " It looks inexhaustible." or ""
        if rarity then
            return "It hums with a " .. rarity .. " enchantment." .. suffix
        end
        return "It hums with latent magic." .. suffix
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "papyrus"

    inst:AddComponent("modifier_scroll")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("enchantedpapyrus", fn, assets)

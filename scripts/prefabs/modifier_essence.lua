local assets =
{
    Asset("IMAGE", "images/inventoryimages.xml"),
    Asset("ATLAS", "images/inventoryimages.xml"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("goldnugget")
    inst.AnimState:SetBuild("goldnugget")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("modifier_essence")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "greengem"
    inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("modifier_essence", fn, assets)

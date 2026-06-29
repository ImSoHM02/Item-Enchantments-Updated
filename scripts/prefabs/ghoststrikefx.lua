local assets =
{
    --no asset needed: reuses the already-loaded player build at spawn time
}

local function OnSpawn(inst, player, weapon)
    if player == nil or not player:IsValid() or player.AnimState == nil then
        inst:Remove()
        return
    end
    --all characters share the "wilson" player bank; reuse the player's current build
    --(includes their base skin) so the ghost matches the attacker without a real prefab.
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild(player.AnimState:GetBuild() or "wilson")
    inst.AnimState:PlayAnimation("atk")
    inst:ListenForEvent("animover", function()
        SpawnPrefab("small_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
    end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    --placeholder build; the server swaps to the attacker's actual build in OnSpawn and
    --the AnimState (bank/build/anim/colour) replicates to clients automatically.
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wilson")
    inst.AnimState:SetMultColour(0.4, 0.4, 0.4, 0.4)--ghostly

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst.OnSpawn = OnSpawn

    inst:DoTaskInTime(3, inst.Remove)--safety net in case animover never fires

    return inst
end

return Prefab("ghoststrikefx", fn, assets)

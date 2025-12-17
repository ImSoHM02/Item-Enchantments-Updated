local assets =
{
	Asset("ANIM", "anim/modifier_orb.zip"),
}
local function OnLink(inst, rarity)
	if rarity == "mythic" and inst:HasTag("playerghost") then
	    inst:PushEvent("respawnfromghost", { source = { name = "Mythicalness", components = {} } })
	end
	if rarity == nil or rarity == "" then
		return
	end

	local scroll = SpawnPrefab("enchantedpapyrus")
	if scroll and scroll.components.modifier_scroll then
		scroll.components.modifier_scroll:SetRarity(rarity)
		local success = inst.components ~= nil and inst.components.inventory and inst.components.inventory:GiveItem(scroll)
		if not success then
			local x, y, z = inst.Transform:GetWorldPosition()
			scroll.Transform:SetPosition(x, y, z)
		elseif inst.components.talker then
			inst.components.talker:Say("I'll save this enchantment for later.")
		end
	end
end

local function OnSpawn(inst, target, rarity)
    rarity = rarity or ""
    inst:SpawnChild("yellowamuletlight")
    if inst.AnimState:BuildHasSymbol("spinner_".. rarity) then
        inst.AnimState:OverrideSymbol("spinner", "modifier_orb", "spinner_"..rarity)
    end
    local x,y,z = inst.Transform:GetWorldPosition()
    local count = 0.1
    inst.risetask = inst:DoPeriodicTask(0, function()--probably better off to just do this via animation?
        inst.Transform:SetPosition(x,count,z)
        count = count + 0.3 + (count > 6 and 0.2 or 0)
        if count > 20 then
            inst.risetask:Cancel()
            target:AddChild(inst)
            inst.falltask = inst:DoPeriodicTask(0, function()
                inst.Transform:SetPosition(0,count,0)
                count = count - 0.3 + (count < 5 and -0.1 or 0)
                if count <= 0.5 then
                    inst.falltask:Cancel()
                    if rarity ~= "" then OnLink(target, rarity) end
                    inst:Remove()
                end
            end)
        end
    end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeCharacterPhysics(inst, 0, .1)
    RemovePhysicsColliders(inst)

	inst.AnimState:SetBank("modifier_orb")--temp
    inst.AnimState:SetBuild("modifier_orb")
    inst.AnimState:PlayAnimation("idle", true)
	
	--inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_despawn")
	
    inst.Transform:SetFourFaced()
	inst.Transform:SetScale(0.5,0.5,0.5) --width,height,thiccccness
	
    inst:AddTag("FX")
	inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	
	
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst.OnSpawn = OnSpawn
    
    inst:DoTaskInTime(60, inst.Remove)--1minute timeout

    return inst
end

return Prefab("modifierfx", fn, assets)

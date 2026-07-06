----------Effect Functions----------
local function effect_fiery(inst, weapon, target)
	if math.random() < 0.5 then return end--only 50% chance of burning
	if target.components.burnable then
        target.components.burnable:Ignite(false, inst)
    end
    if target.components.freezable then
        target.components.freezable:Unfreeze()
    end
end

local function effect_icey(inst, weapon, target, extra)
	if math.random() < 0.5 then return end--only 50% chance of freezing
	if target.components.burnable then
		target.components.burnable:Extinguish()
		target.components.burnable:StopSmoldering()
	end
	if target.components.freezable then
        target.components.freezable:AddColdness(extra or 0.75)
        target.components.freezable:SpawnShatterFX()
	end
end

local function effect_bloodlust(inst, weapon, target)
	if weapon.components.finiteuses and weapon.modifier_kills and math.random() < 0.15 then--only 15% chance of selfrepairing
		if target.brain then
			if weapon.modifier_kills > 10 and weapon.components.talker then
				weapon.components.talker:Say("Yes! More Blood!")
			end
			local newpercent = weapon.components.finiteuses:GetPercent() + (0.01 * weapon.modifier_kills)--1% * killcount
			newpercent = math.min(newpercent, 1)--cap it at 100%
			weapon.components.finiteuses:SetPercent(newpercent)
			inst:SpawnChild("buff_fx"):anim("positive", { build = "buff_fx", symbol = "repair"})
		end
	end
end

local function effect_resourcelust(inst, tool, target, action)
	if tool.components.finiteuses and tool.modifier_kills and math.random() < 0.15 then--only 15% chance of selfrepairing
		if tool.modifier_kills > 0 then
			if tool.modifier_kills == 10 and tool.components.talker and math.random() < 0.1 then
				tool.components.talker:Say("Yes! More destruction!")
			end
			local newpercent = tool.components.finiteuses:GetPercent() + (0.01 * tool.modifier_kills)--1% * killcount
			newpercent = math.min(newpercent, 1)--cap it at 100%
			tool.components.finiteuses:SetPercent(newpercent)
			inst:SpawnChild("buff_fx"):anim("positive", { build = "buff_fx", symbol = "repair"})
		end
	end
end

local function effect_prospector(worker, tool, target, action, workable)
	if action ~= GLOBAL.ACTIONS.MINE or workable == nil or (workable.workleft or 1) > 0 or math.random() >= 0.1 then--only pays out when the mining finishes
		return
	end
	if worker == nil or not worker:IsValid() then return end
	local prize = GLOBAL.weighted_random_choice({goldnugget = 60, redgem = 12, bluegem = 12, purplegem = 8, orangegem = 4, yellowgem = 2, greengem = 2})
	local item = prize ~= nil and GLOBAL.SpawnPrefab(prize) or nil
	if item == nil then return end
	if worker.components.inventory == nil or not worker.components.inventory:GiveItem(item) then
		item.Transform:SetPosition(worker.Transform:GetWorldPosition())
	end
	worker:SpawnChild("buff_fx")
end

local function effect_resonant(worker, tool, target, action, workable)
	if tool.modifier_resonant_echoing then return end--the echo below re-enters this hook
	tool.modifier_resonant_count = (tool.modifier_resonant_count or 0) + 1
	if tool.modifier_resonant_count < 3 then return end
	tool.modifier_resonant_count = 0
	if target and target:IsValid() and workable and (workable.workleft or 0) > 0 then
		tool.modifier_resonant_echoing = true
		workable:WorkedBy(worker, (tool.components.tool and tool.components.tool:GetEffectiveness(action)) or 1)--free echo hit; WorkedBy itself consumes no durability
		tool.modifier_resonant_echoing = nil
		if worker and worker:IsValid() then
			worker:SpawnChild("buff_fx")
		end
	end
end

local function effect_lifesteal(inst, weapon, target)
	if math.random() >= 0.25 then return end--only 25% chance of lifestealing
	local stealpercent = 0.03
	if not target.brain then--no brain, no gain
		stealpercent = 0
	end
	if target:HasTag("largecreature") then
		stealpercent = 0.06
	end
	if target:HasTag("epic") then
		stealpercent = 0.12
	end

	if stealpercent > 0 then
		local stolenlife = stealpercent * (inst.components.health:GetMaxWithPenalty() - inst.components.health.currenthealth)--we heal a % of missing health, not max health
		inst.components.health:DoDelta(stolenlife, nil, weapon)
		inst:SpawnChild("buff_fx")
	end
end

local BLEED_MAX_STACKS = 5
local BLEED_DURATION = 6
local BLEED_TICK_PERIOD = 1

local function ClearBleed(target)
	if target == nil then
		return
	end
	if target.modifier_bleed_task then
		target.modifier_bleed_task:Cancel()
		target.modifier_bleed_task = nil
	end
	target.modifier_bleed_stacks = nil
	target.modifier_bleed_expires = nil
	target.modifier_bleed_source = nil
	target.modifier_bleed_weapon = nil
end

local function TickBleed(target)
	if target == nil or target.components == nil or target.components.health == nil then
		ClearBleed(target)
		return
	end
	if target.components.health:IsDead() then
		ClearBleed(target)
		return
	end

	local expires = target.modifier_bleed_expires or 0
	if expires <= 0 or GLOBAL.GetTime() > expires then
		ClearBleed(target)
		return
	end

	local stacks = target.modifier_bleed_stacks or 0
	if stacks <= 0 then
		ClearBleed(target)
		return
	end

	local dmg = 1.5 + (stacks - 1) * 0.75
	local source = target.modifier_bleed_source
	local weapon = target.modifier_bleed_weapon

	if target.components.combat and source and source:IsValid() then
		target.components.combat:GetAttacked(source, dmg, weapon)
	elseif target.components.health then
		target.components.health:DoDelta(-dmg, nil, weapon)
	end
end

local function ApplyBleed(target, source, weapon)
	if target == nil or target.components == nil or target.components.health == nil then
		return
	end
	if target.components.health:IsDead() then
		return
	end
	if target:HasTag("player") and not GLOBAL.TheNet:GetPVPEnabled() then
		return
	end

	target.modifier_bleed_stacks = math.min(BLEED_MAX_STACKS, (target.modifier_bleed_stacks or 0) + 1)
	target.modifier_bleed_expires = GLOBAL.GetTime() + BLEED_DURATION
	target.modifier_bleed_source = source
	target.modifier_bleed_weapon = weapon

	if target.modifier_bleed_task == nil then
		target.modifier_bleed_task = target:DoPeriodicTask(BLEED_TICK_PERIOD, TickBleed)
	end
end

local function effect_hemorrhage(inst, weapon, target)
	if target == nil then
		return
	end
	ApplyBleed(target, inst, weapon)
end

local function effect_executioner(inst, weapon, target)
	if target == nil or not target:IsValid() or target.components.health == nil or target.components.health:IsDead() or target.components.combat == nil then
		return
	end
	if target.components.health:GetPercent() > 0.25 then return end
	local dmg = weapon.components.weapon and weapon.components.weapon.damage or nil
	if type(dmg) ~= "number" or dmg <= 0 then return end--variable-damage weapons store a function here
	target.components.combat:GetAttacked(inst, dmg, weapon)--+100% weapon damage below 25% health
end

local function effect_duelist(inst, weapon, target)
	if target == nil or not target:IsValid() or target.components.health == nil or target.components.health:IsDead() or target.components.combat == nil then
		return
	end
	local dmg = weapon.components.weapon and weapon.components.weapon.damage or nil
	if type(dmg) ~= "number" or dmg <= 0 then return end
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 15, {"_combat"})
	local threats = 0
	for i, v in ipairs(ents) do
		if v ~= inst and v.components.combat and v.components.combat.target == inst then
			threats = threats + 1
			if threats > 1 then break end
		end
	end
	if threats == 1 then--only rewards a fair one-on-one duel
		target.components.combat:GetAttacked(inst, dmg * 0.35, weapon)
	end
end

local function effect_reaping(inst, weapon, target)
	if target == nil or target.components == nil or target.components.health == nil or not target.components.health:IsDead() or target.components.lootdropper == nil then
		return
	end
	if math.random() >= 0.15 then return end--15% chance of an extra loot roll on kill
	local loot = target.components.lootdropper:GenerateLoot()
	if loot == nil or #loot == 0 then return end
	local pt = target:IsValid() and target:GetPosition() or inst:GetPosition()
	target.components.lootdropper:SpawnLootPrefab(loot[math.random(#loot)], pt)
end

local function moonstruck_update(inst)
	if inst.components.planardamage == nil then return end
	local base = 0
	if GLOBAL.TheWorld.state.isnight then
		base = GLOBAL.TheWorld.state.isfullmoon and 80 or 40
	end
	inst.components.planardamage:SetBaseDamage(base)
end

local function walkable_tile(tile)
	if tile == nil or tile == GROUND.IMPASSABLE or tile == GROUND.INVALID or (tile >= GROUND.OCEAN_START and tile <= GROUND.OCEAN_END ) then
		return false
	end

	return true
end


local function effect_telesick(inst, modifiedItem, nilORtarget, bypass)
	if inst == nil then return end
	if not bypass and math.random() > 0.3 then return end--30% chance of telepoofing
	local x,y,z = inst.Transform:GetWorldPosition()
	local count = 0
	local nx = x
	local nz = z
	local tileAtLoc = 1
	while(walkable_tile(tileAtLoc) == false) do--the count is used in rare cases where there is no ground to find nearby
		nx = x + math.random(-50 - count, 50 + count)--raising the random position area by 1 each iteration
		nz = z + math.random(-50 - count, 50 + count)
		tileAtLoc = GLOBAL.TheWorld.Map:GetTileAtPoint(nx,y,nz)
		count = count + 1
	end

	GLOBAL.SpawnPrefab("small_puff").Transform:SetPosition(x, y+0.1, z)
	inst.Transform:SetPosition(nx, y, nz)--fx at old and new locations
	GLOBAL.SpawnPrefab("small_puff").Transform:SetPosition(nx, y+0.1, nz)
end

local function effect_thorns(inst, item, attacker, data)--{damage, attacker.weapon, stimuli}
	if attacker and attacker.components.combat and attacker.components.health and not attacker.components.health:IsDead() and data and type(data.damage) == "number" then
		local extramult = 0
		if item.components.armor then
			extramult = extramult + (item.components.armor.absorb_percent/10)
		end
		local reflectdamage = data.damage * (0.1 + extramult)--10-20% of damage(better armor, higher reflect)
		attacker.components.combat:GetAttacked(attacker, reflectdamage, item)
	end
end

local function effect_thorns_fiery(inst, item, attacker, data)--{damage, attacker.weapon, stimuli}
	if attacker and attacker.components.health and not attacker.components.health:IsDead() then
		effect_fiery(inst, item, attacker)
		if math.random() > 0.75 then--also has 25% chance of burning the user
			effect_fiery(inst, item, inst)
		end
	end
end

local function effect_thorns_icey(inst, item, attacker, data)--{damage, attacker.weapon, stimuli}
	if attacker and attacker.components.health and not attacker.components.health:IsDead() then
		effect_icey(inst, item, attacker, 1.5)
		if math.random() > 0.75 then--also has 25% chance of cooling the user
			effect_icey(inst, item, inst)
		end
	end
end

local function effect_solar(item, toggled_on)
	if not toggled_on then--toggled off
		if item.solartask ~= nil then
			item.solartask:Cancel()
			item.solartask = nil
		end
		item.solartask = item:DoPeriodicTask(15, function()
			if (GLOBAL.TheWorld.state.isday or GLOBAL.TheWorld.state.isfullmoon) and not item:HasTag("INLIMBO") and item.components.fueled.maxfuel > item.components.fueled.currentfuel then
				local delta = (GLOBAL.TheWorld.state.isfullmoon and 0.03 or 0.01) * item.components.fueled.maxfuel--4% a min at day, 12% a min during fullmoon
				item.components.fueled:DoDelta(delta)
				item:SpawnChild("buff_fx"):anim("positive", { build = "buff_fx", symbol = "sun"})
			end
		end)
	else--toggled on
		if item.solartask ~= nil then
			item.solartask:Cancel()
			item.solartask = nil
		end
	end
end

local function radiant_getlight(item)
	return item.Light or (item._light ~= nil and item._light.Light or nil)--lanterns keep their light on a child entity
end

local function effect_radiant(item, toggled_on)
	if toggled_on then
		item:DoTaskInTime(0, function()--lanterns spawn their light child during turnon; wait a frame so it exists
			if not item:HasTag("modifier_radiant") then return end--disenchanted in the same frame
			if item.components.fueled == nil or not item.components.fueled.consuming then return end--turned back off already
			local light = radiant_getlight(item)
			if light == nil or light.GetRadius == nil then return end
			if item.modifier_radiant_prev == nil then
				item.modifier_radiant_prev = light:GetRadius()
			end
			light:SetRadius(item.modifier_radiant_prev * 1.3)
		end)
	elseif item.modifier_radiant_prev ~= nil then
		local light = radiant_getlight(item)
		if light ~= nil and light.SetRadius ~= nil then
			light:SetRadius(item.modifier_radiant_prev)
		end
		item.modifier_radiant_prev = nil--if the light child was already removed, the next one spawns at default radius anyway
	end
end

local function effect_warming(item, toggled_on)
	if toggled_on then
		if item.components.heater == nil then
			item:AddComponent("heater")
			item.components.heater.heat = 25
			item.modifier_heater_added = true
		end
	elseif item.modifier_heater_added then
		item:RemoveComponent("heater")
		item.modifier_heater_added = nil
	end
end

local function effect_brisk(item, toggled_on)
	if toggled_on then
		if item.components.heater == nil then
			item:AddComponent("heater")
			item.components.heater.heat = -10
			item.components.heater:SetThermics(false, true)--endothermic + negative heat cools, like the cold fire
			item.modifier_heater_added = true
		end
	elseif item.modifier_heater_added then
		item:RemoveComponent("heater")
		item.modifier_heater_added = nil
	end
end

local function effect_geothermal(item, toggled_on)
	if not toggled_on then--toggled off
		if item.geothermaltask ~= nil then
			item.geothermaltask:Cancel()
			item.geothermaltask = nil
		end
		item.geothermaltask = item:DoPeriodicTask(15, function()
			if item.components.fueled.currentfuel >= item.components.fueled.maxfuel then return end
			local source = item.components.inventoryitem and item.components.inventoryitem:GetGrandOwner() or nil--carried: scan around the carrier
			if source == nil and not item:HasTag("INLIMBO") then
				source = item
			end
			if source == nil then return end
			local x, y, z = source.Transform:GetWorldPosition()
			for i, v in ipairs(TheSim:FindEntities(x, y, z, 4, {"HASHEATER"})) do
				if v ~= item then
					item.components.fueled:DoDelta(0.02 * item.components.fueled.maxfuel)
					item:SpawnChild("buff_fx"):anim("positive", { build = "buff_fx", symbol = "repair"})
					return
				end
			end
		end)
	else--toggled on
		if item.geothermaltask ~= nil then
			item.geothermaltask:Cancel()
			item.geothermaltask = nil
		end
	end
end

local function effect_ghoststrike(inst, weapon, target)
	if target == nil or weapon == nil or inst == nil or (inst.components.health and inst.components.health:IsDead()) then return end

	weapon:AddTag("modifier_ghoststrike_oncooldown")
	weapon:DoTaskInTime(2.5, function()
		if weapon and weapon:IsValid() then
			weapon:RemoveTag("modifier_ghoststrike_oncooldown")
		end
	end)

	--lightweight FX clone: a single FX entity reusing the player's loaded build,
	--instead of spawning a full player prefab + real copies of every equipped item.
	local ghost = GLOBAL.SpawnPrefab("ghoststrikefx")
	if ghost == nil then return end
	ghost:OnSpawn(inst, weapon)

	local tx, ty, tz = target.Transform:GetWorldPosition()
	ghost.Transform:SetPosition(tx + (math.random() * 2 - 1), ty, tz + (math.random() * 2 - 1))--float offsets; integer math.random(-1,1) landed exactly on the target 1/9 of the time (NaN rotation)
	ghost:ForceFacePoint(tx, ty, tz)
end


local function play_song(inst, musician, song)
	local x, y, z = musician.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, inst.components.instrument.range, song.audience, song.haters)
	for guid, listener in ipairs(ents) do
		if not song.sucks or GLOBAL.TheNet:GetPVPEnabled() or not listener:HasTag("player") then--make sure to not help enemy players in pvp
			if not song.periodic or song.periodic == 0 then
				song.fn(listener)
			else	
				if listener[song.name .. "_pt"] == nil then--if nil, start ticking the task, if not, keep ticking
					listener[song.name .. "_pt"] = listener:DoPeriodicTask(song.periodic or 1, song.fn)
				end

				if listener[song.name .. "_et"] then--if regen song end timer already exists, remove it, so we can re-set it below
					listener[song.name .. "_et"]:Cancel()
					listener[song.name .. "_et"] = nil
				end

				listener[song.name .. "_et"] = listener:DoTaskInTime(song.duration or 10, function()--set 
					listener[song.name .. "_pt"]:Cancel()
					listener[song.name .. "_pt"] = nil
					listener[song.name .. "_et"]:Cancel()
					listener[song.name .. "_et"] = nil
				end)
			end
		end
	end
end

local function effect_regensong(inst, musician)
	local song = {
		name ="regensong",
		periodic = 2.5,
		duration = 25,
		audience = { "player" },
		haters = { "INLIMBO" },
		--sucks = false --sucks should only be true for harmful songs
		fn = function(listener)
			if listener:IsValid() and listener.components.health and not listener.components.health:IsDead() then
				listener.components.health:DoDelta(2.5)--2.5hp per 2.5s for 25s aka (10ticks x 2.5hp = 25hp)
				listener:SpawnChild("buff_fx")
				--fx:anim("positive", { build = "health", symbol = "heart"}) -- these are the defaults already
			end
		end
	}
	play_song(inst, musician, song)
end

local function effect_sanitysong(inst, musician)
	local song = {
		name ="sanitysong",
		periodic = 2.5,
		duration = 25,
		audience = { "player" },
		haters = { "INLIMBO" },
		--sucks = false --sucks should only be true for debuff/negative songs
		fn = function(listener)
			if listener:IsValid() and listener.components.sanity then
				listener.components.sanity:DoDelta(2.5)--2.5sanity per 2.5s for 25s aka (10ticks x 2.5hp = 25sanity)
				listener:SpawnChild("buff_fx"):anim("positive", { build = "sanity", symbol = "brain"})
			end
		end
	}
	play_song(inst, musician, song)
end

local function effect_revivalsong(inst, musician)
	local song = {
		name ="revivalsong",
		periodic = 0,
		duration = 0,
		audience = { "playerghost" },
		fn = function(listener)
			if listener and listener.components.health then
				listener:PushEvent("respawnfromghost", { source = { name="Song of Revival", components = {} } })
			end
		end
	}
	play_song(inst, musician, song)
end

local function effect_tauntsong(inst, musician)
	local song = {
		name ="tauntsong",
		periodic = 2.5,
		duration = 10,
		audience = { "_combat" },
		haters = { "INLIMBO", "playerghost", "shadowcreature"},
		sucks = true,
		fn = function(listener)
			if listener and listener.components.health and listener.components.combat and (listener.components.follower == nil or listener.components.follower.leader ~= musician) and listener.components.combat.defaultdamage ~= 0 then
				--listener.components.combat:SuggestTarget(musician)
				listener.components.combat:GetAttacked(musician, 2.5)
			end
		end
	}
	play_song(inst, musician, song)
end

local function effect_couragesong(inst, musician)
	local song = {
		name = "couragesong",
		periodic = 0,
		duration = 0,
		audience = { "player" },
		haters = { "INLIMBO" },
		fn = function(listener)
			if listener:IsValid() and listener.components.combat then
				listener.components.combat.externaldamagemultipliers:SetModifier(listener, 1.15, "modifier_couragesong")--listener is its own source, so cleanup stays local
				if listener.modifier_couragesong_task then--replaying refreshes the duration
					listener.modifier_couragesong_task:Cancel()
					listener.modifier_couragesong_task = nil
				end
				listener.modifier_couragesong_task = listener:DoTaskInTime(20, function()
					listener.modifier_couragesong_task = nil
					if listener.components.combat then
						listener.components.combat.externaldamagemultipliers:RemoveModifier(listener, "modifier_couragesong")
					end
				end)
				listener:SpawnChild("buff_fx")
			end
		end
	}
	play_song(inst, musician, song)
end

local function effect_warmthsong(inst, musician)
	local song = {
		name = "warmthsong",
		periodic = 2.5,
		duration = 30,
		audience = { "player" },
		haters = { "INLIMBO" },
		fn = function(listener)
			if listener:IsValid() and listener.components.temperature then
				local cur = listener.components.temperature:GetCurrent()
				if cur < 20 then--nudge towards the comfortable 20-40 band
					listener.components.temperature:DoDelta(math.min(2, 20 - cur))
				elseif cur > 40 then
					listener.components.temperature:DoDelta(math.max(-2, 40 - cur))
				end
			end
		end
	}
	play_song(inst, musician, song)
end

local function effect_hastesong(inst, musician)
	local song = {
		name = "hastesong",
		periodic = 0,
		duration = 0,
		audience = { "player" },
		haters = { "INLIMBO" },
		fn = function(listener)
			if listener:IsValid() and listener.components.locomotor then
				listener.components.locomotor:SetExternalSpeedMultiplier(listener, "modifier_hastesong", 1.25)
				if listener.modifier_hastesong_task then--replaying refreshes the duration
					listener.modifier_hastesong_task:Cancel()
					listener.modifier_hastesong_task = nil
				end
				listener.modifier_hastesong_task = listener:DoTaskInTime(15, function()
					listener.modifier_hastesong_task = nil
					if listener.components.locomotor then
						listener.components.locomotor:RemoveExternalSpeedMultiplier(listener, "modifier_hastesong")
					end
				end)
				listener:SpawnChild("buff_fx"):anim("positive", { build = "buff_fx", symbol = "speed"})
			end
		end
	}
	play_song(inst, musician, song)
end

local function effect_stonesong(inst, musician)
	local song = {
		name = "stonesong",
		periodic = 0,
		duration = 0,
		audience = { "player" },
		haters = { "INLIMBO" },
		fn = function(listener)
			if listener:IsValid() and listener.components.combat then
				listener.components.combat.externaldamagetakenmultipliers:SetModifier(listener, 0.5, "modifier_stonesong")
				if listener.modifier_stonesong_task then--replaying refreshes the duration
					listener.modifier_stonesong_task:Cancel()
					listener.modifier_stonesong_task = nil
				end
				listener.modifier_stonesong_task = listener:DoTaskInTime(10, function()
					listener.modifier_stonesong_task = nil
					if listener.components.combat then
						listener.components.combat.externaldamagetakenmultipliers:RemoveModifier(listener, "modifier_stonesong")
					end
				end)
				listener:SpawnChild("buff_fx")
			end
		end
	}
	play_song(inst, musician, song)
end

local function effect_collisionproj_stop(inst, owner)
	if not inst:IsValid() then return end
	if inst.mod_collision then
		inst.mod_collision:Cancel()
		inst.mod_collision = nil
	end
	inst.mod_collision_targets = nil
end

local function effect_collisionproj_throw(inst, owner, target)
	if not inst:IsValid() then return end
	if inst.mod_collision then
		effect_collisionproj_stop(inst, owner)
	end
	inst.mod_collision_targets = {}
	inst.mod_collision = inst:DoPeriodicTask(0, function() 
		local x,y,z = inst.Transform:GetWorldPosition()
		local targets = TheSim:FindEntities(x,y,z, 1, {"_combat"})
		for k,v in pairs(targets) do
			if v ~= owner and v.components.health and not v.components.health:IsDead() and v.components.combat and (GLOBAL.TheNet:GetPVPEnabled() or not v:HasTag("player")) and not GLOBAL.table.contains(inst.mod_collision_targets, v.GUID) then
				table.insert(inst.mod_collision_targets, v.GUID)
				v.components.combat:GetAttacked(owner, inst.components.weapon.damage)
			end
		end
	end)	
end

local function effect_rushing(inst, weapon, target, extra)
	if weapon:IsValid() and weapon.components.equippable then
		if weapon.mod_rushing then
			weapon.mod_rushing:Cancel()
			weapon.mod_rushing = nil
		else--capture the equip's real mult once, before we overwrite it
			weapon.mod_rushing_prevmult = weapon.components.equippable.walkspeedmult
		end
		weapon.components.equippable.walkspeedmult = 1.25
		weapon.mod_rushing = weapon:DoTaskInTime(5, function()
			weapon.components.equippable.walkspeedmult = weapon.mod_rushing_prevmult or 1
			weapon.mod_rushing_prevmult = nil
			weapon.mod_rushing = nil
		end)
	end
end

local function effect_electric_thorns(inst, item, attacker, data)--{damage, attacker.weapon, stimuli}
	if inst and attacker and attacker.components and GLOBAL.GetTableSize(inst.orbs) > 0 then
		effect_telesick(attacker, item, nil, true)

		local atkhealth = attacker.components.health
		local atkhp = atkhealth and atkhealth.currenthealth
		GLOBAL.TheWorld:PushEvent("ms_sendlightningstrike", attacker:GetPosition() or {x=0, y=0, z=0})

		if attacker.components.burnable and math.random() < 0.3 then
			attacker.components.burnable:Ignite()
		end
		if atkhealth and atkhp == atkhealth.currenthealth then--if lightning did no dmg
			if attacker ~= inst and attacker.components.combat then
				attacker.components.combat:GetAttacked(inst, 25)
			elseif attacker == inst and inst.components.health then
				inst.components.health:DoDelta(-15)
			end
		end
		
		local orbindex = GLOBAL.GetTableSize(inst.orbs)
		local orb = inst.orbs[orbindex]
		inst.orbs[orbindex] = nil
		if orb then
			orb:Remove()
		end
		if GLOBAL.GetTableSize(inst.orbs) == 0 then
			item.modifier_resist = nil
		end
	end
end

local function effect_electric_thorns_off(inst, data)
	if data and data.percent then
		if data.percent > 0 then return end
		data.owner = inst.components.inventoryitem:GetGrandOwner() or nil
	end
	local owner = data.owner
	inst.modifier_resist = nil
	for i,orb in pairs(owner and owner.orbs or {}) do
		orb:Remove()
	end
	if owner then
		if owner.mod_orbs then
			owner.mod_orbs:Cancel()
			owner.mod_orbs = nil
		end
		owner.orbs = nil
	end
end

local function effect_electric_thorns_on(inst, data)
	local owner = data.owner
	if owner.mod_orbs then
		effect_electric_thorns_off(inst, data)
	end
	owner.orbs = {}
	owner.mod_orbs = owner:DoPeriodicTask(12, function()
		local orbcount = GLOBAL.GetTableSize(owner.orbs)
		if orbcount < 7 then
			inst.modifier_resist = 0.4--the charging orbs ward off some damage
			table.insert(owner.orbs, owner:SpawnChild("orbfx"))
		else
			inst.modifier_resist = nil
			effect_electric_thorns(owner, inst, owner)
			owner:DoTaskInTime(0.5, function()
				for i,o in pairs(owner.orbs) do
					o:Remove()
				end
				owner.orbs = {}
			end)
		end
	end)
end

local function umbral_release(inst, owner)--drop this item's claim on the owner's shadowdominance tag
	if owner == nil then return end
	local sources = owner.modifier_umbral_sources
	if sources == nil or sources[inst.GUID] == nil then return end
	sources[inst.GUID] = nil
	if GLOBAL.next(sources) == nil then
		owner.modifier_umbral_sources = nil
		if owner.modifier_umbral_tagged then--only remove the tag if we added it (never strip a real Bone Helm's)
			owner.modifier_umbral_tagged = nil
			if owner:IsValid() then
				owner:RemoveTag("shadowdominance")
			end
		end
	end
end

local function umbral_acquire(inst, owner)
	if owner == nil or not owner:IsValid() then return end
	if owner.modifier_umbral_sources == nil then
		owner.modifier_umbral_sources = {}
	end
	owner.modifier_umbral_sources[inst.GUID] = true
	if not owner:HasTag("shadowdominance") then--re-claims the tag if another source (a real Bone Helm) added it and later dropped it
		owner:AddTag("shadowdominance")
		owner.modifier_umbral_tagged = true
	end
end

local function effect_unwithering(inst)
	inst:DoTaskInTime(1, function()
		if inst.decay_task ~= nil then
			inst.decay_task:Cancel()
			inst.decay_task = nil
		end
		inst.decayed = false
	end)
end

----------UTIL Functions----------
local function insertfn(inst, tbl, fn)
	if inst == nil or tbl == nil or fn == nil then print(inst, tbl, fn, "error?") return end
	if inst[tbl] == nil then
		inst[tbl] = {}
	end
	table.insert(inst[tbl], fn)
end

local function removefn(inst, tbl, fn)
	if inst == nil or tbl == nil or fn == nil or inst[tbl] == nil then print(inst, tbl, inst and tbl and inst[tbl] or nil, fn, "error?") return end
	GLOBAL.table.removearrayvalue(inst[tbl], fn)
	if GLOBAL.GetTableSize(inst[tbl]) == 0 then
		inst[tbl] = nil
	end
end

----------Modifier Effects Data----------
if GLOBAL.rawget(GLOBAL, "modifier_effects") == nil then
	GLOBAL.modifier_effects = {}
end
--[[{
		checkfn = function(inst)
			
		end,
		fn = function(inst)

		end,
		unfn = function(inst)

		end,
		prefix = "",
		rarity = "",
		desc = ""
	}]]


local resourceactions = {GLOBAL.ACTIONS.CHOP, GLOBAL.ACTIONS.MINE, GLOBAL.ACTIONS.DIG, GLOBAL.ACTIONS.HAMMER}

local function resourcetoolcheck(inst)--tool with at least one gathering action
	if inst.components.tool and inst.components.tool.actions then
		for action, power in pairs(inst.components.tool.actions) do
			if GLOBAL.table.contains(resourceactions, action) then
				return true
			end
		end
	end
	return false
end

GLOBAL.modifier_effects.finiteuses = {
	sturdy_1 = {
		fn = function(inst)
			if inst and (inst.components.finiteuses or inst.components.armor) then
				inst.modifier_use = 0.75--25% less use
			end
		end,
		unfn = function(inst)
			if inst and (inst.components.finiteuses or inst.components.armor) then
				inst.modifier_use = nil
			end
		end,
		rarity = "good",
	},
	sturdy_2 = {
		fn = function(inst)
			if inst and (inst.components.finiteuses or inst.components.armor) then
				inst.modifier_use = 0.5--50% less use
			end
		end,
		unfn = function(inst)
			if inst and (inst.components.finiteuses or inst.components.armor) then
				inst.modifier_use = nil
			end
		end,
		rarity = "rare",
	},
		sturdy_x = {
			checkfn = function(inst)
				return not inst.components.fertilizer and not inst.components.sewing and not string.find(inst.prefab, "rifle")--bucket o' poop because super op with this otherwise
			end,
			fn = function(inst)
				if inst and (inst.components.finiteuses or inst.components.armor) then
					inst.modifier_use = 0--100% less use
				end
			end,
			unfn = function(inst)
				if inst and (inst.components.finiteuses or inst.components.armor) then
					inst.modifier_use = nil
				end
			end,
			rarity = "mythic",
		},
	bloodlust = {
		checkfn = function(inst)
			return inst.components.weapon ~= nil and (inst.modifier_use == nil or inst.modifier_use ~= 0) and inst.components.tool == nil and inst.components.fishingrod == nil--effect also requires item to be weapon, and not infinite durability
		end,
		fn = function(inst)
			inst.modifier_kills = 0
			insertfn(inst, "modifier_wep_fns", effect_bloodlust)
		end,
		unfn = function(inst)
			inst.modifier_kills = nil
			removefn(inst, "modifier_wep_fns", effect_bloodlust)
		end,
		rarity = "epic",
	},
	resourcelust = {
		checkfn = function(inst)
			local cangather = false
			if inst.components.tool and inst.components.tool.actions then
				for action,power in pairs(inst.components.tool.actions) do
					if GLOBAL.table.contains(resourceactions, action) then
						cangather = true
						break
					end
				end
			end
			if inst.components.fishingrod then
				cangather = true
			end
			return cangather and (inst.modifier_use == nil or inst.modifier_use ~= 0)--effect also requires item to be tool, and not infinite durability
		end,
		fn = function(inst)
			inst.modifier_kills = 0
			insertfn(inst, "modifier_tool_fns", effect_resourcelust)
		end,
		unfn = function(inst)
			inst.modifier_kills = nil
			removefn(inst, "modifier_tool_fns", effect_resourcelust)
		end,
		rarity = "legendary",--not epic like bloodlust, because its easier to farm resources than kills
	},
	feller = {
		checkfn = function(inst)
			return inst.components.tool ~= nil and inst.components.tool.actions[GLOBAL.ACTIONS.CHOP] ~= nil
		end,
		fn = function(inst)
			inst.modifier_workfn = function(tool, worker, target, action, numworks)
				if action == GLOBAL.ACTIONS.CHOP then
					return (numworks or 1) * 2
				end
				return numworks
			end
		end,
		unfn = function(inst)
			inst.modifier_workfn = nil
		end,
		rarity = "rare",
	},
	prospector = {
		checkfn = function(inst)
			return inst.components.tool ~= nil and inst.components.tool.actions[GLOBAL.ACTIONS.MINE] ~= nil
		end,
		fn = function(inst)
			insertfn(inst, "modifier_tool_fns", effect_prospector)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_tool_fns", effect_prospector)
		end,
		rarity = "rare",
	},
	laborer = {
		checkfn = resourcetoolcheck,
		fn = function(inst)
			inst.modifier_workfn = function(tool, worker, target, action, numworks)
				return (numworks or 1) + 1
			end
		end,
		unfn = function(inst)
			inst.modifier_workfn = nil
		end,
		rarity = "legendary",
	},
	resonant = {
		checkfn = resourcetoolcheck,
		fn = function(inst)
			inst.modifier_resonant_count = 0
			insertfn(inst, "modifier_tool_fns", effect_resonant)
		end,
		unfn = function(inst)
			inst.modifier_resonant_count = nil
			inst.modifier_resonant_echoing = nil
			removefn(inst, "modifier_tool_fns", effect_resonant)
		end,
		rarity = "mythic",
	},
}

local solarfueltypes = { GLOBAL.FUELTYPE.BURNABLE, GLOBAL.FUELTYPE.WORMLIGHT, GLOBAL.FUELTYPE.CAVE, GLOBAL.FUELTYPE.MAGIC }

GLOBAL.modifier_effects.fueled = {
	efficiency_1 = {
		fn = function(inst)
			inst.modifier_use = 0.9--10% less use
		end,
		unfn = function(inst)
			inst.modifier_use = nil
		end,
		rarity = "good",
	},
		efficiency_2 = {
			fn = function(inst)
				inst.modifier_use = 0.75--25% less use
			end,
			unfn = function(inst)
				inst.modifier_use = nil
			end,
			rarity = "rare",
		},
		solar = {
			checkfn = function(inst)
				return inst.components.fueled.accepting and GLOBAL.table.contains(solarfueltypes, inst.components.fueled.fueltype)
			end,
			fn = function(inst)
			insertfn(inst, "modifier_consuming_fns", effect_solar)
		end,
		unfn = function(inst)
			if inst.solartask ~= nil then--the recharge task outlives the enchant otherwise (permanent free fuel)
				inst.solartask:Cancel()
				inst.solartask = nil
			end
			removefn(inst, "modifier_consuming_fns", effect_solar)
		end,
		rarity = "epic",
	},
	radiant = {
		--no checkfn: lanterns only spawn their light child while lit, so it can't be detected at roll time;
		--fueled items without a light are filtered out in enchant_list.lua instead
		fn = function(inst)
			insertfn(inst, "modifier_consuming_fns", effect_radiant)
			if inst.components.fueled.consuming then--already lit when enchanted
				effect_radiant(inst, true)
			end
		end,
		unfn = function(inst)
			effect_radiant(inst, false)
			removefn(inst, "modifier_consuming_fns", effect_radiant)
		end,
		rarity = "rare",
	},
	warming = {
		checkfn = function(inst)
			return inst.components.heater == nil
		end,
		fn = function(inst)
			insertfn(inst, "modifier_consuming_fns", effect_warming)
			if inst.components.fueled.consuming then--already lit when enchanted
				effect_warming(inst, true)
			end
		end,
		unfn = function(inst)
			effect_warming(inst, false)
			removefn(inst, "modifier_consuming_fns", effect_warming)
		end,
		rarity = "rare",
	},
	brisk = {
		checkfn = function(inst)
			return inst.components.heater == nil
		end,
		fn = function(inst)
			insertfn(inst, "modifier_consuming_fns", effect_brisk)
			if inst.components.fueled.consuming then--already lit when enchanted
				effect_brisk(inst, true)
			end
		end,
		unfn = function(inst)
			effect_brisk(inst, false)
			removefn(inst, "modifier_consuming_fns", effect_brisk)
		end,
		rarity = "rare",
	},
	geothermal = {
		checkfn = function(inst)
			return inst.components.fueled.accepting and GLOBAL.table.contains(solarfueltypes, inst.components.fueled.fueltype)
		end,
		fn = function(inst)
			insertfn(inst, "modifier_consuming_fns", effect_geothermal)
		end,
		unfn = function(inst)
			if inst.geothermaltask ~= nil then--the refuel task outlives the enchant otherwise (permanent free fuel)
				inst.geothermaltask:Cancel()
				inst.geothermaltask = nil
			end
			removefn(inst, "modifier_consuming_fns", effect_geothermal)
		end,
		rarity = "epic",
	}
}

GLOBAL.modifier_effects.armor = { --ideas: selfrepairing, selfdegrading, player regen, fire protection, ice protection
	toughness_1 = {
		fn = GLOBAL.modifier_effects.finiteuses.sturdy_1.fn,
		unfn = GLOBAL.modifier_effects.finiteuses.sturdy_1.unfn,
		rarity = "good",
	},
	toughness_2 = {
		fn = GLOBAL.modifier_effects.finiteuses.sturdy_2.fn,
		unfn = GLOBAL.modifier_effects.finiteuses.sturdy_2.unfn,
		rarity = "rare",
	},
	toughness_x = {
		fn = GLOBAL.modifier_effects.finiteuses.sturdy_x.fn,
		unfn = GLOBAL.modifier_effects.finiteuses.sturdy_x.unfn,
		rarity = "mythic",
	},	
	resistance_1 = {
		fn = function(inst)
			inst.modifier_resist = 0.1--10% dmg reduction
		end,
		unfn = function(inst)
			inst.modifier_resist = nil
		end,
		rarity = "good",
	},
	resistance_2 = {
		fn = function(inst)
			inst.modifier_resist = 0.25--25% dmg reduction
		end,
		unfn = function(inst)
			inst.modifier_resist = nil
		end,
		rarity = "rare",
	},
	resistance_x = {
		fn = function(inst)
			inst.modifier_resist = 1--100% dmg reduction
		end,
		unfn = function(inst)
			inst.modifier_resist = nil
		end,
		rarity = "mythic",
	},
	thorns = {
		fn = function(inst)
			insertfn(inst, "modifier_reflect_fns", effect_thorns)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_reflect_fns", effect_thorns)
		end,
		rarity = "rare",
	},
	fiery_thorns = {
		fn = function(inst)
			insertfn(inst, "modifier_reflect_fns", effect_thorns_fiery)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_reflect_fns", effect_thorns_fiery)
		end,
		rarity = "legendary",
	},
	icey_thorns = {
		fn = function(inst)
			insertfn(inst, "modifier_reflect_fns", effect_thorns_icey)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_reflect_fns", effect_thorns_icey)
		end,
		rarity = "legendary",
	},
	lightweight = {
		checkfn = function(inst)
			return inst.components.equippable and (inst.components.equippable.walkspeedmult == nil or inst.components.equippable.walkspeedmult == 1)
		end,
		fn = function(inst)
			inst.components.equippable.walkspeedmult = 1.25
		end,
		unfn = function(inst)
			inst.components.equippable.walkspeedmult = 1
		end,
		rarity = "legendary"
	},
	electric_thorns = {
		checkfn = function(inst)
			return true
		end,
		fn = function(inst)
			inst:ListenForEvent("equipped", effect_electric_thorns_on)
			inst:ListenForEvent("unequipped", effect_electric_thorns_off)
			inst:ListenForEvent("percentusedchange", effect_electric_thorns_off)
			insertfn(inst, "modifier_reflect_fns", effect_electric_thorns)
		end,
		unfn = function(inst)
			effect_electric_thorns_off(inst, {owner = inst.components.inventoryitem:GetGrandOwner()})
			inst:RemoveEventCallback("equipped", effect_electric_thorns_on)
			inst:RemoveEventCallback("unequipped", effect_electric_thorns_off)
			inst:RemoveEventCallback("percentusedchange", effect_electric_thorns_off)
			removefn(inst, "modifier_reflect_fns", effect_electric_thorns)
		end,
		rarity = "legendary"
	},
	selfmending = {
		fn = function(inst)
			inst.modifier_selfmend_task = inst:DoPeriodicTask(30, function()
				if inst.components.equippable and inst.components.equippable:IsEquipped() then
					return--only mends while resting in the inventory or on the ground
				end
				local comp = inst.components.armor or inst.components.finiteuses
				if comp and comp:GetPercent() < 1 then
					comp:SetPercent(math.min(1, comp:GetPercent() + 0.01))
				end
			end)
		end,
		unfn = function(inst)
			if inst.modifier_selfmend_task then
				inst.modifier_selfmend_task:Cancel()
				inst.modifier_selfmend_task = nil
			end
		end,
		rarity = "epic",
	},
	umbral = {
		fn = function(inst)
			inst.modifier_umbral_onsanity = function()--fires as sanitydelta on the current owner
				local owner = inst.modifier_umbral_owner
				if owner == nil or not owner:IsValid() then return end
				if owner.components.sanity and owner.components.sanity:GetPercent() < 0.3 then
					umbral_acquire(inst, owner)
				else
					umbral_release(inst, owner)
				end
			end
			inst.modifier_umbral_onequipped = function(_, data)
				local owner = data and data.owner or nil
				if owner == nil then return end
				inst.modifier_umbral_owner = owner
				inst:ListenForEvent("sanitydelta", inst.modifier_umbral_onsanity, owner)
				inst.modifier_umbral_onsanity()
			end
			inst.modifier_umbral_onunequipped = function(_, data)
				local owner = (data and data.owner) or inst.modifier_umbral_owner
				inst.modifier_umbral_owner = nil
				if owner == nil then return end
				inst:RemoveEventCallback("sanitydelta", inst.modifier_umbral_onsanity, owner)
				umbral_release(inst, owner)
			end
			inst:ListenForEvent("equipped", inst.modifier_umbral_onequipped)
			inst:ListenForEvent("unequipped", inst.modifier_umbral_onunequipped)
			if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem and inst.components.inventoryitem.owner then--enchanted while worn
				inst.modifier_umbral_onequipped(inst, { owner = inst.components.inventoryitem.owner })
			end
		end,
		unfn = function(inst)
			if inst.modifier_umbral_onequipped then
				inst:RemoveEventCallback("equipped", inst.modifier_umbral_onequipped)
			end
			if inst.modifier_umbral_onunequipped then
				inst:RemoveEventCallback("unequipped", inst.modifier_umbral_onunequipped)
			end
			local owner = inst.modifier_umbral_owner
			if owner ~= nil then--still worn: do the full release
				if inst.modifier_umbral_onsanity then
					inst:RemoveEventCallback("sanitydelta", inst.modifier_umbral_onsanity, owner)
				end
				umbral_release(inst, owner)
				inst.modifier_umbral_owner = nil
			end
			inst.modifier_umbral_onequipped = nil
			inst.modifier_umbral_onunequipped = nil
			inst.modifier_umbral_onsanity = nil
		end,
		rarity = "mythic",
	}
}

local function defaultdmgcheck(inst)
	return inst.components.weapon.damage ~= 0 or inst.components.zupalexsrangedweapons
end

GLOBAL.modifier_effects.weapon = {
	sharpness_1 = {
		checkfn = defaultdmgcheck,
		fn = function(inst)
			inst.modifier_dmg = 0.1--10% buff
		end,
		unfn = function(inst)
			inst.modifier_dmg = nil
		end,
		rarity = "good",
	},
	sharpness_2 = {
		checkfn = defaultdmgcheck,
		fn = function(inst)
			inst.modifier_dmg = 0.25--25% buff
		end,
		unfn = function(inst)
			inst.modifier_dmg = nil
		end,
		rarity = "rare",
	},
	sharpness_3 = {
		checkfn = defaultdmgcheck,
		fn = function(inst)
			inst.modifier_dmg = 0.5--50% buff
		end,
		unfn = function(inst)
			inst.modifier_dmg = nil
		end,
		rarity = "mythic",
	},
	fiery = {
		checkfn = function(inst)
			return not inst:HasTag("lighter") and not inst:HasTag("rangedlighter") and not inst:HasTag("extinguisher")--no existing fire/ice effect weapon should get this
		end,
		fn = function(inst)
			insertfn(inst, "modifier_wep_fns", effect_fiery)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_wep_fns", effect_fiery)
		end,
		rarity = "epic",
	},
	icey = {
		checkfn = function(inst)
			return not inst:HasTag("extinguisher") and not inst:HasTag("lighter") and not inst:HasTag("rangedlighter")--no existing fire/ice effect weapon should get this
		end,
		fn = function(inst)
			insertfn(inst, "modifier_wep_fns", effect_icey)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_wep_fns", effect_icey)
		end,
		rarity = "epic",
	},
	lifesteal = {
		fn = function(inst)
			insertfn(inst, "modifier_wep_fns", effect_lifesteal)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_wep_fns", effect_lifesteal)
		end,
		rarity = "legendary",
	},
	hemorrhage = {
		checkfn = defaultdmgcheck,
		fn = function(inst)
			insertfn(inst, "modifier_wep_fns", effect_hemorrhage)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_wep_fns", effect_hemorrhage)
		end,
		rarity = "rare",
	},
	ghoststrike = {
		checkfn = function(inst)
			return not inst:HasTag("rangedweapon") and not inst.components.weapon.projectile and not inst.components.projectile and not inst.components.complexprojectile and not inst.components.fueled and (inst.components.inventoryitem.owner == nil or inst.components.inventoryitem:GetGrandOwner().prefab ~= "yorha2b_dst_td1madao")
		end,
		fn = function(inst)
			inst.modifier_use = inst.modifier_use == 0 and 0 or 3--uses 3x durability
			inst.modifier_oldrange = inst.components.weapon.attackrange--may be nil; keep exact original for restore
			inst.modifier_oldhitrange = inst.components.weapon.hitrange
			inst.components.weapon:SetRange((inst.modifier_oldrange or 0) + 10)
			insertfn(inst, "modifier_wep_fns", effect_ghoststrike)
		end,
		unfn = function(inst)
			inst.modifier_use = nil
			inst.components.weapon.attackrange = inst.modifier_oldrange--restore exact originals (SetRange would coerce nil hitrange)
			inst.components.weapon.hitrange = inst.modifier_oldhitrange
			inst.modifier_oldrange = nil
			inst.modifier_oldhitrange = nil
			removefn(inst, "modifier_wep_fns", effect_ghoststrike)
		end,
		rarity = "mythic",
	},
	rushing = {
		checkfn = function(inst)
			return inst.components.equippable and (inst.components.equippable.walkspeedmult == nil or inst.components.equippable.walkspeedmult == 1)
		end,
		fn = function(inst)
			insertfn(inst, "modifier_wep_fns", effect_rushing)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_wep_fns", effect_rushing)
		end,
		rarity = "rare",
	},
	executioner = {
		checkfn = defaultdmgcheck,
		fn = function(inst)
			insertfn(inst, "modifier_wep_fns", effect_executioner)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_wep_fns", effect_executioner)
		end,
		rarity = "epic",
	},
	duelist = {
		checkfn = defaultdmgcheck,
		fn = function(inst)
			insertfn(inst, "modifier_wep_fns", effect_duelist)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_wep_fns", effect_duelist)
		end,
		rarity = "epic",
	},
	reaping = {
		checkfn = defaultdmgcheck,
		fn = function(inst)
			insertfn(inst, "modifier_wep_fns", effect_reaping)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_wep_fns", effect_reaping)
		end,
		rarity = "legendary",
	},
	moonstruck = {
		checkfn = function(inst)
			return defaultdmgcheck(inst) and inst.components.planardamage == nil
		end,
		fn = function(inst)
			inst:AddComponent("planardamage")
			inst:WatchWorldState("isnight", moonstruck_update)--not "phase": the phase watcher fires before worldstate updates isnight, so we'd read the OLD phase's value
			inst:WatchWorldState("isfullmoon", moonstruck_update)
			moonstruck_update(inst)
		end,
		unfn = function(inst)
			inst:StopWatchingWorldState("isnight", moonstruck_update)
			inst:StopWatchingWorldState("isfullmoon", moonstruck_update)
			inst:RemoveComponent("planardamage")
		end,
		rarity = "mythic",
	},
	}

GLOBAL.modifier_effects.instrument = {
	regensong = {
		fn = function(inst)
			insertfn(inst, "modifier_instrument_fns", effect_regensong)			
		end,
		unfn = function(inst)
			removefn(inst, "modifier_instrument_fns", effect_regensong)	
		end,
		rarity = "legendary",
	},
	sanitysong = {
		fn = function(inst)
			insertfn(inst, "modifier_instrument_fns", effect_sanitysong)			
		end,
		unfn = function(inst)
			removefn(inst, "modifier_instrument_fns", effect_sanitysong)	
		end,
		rarity = "epic",
	},
	revivalsong = {
		fn = function(inst)
			insertfn(inst, "modifier_instrument_fns", effect_revivalsong)			
		end,
		unfn = function(inst)
			removefn(inst, "modifier_instrument_fns", effect_revivalsong)	
		end,
		rarity = "mythic",
	},
	tauntsong = {
		checkfn = function(inst)
			return inst.prefab ~= "panflute"--panflute makes enemies sleep, can't really have taunt+sleep
		end,
		fn = function(inst)
			insertfn(inst, "modifier_instrument_fns", effect_tauntsong)			
		end,
		unfn = function(inst)
			removefn(inst, "modifier_instrument_fns", effect_tauntsong)	
		end,
		rarity = "rare",
	},
	couragesong = {
		fn = function(inst)
			insertfn(inst, "modifier_instrument_fns", effect_couragesong)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_instrument_fns", effect_couragesong)
		end,
		rarity = "epic",
	},
	warmthsong = {
		fn = function(inst)
			insertfn(inst, "modifier_instrument_fns", effect_warmthsong)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_instrument_fns", effect_warmthsong)
		end,
		rarity = "rare",
	},
	hastesong = {
		fn = function(inst)
			insertfn(inst, "modifier_instrument_fns", effect_hastesong)
		end,
		unfn = function(inst)
			removefn(inst, "modifier_instrument_fns", effect_hastesong)
		end,
		rarity = "epic",
	},
	stonesong = {
		fn = function(inst)
			inst.modifier_use = 3--a ward this strong wears the instrument 3x faster
			insertfn(inst, "modifier_instrument_fns", effect_stonesong)
		end,
		unfn = function(inst)
			inst.modifier_use = nil
			removefn(inst, "modifier_instrument_fns", effect_stonesong)
		end,
		rarity = "legendary",
	},
}

GLOBAL.modifier_effects.projectile = {
	fast_projectile = {
		fn = function(inst)
			inst.oldspeed = inst.components.projectile.speed
			inst.components.projectile:SetSpeed(inst.oldspeed * 1.5)		
		end,
		unfn = function(inst)
			inst.components.projectile:SetSpeed(inst.oldspeed)
			inst.oldspeed = nil
		end,
		rarity = "rare",
	},
	collision_projectile = {
		checkfn = function(inst)
			return inst.components.weapon and inst.components.weapon.damage ~= 0
		end,
		fn = function(inst)
			insertfn(inst, "modifier_throw_fns", effect_collisionproj_throw)	
			insertfn(inst, "modifier_catch_fns", effect_collisionproj_stop)	
		end,
		unfn = function(inst)
			removefn(inst, "modifier_throw_fns", effect_collisionproj_throw)	
			removefn(inst, "modifier_catch_fns", effect_collisionproj_stop)	
		end,
		rarity = "legendary",
	},
}

GLOBAL.modifier_effects.container = {
	freezer = {
		checkfn = function(inst)
			return inst.prefab ~= "icepack"--CHECK FOR CONTAINERS THAT DONT STORE FOOD
		end,
		fn = function(inst)
			inst:AddTag("fridge")
		end,
		unfn = function(inst)
			inst:RemoveTag("fridge")
		end,
		rarity = "legendary",
	},
	subzero = {
		checkfn = function(inst)
			return inst:HasTag("fridge")
		end,
		fn = function(inst)
			if inst.components.preserver == nil then
				inst:AddComponent("preserver")
				inst.modifier_preserver_added = true
			end
			if inst.components.preserver then
				if inst.modifier_preserver_prev == nil then
					inst.modifier_preserver_prev = inst.components.preserver:GetPerishRateMultiplier()
				end
				inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_FRIDGE_MULT * 0.5)
			end
		end,
		unfn = function(inst)
			if inst.modifier_preserver_added then
				if inst.components.preserver then
					inst:RemoveComponent("preserver")
				end
				inst.modifier_preserver_added = nil
			elseif inst.components.preserver and inst.modifier_preserver_prev ~= nil then
				inst.components.preserver:SetPerishRateMultiplier(inst.modifier_preserver_prev)
			end
			inst.modifier_preserver_prev = nil
		end,
		rarity = "rare",
	},
	fireproof = {
		checkfn = function(inst)
			return inst.components.burnable or inst.modifier_fireproof_bu
		end,
		fn = function(inst)
			inst.modifier_fireproof_bu = {
				onignite = inst.components.burnable.onignite,
				onburnt = inst.components.burnable.onburnt,
				onextinguish = inst.components.burnable.onextinguish
			}
			inst:RemoveComponent("propagator")
			inst:RemoveComponent("burnable")
		end,
		unfn = function(inst)
			GLOBAL.MakeSmallBurnable(inst)
			if inst.modifier_fireproof_bu then
				for name,fn in pairs(inst.modifier_fireproof_bu) do
					inst.components.burnable[name] = fn or inst.components.burnable[name]
				end
			end
			GLOBAL.MakeSmallPropagator(inst)
		end,
		rarity = "epic",
	},
	unwithering = {
		checkfn = function(inst)
			return inst.skin_build_name or inst.skinname or inst.skin_id
		end,
		fn = function(inst)
			inst:ListenForEvent("ondropped", effect_unwithering)
			effect_unwithering(inst)
		end,
		unfn = function(inst)
			inst:RemoveEventCallback("ondropped", effect_unwithering)
			inst:OnLoad({decayed = true, remaining_decay_time = 1})
		end,
		rarity = "rare"
	}
}

GLOBAL.modifier_effects.dryingrack = {
	desiccating = {
		fn = function(inst)
			inst.modifier_drying_speedmult = 0.5
		end,
		unfn = function(inst)
			inst.modifier_drying_speedmult = nil
		end,
		rarity = "rare",
	},
}

GLOBAL.modifier_effects.dryer = GLOBAL.modifier_effects.dryingrack

GLOBAL.modifier_effects.modifier_cleaner = {
	repairer = {
		rarity = "epic"
	},
	infinite = {
		rarity = "legendary"
	},
	preserver = {
		rarity = "epic"
	},
	gambler = {
		rarity = "rare"
	}
}
GLOBAL.modifier_effects.equippable = {--ideas: sanity/hunger/temperature effects
	--[[godlike = {
		fn = function(inst)
			if inst and inst.components.finiteuses then
				GLOBAL.modifier_effects.finiteuses.sturdy_x.fn(inst)
				GLOBAL.modifier_effects.finiteuses.bloodlust.fn(inst)
			end
			if inst and inst.components.weapon then
				GLOBAL.modifier_effects.weapon.sharpness_3.fn(inst)
				GLOBAL.modifier_effects.weapon.fiery.fn(inst)
				GLOBAL.modifier_effects.weapon.lifesteal.fn(inst)
				GLOBAL.modifier_effects.weapon.ghoststrike.fn(inst)
			end
			if inst and inst.components.armor then
				GLOBAL.modifier_effects.armor.toughness_x.fn(inst)
				GLOBAL.modifier_effects.armor.resistance_x.fn(inst)
				GLOBAL.modifier_effects.armor.thorns.fn(inst)
			end
			if inst and inst.components.fueled then
				GLOBAL.modifier_effects.fueled.solar.fn(inst)
			end
			if inst and inst.components.instrument then
				GLOBAL.modifier_effects.instrument.regensong.fn(inst)
				GLOBAL.modifier_effects.instrument.sanitysong.fn(inst)
				GLOBAL.modifier_effects.instrument.revivalsong.fn(inst)
				GLOBAL.modifier_effects.instrument.tauntsong.fn(inst)
			end
			if inst and inst.components.container then
				GLOBAL.modifier_effects.container.freezer.fn(inst)
			end
			if inst and inst.components.modifier_cleaner then
				GLOBAL.modifier_effects.modifier_cleaner.repairer.fn(inst)
				GLOBAL.modifier_effects.modifier_cleaner.infinite.fn(inst)
			end
			if inst and inst.components.projectile then
				GLOBAL.modifier_effects.projectile.slow_projectile.fn(inst)
				GLOBAL.modifier_effects.projectile.collision_projectile.fn(inst)	
			end
			inst.components.inventoryitem.keepondeath = true
		end,
		unfn = function(inst)
			if inst and inst.components.finiteuses then
				GLOBAL.modifier_effects.finiteuses.sturdy_x.unfn(inst)
				GLOBAL.modifier_effects.finiteuses.bloodlust.unfn(inst)
			end
			if inst and inst.components.weapon then
				GLOBAL.modifier_effects.weapon.sharpness_3.unfn(inst)
				GLOBAL.modifier_effects.weapon.fiery.unfn(inst)
				GLOBAL.modifier_effects.weapon.lifesteal.unfn(inst)
				GLOBAL.modifier_effects.weapon.ghoststrike.unfn(inst)
			end
			if inst and inst.components.armor then
				GLOBAL.modifier_effects.armor.toughness_x.unfn(inst)
				GLOBAL.modifier_effects.armor.resistance_x.unfn(inst)
				GLOBAL.modifier_effects.armor.thorns.unfn(inst)
			end
			if inst and inst.components.fueled then
				GLOBAL.modifier_effects.fueled.solar.unfn(inst)
			end
			if inst and inst.components.instrument then
				GLOBAL.modifier_effects.instrument.regensong.unfn(inst)
				GLOBAL.modifier_effects.instrument.sanitysong.unfn(inst)
				GLOBAL.modifier_effects.instrument.revivalsong.unfn(inst)
				GLOBAL.modifier_effects.instrument.tauntsong.unfn(inst)
			end
			if inst and inst.components.container then
				GLOBAL.modifier_effects.container.freezer.unfn(inst)
			end
			if inst and inst.components.modifier_cleaner then
				GLOBAL.modifier_effects.modifier_cleaner.repairer.unfn(inst)
				GLOBAL.modifier_effects.modifier_cleaner.infinite.unfn(inst)
			end
			if inst and inst.components.projectile then
				GLOBAL.modifier_effects.projectile.slow_projectile.unfn(inst)
				GLOBAL.modifier_effects.projectile.collision_projectile.unfn(inst)	
			end
			inst.components.inventoryitem.keepondeath = false
		end,
		rarity = "test",
	},]]
	soulbound = {
		checkfn = function(inst)--require finiteuses else it will stuck on the player forever
			return ((inst.components.armor and not inst.components.armor.indestructible) or (inst.components.finiteuses and inst.components.finiteuses.onfinished)) and not inst.components.trap and inst.prefab ~= "amulet" and not inst.components.fueled and not inst.components.useableitem and not inst.components.perishable and not inst.components.projectile and not inst.MakeProjectile--this item requires to be haunted, if u pick it up automatically, it would be hard to haunt
		end,
		fn = function(inst)
			inst.components.inventoryitem.keepondeath = true
			inst:DoTaskInTime(0, function()--delay it so owner is actually assigned if this is ran on start up
				if inst.components.inventoryitem == nil or inst.components.equippable == nil then
					return
				end
				if inst.components.inventoryitem.owner then
					local slot = inst.components.equippable.equipslot
					local owner = inst.components.inventoryitem:GetGrandOwner()
					if owner == nil or owner.components.inventory == nil then
						return--grand owner is a container (chest / backpack on the ground): stay dormant, bind on next real pickup
					end
					inst.boundguy = owner
					if slot and (owner.components.inventory.equipslots[slot] == nil or not owner.components.inventory.equipslots[slot]:HasTag("modifier_soulbound")) then
						owner.components.inventory:Equip(inst)
					end
				end
			end)
		end,
		unfn = function(inst)--does the inventory item tile update to be clickable again? | we shouldn't be able to unfn while equipped so we shouldn't care
			inst.components.inventoryitem.keepondeath = false
		end,
		rarity = "epic",
	},
	fleetfooted = {
		checkfn = function(inst)
			return inst.prefab == "cane" and inst.components.equippable ~= nil
		end,
		fn = function(inst)
			if inst.components.equippable then
				inst.modifier_fleetfoot_prev = inst.components.equippable.walkspeedmult or 1
				local base = inst.modifier_fleetfoot_prev > 0 and inst.modifier_fleetfoot_prev or 1
				inst.components.equippable.walkspeedmult = base + 0.15
			end
		end,
		unfn = function(inst)
			if inst.components.equippable then
				if inst.modifier_fleetfoot_prev ~= nil then
					inst.components.equippable.walkspeedmult = inst.modifier_fleetfoot_prev
				end
			end
			inst.modifier_fleetfoot_prev = nil
		end,
		rarity = "rare",
	},
	mindascender = {
		checkfn = function(inst)
			return inst.components.equippable.equipslot == GLOBAL.EQUIPSLOTS.HEAD and (inst.components.finiteuses or inst.components.armor or inst.components.perishable or inst.components.fueled)
		end,
		rarity = "legendary"
	},
	mindtranscender = {
		checkfn = function(inst)
			return inst.components.equippable.equipslot == GLOBAL.EQUIPSLOTS.HEAD and (inst.components.finiteuses or inst.components.armor or inst.components.perishable or inst.components.fueled)
		end,
		rarity = "mythic"
	},
	dapper = {
		checkfn = function(inst)
			return inst.components.equippable ~= nil and (inst.components.equippable.dapperness or 0) == 0
		end,
		fn = function(inst)
			inst.modifier_dapper_prev = inst.components.equippable.dapperness--may be nil; keep exact original for restore
			inst.components.equippable.dapperness = GLOBAL.TUNING.DAPPERNESS_SMALL
		end,
		unfn = function(inst)
			if inst.components.equippable then
				inst.components.equippable.dapperness = inst.modifier_dapper_prev
			end
			inst.modifier_dapper_prev = nil
		end,
		rarity = "good",
	},
	insulating = {
		checkfn = function(inst)
			return inst.components.equippable ~= nil and inst.components.insulator == nil
		end,
		fn = function(inst)
			inst:AddComponent("insulator")
			inst.components.insulator:SetInsulation(GLOBAL.TUNING.INSULATION_SMALL)--60, matches the advertised value
			inst.components.insulator:SetWinter()
		end,
		unfn = function(inst)
			inst:RemoveComponent("insulator")
		end,
		rarity = "rare",
	},
	shaded = {
		checkfn = function(inst)
			return inst.components.equippable ~= nil and inst.components.insulator == nil
		end,
		fn = function(inst)
			inst:AddComponent("insulator")
			inst.components.insulator:SetInsulation(GLOBAL.TUNING.INSULATION_SMALL)--60, matches the advertised value
			inst.components.insulator:SetSummer()
		end,
		unfn = function(inst)
			inst:RemoveComponent("insulator")
		end,
		rarity = "rare",
	},
	satiating = {
		fn = function(inst)
			inst.modifier_satiating_onequipped = function(_, data)
				local owner = data and data.owner or nil
				if owner and owner.components.hunger and owner.components.hunger.burnratemodifiers then
					owner.components.hunger.burnratemodifiers:SetModifier(inst, 0.85, "modifier_satiating")--15% slower hunger drain while worn
				end
			end
			inst.modifier_satiating_onunequipped = function(_, data)
				local owner = data and data.owner or nil
				if owner and owner.components.hunger and owner.components.hunger.burnratemodifiers then
					owner.components.hunger.burnratemodifiers:RemoveModifier(inst, "modifier_satiating")
				end
			end
			inst:ListenForEvent("equipped", inst.modifier_satiating_onequipped)
			inst:ListenForEvent("unequipped", inst.modifier_satiating_onunequipped)
			if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem and inst.components.inventoryitem.owner then--enchanted while worn
				inst.modifier_satiating_onequipped(inst, { owner = inst.components.inventoryitem.owner })
			end
		end,
		unfn = function(inst)
			if inst.modifier_satiating_onequipped then
				inst:RemoveEventCallback("equipped", inst.modifier_satiating_onequipped)
			end
			if inst.modifier_satiating_onunequipped then
				inst:RemoveEventCallback("unequipped", inst.modifier_satiating_onunequipped)
				if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem and inst.components.inventoryitem.owner then--disenchanted while worn
					inst.modifier_satiating_onunequipped(inst, { owner = inst.components.inventoryitem.owner })
				end
			end
			inst.modifier_satiating_onequipped = nil
			inst.modifier_satiating_onunequipped = nil
		end,
		rarity = "epic",
	}
}

local modcount = 0
for comp,sub in pairs(GLOBAL.modifier_effects) do
	modcount = modcount + GLOBAL.GetTableSize(sub)
	print(GLOBAL.GetTableSize(sub) .. " " .. comp ..  " modifiers loaded.")
end
print("Total modifier count: " .. modcount)

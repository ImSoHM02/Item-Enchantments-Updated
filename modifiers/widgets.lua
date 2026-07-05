local mod_rarity_colors = {					--darker
	good = { 173/255, 213/255, 112/255 , 1 },--145/255, 180/255, 95/255
	rare = { 133/255, 230/255, 255/255, 1 },--35/255, 200/255, 225/255
	epic = {250/255, 190/255, 55/255, 1},--230/255, 175/255, 30/255
	legendary = {145/255, 85/255, 190/255, 1},--101/255, 45/255, 145/255
	mythic = {255/255, 125/255, 0/255, 1 },--x/255, x/255, x/255
	test = {30/255, 30/255, 30/255, 1},
	boss = {255/255, 150/255, 195/255, 1},
}

GLOBAL.MODIFIER_RARITY_COLORS = mod_rarity_colors

local function GetRarityColor(rarity)
	if rarity == nil then
		return nil
	end
	return mod_rarity_colors[string.lower(rarity)] or nil
end

local function GetItemRarityData(inst)
	if inst == nil or not inst:IsValid() then
		return nil
	end
	if inst.replica.modifier and inst.replica.modifier:IsModified() then
		return inst.replica.modifier:GetRarity(), "modifier"
	end
	if inst.replica.modifier_scroll then
		local rarity = inst.replica.modifier_scroll:GetRarity()
		if rarity ~= nil and rarity ~= "" then
			return rarity, "scroll"
		end
	end
	return nil
end

AddClassPostConstruct("widgets/hoverer", function(self, owner)--coloring on hover text for dropped items
	local oldUpdate = self.OnUpdate
	function self:OnUpdate()
		oldUpdate(self)
		
		local lmb = self.owner.components and self.owner.components.playercontroller and self.owner.components.playercontroller:GetLeftMouseAction()
		if lmb and lmb.target then
			local color = self.text:GetColour() or GLOBAL.NORMAL_TEXT_COLOUR
			if lmb.target:GetIsWet() then
				color = GLOBAL.WET_TEXT_COLOUR
			end

			if lmb.target:HasTag("modifier_boss") then
				local boss_color = GetRarityColor(lmb.target.rarity) or mod_rarity_colors["boss"]
				if boss_color then
					color = boss_color
				end
			end

			if not lmb.target:GetIsWet() then
				local rarity = GetItemRarityData(lmb.target)
				if rarity then
					color = rarity and mod_rarity_colors[string.lower(rarity)] or GLOBAL.NORMAL_TEXT_COLOUR
				end
			end
			
			self.text:SetColour(color)
			self.secondarytext:SetColour(color)
		else--sometimes, 2nd text is the only 1 showing, without hovering on anything(Example: Waterballoon's Toss Action)
			self.secondarytext:SetColour(GLOBAL.NORMAL_TEXT_COLOUR)
		end
	end
end)

AddClassPostConstruct("widgets/targetindicator", function(self)
	local oldOnUpdate = self.OnUpdate
	function self:OnUpdate(...)
		if self.target and self.target:IsValid() and self.target:HasTag("modifier_boss") then
			local colors = GLOBAL.MODIFIER_RARITY_COLORS or mod_rarity_colors
			local rarity = self.target.rarity or "boss"
			local c = (colors and colors[string.lower(rarity)]) or (colors and colors["boss"])
			if c then
				self.colour = c
			end
		end
		return oldOnUpdate(self, ...)
	end
end)

local UIAnim = GLOBAL.require "widgets/uianim"

local function updateUI(self)
	local rarity, source = GetItemRarityData(self.item)
	if rarity then
		self.modified:Show()
		if self.spoilage then
			self.spoilage:GetAnimState():SetMultColour(1,1,1,0.6)
		end

		if self.percent then
			if source == "modifier" then
				if self.item:HasTag("modifier_sturdy_x") or self.item:HasTag("modifier_toughness_x") or self.item:HasTag("modifier_godlike") then
					self.percent:Hide()
				else
					self.percent:Show()
				end
			else
				self.percent:Hide()
			end
		end
		if rarity and not self.item:GetIsWet() then
			self:SetTooltipColour(rarity and mod_rarity_colors[string.lower(rarity)] or GLOBAL.NORMAL_TEXT_COLOUR)
		end	

		self.modified:GetAnimState():PushAnimation(rarity and string.lower(rarity) or "test", true)
		if source == "modifier" and self.item:HasTag("modifier_ghoststrike") and self.item.uitask == nil then--at most one task per item
			self.item.uitask = self.item:DoPeriodicTask(0.9, function(inst)
				if not self.inst:IsValid() then--this tile was killed; stop and let the next live tile recreate the task
					inst.uitask:Cancel()
					inst.uitask = nil
					inst.lastchange = nil
					return
				end
				if inst.lastchange == nil then
					inst.lastchange = inst.replica.modifier:GetRarity()
				end
				if not inst:HasTag("modifier_ghoststrike") and inst.uitask then
					inst.uitask:Cancel()
					inst.uitask = nil
					inst.lastchange = nil
					return
				end
				local rar = inst:HasTag("modifier_ghoststrike_oncooldown") and "good" or inst.replica.modifier:GetRarity()
				if inst.lastchange ~= rar then
					self.modified:GetAnimState():PushAnimation(rar and string.lower(rar) or "test", true)
					inst.lastchange = rar		
				end		
			end)
		end

		return rarity
	else
		self.modified:Hide()
		if self.spoilage then
			self.spoilage:GetAnimState():SetMultColour(1,1,1,1)
		end
		self:SetTooltipColour(self.item:GetIsWet() and GLOBAL.WET_TEXT_COLOUR or GLOBAL.NORMAL_TEXT_COLOUR)
		return nil
	end
end

AddClassPostConstruct("widgets/itemtile", function(self, owner)--adding new UIAnim for modifiers, coloring on hover text for inventory tiles
	self.modified = self:AddChild(UIAnim())
	self.modified:MoveToBack()--Index - modified: 0, bg: 1, spoilage: 2
	if self.bg then
        self.bg:MoveToBack()--Index - bg: 0, modified: 1, spoilage: 2
    end--so ordering is perish_bg, modifier, perish_pct, wetness, recharge_bg, item, recharge_pct
    self.modified:GetAnimState():SetBank("modifier_border")
    self.modified:GetAnimState():SetBuild("modifier_border")
	--self.modified:GetAnimState():PlayAnimation("test", true)
    self.modified:Hide()
	self.modified:SetClickable(false)

	updateUI(self)
	self.inst:ListenForEvent("modifier_rarity_client", function(inst)
		updateUI(self)
	end, self.item)--listen via the widget's entity so callbacks die with the tile (vanilla itemtile pattern)
	self.inst:ListenForEvent("modifier_scroll_dirty", function(inst)
		updateUI(self)
	end, self.item)
	
	local oldUpdate = self.UpdateTooltip
	function self:UpdateTooltip()
		oldUpdate(self)
		updateUI(self)
	end

	local oldDrag = self.StartDrag
	function self:StartDrag()
		oldDrag(self)
		self.modified:Hide()
	end
end)

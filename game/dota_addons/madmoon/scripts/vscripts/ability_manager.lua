if AbilityManager == nil then 
	AbilityManager = {}
	AbilityManager.__index = AbilityManager
end

ABILITY_CATEGORY_PROJECTILE = 1
ABILITY_CATEGORY_AOE		= 2
ABILITY_CATEGORY_MOVEMENT	= 4
ABILITY_CATEGORY_ATTACK		= 8


function AbilityManager:AbilityWrapper(hAbility, abilityProperties)
	-- wrapper check
	if hAbility:IsWrapped() ~= nil then return end
	if hAbility:GetClassname() ~= "ability_lua" then
		print("[ERROR] "..hAbility:GetAbilityName().." is not a Lua ability or item.")
		return
	end

	-- ability private vars
	local iExperienceGained = 0
	local nMaxModifiers = 5

	-- ability modifiers table
	-- empty = false
	local mModifiers = {
		[1] = false, [2] = false, [3] = false, [4] = false, [5] = false
	}

	-- helper vars
	local bAbilityWrapped = true
	local bAutoDeriveCategory = true

	--------------------------------------------------------------------------
	-- (bool) GetAbilitySpecial: Returns ability special val
	--------------------------------------------------------------------------
	function hAbility:GetAbilitySpecial(strProp, nLevel)
		local ability_table = ABILITIES_KV[hAbility:GetAbilityName()]
		if ability_table then
			if type(ability_table[strProp]) == "table" and type(nLevel) == "number" then
				return ability_table[strProp][nLevel]
			elseif type(strProp) == "string" then
				return ability_table[strProp]
			end
		end
		return nil
	end

	--------------------------------------------------------------------------
	-- (bool) IsWrapped: Returns true if ability is wrapped
	--------------------------------------------------------------------------
	function hAbility:IsWrapped()
		return bAbilityWrapped
	end

	--------------------------------------------------------------------------
	-- (int) GetModifierCount: Returns number of modifiers
	--------------------------------------------------------------------------
	function hAbility:GetModifierCount()
		local count = 0
		for _,v in ipairs(mModifiers) do
			if v ~= false and type(v) == "table" then
				count = count + 1
			end
		end
		return count
	end

	--------------------------------------------------------------------------
	-- (hscript) GetModifierByIndex: Returns ability modifier handle
	--------------------------------------------------------------------------
	function hAbility:GetModifierByIndex(nIndex)
		if mModifiers[nIndex] ~= false then return mModifiers[nIndex] end
		return nil
	end

	--------------------------------------------------------------------------
	-- (int) GetAbilityCategory: 
	--------------------------------------------------------------------------
	if bAutoDeriveCategory then
		function hAbility:GetAbilityCategory()
			local i = 0

			-- bitfield helper to determine category from ability behavior
			local iBehavior = self:GetBehavior()
			local bIsFlagged = function(...)
				return bit.band(iBehavior, ...) ~= 0
			end

			if self:HasProjectileBehavior() then
				i = i + ABILITY_CATEGORY_PROJECTILE
			end
			if bIsFlagged(DOTA_ABILITY_BEHAVIOR_AOE) then
				i = i + ABILITY_CATEGORY_AOE
			end
			if bIsFlagged(DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES) then
				i = i + ABILITY_CATEGORY_MOVEMENT
			end
			if bIsFlagged(DOTA_ABILITY_BEHAVIOR_ATTACK) then
				i = i + ABILITY_CATEGORY_ATTACK
			end
			return i
		end
	end

	--------------------------------------------------------------------------
	-- (int) GetStaminaCost
	--------------------------------------------------------------------------
	function hAbility:GetStaminaCost()
		return self:GetSpecialValueFor("stamina_cost") or 0
	end

	--------------------------------------------------------------------------
	-- (int) GetEnergyOrbCost
	--------------------------------------------------------------------------
	function hAbility:GetEnergyOrbCost()
		return self:GetSpecialValueFor("energy_orb_cost") or 0
	end

	--------------------------------------------------------------------------
	-- (int) GetEnergyOrbCost
	--------------------------------------------------------------------------
	function hAbility:GetEnergyOrbGenerateAmount()
		return self:GetSpecialValueFor("generate_energy_orb") or 0
	end

	--------------------------------------------------------------------------
	-- (int) GetExperienceGained
	--------------------------------------------------------------------------
	function hAbility:GetExperienceGained()
		return iExperienceGained
	end

	--------------------------------------------------------------------------
	-- Events: OnExperienceGained: Ability gained experience
	--------------------------------------------------------------------------
	function hAbility:OnExperienceGained(iXPGained, bApplyDifficultyScaling) --future stuff: bApplyDifficultyScaling 
		-- self.iExperienceGained = self.iExperienceGained + iXPGained
		iExperienceGained = iExperienceGained + iXPGained
	end

	--------------------------------------------------------------------------
	-- AddModifier [[todo:abilitymodifierslots]]
	--------------------------------------------------------------------------
	function hAbility:AddModifier(hCaster, strModifierName, modifierData, modifierSlot)
		local hCaster = hCaster or self:GetCaster()
		local nModifierCount = self:GetModifierCount()

		if nModifierCount < self.tInstanceProperties.nMaxModifiers then
			self.RemoveModifierByNameAndCaster(strModifierName, hCaster)
			for k,v in ipairs(self.mModifiers) do
				if v == false then
					v = { 
						modifier_name = strModifierName, 
						caster_entindex = hCaster:GetEntityIndex(), 
						modifier_data = modifierData,
						modifier_slot = tonumber(k)
					}
					break
				end
			end
		end
	end

	--------------------------------------------------------------------------
	-- RemoveModifier
	--------------------------------------------------------------------------
	function hAbility:RemoveModifierByNameAndCaster(strModifierName, hCaster)
		local t = {}
		for _,v in ipairs(self.mModifiers) do
			if v[modifier_name] == strModifierName and v[caster_entindex] == hCaster:GetEntityIndex() then
				v = false
			end
		end
	end


	print("wrapped")
end

--------------------------------------------------------------------------------
-- Projectile Event/Filter
--------------------------------------------------------------------------------
function AbilityManager:LinearProjectileFilter(infoTable)
	local tProjectileInfo = infoTable
	local hAbility = tProjectileInfo.Ability
	
	--------------------------------------
	-- OnProjectileStart modify-able vars
	--------------------------------------
	local fDistance = tProjectileInfo.fDistance or 1000
	local fSpeed = tProjectileInfo.fSpeed or 800
	local fStartRadius = tProjectileInfo.fStartRadius or 50
	local fEndRadius = tProjectileInfo.fEndRadius or 50
	local nProjectiles = 1

	local bMultiplication = false

	-- bitfield helper
	local m = hAbility:GetAbilityModifiers()
	local bIsFlagged = function(...)
		return bit.band(m, ...) ~= 0
	end
	if bIsFlagged(ABILITY_MODIFIER_PROJECTILE_LESSER_MULTIPLICATION) then
		nProjectiles = nProjectiles + 2
		bMultiplication = true
	end
	if bIsFlagged(ABILITY_MODIFIER_PROJECTILE_GREATER_MULTIPLICATION) then
		nProjectiles = nProjectiles + 4
		bMultiplication = true
	end
	if bIsFlagged(ABILITY_MODIFIER_PROJECTILE_MAGNIFY) then
		fStartRadius = fStartRadius * 1.2
		fEndRadius = fEndRadius * 1.2
	end
	if bIsFlagged(ABILITY_MODIFIER_PROJECTILE_SCATTER) then
		fEndRadius = fEndRadius * 2.0
	end
	if bIsFlagged(ABILITY_MODIFIER_PROJECTILE_SHOTGUN) then
		fStartRadius = fStartRadius * 2.0
	end
	if bIsFlagged(ABILITY_MODIFIER_PROJECTILE_GREATER_SPEED) then
		fSpeed = fSpeed * 1.5
	end
	if bIsFlagged(ABILITY_MODIFIER_PROJECTILE_LONGSHOT) then
		fDistance = fDistance * 1.5
	end
	
	


	

end




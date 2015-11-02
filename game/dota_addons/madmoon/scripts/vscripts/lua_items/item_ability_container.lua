if item_ability_container == nil then item_ability_container = class({}) end

function item_ability_container:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function item_ability_container:OnAbilityPhaseStart()
	local hCaster = self:GetCaster()
	local nAbilityCount = hCaster:GetAbilityCount()
	if nAbilityCount > 15 then --max abilslots 
		return false
	end
	if hCaster:HasAttackCapability() ~= 2 then
		return false
	end
	if hCaster:HasAbility("archer_powershot") then
		return false
	end
	return true
end

function item_ability_container:OnSpellStart() 
	
end
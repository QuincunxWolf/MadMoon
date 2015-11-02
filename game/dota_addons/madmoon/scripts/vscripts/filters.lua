-------------------------------------
--[[ 
		FILTERS
]]
-------------------------------------

function MadMoon:ModifyExperienceFilter(filterTable)
	
	--------------------------------------------------------------------------------
	-- Experience Gained Event
	--------------------------------------------------------------------------------	
	local playerID = PlayerResource:GetPlayer(filterTable.player_id_const)
	local hero = playerID:GetAssignedHero()
	local nAbilityCount = hPlayerHero:GetAbilityCount()
	for i=0, nAbilityCount-1 do
		local hAbility = hPlayerHero:GetAbilityByIndex(i)
		if hAbility:IsWrapped() or hAbility:GetClassname() == "ability_lua" then
			local iXPGained = filterTable.experience
			hAbility:OnExperienceGained(iXPGained)
		end
	end	
	--------------------------------------------------------------------------------


	return true
end

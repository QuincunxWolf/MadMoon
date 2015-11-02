if ModifierManager == nil then
	ModifierManager = {}
	ModifierManager.__index = ModifierManager
end

local tModifierTable = tModifierTable or {}
local tModifierIndexCount = tModifierIndexCount or 0


--------------------------------------------------------------------------
-- ModifierManager
--------------------------------------------------------------------------
function ModifierManager:CreateModifier(hParentAbility, strModifierName, modifierData)
	local nModifierGlobalIndex = tModifierIndexCount + 1
	tModifierTable[nModifierGlobalIndex] = {}

	-- modifier table
	local hModifier = tModifierTable[nModifierGlobalIndex]

	-- instance props
	local fCreationTime = GameRules:GetGameTime()
	local nParentAbilityIndex = hParentAbility:GetEntityIndex()
	local strModifierName = strModifierName
	local nModifierIndex = {}

	-- helpers
	local bIsEquipped = false
	
	-- modifier properties
	local tProperties = {}
	if type(modifierData) == "table" then
		for k,v in pairs(modifierData) do
			tProperties[k] = v 
		end
	end

	-- GetProperties: Returns params' value, table or string
	function hModifier:GetProperties(propertyName)
		if type(propertyName) == "table" then 
			local t = {}
			for _,v in pairs(propertyName) do
				t[v] = tProperties(v)
			end
			return t
		elseif type(propertyName) == "string" then
			return tProperties[propertyName] 
		end
		return tProperties
	end

	-- GetCreationTime: Returns modifier creation time
	function hModifier:GetCreationTime()
		return fCreationTime
	end

	function hModifier:GetModifierGlobalIndex()
		return nModifierGlobalIndex
	end

	function hModifier:GetModifierIndex()
		if bIsEquipped then return nModifierIndex end
		return nil
	end

	function hModifier:GetParentAbility()
		return EntIndexToHScript(nParentAbilityIndex) 
	end

	function hModifier:GetModifierName()
		return strModifierName
	end

	function hModifier:OnEquipped()
		bIsEquipped = true
	end

	function hModifier:OnUnequipped()
		bIsEquipped = false
	end

	function hModifier:OnDestroy()
		hModifier = false
	end

	return hModifier
end
--[[ 
	Ability: Fireball
	Description: Shoot a fireball at a target point.
]]

if sorcerer_fireball == nil then sorcerer_fireball = class({}) end

function sorcerer_fireball:OnSpellStart()
	local vCursorPos = self:GetCursorPosition()
	local hCaster = self:GetCaster()

	

end

function sorcerer_fireball:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT
end
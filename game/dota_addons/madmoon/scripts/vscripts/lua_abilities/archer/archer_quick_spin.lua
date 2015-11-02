if archer_quick_spin == nil then archer_quick_spin = class({}) end

function archer_quick_spin:CastFilterResult()
	if not self:GetCaster():IsStunned() then
		return UF_FAIL_CUSTOM
	else
		self.bIsCasterStunned = true
	end
	return UF_SUCCESS
end

function archer_quick_spin:GetCustomCastError()
	return "Can't use if no stunned status."
end

function archer_quick_spin:OnSpellStart()

end

function archer_quick_spin:GetCooldown(iLevel)
	return
end

function archer_quick_spin:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_UNRESTRICTED
end
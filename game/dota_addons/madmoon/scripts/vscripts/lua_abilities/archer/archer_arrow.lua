if archer_arrow == nil then archer_arrow = class({}) end

function archer_arrow:IsProjectileBased()
	return true
end

function archer_arrow:GetCastAnimation()
	return ACT_DOTA_ATTACK
end

function archer_arrow:GetCastRange(vLocation, hTarget)
	return 1000
end

function archer_arrow:OnSpellStart()
	local hCaster = self:GetCaster()
	local vCursorPos = self:GetCursorPosition()
	local vDirection = vCursorPos - hCaster:GetOrigin()
	local vLength = vDirection:Length2D()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	local vAttachPos = hCaster:GetAttachmentOrigin(hCaster:ScriptLookupAttachment("attach_attack1"))
	self.projectile_width = self:GetSpecialValueFor("default_projectile_width")
	self.projectile_speed = self:GetSpecialValueFor("default_projectile_speed")
	self.projectile_distance = self:GetSpecialValueFor("default_projectile_distance")
	self.max_damage = hCaster:GetAverageTrueAttackDamage() * 5.0
	self.vInitialPos = hCaster:GetOrigin()
	self.vInitialPos.z = vAttachPos.z

	local arrow_info = {
		EffectName = "",
		Ability = self,
		vSpawnOrigin = self.vInitialPos, 
		fStartRadius = self.projectile_width,
		fEndRadius = self.projectile_width,
		vVelocity = vDirection * self.projectile_speed,
		fDistance = self.projectile_distance,
		Source = hCaster,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		vCursorPos = vCursorPos,
		fProjectileSpeed = self.projectile_speed 
	}
	ProjectileManager:CreateLinearProjectile(arrow_info)
end

function archer_arrow:OnProjectileHit(hTarget, vLocation)
	local hCaster = self:GetCaster()
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local fDistanceDiff = (hTarget:GetOrigin() - hCaster:GetOrigin()):Length2D()
		local fDamage = (self.projectile_distance - fDistanceDiff) / self.projectile_distance * self.max_damage
		local damage_table = {
			victim = hTarget,
			attacker = hCaster,
			damage_type = DAMAGE_TYPE_PURE,
			damage = fDamage
		}
		ApplyDamage(damage_table)
	end
	return true
end

function archer_arrow:OnProjectileThink(vLocation)
	DebugDrawLine(self.vInitialPos, vLocation, 0, 255, 0, true, 1/30)
	DebugDrawSphere(vLocation, Vector(0, 255, 0), 1.0, self.projectile_width, true, 1/30)
end
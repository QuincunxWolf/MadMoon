if archer_powershot == nil then archer_powershot = class({}) end

function archer_powershot:OnSpellStart()
	PrintTable(self)
	self.fChannelStartTime = GameRules:GetGameTime()
	self.vCursorPos = self:GetCursorPosition()
end

function archer_powershot:GetChannelTime()
	self.fChannelTime = self:GetSpecialValueFor("max_charge_time")
	return self.fChannelTime
end

function archer_powershot:GetChannelAnimation()
	return ACT_DOTA_CAST_ABILITY_2 --powershot animation
end

function archer_powershot:OnChannelFinish(bInterrupted)
	local hCaster = self:GetCaster()
	local hAbility = self

	local fChargeTime = GameRules:GetGameTime() - self.fChannelStartTime
	local fPowerRate = fChargeTime/self.fChannelTime

	local fMaxDamage = self:GetSpecialValueFor("max_damage")
	local fProjectileSpeed = self:GetSpecialValueFor("projectile_speed")
	local fProjectileWidth = self:GetSpecialValueFor("projectile_width")
	local fProjectileDistance = self:GetSpecialValueFor("projectile_distance")

	-- attach pos
	local vAttachPos = hCaster:GetAttachmentOrigin(hCaster:ScriptLookupAttachment("attach_attack1"))
	local vProjSpawnOrig = hCaster:GetOrigin()
	vProjSpawnOrig.z = vAttachPos.z

	-- projectile direction vector
	local vDir = self.vCursorPos - hCaster:GetOrigin()
	vDir.z = 0.0
	vDir = vDir:Normalized()

	-- projectile creation
	local projectile = {
		Ability = hAbility,
		EffectName = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf",
		vSpawnOrigin = vProjSpawnOrig,
		fDistance = fProjectileDistance,
		fStartRadius = fProjectileWidth,
		fEndRadius = fProjectileWidth,
		Source = hCaster,
		fExpireTime = fProjectileDistance/fProjectileSpeed,
		vVelocity = vDir * fProjectileSpeed,
		UnitBehavior = PROJECTILES_NOTHING,
		bMultipleHits = false,
		bIgnoreSource = true,
		TreeBehavior = PROJECTILES_NOTHING,
		bCutTrees = false,
		bTreeFullCollision = false,
		WallBehavior = PROJECTILES_NOTHING,
		GroundBehavior = PROJECTILES_NOTHING,
		fGroundOffset = 80.0,
		nChangeMax = 1,
		bRecreateOnChange = true,
		bZCheck = false,
		bGroundLock = false,
		bProvidesVision = true,
		iVisionRadius = 350,
		iVisionTeamNumber = hCaster:GetTeam(),
		bFlyingVision = false,
		fVisionTickTime = .1,
		fVisionLingerDuration = 1,
		draw = true,
		fHitCount = 0,
		UnitTest = function(self, unit) return unit:GetTeamNumber() ~= hCaster:GetTeamNumber() end,
  		OnUnitHit = function(self, unit)
  			unit:AddNewModifier(self.Source, hAbility,"modifier_stunned", {duration = 2.0})
  			self.fHitCount = self.fHitCount + 1
  			if self.fHitCount >= 4 then
  				self.UnitBehavior = PROJECTILES_DESTROY
  			end
  		end,
  		OnFinish = function(self, pos) end,
	}
	Projectiles:CreateProjectile(projectile)
	
end
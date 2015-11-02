------------------------------------ 
-- Projectile Modifier Mods			
------------------------------------
PROJECTILE_MODIFIER_LESSER_MULTIPLICATION 	= 1		-- additional 2 projectiles
PROJECTILE_MODIFIER_GREATER_MULTIPLICATION	= 2		-- additional 4 projectiles
PROJECTILE_MODIFIER_LONGSHOT 				= 4		-- increased projectile max distance
PROJECTILE_MODIFIER_GREATER_SPEED			= 8		-- increased projectile speed
PROJECTILE_MODIFIER_MAGNIFY					= 16	-- increased projectile width
PROJECTILE_MODIFIER_SHOTGUN					= 32	-- increased projectile start radius
PROJECTILE_MODIFIER_SCATTER					= 64	-- increased projectile end radius

------------------------------------ 
-- Projectile Hit Modifier Mods			
------------------------------------
PROJECTILE_HIT_MODIFIER_PIERCE				= 1		
PROJECTILE_HIT_MODIFIER_FORK				= 2		
PROJECTILE_HIT_MODIFIER_CHAIN 				= 4		
PROJECTILE_HIT_MODIFIER_MIRROR				= 8		
PROJECTILE_HIT_MODIFIER_BLINK				= 16	
PROJECTILE_HIT_MODIFIER_SAP					= 32	
PROJECTILE_HIT_MODIFIER_					= 64	


------------------------------------ 
-- GetProjectileModifier		
------------------------------------	
function ProjectileManager:GetProjectileModifiers(ability)
	if ability.iProjectileModifiers == nil then return nil end

	local iProjectileModifiers = ability.iProjectileModifiers
	local tProjectileModifiers = {}
	local tSubsets = { 64, 32, 16, 8, 4, 2, 1 }

	-- highest to lowest subsets sum
	repeat
		for i=1, #tSubsets do
			if tSubsets[i] <= iProjectileModifiers then
				--
				table.insert(tProjectileModifiers, tSubsets[i])
				iProjectileModifiers = iProjectileModifiers - tSubsets[i]
				break
			end
		end
	until iProjectileModifiers == 0
		
	return tProjectileModifiers
end

------------------------------------ 
-- GetProjectileHitModifier		
------------------------------------	
function GetProjectileHitModifiers(iProjectileHitModifiers)

end


function ProjectileManager:FireLinearProjectile(vCursorPos, fProjectileSpeed, infoTable)
	local info = infoTable
	local tProjectileModifiers = ProjectileManager:GetProjectileModifiers(info.Ability)

	-- should be changed
	if tProjectileModifiers == nil then 
		ProjectileManager:CreateLinearProjectile(info)
	end

	local nNumProjectiles = 1
	local bHasLesserMultiplication, bHasGreatedMultiplication = false
	local fInitialDistance = info.fDistance
	-- mana cost
	local fPreModsManaCost = info.Ability:GetManaCost(info.Ability:GetLevel())
	local fAdjustedManaCost = fPreModsManaCost

	if table.contains(tProjectileModifiers, PROJECTILE_MODIFIER_LESSER_MULTIPLICATION) then
		nNumProjectiles = nNumProjectiles + 2
		bHasLesserMultiplication = true

		-- mana multiplier
		local fManaMultiplier = 140 -- HARDCODED ATM
		fAdjustedManaCost = fAdjustedManaCost * fManaMultiplier/100
	end
	if table.contains(tProjectileModifiers, PROJECTILE_MODIFIER_GREATER_MULTIPLICATION) then
		nNumProjectiles = nNumProjectiles + 4
		bHasGreatedMultiplication = true

		-- mana multiplier
		local fManaMultiplier = 180 -- HARDCODED ATM
		fAdjustedManaCost = fAdjustedManaCost * fManaMultiplier/100
	end
	if table.contains(tProjectileModifiers, PROJECTILE_MODIFIER_LONGSHOT) then
		info.fDistance = info.fDistance + info.fDistance * 1.5

		-- mana multiplier
		local fManaMultiplier = 120 -- HARDCODED ATM
		fAdjustedManaCost = fAdjustedManaCost * fManaMultiplier/100
	end
	if table.contains(tProjectileModifiers, PROJECTILE_MODIFIER_GREATER_SPEED) then
		fProjectileSpeed = fProjectileSpeed + 500

		-- mana multiplier
		local fManaMultiplier = 130 -- HARDCODED ATM
		fAdjustedManaCost = fAdjustedManaCost * fManaMultiplier/100
	end
	if table.contains(tProjectileModifiers, PROJECTILE_MODIFIER_MAGNIFY) then
		info.fStartRadius = info.fStartRadius + info.fStartRadius * 1.5
		info.fEndRadius = info.fEndRadius + info.fEndRadius * 1.5

		-- mana multiplier
		local fManaMultiplier = 180 -- HARDCODED ATM
		fAdjustedManaCost = fAdjustedManaCost * fManaMultiplier/100
	end
	if table.contains(tProjectileModifiers, PROJECTILE_MODIFIER_SHOTGUN) then
		info.fStartRadius = info.fStartRadius + info.fStartRadius * 1.5

		-- mana multiplier
		local fManaMultiplier = 130 -- HARDCODED ATM
		fAdjustedManaCost = fAdjustedManaCost * fManaMultiplier/100
	end
	if table.contains(tProjectileModifiers, PROJECTILE_MODIFIER_SCATTER) then
		info.fEndRadius = info.fEndRadius + info.fEndRadius * 1.5

		-- mana multiplier
		local fManaMultiplier = 130 -- HARDCODED ATM
		fAdjustedManaCost = fAdjustedManaCost * fManaMultiplier/100
	end

	-- PAY EXTRA MANA COST
	local fExtraManaCost = fAdjustedManaCost - fPreModsManaCost
	if info.Source:GetMana() < fExtraManaCost then
		info.Ability:RefundManaCost()
		return
	else
		info.Source:SpendMana(fExtraManaCost, info.Ability)
	end

	-- Multiple Projectiles
	if bHasLesserMultiplication or bHasGreatedMultiplication then
		-- determine sweep angle via cursor caster diff distance
		local fCursorCasterDiff = (vCursorPos - info.Source:GetOrigin()):Length2D()
		if fCursorCasterDiff > fInitialDistance then fCursorCasterDiff = fInitialDistance end
		-- finding angle specifics
		local fAngleRate = (1.0 - fCursorCasterDiff/fInitialDistance) or 0.0
		local fMaxSweepAngle, fMinSweepAngle = 70, 10 -- HARDCODED atm
		local fSweepAngle = ((fMaxSweepAngle - fMinSweepAngle) * fAngleRate) + fMinSweepAngle
		local fStartAngle = fSweepAngle / -2.0
		local fAngleStep = fSweepAngle / (nNumProjectiles - 1)

		for i=1, nNumProjectiles do
			local vDirection = (vCursorPos - info.Source:GetOrigin())
			vDirection.z = 0.0
			vDirection = RotatePosition(Vector(0,0,0), QAngle(0, fStartAngle+(i-1)*fAngleStep, 0), vDirection:Normalized())
			info.vVelocity = vDirection * fProjectileSpeed
			ProjectileManager:CreateLinearProjectile(info)
		end
	else
		ProjectileManager:CreateLinearProjectile(info)
	end
end

------------------------------------ 
-- Utility Functions	
------------------------------------
function table.contains(table, element)
	for k,v in pairs(table) do
		if v == element then
			return true
		end
	end
	return false
end
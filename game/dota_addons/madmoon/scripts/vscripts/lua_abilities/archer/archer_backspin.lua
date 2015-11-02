if archer_backspin == nil then archer_backspin = class({}) end


--[[ 
    Code snippet from BMD Hunter
]]
function archer_backspin:OnSpellStart()
    local hAbility = self
    local hCaster = self:GetCaster()

    local ACT_FRAMES = 19
    local fDuration = 0.8
    local fForwardPitch = 0

    local vDirection = self:GetCursorPosition() - hCaster:GetOrigin()
    vDirection.z = 0
    vDirection = vDirection:Normalized()

    local fAngles = hCaster:GetAngles()
    fAngles.x = 0
    hCaster:SetAngles(fAngles.x + fForwardPitch, fAngles.y, fAngles.z)

    -- BMD Physics
    Physics:Unit(hCaster)
    hCaster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
    hCaster:FollowNavMesh(true)
    hCaster:Hibernate(false)
    hCaster:SetAutoUnstuck(false)
    hCaster:SetPhysicsFriction(0)

    local xydir = -1 * vDirection
    local xydist = 400 + hCaster:GetMoveSpeedModifier(hCaster:GetBaseMoveSpeed())

    hCaster:SetPhysicsVelocity(xydir * (xydist / fDuration) + Vector(0,0, hCaster:GetPhysicsAcceleration().z / -2 * fDuration))
    StartAnimation( hCaster, { duration = fDuration + 0.1, activity = ACT_DOTA_SPAWN, rate = fDuration * 30 / ACT_FRAMES })

    local flip = 360 + fForwardPitch
    local flip_step = flip / fDuration / 30
    local count = 0

    Timers:CreateTimer(function()
        local pitch = fAngles.x + fForwardPitch - flip_step * count
        hCaster:SetAngles(fAngles.x, fAngles.y + flip_step*count, fAngles.z)
        local factor = (180 - math.abs(pitch)) / 5
        factor = factor / 2

        if count < fDuration * 15 then
          hCaster:SetAbsOrigin(hCaster:GetAbsOrigin() + Vector(0,0,factor))
        else
          hCaster:SetAbsOrigin(hCaster:GetAbsOrigin() + Vector(0,0,factor))
        end
        if count >= fDuration * 30 then
          hCaster:SetAngles(fAngles.x, fAngles.y, fAngles.z)
          return
        end
        count = count + 1
        return .03
    end)

    Timers:CreateTimer(fDuration+.03, function()
        StartAnimation(hCaster, {duration=.5, activity=ACT_DOTA_OVERRIDE_ABILITY_2, rate=1.5})    
        hCaster:SetPhysicsVelocity(hCaster:GetPhysicsVelocity()/20)    
        hCaster:PreventDI(false)
        hCaster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
        hCaster:SetGroundBehavior(PHYSICS_GROUND_ABOVE)
        hCaster:FollowNavMesh(true)
        hCaster:Hibernate(true)
        hCaster:SetPhysicsFriction(hCaster.originalFriction or 0.05)
        hCaster:Stop()    
    end)

end

function archer_backflip:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

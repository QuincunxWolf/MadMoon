--[[ Events ]]

--------------------------------------------------------------------------------
-- GameEvent:OnGameRulesStateChange
--------------------------------------------------------------------------------
function MadMoon:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		print( "OnGameRulesStateChange: Custom Game Setup" )
	elseif nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		print( "OnGameRulesStateChange: Hero Selection" )
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		print( "OnGameRulesStateChange: Pre Game" )
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print( "OnGameRulesStateChange: Game In Progress" )
	end
end

--------------------------------------------------------------------------------
-- GameEvent: OnNPCSpawned
--------------------------------------------------------------------------------
function MadMoon:OnNPCSpawned( event )
	hSpawnedUnit = EntIndexToHScript( event.entindex )

	if hSpawnedUnit:IsOwnedByAnyPlayer() and hSpawnedUnit:IsRealHero() then
		local hPlayerHero = hSpawnedUnit

		self._GameMode:SetContextThink( "self:Think_InitializePlayerHero( hPlayerHero )", function() return self:Think_InitializePlayerHero( hPlayerHero ) end, 0 )
	end
end

--------------------------------------------------------------------------------
-- Think_InitializePlayerHero
--------------------------------------------------------------------------------
function MadMoon:Think_InitializePlayerHero( hPlayerHero )
	if not hPlayerHero then
		return 0.1
	end

	local nPlayerID = hPlayerHero:GetPlayerID()

	if self._tPlayerHeroInitStatus[ nPlayerID ] == false then
		self._tPlayerHeroInitStatus[ nPlayerID ] = true

		--[[ Start ability wrapper ]]
		local nAbilityCount = hPlayerHero:GetAbilityCount()
		for i=0, nAbilityCount-1 do
			local hAbility = hPlayerHero:GetAbilityByIndex(i)
			AbilityManager:AbilityWrapper(hAbility)
		end
		--[[ End ability wrapper ]]
	end
end


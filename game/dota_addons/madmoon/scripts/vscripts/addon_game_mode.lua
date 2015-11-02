----------------------
-- Integer Constants
----------------------

----------------------
-- MadMoon class
----------------------
if MadMoon == nil then
	_G.MadMoon = class({})
end

----------------------
-- Require lua files
----------------------
require('libraries/timers')
require('libraries/projectiles')
require('libraries/animations')
require('libraries/physics')
require('util')
require('filters')
require('events')
require('ability_manager')
-- ability kvs
require('lua_abilities/lua_abilityspecial_kvs')

----------------------
-- Precache
----------------------
function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

--------------------------------------------------------------------------------
-- Activate mode
--------------------------------------------------------------------------------
function Activate()
	GameRules.mad_moon = MadMoon()
	GameRules.mad_moon:InitGameMode()
end

--------------------------------------------------------------------------------
-- Init
--------------------------------------------------------------------------------
function MadMoon:InitGameMode()
	self._GameMode = GameRules:GetGameModeEntity()

	ListenToGameEvent('npc_spawned', Dynamic_Wrap(MadMoon, 'OnNPCSpawned'), self)
	self._GameMode:SetModifyExperienceFilter(Dynamic_Wrap( MadMoon, "ModifyExperienceFilter"), self)
	self._GameMode:SetContextThink( "MadMoon:GameThink", function() return self:GameThink() end, 0 )

	self._tPlayerHeroInitStatus = {}	

	for nPlayerID = 0, DOTA_MAX_PLAYERS do
		self._tPlayerHeroInitStatus[ nPlayerID ] = false
	end
end

--------------------------------------------------------------------------------
-- Main Think
--------------------------------------------------------------------------------
function MadMoon:GameThink()
	local flThinkTick = 0.2

	return flThinkTick
end

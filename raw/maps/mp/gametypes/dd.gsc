#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
	Action SAB/SD = DD
	Attackers objective: Bomb both of 2 positions
	Defenders objective: Defend these 2 positions / Defuse planted bombs
	Round ends:	When one team defends for duration of match, both sites are destroyed.
	Map ends:	When one team reaches the score limit, or time limit or round limit is reached
	Respawning:	Players respawn indefinetly and immediately

	Level requirements
	------------------
		Allied Spawnpoints:
			classname		mp_sd_spawn_attacker
			Allied players spawn from these. Place at least 16 of these relatively close together.

		Axis Spawnpoints:
			classname		mp_sd_spawn_defender
			Axis players spawn from these. Place at least 16 of these relatively close together.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.

		Bombzones:
			classname					trigger_multiple
			targetname					bombzone
			script_gameobjectname		bombzone
			script_bombmode_original	<if defined this bombzone will be used in the original bomb mode>
			script_bombmode_single		<if defined this bombzone will be used in the single bomb mode>
			script_bombmode_dual		<if defined this bombzone will be used in the dual bomb mode>
			script_team					Set to allies or axis. This is used to set which team a bombzone is used by in dual bomb mode.
			script_label				Set to A or B. This sets the letter shown on the compass in original mode.
			This is a volume of space in which the bomb can planted. Must contain an origin brush.

		Bomb:
			classname				trigger_lookat
			targetname				bombtrigger
			script_gameobjectname	bombzone
			This should be a 16x16 unit trigger with an origin brush placed so that it's center lies on the bottom plane of the trigger.
			Must be in the level somewhere. This is the trigger that is used when defusing a bomb.
			It gets moved to the position of the planted bomb model.

	Level script requirements
	-------------------------
		Team Definitions:
			game["attackers"] = "allies";
			game["defenders"] = "axis";
			This sets which team is attacking and which team is defending. Attackers plant the bombs. Defenders protect the targets.

		Exploder Effects:
			Setting script_noteworthy on a bombzone trigger to an exploder group can be used to trigger additional effects.
	
	multiple bombs
	multiple targets
	spawning
	round handling when both sites are destroyed

*/

/*QUAKED mp_dd_spawn_attacker_a (0.75 0.0 0.5) (-16 -16 0) (16 16 72)
Axis players spawn near bomb a.*/

/*QUAKED mp_dd_spawn_attacker_b (0.75 0.0 0.5) (-16 -16 0) (16 16 72)
Axis players spawn near bomb b.*/

/*QUAKED mp_dd_spawn_attacker (0.75 0.0 0.5) (-16 -16 0) (16 16 72)
Axis players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_dd_spawn_defender (0.0 0.75 0.5) (-16 -16 0) (16 16 72)
Allied players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_dd_spawn_defender_a (0.0 0.75 0.5) (-16 -16 0) (16 16 72)
Allied players spawn near bomb site a.*/

/*QUAKED mp_dd_spawn_defender_b (0.0 0.75 0.5) (-16 -16 0) (16 16 72)
Allied players spawn near bomb site b.*/

/*QUAKED mp_dd_spawn_attacker_start (0.0 1.0 0.0) (-16 -16 0) (16 16 72)
Attacking players spawn randomly at one of these positions at the beginning of a round.*/

/*QUAKED mp_dd_spawn_defender_start (1.0 0.0 0.0) (-16 -16 0) (16 16 72)
Defending players spawn randomly at one of these positions at the beginning of a round.*/

main()
{
	if(getdvar("mapname") == "mp_background")
		return;
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	
	registerRoundSwitchDvar( level._gameType, 1, 0, 9 );
	registerTimeLimitDvar( level._gameType, 3, 0, 1440 );
	registerScoreLimitDvar( level._gameType, 0, 0, 500 );
	registerRoundLimitDvar( level._gameType, 3, 0, 12 );
	registerWinLimitDvar( level._gameType, 2, 0, 12 );
	registerNumLivesDvar( level._gameType, 0, 0, 10 );
	registerHalfTimeDvar( level._gameType, 0, 0, 1 );
	
	level._objectiveBased = true;
	level._teamBased = true;
	level._onPrecacheGameType = ::onPrecacheGameType;
	level._onStartGameType = ::onStartGameType;
	level._getSpawnPoint = ::getSpawnPoint;
	level._onSpawnPlayer = ::onSpawnPlayer;
	level._onDeadEvent = ::onDeadEvent;
	level._onTimeLimit = ::onTimeLimit;
	level._onNormalDeath = ::onNormalDeath;
	level._initGametypeAwards = ::initGametypeAwards;
	level._dd = true;
	level._bombsPlanted = 0;
	level._ddBombModel = []
	
	setBombTimerDvar();
	
	makeDvarServerInfo( "ui_bombtimer_a", -1 );
	makeDvarServerInfo( "ui_bombtimer_b", -1 );
	
	game["dialog"]["gametype"] = "demolition";
	
	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level._gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";
	
	game["dialog"]["offense_obj"] = "obj_destroy";
	game["dialog"]["defense_obj"] = "obj_defend";
}


onPrecacheGameType()
{
	game["bomb_dropped_sound"] = "mp_war_objective_lost";
	game["bomb_recovered_sound"] = "mp_war_objective_taken";

	precacheShader("waypoint_bomb");
	precacheShader("hud_suitcase_bomb");
	precacheShader("waypoint_target");
	precacheShader("waypoint_target_a");
	precacheShader("waypoint_target_b");
	precacheShader("waypoint_defend");
	precacheShader("waypoint_defend_a");
	precacheShader("waypoint_defend_b");
	precacheShader("waypoint_defuse_a");
	precacheShader("waypoint_defuse_b");
	precacheShader("waypoint_target");
	precacheShader("waypoint_target_a");
	precacheShader("waypoint_target_b");
	precacheShader("waypoint_defend");
	precacheShader("waypoint_defend_a");
	precacheShader("waypoint_defend_b");
	precacheShader("waypoint_defuse");
	precacheShader("waypoint_defuse_a");
	precacheShader("waypoint_defuse_b");
	
	precacheString( &"MP_EXPLOSIVES_RECOVERED_BY" );
	precacheString( &"MP_EXPLOSIVES_DROPPED_BY" );
	precacheString( &"MP_EXPLOSIVES_PLANTED_BY" );
	precacheString( &"MP_EXPLOSIVES_DEFUSED_BY" );
	precacheString( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
	precacheString( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	precacheString( &"MP_CANT_PLANT_WITHOUT_BOMB" );	
	precacheString( &"MP_PLANTING_EXPLOSIVE" );	
	precacheString( &"MP_DEFUSING_EXPLOSIVE" );	
	precacheString( &"MP_BOMB_A_TIMER" );
	precacheString( &"MP_BOMB_B_TIMER" );	
	precacheString( &"MP_BOMBSITE_IN_USE" );
}

onStartGameType()
{
	if ( !isDefined( game["switchedsides"] ) )
		game["switchedsides"] = false;
	
	if ( game["switchedsides"] )
	{
		oldAttackers = game["attackers"];
		oldDefenders = game["defenders"];
		game["attackers"] = oldDefenders;
		game["defenders"] = oldAttackers;
	}
	
	level._useStartSpawns = true;
	
	setClientNameMode( "manual_change" );
	
	game["strings"]["target_destroyed"] = &"MP_TARGET_DESTROYED";
	game["strings"]["bomb_defused"] = &"MP_BOMB_DEFUSED";
	
	precacheString( game["strings"]["target_destroyed"] );
	precacheString( game["strings"]["bomb_defused"] );

	level._effect["bombexplosion"] = loadfx("explosions/tanker_explosion");
	
	setObjectiveText( game["attackers"], &"OBJECTIVES_DD_ATTACKER" );
	setObjectiveText( game["defenders"], &"OBJECTIVES_DD_DEFENDER" );

	if ( level._splitscreen )
	{
		setObjectiveScoreText( game["attackers"], &"OBJECTIVES_DD_ATTACKER" );
		setObjectiveScoreText( game["defenders"], &"OBJECTIVES_DD_DEFENDER" );
	}
	else
	{
		setObjectiveScoreText( game["attackers"], &"OBJECTIVES_DD_ATTACKER_SCORE" );
		setObjectiveScoreText( game["defenders"], &"OBJECTIVES_DD_DEFENDER_SCORE" );
	}
	setObjectiveHintText( game["attackers"], &"OBJECTIVES_DD_ATTACKER_HINT" );
	setObjectiveHintText( game["defenders"], &"OBJECTIVES_DD_DEFENDER_HINT" );

	level._spawnMins = ( 0, 0, 0 );
	level._spawnMaxs = ( 0, 0, 0 );	
	
	
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( game["defenders"], "mp_dd_spawn_defender" );	
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( game["defenders"], "mp_dd_spawn_defender_a", true );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( game["defenders"], "mp_dd_spawn_defender_b", true );
	
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_dd_spawn_defender_start" );
	
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( game["attackers"], "mp_dd_spawn_attacker" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( game["attackers"], "mp_dd_spawn_attacker_a", true );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( game["attackers"], "mp_dd_spawn_attacker_b", true );
	
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_dd_spawn_attacker_start" );
	
	level._spawn_defenders = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dd_spawn_defender" );
	level._spawn_defenders_a = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dd_spawn_defender_a" );
	level._spawn_defenders_a = array_combine( level._spawn_defenders, level._spawn_defenders_a );
	level._spawn_defenders_b = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dd_spawn_defender_b" );
	level._spawn_defenders_b = array_combine( level._spawn_defenders, level._spawn_defenders_b );
	
	level._spawn_attackers = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dd_spawn_attacker" );
	level._spawn_attackers_a = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dd_spawn_attacker_a" );
	level._spawn_attackers_a = array_combine( level._spawn_attackers, level._spawn_attackers_a );
	level._spawn_attackers_b = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dd_spawn_attacker_b" );
	level._spawn_attackers_b = array_combine( level._spawn_attackers, level._spawn_attackers_b );
	
	level._spawn_defenders_start = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dd_spawn_defender_start" );
	level._spawn_attackers_start = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dd_spawn_attacker_start" );
	
	level._mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level._spawnMins, level._spawnMaxs );
	level._aPlanted = false;
	level._bPlanted = false;
	
	setMapCenter( level._mapCenter );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "win", 2 );
	maps\mp\gametypes\_rank::registerScoreInfo( "loss", 1 );
	maps\mp\gametypes\_rank::registerScoreInfo( "tie", 1.5 );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 20 );
	maps\mp\gametypes\_rank::registerScoreInfo( "plant", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "defuse", 100 );
	
	thread updateGametypeDvars();
	thread waitToProcess();
	
	winlimit = getWatchedDvar("winlimit");
	
	allowed[0] = "dd";
	bombZones = getEntArray( "dd_bombzone", "targetname" );
	if ( bombZones.size )
		allowed[1] = "dd_bombzone";
	else
		allowed[1] = "bombzone";
	allowed[2] = "blocker";
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	thread bombs();
}

waitToProcess()
{
	level endon( "game_end" );

	for ( ;; )
	{
		if ( level._inGracePeriod == 0 )
			break;
			
		wait ( 0.05 );	
	}
	
	level._useStartSpawns = false;
		
}

getSpawnPoint()
{
	spawnteam = self.pers["team"];

	if ( level._useStartSpawns )
	{
		if ( spawnteam == game["attackers"] )
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level._spawn_attackers_start);
		else
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level._spawn_defenders_start);
	}	
	else
	{
		if (spawnteam == game["attackers"] )
		{
			if ( (!level._aPlanted && !level._bPlanted) )
				spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnteam );
			else if ( level._aPlanted && !level._bPlanted )
				spawnPoints = level._spawn_attackers_a;
			else if ( level._bPlanted && !level._aPlanted )
				spawnPoints = level._spawn_attackers_b;
			else
				spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnteam );
			
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
		}
		else
		{
			if ( (!level._aPlanted && !level._bPlanted) )
				spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnteam );
			else if ( level._aPlanted && !level._bPlanted )
				spawnPoints = level._spawn_defenders_a;
			else if ( level._bPlanted && !level._aPlanted )
				spawnPoints = level._spawn_defenders_b;
			else
				spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnteam );
			
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
		}
	}
	
	assert( isDefined(spawnpoint) );

	return spawnpoint;
}

onSpawnPlayer()
{
	
	if ( self.pers["team"] == game["attackers"] )
	{
		self.isPlanting = false;
		self.isDefusing = false;
		self.isBombCarrier = true;
		
		if ( level._splitscreen )
		{
			self.carryIcon = createIcon( "hud_suitcase_bomb", 33, 33 );
			self.carryIcon setPoint( "BOTTOM RIGHT", "BOTTOM RIGHT", 0, -78 );
			self.carryIcon.alpha = 0.75;
		}
		else
		{
			self.carryIcon = createIcon( "hud_suitcase_bomb", 50, 50 );
			self.carryIcon setPoint( "BOTTOM RIGHT", "BOTTOM RIGHT", -90, -65 );
			self.carryIcon.alpha = 0.75;
		}
	}
	else
	{
		self.isPlanting = false;
		self.isDefusing = false;
		self.isBombCarrier = false;
		
		if ( isDefined( self.carryIcon ) )
		{
			self.carryIcon Destroy();
		}
	}

	level notify ( "spawned_player" );
}


dd_endGame( winningTeam, endReasonText )
{
	thread maps\mp\gametypes\_gamelogic::endGame( winningTeam, endReasonText );
}


onDeadEvent( team )
{
	if ( level._bombExploded || level._bombDefused )
		return;
	
	if ( team == "all" )
	{
		if ( level._bombPlanted )
			dd_endGame( game["attackers"], game["strings"][game["defenders"]+"_eliminated"] );
		else
			dd_endGame( game["defenders"], game["strings"][game["attackers"]+"_eliminated"] );
	}
	else if ( team == game["attackers"] )
	{
		if ( level._bombPlanted )
			return;

		level thread dd_endGame( game["defenders"], game["strings"][game["attackers"]+"_eliminated"] );
	}
	else if ( team == game["defenders"] )
	{
		level thread dd_endGame( game["attackers"], game["strings"][game["defenders"]+"_eliminated"] );
	}
}


onNormalDeath( victim, attacker, lifeId )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
	assert( isDefined( score ) );

	team = victim.team;
	
	if ( game["state"] == "postgame" && (victim.team == game["defenders"] || !level._bombPlanted) )
		attacker.finalKill = true;
		
	if ( victim.isPlanting )
	{
		thread maps\mp\_matchdata::logKillEvent( lifeId, "planting" );
	}
	else if ( victim.isDefusing )
	{
		thread maps\mp\_matchdata::logKillEvent( lifeId, "defusing" );
	}
}


onTimeLimit()
{
	dd_endGame( game["defenders"], game["strings"]["time_limit_reached"] );
}


updateGametypeDvars()
{
	level._plantTime = dvarFloatValue( "planttime", 5, 0, 20 );
	level._defuseTime = dvarFloatValue( "defusetime", 5, 0, 20 );
	level._bombTimer = dvarIntValue( "bombtimer", 45, 1, 300 );
	level._ddTimeToAdd = dvarFloatValue( "addtime", 2, 0, 5 );; //how much time is added to the match when a target is destroyed
}


bombs()
{
	level._bombPlanted = false;
	level._bombDefused = false;
	level._bombExploded = 0;

	level._bombZones = [];
	
	bombZones = getEntArray( "dd_bombzone", "targetname" );
	if ( !bombZones.size )	
		bombZones = getEntArray( "bombzone", "targetname" );
	
	for ( index = 0; index < bombZones.size; index++ )
	{
		trigger = bombZones[index];
		visuals = getEntArray( bombZones[index].target, "targetname" );
		
		bombZone = maps\mp\gametypes\_gameobjects::createUseObject( game["defenders"], trigger, visuals, (0,0,64) );
		bombZone maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
		bombZone maps\mp\gametypes\_gameobjects::setUseTime( level._plantTime );
		bombZone maps\mp\gametypes\_gameobjects::setUseText( &"MP_PLANTING_EXPLOSIVE" );
		bombZone maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
		bombZone maps\mp\gametypes\_gameobjects::setKeyObject( level._ddBomb );
	
		label = bombZone maps\mp\gametypes\_gameobjects::getLabel();
		bombZone.label = label;
		bombZone.index = index;
		bombZone maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_defend" + label );
		bombZone maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" + label );
		bombZone maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_target" + label );
		bombZone maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_target" + label );
		bombZone maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		bombZone.onBeginUse = ::onBeginUse;
		bombZone.onEndUse = ::onEndUse;
		bombZone.onUse = ::onUseObject;
		bombZone.onCantUse = ::onCantUse;
		bombZone.useWeapon = "briefcase_bomb_mp";
		bombZone.visuals[0].killCamEnt = spawn( "script_model", bombZone.visuals[0].origin + (0,0,128) );
		
		for ( i = 0; i < visuals.size; i++ )
		{
			if ( isDefined( visuals[i].script_exploder ) )
			{
				bombZone.exploderIndex = visuals[i].script_exploder;
				break;
			}
		}
		
		level._bombZones[level._bombZones.size] = bombZone;
		
		bombZone.bombDefuseTrig = getent( visuals[0].target, "targetname" );
		assert( isdefined( bombZone.bombDefuseTrig ) );
		bombZone.bombDefuseTrig.origin += (0,0,-10000);
		bombZone.bombDefuseTrig.label = label;
	}
	
	for ( index = 0; index < level._bombZones.size; index++ )
	{
		array = [];
		for ( otherindex = 0; otherindex < level._bombZones.size; otherindex++ )
		{
			if ( otherindex != index )
				array[ array.size ] = level._bombZones[otherindex];
		}
		level._bombZones[index].otherBombZones = array;
	}
}

onUseObject( player )
{
	team = player.pers["team"];
	otherTeam = level._otherTeam[team];

	if ( !self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
	{
		player notify ( "bomb_planted" );
		player playSound( "mp_bomb_plant" );

		thread teamPlayerCardSplash( "callout_bombplanted", player );
		//iPrintLn( &"MP_EXPLOSIVES_PLANTED_BY", player );
		leaderDialog( "bomb_planted" );

		player thread maps\mp\gametypes\_hud_message::SplashNotify( "plant", maps\mp\gametypes\_rank::getScoreInfoValue( "plant" ) );
		player thread maps\mp\gametypes\_rank::giveRankXP( "plant" );
		maps\mp\gametypes\_gamescore::givePlayerScore( "plant", player );		
		player incPlayerStat( "bombsplanted", 1 );
		player thread maps\mp\_matchdata::logGameEvent( "plant", player.origin );
		player.bombPlantedTime = getTime();

		level thread bombPlanted( self, player );

		level._bombOwner = player;
		self.useWeapon = "briefcase_bomb_defuse_mp";
		self setUpForDefusing();
	}
	else // defused the bomb
	{
		self thread bombHandler( player, "defused" );
	}
}


resetBombZone()
{
	self maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
	self maps\mp\gametypes\_gameobjects::setUseTime( level._plantTime );
	self maps\mp\gametypes\_gameobjects::setUseText( &"MP_PLANTING_EXPLOSIVE" );
	self maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
	self maps\mp\gametypes\_gameobjects::setKeyObject( level._ddBomb );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_defend" + self.label );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" + self.label  );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_target" + self.label );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_target" + self.label );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	self.useWeapon = "briefcase_bomb_mp";
}

setUpForDefusing()
{
	self maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
	self maps\mp\gametypes\_gameobjects::setUseTime( level._defuseTime );
	self maps\mp\gametypes\_gameobjects::setUseText( &"MP_DEFUSING_EXPLOSIVE" );
	self maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	self maps\mp\gametypes\_gameobjects::setKeyObject( undefined );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_defuse" + self.label );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defuse" + self.label );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_defend" + self.label );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_defend" + self.label );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
}

onBeginUse( player )
{
	if ( self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
	{
		player playSound( "mp_bomb_defuse" );
		player.isDefusing = true;
		
		bestDistance = 9000000;
		closestBomb = undefined;
		
		if ( isDefined( level._ddBombModel ) )
		{
			foreach ( bomb in level._ddBombModel )
			{
				if ( !isDefined( bomb ) )
					continue;
				
				dist = distanceSquared( player.origin, bomb.origin );
				
				if (  dist < bestDistance )
				{
					bestDistance = dist;			
					closestBomb = bomb;
				}
			}
			
			assert( isDefined(closestBomb) );
			player.defusing = closestBomb;
			closestBomb hide();
		}
	}
	else
	{
		player.isPlanting = true;
	}
}

onEndUse( team, player, result )
{
	if ( !isDefined( player ) )
		return;
	
	if ( isAlive( player ) )
	{
		player.isDefusing = false;
		player.isPlanting = false;
	}
	
	if ( self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
	{
		if ( isDefined( player.defusing ) && !result )
		{
			player.defusing show();
		}
	}
}

onCantUse( player )
{
	player iPrintLnBold( &"MP_BOMBSITE_IN_USE" );
}

onReset()
{
}

bombPlanted( destroyedObj, player )
{
	destroyedObj endon( "defused" );
	
	level._bombsPlanted += 1;
	self setBombTimerDvar();
	maps\mp\gametypes\_gamelogic::pauseTimer();
	level._timePauseStart = getTime();
	level._timeLimitOverride = true;
	
	level._bombPlanted = true;
	level._destroyedObject = destroyedObj;
	
	if ( level._destroyedObject.label == "_a" )
		level._aPlanted = true;
	else
		level._bPlanted = true; 
	
	level._destroyedObject.bombPlanted = true;
	
	destroyedObj.visuals[0] thread playDemolitionTickingSound(destroyedObj);
	level._tickingObject = destroyedObj.visuals[0];
	
	self dropBombModel( player, destroyedObj.label );
	destroyedObj.bombDefused = false;	
	destroyedObj maps\mp\gametypes\_gameobjects::allowUse( "none" );
	destroyedObj maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
	destroyedObj setUpForDefusing();
	
	destroyedObj BombTimerWait(destroyedObj); //waits for bomb to explode!
	
	destroyedObj thread bombHandler( player ,"explode" );
	
}

bombHandler( player, destType )
{
	self.visuals[0] notify( "stopTicking" );
	level._bombsPlanted -= 1;
	
	if ( self.label == "_a" )
		level._aPlanted = false;
	else
		level._bPlanted = false; 
		
	self.bombPlanted = 0;
	
	self restartTimer();
	self setBombTimerDvar();

	setDvar( "ui_bombtimer" + self.label, -1 );
	//self maps\mp\gametypes\_gameobjects::updateTimer( 0, false );
	
	if ( level._gameEnded )
		return;
	
	if ( destType == "explode" )
	{
		level._bombExploded += 1;
		
		explosionOrigin = self.curorigin;
		level._ddBombModel[ self.label ] Delete();
		
		if ( isdefined( player ) )
		{
			self.visuals[0] radiusDamage( explosionOrigin, 512, 200, 20, player );
			player incPlayerStat( "targetsdestroyed", 1 );
		}
		else
		{
			self.visuals[0] radiusDamage( explosionOrigin, 512, 200, 20 );
		}
		
		rot = randomfloat(360);
		explosionEffect = spawnFx( level._effect["bombexplosion"], explosionOrigin + (0,0,50), (0,0,1), (cos(rot),sin(rot),0) );
		triggerFx( explosionEffect );
		
		PlayRumbleOnPosition( "grenade_rumble", explosionOrigin );
		earthquake( 0.75, 2.0, explosionOrigin, 2000 );
		
		thread playSoundinSpace( "exp_suitcase_bomb_main", explosionOrigin );
		
		if ( isDefined( self.exploderIndex ) )
			exploder( self.exploderIndex );
		
		self maps\mp\gametypes\_gameobjects::disableObject();

		if ( level._bombExploded < 2 )
		{
			foreach ( splashPlayer in level._players )
				splashPlayer thread maps\mp\gametypes\_hud_message::SplashNotify( "time_added" );
		}
	
		wait 2;
		
		if ( level._bombExploded > 1 )
			dd_endGame( game["attackers"], game["strings"]["target_destroyed"] );
		else
			level thread teamPlayerCardSplash( "callout_time_added", player );
	}
	else //defused
	{
		player notify ( "bomb_defused" );
		self notify( "defused" );

//		if ( !level.hardcoreMode )
//			iPrintLn( &"MP_EXPLOSIVES_DEFUSED_BY", player );

		leaderDialog( "bomb_defused" );

		level thread teamPlayerCardSplash( "callout_bombdefused", player );

		level thread bombDefused( self );
		self resetBombzone();

		if ( isDefined( level._bombOwner ) && ( level._bombOwner.bombPlantedTime + 4000 + (level._defuseTime*1000) ) > getTime() && isReallyAlive( level._bombOwner ) )
			player thread maps\mp\gametypes\_hud_message::SplashNotify( "ninja_defuse", ( maps\mp\gametypes\_rank::getScoreInfoValue( "defuse" ) ) );
		else
			player thread maps\mp\gametypes\_hud_message::SplashNotify( "defuse", maps\mp\gametypes\_rank::getScoreInfoValue( "defuse" ) );
					
		player thread maps\mp\gametypes\_rank::giveRankXP( "defuse" );
		maps\mp\gametypes\_gamescore::givePlayerScore( "defuse", player );
		player incPlayerStat( "bombsdefused", 1 );
		player thread maps\mp\_matchdata::logGameEvent( "defuse", player.origIn );
	}
	
}

playDemolitionTickingSound( site )
{
	self endon("death");
	self endon("stopTicking");
	level endon("game_ended");
	
	while(1)
	{
		self playSound( "ui_mp_suitcasebomb_timer" );
		
		if ( !isDefined( site.waitTime ) || site.waitTime > 10 )
			wait 1.0;
		else if ( isDefined( site.waitTime ) && site.waitTime > 5  )
			wait 0.5;
		else 
			wait 0.25;
		maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
	}
}

setBombTimerDvar()
{
	println( "BOMBS PLANTED: " + level._bombsPlanted );
	
	if ( level._bombsPlanted == 1 )
		setDvar( "ui_bomb_timer", 2 );
	else if ( level._bombsPlanted == 2 )
		setDvar( "ui_bomb_timer", 3 );
	else
		setDvar( "ui_bomb_timer", 0 );
}


dropBombModel( player, site )
{
	trace = bulletTrace( player.origin + (0,0,20), player.origin - (0,0,2000), false, player );

	tempAngle = randomfloat( 360 );
	forward = (cos( tempAngle ), sin( tempAngle ), 0);
	forward = vectornormalize( forward - common_scripts\utility::vector_multiply( trace["normal"], vectordot( forward, trace["normal"] ) ) );
	dropAngles = vectortoangles( forward );
	
	level._ddBombModel[ site ] = spawn( "script_model", trace["position"] );
	level._ddBombModel[ site ].angles = dropAngles;
	level._ddBombModel[ site ] setModel( "prop_suitcase_bomb" );
}


restartTimer()
{
	if ( level._bombsPlanted <= 0 )
	{
		maps\mp\gametypes\_gamelogic::resumeTimer();
		level._timePaused = ( getTime() - level._timePauseStart ) ;
		level._timeLimitOverride = false;
	}
}


BombTimerWait(siteLoc)
{
	level endon("game_ended");
	level endon("bomb_defused" + siteLoc.label );

	siteLoc.waitTime = level._bombTimer;
	
	while ( siteLoc.waitTime >= 0 )
	{
		siteLoc.waitTime--;
		setDvar( "ui_bombtimer" + siteLoc.label, siteLoc.waitTime );

		//self maps\mp\gametypes\_gameobjects::updateTimer( waitTime, true );
		
		if ( siteLoc.waitTime >= 0 )
			wait( 1 );
		
		maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
	}
}

bombDefused( siteDefused )
{
	level._tickingObject maps\mp\gametypes\_gamelogic::stopTickingSound();
	siteDefused.bombDefused = true;
	self setBombTimerDvar();
	
	setDvar( "ui_bombtimer" + siteDefused.label, -1 );
	
	level notify("bomb_defused" + siteDefused.label);	
}

initGametypeAwards()
{
	maps\mp\_awards::initStatAward( "targetsdestroyed", 	0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "bombsplanted", 		0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "bombsdefused", 		0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "bombcarrierkills", 	0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "bombscarried", 		0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "killsasbombcarrier", 	0, maps\mp\_awards::highestWins );
}

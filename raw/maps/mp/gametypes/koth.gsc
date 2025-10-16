#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	if ( getdvar("mapname") == "mp_background" )
		return;

	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	registerTimeLimitDvar( level._gameType, 30, 0, 1440 );
	registerScoreLimitDvar( level._gameType, 300, 0, 1000 );
	registerRoundLimitDvar( level._gameType, 1, 0, 10 );
	registerWinLimitDvar( level._gameType, 1, 0, 10 );
	registerNumLivesDvar( level._gameType, 0, 0, 10 );
	registerHalfTimeDvar( level._gameType, 0, 0, 1 );
	
	level._teamBased = true;
	level._doPrematch = true;
	level._onStartGameType = ::onStartGameType;
	level._getSpawnPoint = ::getSpawnPoint;
	level._onSpawnPlayer = ::onSpawnPlayer;
	level._onPlayerKilled = ::onPlayerKilled;
	level._initGametypeAwards = ::initGametypeAwards;

	precacheShader( "waypoint_captureneutral" );
	precacheShader( "waypoint_capture" );
	precacheShader( "waypoint_defend" );

	precacheShader( "waypoint_targetneutral" );
	precacheShader( "waypoint_captureneutral" );
	precacheShader( "waypoint_capture" );
	precacheShader( "waypoint_defend" );
	
	precacheString( &"MP_WAITING_FOR_HQ" );
	
	if ( getdvar("koth_autodestroytime") == "" )
		setdvar("koth_autodestroytime", "60");
	level._hqAutoDestroyTime = getdvarint("koth_autodestroytime");
	
	if ( getdvar("koth_spawntime") == "" )
		setdvar("koth_spawntime", "0");
	level._hqSpawnTime = getdvarint("koth_spawntime");
	
	if ( getdvar("koth_kothmode") == "" )
		setdvar("koth_kothmode", "1");
	level._kothMode = getdvarint("koth_kothmode");

	if ( getdvar("koth_captureTime") == "" )
		setdvar("koth_captureTime", "20");
	level._captureTime = getdvarint("koth_captureTime");

	if ( getdvar("koth_destroyTime") == "" )
		setdvar("koth_destroyTime", "10");
	level._destroyTime = getdvarint("koth_destroyTime");
	
	if ( getdvar("koth_delayPlayer") == "" )
		setdvar("koth_delayPlayer", 1);
	level._delayPlayer = getdvarint("koth_delayPlayer");

	if ( getdvar("koth_spawnDelay") == "" )
		setdvar("koth_spawnDelay", 0);
	level._spawnDelay = getdvarint("koth_spawnDelay");

	if ( getdvar("koth_extraDelay") == "" )
		setdvar("koth_extraDelay", 0.0 );

	level._extraDelay = getdvarint("koth_extraDelay");

	setDvarIfUninitialized( "koth_proMode", 0 );

	level._proMode = getDvarInt( "koth_proMode" );
		
	level._iconoffset = (0,0,32);
	
	level._onRespawnDelay = ::getRespawnDelay;

	game["dialog"]["gametype"] = "headquarters";

	if ( getDvarInt( "g_hardcore" ) )
	{
		if ( getMapCustom( "allieschar" ) == "us_army" )
			game["dialog"]["allies_gametype"] = "hc_gtw";
		if ( getMapCustom( "axischar" ) == "us_army" )
			game["dialog"]["axis_gametype"] = "hc_gtw";

		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	}
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level._gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";
}


updateObjectiveHintMessages( alliesObjective, axisObjective )
{
	game["strings"]["objective_hint_allies"] = alliesObjective;
	game["strings"]["objective_hint_axis"  ] = axisObjective;
	
	for ( i = 0; i < level._players.size; i++ )
	{
		player = level._players[i];
		if ( isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" )
		{
			hintText = getObjectiveHintText( player.pers["team"] );
			player thread maps\mp\gametypes\_hud_message::hintMessage( hintText );
		}
	}
}


getRespawnDelay()
{
	self clearLowerMessage( "hq_respawn" );

	if ( !isDefined( level._radioObject ) )
		return undefined;
	
	hqOwningTeam = level._radioObject maps\mp\gametypes\_gameobjects::getOwnerTeam();
	if ( self.pers["team"] == hqOwningTeam )
	{
		if ( !isDefined( level._hqDestroyTime ) )
			return undefined;
		
		if (!level._spawnDelay )
			return undefined;

		timeRemaining = (level._hqDestroyTime - gettime()) / 1000;
		timeRemaining += level._extraDelay + 1.0; // extra second for slowed spawning

		if ( level._spawnDelay >= level._hqAutoDestroyTime )
			setLowerMessage( "hq_respawn", &"MP_WAITING_FOR_HQ", undefined, 10 );
		
		if ( !isAlive( self ) )
			self.forceSpawnNearTeammates = true;
		
		if ( level._delayPlayer )
		{
			return min( level._spawnDelay, timeRemaining );
		}
		else
		{
			return (int(timeRemaining) % level._spawnDelay);
		}
	}
}


onStartGameType()
{
	setObjectiveText( "allies", &"OBJECTIVES_KOTH" );
	setObjectiveText( "axis", &"OBJECTIVES_KOTH" );
	
	if ( level._splitscreen )
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_KOTH" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_KOTH" );
	}
	else
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_KOTH_SCORE" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_KOTH_SCORE" );
	}
	
	level._objectiveHintPrepareHQ = &"MP_CONTROL_HQ";
	level._objectiveHintCaptureHQ = &"MP_CAPTURE_HQ";
	level._objectiveHintDestroyHQ = &"MP_DESTROY_HQ";
	level._objectiveHintDefendHQ = &"MP_DEFEND_HQ";
	precacheString( level._objectiveHintPrepareHQ );
	precacheString( level._objectiveHintCaptureHQ );
	precacheString( level._objectiveHintDestroyHQ );
	precacheString( level._objectiveHintDefendHQ );
	
	if ( level._kothmode )
		level._objectiveHintDestroyHQ = level._objectiveHintCaptureHQ;
	
	if ( level._hqSpawnTime )
		updateObjectiveHintMessages( level._objectiveHintPrepareHQ, level._objectiveHintPrepareHQ );
	else
		updateObjectiveHintMessages( level._objectiveHintCaptureHQ, level._objectiveHintCaptureHQ );
	
	setClientNameMode("auto_change");
	
	// TODO: HQ spawnpoints
	level._spawnMins = ( 0, 0, 0 );
	level._spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
	
	level._mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level._spawnMins, level._spawnMaxs );
	setMapCenter( level._mapCenter );
	
	level._spawn_all = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn" );
	if ( !level._spawn_all.size )
	{
		println("^1No mp_tdm_spawn spawnpoints in level!");
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}
	
	
	allowed[0] = "hq";
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	thread SetupRadios();

	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 10 );
	maps\mp\gametypes\_rank::registerScoreInfo( "defend", 10 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assault", 10 );
	maps\mp\gametypes\_rank::registerScoreInfo( "capture", 250 );
	
	thread HQMainLoop();
}


HQMainLoop()
{
	level endon("game_ended");
	
	level._hqRevealTime = -100000;
	
	hqSpawningInStr = &"MP_HQ_AVAILABLE_IN";
	if ( level._kothmode )
	{
		hqDestroyedInFriendlyStr = &"MP_HQ_DESPAWN_IN";
		hqDestroyedInEnemyStr = &"MP_HQ_DESPAWN_IN";
	}
	else
	{

		if ( !level._splitscreen )
		{
			hqDestroyedInFriendlyStr = &"MP_HQ_REINFORCEMENTS_IN";
			hqDestroyedInEnemyStr = &"MP_HQ_DESPAWN_IN";
		}
		else
		{	
			hqDestroyedInFriendlyStr = &"MP_HQ_REINFORCEMENTS_IN_SPLITSCREEN";
			hqDestroyedInEnemyStr = &"MP_HQ_DESPAWN_IN";
		}
	}
	
	precacheString( hqSpawningInStr );
	precacheString( hqDestroyedInFriendlyStr );
	precacheString( hqDestroyedInEnemyStr );
	precacheString( &"MP_CAPTURING_HQ" );
	precacheString( &"MP_DESTROYING_HQ" );
	
	gameFlagWait( "prematch_done" );
	
	wait 5;
	
	timerDisplay = [];
	timerDisplay["allies"] = createServerTimer( "objective", 1.4, "allies" );
	timerDisplay["allies"] setPoint( "TOPRIGHT", "TOPRIGHT", 0, 0 );
	timerDisplay["allies"].label = hqSpawningInStr;
	timerDisplay["allies"].alpha = 0;
	timerDisplay["allies"].archived = false;
	timerDisplay["allies"].hideWhenInMenu = true;
	
	timerDisplay["axis"  ] = createServerTimer( "objective", 1.4, "axis" );
	timerDisplay["axis"  ] setPoint( "TOPRIGHT", "TOPRIGHT", 0, 0 );
	timerDisplay["axis"  ].label = hqSpawningInStr;
	timerDisplay["axis"  ].alpha = 0;
	timerDisplay["axis"  ].archived = false;
	timerDisplay["axis"  ].hideWhenInMenu = true;
	
	level._timerDisplay = timerDisplay;
	
	thread hideTimerDisplayOnGameEnd( timerDisplay["allies"] );
	thread hideTimerDisplayOnGameEnd( timerDisplay["axis"  ] );
	
	locationObjID = maps\mp\gametypes\_gameobjects::getNextObjID();
	
	objective_add( locationObjID, "invisible", (0,0,0) );
	
	while( 1 )
	{
		radio = PickRadioToSpawn();
		radio makeRadioActive();
		
		//iPrintLn( &"MP_HQ_REVEALED" );
		playSoundOnPlayers( "mp_suitcase_pickup" );
		leaderDialog( "hq_located" );
		
		radioObject = radio.gameobject;
		level._radioObject = radioObject;
		
		radioObject maps\mp\gametypes\_gameobjects::setModelVisibility( true );
		
		level._hqRevealTime = gettime();
		
		if ( level._hqSpawnTime )
		{
			nextObjPoint = maps\mp\gametypes\_objpoints::createTeamObjpoint( "objpoint_next_hq", radio.origin + level._iconoffset, "all", "waypoint_targetneutral" );
			nextObjPoint setWayPoint( true, true );
			objective_position( locationObjID, radio.trigorigin );
			objective_icon( locationObjID, "waypoint_targetneutral" );
			objective_state( locationObjID, "active" );

			updateObjectiveHintMessages( level._objectiveHintPrepareHQ, level._objectiveHintPrepareHQ );
			
			timerDisplay["allies"].label = hqSpawningInStr;
			timerDisplay["allies"] setTimer( level._hqSpawnTime );
			//if ( !level.splitscreen )
			timerDisplay["allies"].alpha = 1;
			
			timerDisplay["axis"  ].label = hqSpawningInStr;
			timerDisplay["axis"  ] setTimer( level._hqSpawnTime );
			//if ( !level.splitscreen )
			timerDisplay["axis"  ].alpha = 1;

			wait level._hqSpawnTime;

			maps\mp\gametypes\_objpoints::deleteObjPoint( nextObjPoint );
			objective_state( locationObjID, "invisible" );
			leaderDialog( "hq_online" );
		}

		timerDisplay["allies"].alpha = 0;
		timerDisplay["axis"  ].alpha = 0;
		
		waittillframeend;
		
		leaderDialog( "obj_capture" );
		updateObjectiveHintMessages( level._objectiveHintCaptureHQ, level._objectiveHintCaptureHQ );
		playSoundOnPlayers( "mp_killstreak_radar" );

		radioObject maps\mp\gametypes\_gameobjects::allowUse( "any" );
		radioObject maps\mp\gametypes\_gameobjects::setUseTime( level._captureTime );
		radioObject maps\mp\gametypes\_gameobjects::setUseText( &"MP_CAPTURING_HQ" );
		
		radioObject maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_captureneutral" );
		radioObject maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_captureneutral" );
		radioObject maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		radioObject maps\mp\gametypes\_gameobjects::setModelVisibility( true );
		
		radioObject.onUse = ::onRadioCapture;
		radioObject.onBeginUse = ::onBeginUse;
		radioObject.onEndUse = ::onEndUse;
		
		level waittill( "hq_captured" );
		
		ownerTeam = radioObject maps\mp\gametypes\_gameobjects::getOwnerTeam();
		otherTeam = getOtherTeam( ownerTeam );
		
		if ( level._hqAutoDestroyTime )
		{
			thread DestroyHQAfterTime( level._hqAutoDestroyTime );
			timerDisplay[ownerTeam] setTimer( level._hqAutoDestroyTime + level._extraDelay );
			timerDisplay[otherTeam] setTimer( level._hqAutoDestroyTime );
		}
		else
		{
			level._hqDestroyedByTimer = false;
		}
		
		/#
		thread scriptDestroyHQ();
		#/
		
		while( 1 )
		{
			ownerTeam = radioObject maps\mp\gametypes\_gameobjects::getOwnerTeam();
			otherTeam = getOtherTeam( ownerTeam );
	
			if ( ownerTeam == "allies" )
			{
				updateObjectiveHintMessages( level._objectiveHintDefendHQ, level._objectiveHintDestroyHQ );
			}
			else
			{
				updateObjectiveHintMessages( level._objectiveHintDestroyHQ, level._objectiveHintDefendHQ );
			}
	
			radioObject maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
			radioObject maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_defend" );
			radioObject maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" );
			radioObject maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_capture" );
			radioObject maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_capture" );

			if ( !level._kothMode )
				radioObject maps\mp\gametypes\_gameobjects::setUseText( &"MP_DESTROYING_HQ" );
			
			radioObject.onUse = ::onRadioDestroy;
			
			if ( level._hqAutoDestroyTime )
			{
				timerDisplay[ownerTeam].label = hqDestroyedInFriendlyStr;
				//if ( !level.splitscreen )
					timerDisplay[ownerTeam].alpha = 1;
					
				timerDisplay[otherTeam].label = hqDestroyedInEnemyStr;
				//if ( !level.splitscreen )
					timerDisplay[otherTeam].alpha = 1;
			}
			
			level waittill( "hq_destroyed" );
			
			timerDisplay[otherTeam].alpha = 0;
			
			if ( !level._kothmode || level._hqDestroyedByTimer )
				break;
			
			thread forceSpawnTeam( ownerTeam );
			
			radioObject maps\mp\gametypes\_gameobjects::setOwnerTeam( getOtherTeam( ownerTeam ) );
		}
		
		level notify("hq_reset");
		
		radioObject maps\mp\gametypes\_gameobjects::allowUse( "none" );
		radioObject maps\mp\gametypes\_gameobjects::setOwnerTeam( "neutral" );
		radioObject maps\mp\gametypes\_gameobjects::setModelVisibility( false );
		
		radio makeRadioInactive();
		
		level._radioObject = undefined;
		
		thread forceSpawnTeam( ownerTeam, level._extraDelay );

		wait ( level._extraDelay );
		
		wait ( max ( 1.0, 6.0 - level._extraDelay ) );
	}
}


hideTimerDisplayOnGameEnd( timerDisplay )
{
	level waittill("game_ended");
	timerDisplay.alpha = 0;
}

forceSpawnTeam( team, extraDelay )
{
	if ( extraDelay )
	{
		foreach ( player in level._players )
		{
			if ( isAlive( player ) )
				continue;
				
			if ( player.pers["team"] == team )
				player setLowerMessage( "hq_respawn", game["strings"]["waiting_to_spawn"], extraDelay );
		}

		wait ( extraDelay );
	}
	
	level._timerDisplay[team].alpha = 0;
	
	foreach ( player in level._players )
	{
		if ( player.pers["team"] == team )
		{
			player clearLowerMessage( "hq_respawn" );
			if ( !isAlive( player ) )
				player.forceSpawnNearTeammates = true;
			player notify( "force_spawn" );
		}
	}
}


onBeginUse( player )
{
	ownerTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();

	if ( ownerTeam == "neutral" )
	{
		self.objPoints[player.pers["team"]] thread maps\mp\gametypes\_objpoints::startFlashing();
	}
	else
	{
		self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::startFlashing();
		self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::startFlashing();
	}
}


onEndUse( team, player, success )
{
	self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::stopFlashing();
	self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::stopFlashing();
}


onRadioCapture( player )
{
	team = player.pers["team"];

	player thread [[level._onXPEvent]]( "capture" );
	maps\mp\gametypes\_gamescore::givePlayerScore( "capture", player );
	player incPlayerStat( "hqscaptured", 1 );
	player thread maps\mp\_matchdata::logGameEvent( "capture", player.origin );

	oldTeam = maps\mp\gametypes\_gameobjects::getOwnerTeam();
	self maps\mp\gametypes\_gameobjects::setOwnerTeam( team );
	if ( !level._kothMode )
		self maps\mp\gametypes\_gameobjects::setUseTime( level._destroyTime );
	
	otherTeam = "axis";
	if ( team == "axis" )
		otherTeam = "allies";
	
	teamPlayerCardSplash( "callout_capturedhq", player );

	leaderDialog( "hq_secured", team );
	leaderDialog( "hq_enemy_captured", otherTeam );
	thread playSoundOnPlayers( "mp_war_objective_taken", team );
	thread playSoundOnPlayers( "mp_war_objective_lost", otherTeam );
	
	level thread awardHQPoints( team );
	
	player notify( "objective", "captured" );
	level notify( "hq_captured" );
}

/#
scriptDestroyHQ()
{
	level endon("hq_destroyed");
	while(1)
	{
		if ( getdvar("scr_destroyhq") != "1" )
		{
			wait .1;
			continue;
		}
		setdvar("scr_destroyhq","0");
		
		hqOwningTeam = level._radioObject maps\mp\gametypes\_gameobjects::getOwnerTeam();
		for ( i = 0; i < level._players.size; i++ )
		{
			if ( level._players[i].team != hqOwningTeam )
			{
				onRadioDestroy( level._players[i] );
				break;
			}
		}
	}
}
#/

onRadioDestroy( player )
{
	team = player.pers["team"];
	otherTeam = "axis";
	if ( team == "axis" )
		otherTeam = "allies";

	//player logString( "radio destroyed" );
	player thread [[level._onXPEvent]]( "capture" );
	maps\mp\gametypes\_gamescore::givePlayerScore( "capture", player );	
	player incPlayerStat( "hqsdestroyed", 1 );
	player thread maps\mp\_matchdata::logGameEvent( "destroy", player.origin );
		
	if ( level._kothmode )
	{
		teamPlayerCardSplash( "callout_capturedhq", player );
		leaderDialog( "hq_secured", team );
		leaderDialog( "hq_enemy_captured", otherTeam );
	}
	else
	{
		teamPlayerCardSplash( "callout_destroyedhq", player );
		leaderDialog( "hq_secured", team );
		leaderDialog( "hq_enemy_destroyed", otherTeam );
	}
	thread playSoundOnPlayers( "mp_war_objective_taken", team );
	thread playSoundOnPlayers( "mp_war_objective_lost", otherTeam );
	
	level notify( "hq_destroyed" );
	
	if ( level._kothmode )
		level thread awardHQPoints( team );
}


DestroyHQAfterTime( time )
{
	level endon( "game_ended" );
	level endon( "hq_reset" );
	
	level._hqDestroyTime = gettime() + time * 1000;
	level._hqDestroyedByTimer = false;
	
	wait time;
	
	level._hqDestroyedByTimer = true;

	leaderDialog( "hq_offline" );
	
	level notify( "hq_destroyed" );
}


awardHQPoints( team )
{
	level endon( "game_ended" );
	level endon( "hq_destroyed" );
	
	level notify("awardHQPointsRunning");
	level endon("awardHQPointsRunning");

	steps = 12;
	baseLine = 5;
	delta = 5;

	if ( level._proMode )
		seconds = int(level._hqAutoDestroyTime / steps);
	else
		seconds = 5;
	
	curStep = 0;
	while ( !level._gameEnded )
	{
		if ( level._proMode && level._hqAutoDestroyTime )
			maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( team, int(5*(curStep+1)) );
		else
			maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( team, seconds );

		for ( index = 0; index < level._players.size; index++ )
		{
			player = level._players[index];
			
			if ( player.pers["team"] == team )
			{
				if ( level._proMode )
				{
					if ( level._hqAutoDestroyTime )
						player thread maps\mp\gametypes\_rank::giveRankXP( "defend", int(baseLine+(delta*curStep)) );
					else
						player thread maps\mp\gametypes\_rank::giveRankXP( "defend", int(baseLine+delta) );
				}
				else
				{
					player thread maps\mp\gametypes\_rank::giveRankXP( "defend" );
				}
				
				if ( isAlive( player ) )
					maps\mp\gametypes\_gamescore::givePlayerScore( "defend", player );	
			}
		}
		
		curStep++;
		wait seconds;
		maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
	}
}


getSpawnPoint()
{
	spawnpoint = undefined;
	
	if ( isdefined( level._radioObject ) )
	{
		hqOwningTeam = level._radioObject maps\mp\gametypes\_gameobjects::getOwnerTeam();
		if ( self.pers["team"] == hqOwningTeam )
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level._spawn_all, level._radioObject.nearSpawns );
		//else if ( level.spawnDelay >= level.hqAutoDestroyTime && gettime() > level.hqRevealTime + 10000 )
		//	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level.spawn_all, level.radioObject.outerSpawns );
		else
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level._spawn_all, level._radioObject.outerSpawns );
	}
	
	if ( !isDefined( spawnpoint ) )
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level._spawn_all );
	
	assert( isDefined(spawnpoint) );
	
	return spawnpoint;
}


onSpawnPlayer()
{
	self clearLowerMessage( "hq_respawn" );
	self.forceSpawnNearTeammates = undefined;
}


SetupRadios()
{
	maperrors = [];

	radios = getentarray( "hq_hardpoint", "targetname" );
	
	if ( radios.size < 2 )
	{
		maperrors[maperrors.size] = "There are not at least 2 entities with targetname \"radio\"";
	}
	
	trigs = getentarray("radiotrigger", "targetname");
	for ( i = 0; i < radios.size; i++ )
	{
		errored = false;
		
		radio = radios[i];
		radio.trig = undefined;
		for ( j = 0; j < trigs.size; j++ )
		{
			if ( radio istouching( trigs[j] ) )
			{
				if ( isdefined( radio.trig ) )
				{
					maperrors[maperrors.size] = "Radio at " + radio.origin + " is touching more than one \"radiotrigger\" trigger";
					errored = true;
					break;
				}
				radio.trig = trigs[j];
				break;
			}
		}
		
		if ( !isdefined( radio.trig ) )
		{
			if ( !errored )
			{
				maperrors[maperrors.size] = "Radio at " + radio.origin + " is not inside any \"radiotrigger\" trigger";
				continue;
			}
			
			// possible fallback (has been tested)
			//radio.trig = spawn( "trigger_radius", radio.origin, 0, 128, 128 );
			//errored = false;
		}
		
		assert( !errored );
		
		radio.trigorigin = radio.trig.origin;
		
		visuals = [];
		visuals[0] = radio;
		
		otherVisuals = getEntArray( radio.target, "targetname" );
		for ( j = 0; j < otherVisuals.size; j++ )
		{
			visuals[visuals.size] = otherVisuals[j];
		}

		radio.visuals = visuals;
		radio maps\mp\gametypes\_gameobjects::setModelVisibility( false );
		/*
		radio.gameObject = maps\mp\gametypes\_gameobjects::createUseObject( "neutral", radio.trig, visuals, (radio.origin - radio.trigorigin) + level.iconoffset );
		radio.gameObject maps\mp\gametypes\_gameobjects::disableObject();
		radio.gameObject maps\mp\gametypes\_gameobjects::setModelVisibility( false );
		radio.trig.useObj = radio.gameObject;
		
		radio setUpNearbySpawns();
		*/
	}
	
	if (maperrors.size > 0)
	{
		println("^1------------ Map Errors ------------");
		for(i = 0; i < maperrors.size; i++)
			println(maperrors[i]);
		println("^1------------------------------------");
		
		error("Map errors. See above");
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		
		return;
	}
	
	level._radios = radios;
	
	level._prevradio = undefined;
	level._prevradio2 = undefined;
	
	/#
	thread kothDebug();
	#/
	
	return true;
}


makeRadioActive()
{
	self.gameObject = maps\mp\gametypes\_gameobjects::createUseObject( "neutral", self.trig, self.visuals, (self.origin - self.trigorigin) + level._iconoffset );
	self.gameObject maps\mp\gametypes\_gameobjects::setModelVisibility( false );
	self.trig.useObj = self.gameObject;
	
	self setUpNearbySpawns();
}


makeRadioInactive()
{
	self.gameObject maps\mp\gametypes\_gameobjects::deleteUseObject();
	
	self.gameObject = undefined;
}


setUpNearbySpawns()
{
	spawns = level._spawn_all;
	
	for ( i = 0; i < spawns.size; i++ )
	{
		spawns[i].distsq = distanceSquared( spawns[i].origin, self.origin );
	}
	
	// sort by distsq
	for ( i = 1; i < spawns.size; i++ )
	{
		thespawn = spawns[i];
		for ( j = i - 1; j >= 0 && thespawn.distsq < spawns[j].distsq; j-- )
			spawns[j + 1] = spawns[j];
		spawns[j + 1] = thespawn;
	}
	
	first = [];
	outer = [];
	
	thirdSize = spawns.size / 3;
	for ( i = 0; i < spawns.size; i++ )
	{
		if ( i <= thirdSize || spawns[i].distsq <= 700*700 )
			first[ first.size ] = spawns[i];
		
		if ( i > thirdSize || spawns[i].distsq > 1000*1000 )
		{
			if ( outer.size < 10 || spawns[i].distsq < 1500*1500 ) // don't include too many far-away spawnpoints
				outer[ outer.size ] = spawns[i];
		}
	}
	
	self.gameObject.nearSpawns = first;
	self.gameObject.outerSpawns = outer;
}


PickRadioToSpawn()
{
	validAllies = [];
	validAxis = [];
	
	foreach ( player in level._players )
	{
		if ( player.team == "spectator" )
			continue;
			
		if ( !isAlive( player ) )
			continue;
			
		player.dist = 0;
		if ( player.team == "allies" )
			validAllies[validAllies.size] = player;
		else
			validAxis[validAxis.size] = player;
	}

	if ( !validAllies.size || !validAxis.size )
	{
		radio = level._radios[ randomint( level._radios.size) ];
		while ( isDefined( level._prevradio ) && radio == level._prevradio ) // so lazy
			radio = level._radios[ randomint( level._radios.size) ];
		
		level._prevradio2 = level._prevradio;
		level._prevradio = radio;
		
		return radio;
	}
	
	for ( i = 0; i < validAllies.size; i++ )
	{
		for ( j = i + 1; j < validAllies.size; j++ )
		{
			dist = distanceSquared( validAllies[i].origin, validAllies[j].origin );
			
			validAllies[i].dist += dist;
			validAllies[j].dist += dist;
		}
	}

	for ( i = 0; i < validAxis.size; i++ )
	{
		for ( j = i + 1; j < validAxis.size; j++ )
		{
			dist = distanceSquared( validAxis[i].origin, validAxis[j].origin );
			
			validAxis[i].dist += dist;
			validAxis[j].dist += dist;
		}
	}

	bestPlayer = validAllies[0];
	foreach ( player in validAllies )
	{
		if ( player.dist < bestPlayer.dist )
			bestPlayer = player;
	}
	avgpos["allies"] = bestPlayer.origin;

	bestPlayer = validAxis[0];
	foreach ( player in validAxis )
	{
		if ( player.dist < bestPlayer.dist )
			bestPlayer = player;
	}
	avgpos["axis"] = validAxis[0].origin;
	
	bestradio = undefined;
	lowestcost = undefined;
	for ( i = 0; i < level._radios.size; i++ )
	{
		radio = level._radios[i];
		
		// (purposefully using distance instead of distanceSquared)
		cost = abs( distance( radio.origin, avgpos["allies"] ) - distance( radio.origin, avgpos["axis"] ) );
		
		if ( isdefined( level._prevradio ) && radio == level._prevradio )
		{
			continue;
		}
		if ( isdefined( level._prevradio2 ) && radio == level._prevradio2 )
		{
			if ( level._radios.size > 2 )
				continue;
			else
				cost += 512;
		}
		
		if ( !isdefined( lowestcost ) || cost < lowestcost )
		{
			lowestcost = cost;
			bestradio = radio;
		}
	}
	assert( isdefined( bestradio ) );
	
	level._prevradio2 = level._prevradio;
	level._prevradio = bestradio;
	
	return bestradio;
}



onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, killId )
{
	if ( !isPlayer( attacker ) || (!self.touchTriggers.size && !attacker.touchTriggers.size) || attacker.pers["team"] == self.pers["team"] )
		return;

	if ( self.touchTriggers.size )
	{
		foreach ( trigger in self.touchTriggers )
		{
			// TODO: way to check for koth specific triggers
			if ( !isDefined( trigger.useObj ) )
				continue;
			
			ownerTeam = trigger.useObj.ownerTeam;
			team = self.pers["team"];

			if ( ownerTeam == "neutral" )
				continue;

			team = self.pers["team"];
			if ( team == ownerTeam )
			{
				attacker thread [[level._onXPEvent]]( "assault" );
				maps\mp\gametypes\_gamescore::givePlayerScore( "assault", attacker );
				
				thread maps\mp\_matchdata::logKillEvent( killId, "defending" );
			}
			else
			{
				attacker thread [[level._onXPEvent]]( "defend" );
				maps\mp\gametypes\_gamescore::givePlayerScore( "defend", attacker );
				
				self thread maps\mp\_matchdata::logKillEvent( killId, "assaulting" );
			}
		}
	}	
	
	if ( attacker.touchTriggers.size )
	{
		foreach ( trigger in attacker.touchTriggers )
		{
			// TODO: way to check for koth specific triggers
			if ( !isDefined( trigger.useObj ) )
				continue;
			
			ownerTeam = trigger.useObj.ownerTeam;
			team = attacker.pers["team"];
		
			if ( ownerTeam == "neutral" )

			team = attacker.pers["team"];
			if ( team == ownerTeam )
			{
				attacker thread [[level._onXPEvent]]( "defend" );
				maps\mp\gametypes\_gamescore::givePlayerScore( "defend", attacker );

				self thread maps\mp\_matchdata::logKillEvent( killId, "assaulting" );
			}
			else
			{
				attacker thread [[level._onXPEvent]]( "assault" );
				maps\mp\gametypes\_gamescore::givePlayerScore( "assault", attacker );

				thread maps\mp\_matchdata::logKillEvent( killId, "defending" );
			}		
		}
	}
}


initGametypeAwards()
{
	maps\mp\_awards::initStatAward( "hqsdestroyed", 0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "hqscaptured", 0, maps\mp\_awards::highestWins );
}

/#
drawPoint( org, size, color )
{
	for ( i = 0; i < 10; i++ )
	{
		a1 = (i / 10) * 360;
		a2 = ((i + 1) / 10) * 360;
		
		pt1 = org + (cos(a1), sin(a1), 0) * size;
		pt2 = org + (cos(a2), sin(a2), 0) * size;
		
		line( pt1, pt2, color );
	}
}

kothDebug()
{
	while(1)
	{
		if (getdvar("scr_kothdebug") != "1") {
			wait 2;
			continue;
		}
		
		while(1)
		{
			if (getdvar("scr_kothdebug") != "1")
				break;
			if ( !isdefined( level._players ) || level._players.size <= 0 )
			{
				wait .05;
				continue;
			}
			
			// show nearest HQ and its "assault" spawnpoints
			
			bestdistsq = 1000000000;
			bestradio = level._radios[0];
			foreach ( radio in level._radios )
			{
				distsq = distanceSquared( radio.origin, level._players[0].origin );
				if ( distsq < bestdistsq )
				{
					bestdistsq = distsq;
					bestradio = radio;
				}
			}
			
			foreach ( radio in level._radios )
			{
				if ( radio != bestradio )
					drawPoint( radio.origin, 50, (.5,.5,.5) );
			}
			
			radio = bestradio;
			drawPoint( radio.origin, 100, (1,1,1) );
			
			foreach ( spawnpoint in radio.gameObject.outerSpawns )
			{
				line( radio.origin, spawnpoint.origin, (1,.5,.5) );
				drawPoint( spawnpoint.origin, 20, (1,.5,.5) );
			}
			foreach ( spawnpoint in radio.gameObject.nearSpawns )
			{
				line( radio.origin + (0,0,10), spawnpoint.origin + (0,0,10), (.5,1,.5) );
				drawPoint( spawnpoint.origin, 30, (.5,1,.5) );
			}
			
			wait .05;
		}
	}
}
#/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
/*
	One Flag CTF
*/

/*QUAKED mp_ctf_spawn_axis (0.75 0.0 0.5) (-16 -16 0) (16 16 72)
Axis players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_ctf_spawn_allies (0.0 0.75 0.5) (-16 -16 0) (16 16 72)
Allied players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_ctf_spawn_axis_start (1.0 0.0 0.5) (-16 -16 0) (16 16 72)
Axis players spawn away from enemies and near their team at one of these positions at the start of a round.*/

/*QUAKED mp_ctf_spawn_allies_start (0.0 1.0 0.5) (-16 -16 0) (16 16 72)
Allied players spawn away from enemies and near their team at one of these positions at the start of a round.*/

main()
{
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	registerTimeLimitDvar( level._gameType, 3, 0, 1440 );
	registerScoreLimitDvar( level._gameType, 1, 0, 10000 );
	registerRoundLimitDvar( level._gameType, 0, 0, 30 );
	registerWinLimitDvar( level._gameType, 4, 0, 10 );
	registerRoundSwitchDvar( level._gameType, 3, 0, 30 );
	registerNumLivesDvar( level._gameType, 0, 0, 10 );
	registerHalfTimeDvar( level._gameType, 1, 0, 1 );

	setOverTimeLimitDvar( 4 );
	
	level._teamBased = true;
	level._onPrecacheGameType = ::onPrecacheGameType;
	level._onStartGameType = ::onStartGameType;
	level._getSpawnPoint = ::getSpawnPoint;
	level._onPlayerKilled = ::onPlayerKilled;
	level._initGametypeAwards = ::initGametypeAwards;
	level._onTimeLimit = ::onTimeLimit;
	level._onSpawnPlayer = ::onSpawnPlayer;

	level._flagReturnTime = getIntProperty( "scr_ctf_returntime", 30 );

	game["dialog"]["gametype"] = "captureflag";

	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level._gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";

	game["dialog"]["offense_obj"] = "capture_obj";
	game["dialog"]["defense_obj"] = "capture_obj";
}

onPrecacheGameType()
{
	precacheString(&"MP_FLAG_TAKEN_BY");
	precacheString(&"MP_ENEMY_FLAG_TAKEN_BY");
	precacheString(&"MP_FLAG_CAPTURED_BY");
	precacheString(&"MP_ENEMY_FLAG_CAPTURED_BY");
	precacheString(&"MP_FLAG_RETURNED");
	precacheString(&"MP_ENEMY_FLAG_RETURNED");
	precacheString(&"MP_YOUR_FLAG_RETURNING_IN");
	precacheString(&"MP_ENEMY_FLAG_RETURNING_IN");
	precacheString(&"MP_ENEMY_FLAG_DROPPED_BY");
	precacheString(&"MP_DOM_NEUTRAL_FLAG_CAPTURED");
	precacheString(&"MP_GRABBING_FLAG");
	precacheString(&"MP_RETURNING_FLAG");
}


onSpawnPlayer()
{
	if( ( inOvertime() ) && !isDefined( self.otSpawned ) )
		self thread printOTHint();
}


printOTHint()
{
	self endon ( "disconnect" );
	// give the "Overtime!" message time to show
	wait ( 0.25 );

	self.otSpawned = true;
	hintMessage = getObjectiveHintText( self.team );
	self thread maps\mp\gametypes\_hud_message::hintMessage( hintMessage );
}


onStartGameType()
{
	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	if ( !isdefined( game["original_defenders"] ) )
		game["original_defenders"] = game["defenders"];

	if ( game["switchedsides"] )
	{
		oldAttackers = game["attackers"];
		oldDefenders = game["defenders"];
		game["attackers"] = oldDefenders;
		game["defenders"] = oldAttackers;
	}

	setClientNameMode("auto_change");
	
	if ( level._splitscreen )
	{
		if ( inOvertime() )
		{
			setObjectiveScoreText( game["attackers"], &"OBJECTIVES_GRAB_FLAG" );
			setObjectiveScoreText( game["defenders"], &"OBJECTIVES_GRAB_FLAG" );
		}
		else
		{
			setObjectiveScoreText( game["attackers"], &"OBJECTIVES_ONE_FLAG_ATTACKER" );
			setObjectiveScoreText( game["defenders"], &"OBJECTIVES_ONE_FLAG_DEFENDER" );
		}
	}
	else
	{
		if ( inOvertime() )
		{
			setObjectiveScoreText( game["attackers"], &"OBJECTIVES_GRAB_FLAG_SCORE" );
			setObjectiveScoreText( game["defenders"], &"OBJECTIVES_GRAB_FLAG_SCORE" );
		}
		else
		{
			setObjectiveScoreText( game["attackers"], &"OBJECTIVES_ONE_FLAG_ATTACKER_SCORE" );
			setObjectiveScoreText( game["defenders"], &"OBJECTIVES_ONE_FLAG_DEFENDER_SCORE" );
		}
	}
	
	if ( inOvertime() )
	{
		setObjectiveText( game["attackers"], &"OBJECTIVES_OVERTIME_CTF" );
		setObjectiveText( game["defenders"], &"OBJECTIVES_OVERTIME_CTF" );
		setObjectiveHintText( game["attackers"], &"OBJECTIVES_GRAB_FLAG_HINT" );
		setObjectiveHintText( game["defenders"], &"OBJECTIVES_GRAB_FLAG_HINT" );
	}
	else
	{
		setObjectiveText( game["attackers"], &"OBJECTIVES_CTF" );
		setObjectiveText( game["defenders"], &"OBJECTIVES_CTF" );
		setObjectiveHintText( game["attackers"], &"OBJECTIVES_ONE_FLAG_ATTACKER_HINT" );
		setObjectiveHintText( game["defenders"], &"OBJECTIVES_ONE_FLAG_DEFENDER_HINT" );
	}

	level._spawnMins = ( 0, 0, 0 );
	level._spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_ctf_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_ctf_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_ctf_spawn_allies" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_ctf_spawn_axis" );
	
	level._mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level._spawnMins, level._spawnMaxs );
	setMapCenter( level._mapCenter );
	
	thread maps\mp\gametypes\_dev::init();
	
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 20 );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "pickup", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "return", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "capture", 250 );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "kill_carrier", 50 );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "defend", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "defend_assist", 100 );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "assault", 200 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assault_assist", 40 );
	
	allowed[0] = "ctf";
	maps\mp\gametypes\_gameobjects::main(allowed);
		
	thread ctf();
}


getSpawnPoint()
{
	if ( self.team == "axis" )
	{
		spawnTeam = game["attackers"];
	}
	else
	{
		spawnTeam = game["defenders"];
	}

//	if ( game["switchedsides"] )
//		spawnTeam = getOtherTeam( spawnteam );
	
	if ( level._inGracePeriod )
	{
		spawnPoints = getentarray("mp_ctf_spawn_" + spawnteam + "_start", "classname");		
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
	}
	else
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnteam );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
	}
	
	return spawnPoint;
}


ctf()
{
	level._flagModel["allies"] = maps\mp\gametypes\_teams::getTeamFlagModel( "allies" );
	level._icon2D["allies"] = maps\mp\gametypes\_teams::getTeamFlagIcon( "allies" );
	level._carryFlag["allies"] = maps\mp\gametypes\_teams::getTeamFlagCarryModel( "allies" );

	precacheModel( level._flagModel["allies"] );
	precacheModel( level._carryFlag["allies"] );

	level._flagModel["axis"] = maps\mp\gametypes\_teams::getTeamFlagModel( "axis" );
	level._icon2D["axis"] = maps\mp\gametypes\_teams::getTeamFlagIcon( "axis" );
	level._carryFlag["axis"] = maps\mp\gametypes\_teams::getTeamFlagCarryModel( "axis" );

	precacheModel( level._flagModel["axis"] );
	precacheModel( level._carryFlag["axis"] );
	
	level._iconEscort3D = "waypoint_escort";
	level._iconEscort2D = "waypoint_escort";
	precacheShader( level._iconEscort3D );
	precacheShader( level._iconEscort2D );
	//level.iconEscort2D = level.iconEscort3D; // flags with words on compass

	level._iconKill3D = "waypoint_kill";
	level._iconKill2D = "waypoint_kill";
	precacheShader( level._iconKill3D );
	precacheShader( level._iconKill2D );
	//level.iconKill2D = level.iconKill3D; // flags with words on compass

	level._iconCaptureFlag3D = "waypoint_capture_flag";
	level._iconCaptureFlag2D = "waypoint_capture_flag";
	precacheShader( level._iconCaptureFlag3D );
	precacheShader( level._iconCaptureFlag2D );
	//level.iconCaptureFlag2D = level.iconCaptureFlag3D; // flags with words on compass

	level._iconDefendFlag3D = "waypoint_defend_flag";
	level._iconDefendFlag2D = "waypoint_defend_flag";
	precacheShader( level._iconDefendFlag3D );
	precacheShader( level._iconDefendFlag2D );
	//level.iconDefendFlag2D = level.iconDefendFlag3D; // flags with words on compass

	level._iconReturnFlag3D = "waypoint_return_flag";
	level._iconReturnFlag2D = "waypoint_return_flag";
	precacheShader( level._iconReturnFlag3D );
	precacheShader( level._iconReturnFlag2D );
	//level.iconReturnFlag2D = level.iconReturnFlag3D; // flags with words on compass

	level._iconWaitForFlag3D = "waypoint_waitfor_flag";
	level._iconWaitForFlag2D = "waypoint_waitfor_flag";
	precacheShader( level._iconWaitForFlag3D );
	precacheShader( level._iconWaitForFlag2D );
	//level.iconWaitForFlag2D = level.iconWaitForFlag3D; // flags with words on compass
	
	precacheShader( level._icon2D["axis"] );
	precacheShader( level._icon2D["allies"] );
	
	precacheShader( "waypoint_flag_friendly" );
	precacheShader( "waypoint_flag_enemy" );

	precacheString( &"OBJECTIVES_FLAG_HOME" );
	precacheString( &"OBJECTIVES_FLAG_NAME" );
	precacheString( &"OBJECTIVES_FLAG_AWAY" );
	
	level._teamFlags[game["defenders"]] = createTeamFlag( game["defenders"], "allies" );
	level._teamFlags[game["attackers"]] = createTeamFlag( game["attackers"], level._otherTeam["allies"] );

	level._capZones[game["defenders"]] = createCapZone( game["defenders"], "allies" );
	level._capZones[game["attackers"]] = createCapZone( game["attackers"], level._otherTeam["allies"] );
	
	if ( level._splitScreen )
		hudElemAlpha = 0;
	else
		hudElemAlpha = 0.85;
	
	level._friendlyFlagStatusIcon["allies"] = createServerIcon( "waypoint_flag_friendly", 32, 32, "allies" );
	level._friendlyFlagStatusIcon["allies"] setPoint( "TOP LEFT", "TOP LEFT", 132, 0 );
	level._friendlyFlagStatusIcon["allies"].alpha = hudElemAlpha;
	level._friendlyFlagStatusIcon["allies"].hideWhenInMenu = true;

	level._friendlyFlagStatusText["allies"] = createServerFontString( "small", 1.6, "allies" );	
	level._friendlyFlagStatusText["allies"] setParent( level._friendlyFlagStatusIcon["allies"] );
	level._friendlyFlagStatusText["allies"] setPoint( "LEFT", "RIGHT", 4 );
	level._friendlyFlagStatusText["allies"] setText( &"OBJECTIVES_FLAG_HOME" );
	level._friendlyFlagStatusText["allies"].alpha = hudElemAlpha;
	level._friendlyFlagStatusText["allies"].color = (1,1,1);
	level._friendlyFlagStatusText["allies"].glowAlpha = 1;
	level._friendlyFlagStatusText["allies"].hideWhenInMenu = true;

	level._enemyFlagStatusIcon["allies"] = createServerIcon( "waypoint_flag_enemy", 24, 24, "allies" );
	level._enemyFlagStatusIcon["allies"] setPoint( "TOP LEFT", "TOP LEFT", 132, 26 );
	level._enemyFlagStatusIcon["allies"].alpha = hudElemAlpha;
	level._enemyFlagStatusIcon["allies"].hideWhenInMenu = true;

	level._enemyFlagStatusText["allies"] = createServerFontString( "small", 1.6, "allies" );
	level._enemyFlagStatusText["allies"] setParent( level._enemyFlagStatusIcon["allies"] );
	level._enemyFlagStatusText["allies"] setPoint( "LEFT", "RIGHT", 4 );
	level._enemyFlagStatusText["allies"] setText( &"OBJECTIVES_FLAG_HOME" );	
	level._enemyFlagStatusText["allies"].alpha = hudElemAlpha;
	level._enemyFlagStatusText["allies"].color = (1,1,1);
	level._enemyFlagStatusText["allies"].glowAlpha = 1;
	level._enemyFlagStatusText["allies"].hideWhenInMenu = true;


	level._friendlyFlagStatusIcon["axis"] = createServerIcon( "waypoint_flag_friendly", 32, 32, "axis" );
	level._friendlyFlagStatusIcon["axis"] setPoint( "TOP LEFT", "TOP LEFT", 132, 0 );
	level._friendlyFlagStatusIcon["axis"].alpha = hudElemAlpha;
	level._friendlyFlagStatusIcon["axis"].hideWhenInMenu = true;

	level._friendlyFlagStatusText["axis"] = createServerFontString( "small", 1.6, "axis" );	
	level._friendlyFlagStatusText["axis"] setParent( level._friendlyFlagStatusIcon["axis"] );
	level._friendlyFlagStatusText["axis"] setPoint( "LEFT", "RIGHT", 4 );
	level._friendlyFlagStatusText["axis"] setText( &"OBJECTIVES_FLAG_HOME" );
	level._friendlyFlagStatusText["axis"].alpha = hudElemAlpha;
	level._friendlyFlagStatusText["axis"].color = (1,1,1);
	level._friendlyFlagStatusText["axis"].glowAlpha = 1;
	level._friendlyFlagStatusText["axis"].hideWhenInMenu = true;

	level._enemyFlagStatusIcon["axis"] = createServerIcon( "waypoint_flag_enemy", 24, 24, "axis" );
	level._enemyFlagStatusIcon["axis"] setPoint( "TOP LEFT", "TOP LEFT", 132, 26 );
	level._enemyFlagStatusIcon["axis"].alpha = hudElemAlpha;
	level._enemyFlagStatusIcon["axis"].hideWhenInMenu = true;

	level._enemyFlagStatusText["axis"] = createServerFontString( "small", 1.6, "axis" );
	level._enemyFlagStatusText["axis"] setParent( level._enemyFlagStatusIcon["axis"] );
	level._enemyFlagStatusText["axis"] setPoint( "LEFT", "RIGHT", 4 );
	level._enemyFlagStatusText["axis"] setText( &"OBJECTIVES_FLAG_HOME" );	
	level._enemyFlagStatusText["axis"].alpha = hudElemAlpha;
	level._enemyFlagStatusText["axis"].color = (1,1,1);
	level._enemyFlagStatusText["axis"].glowAlpha = 1;
	level._enemyFlagStatusText["axis"].hideWhenInMenu = true;
}

//sets overtime and associated variables
onTimeLimit()
{
	if ( !inOvertime() && game["teamScores"]["allies"] == game["teamScores"]["axis"] && game["switchedsides"] )
	{
		thread maps\mp\gametypes\_gamelogic::endGame( "overtime", game["strings"]["time_limit_reached"] );
	}
	else if( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
	{
		thread maps\mp\gametypes\_gamelogic::endGame( "axis", game["strings"]["time_limit_reached"] );
	}
	else if( game["teamScores"]["axis"] < game["teamScores"]["allies"] )
	{
		thread maps\mp\gametypes\_gamelogic::endGame( "allies", game["strings"]["time_limit_reached"] );
	}
	else if ( inOvertime() )
	{
		thread maps\mp\gametypes\_gamelogic::endGame( "tie", game["strings"]["time_limit_reached"] );
	}
}

spawnFxDelay( fxid, pos, forward, right, delay )
{
	wait delay;
	effect = spawnFx( fxid, pos, forward, right );
	triggerFx( effect );
}

createTeamFlag( team, entityTeam )
{
	trigger = getEnt( "ctf_zone_" + entityTeam, "targetname" );
	if ( !isDefined( trigger ) ) 
	{
		error( "No ctf_zone_" + entityTeam + " trigger found in map." );
		return;
	}
	visuals[0] = getEnt( "ctf_flag_" + entityTeam, "targetname" );
	if ( !isDefined( visuals[0] ) ) 
	{
		error( "No ctf_flag_" + entityTeam + " script_model found in map." );
		return;
	}
	
	cloneTrigger = spawn( "trigger_radius", trigger.origin, 0, 96, trigger.height );
	trigger = cloneTrigger;
	
	visuals[0] setModel( level._flagModel[team] );
	
	teamFlag = maps\mp\gametypes\_gameobjects::createCarryObject( team, trigger, visuals, (0,0,85) );
	teamFlag maps\mp\gametypes\_gameobjects::setTeamUseTime( "friendly", 0.5 );
	teamFlag maps\mp\gametypes\_gameobjects::setTeamUseTime( "enemy", 0.5 );
	teamFlag maps\mp\gametypes\_gameobjects::setTeamUseText( "enemy", &"MP_GRABBING_FLAG" );
	teamFlag maps\mp\gametypes\_gameobjects::setTeamUseText( "friendly", &"MP_RETURNING_FLAG" );
	teamFlag maps\mp\gametypes\_gameobjects::allowCarry( "enemy" );
	
	teamFlag maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
	teamFlag maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconKill2D );
	teamFlag maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconKill3D );
	teamFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconEscort2D );
	teamFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconEscort3D );

	teamFlag maps\mp\gametypes\_gameobjects::setCarryIcon( level._icon2D[team] );
	teamFlag.objIDPingFriendly = true;
	teamFlag.allowWeapons = true;
	teamFlag.onPickup = ::onPickup;
	teamFlag.onPickupFailed = ::onPickup;
	teamFlag.onDrop = ::onDrop;
	teamFlag.onReset = ::onReset;
	
	teamFlag.oldRadius = trigger.radius;

	traceStart = trigger.origin + (0,0,32);
	traceEnd = trigger.origin + (0,0,-32);
	trace = bulletTrace( traceStart, traceEnd, false, undefined );
	
	fx = maps\mp\gametypes\_teams::getTeamFlagFX( team );
	fxid = loadfx( fx );
	
	upangles = vectorToAngles( trace["normal"] );
	forward = anglesToForward( upangles );
	right = anglesToRight( upangles );
	
	thread spawnFxDelay( fxid, trace["position"], forward, right, 0.5 );
	
	return teamFlag;
}

createCapZone( team, entityTeam )
{
	trigger = getEnt( "ctf_zone_" + entityTeam, "targetname" );
	if ( !isDefined( trigger ) ) 
	{
		error("No ctf_zone_" + entityTeam + " trigger found in map.");
		return;
	}
	
	visuals = [];
	capZone = maps\mp\gametypes\_gameobjects::createUseObject( team, trigger, visuals, (0,0,85) );
	capZone maps\mp\gametypes\_gameobjects::allowUse( "friendly" );

	capZone maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	capZone maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconDefendFlag2D );
	capZone maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconDefendFlag3D );
	capZone maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconCaptureFlag2D );
	capZone maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconCaptureFlag3D );

	capZone maps\mp\gametypes\_gameobjects::setUseTime( 0 );
	capZone maps\mp\gametypes\_gameobjects::setKeyObject( level._teamFlags[ getOtherTeam( team ) ] );
	
	capZone.onUse = ::onUse;
	capZone.onCantUse = ::onCantUse;
		
	traceStart = trigger.origin + (0,0,32);
	traceEnd = trigger.origin + (0,0,-32);
	trace = bulletTrace( traceStart, traceEnd, false, undefined );
	
	fx = maps\mp\gametypes\_teams::getTeamFlagFX( team );
	fxid = loadfx( fx );
	
	upangles = vectorToAngles( trace["normal"] );
	forward = anglesToForward( upangles );
	right = anglesToRight( upangles );
	
	thread spawnFxDelay( fxid, trace["position"], forward, right, 0.5 );
	
	return capZone;
}


onBeginUse( player )
{
	team = player.pers["team"];

	if ( team == self maps\mp\gametypes\_gameobjects::getOwnerTeam() )
		self.trigger.radius = 1024;
	else
		self.trigger.radius = self.oldRadius;
}


onEndUse( player, team, success )
{
	self.trigger.radius = self.oldRadius;
}


onPickup( player )
{
	self notify ( "picked_up" );

	team = player.pers["team"];

	if ( team == "allies" )
		otherTeam = "axis";
	else
		otherTeam = "allies";
		
	if ( team == self maps\mp\gametypes\_gameobjects::getOwnerTeam() )
	{
		player thread maps\mp\gametypes\_hud_message::SplashNotify( "flagreturn", maps\mp\gametypes\_rank::getScoreInfoValue( "return" ) );
		player thread [[level._onXPEvent]]( "return" );
		self thread returnFlag();
		player incPlayerStat( "flagsreturned", 1 );
		player thread maps\mp\_matchdata::logGameEvent( "return", player.origin );

		printAndSoundOnEveryone( team, getOtherTeam( team ), &"MP_FLAG_RETURNED", &"MP_ENEMY_FLAG_RETURNED", "mp_obj_returned", "mp_obj_returned", "" );
		leaderDialog( "enemy_flag_returned", otherteam, "status" );
		leaderDialog( "flag_returned", team, "status" );	

		level._friendlyFlagStatusText[team] setText( &"OBJECTIVES_FLAG_HOME" );
		level._friendlyFlagStatusText[team].glowColor = (1,1,1);
		level._friendlyFlagStatusText[team].glowAlpha = 0;			
		level._enemyFlagStatusText[otherTeam] setText( &"OBJECTIVES_FLAG_HOME" );
		level._enemyFlagStatusText[otherTeam].glowColor = (1,1,1);
		level._enemyFlagStatusText[otherTeam].glowAlpha = 0;
	}
	else
	{
		if ( inOvertime() )
		{
			if ( isDefined( level._flagCaptured ) )
			{
				// denied splash!
				return;
			}
			
			level thread teamPlayerCardSplash( "callout_grabbedtheflag", player );

			level._teamFlags[team] maps\mp\gametypes\_gameobjects::allowUse( "none" );
			level._teamFlags[otherTeam] maps\mp\gametypes\_gameobjects::allowUse( "none" );
			level._capZones[team] maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
			level._capZones[otherTeam] maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );

			level._flagCaptured = true;

			//wait ( 1.5 );

			maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( team, 1 );
			thread maps\mp\gametypes\_gamelogic::endGame( "winner", game["strings"]["grabbed_flag"] );		
		}
		
		player attachFlag();

		level._friendlyFlagStatusText[otherTeam] setPlayerNameString( player );
		level._friendlyFlagStatusText[otherTeam].glowColor = (0.75,0.25,0.25);
		level._friendlyFlagStatusText[otherTeam].glowAlpha = 1;
		
		level._enemyFlagStatusText[team] setPlayerNameString( player );
		level._enemyFlagStatusText[team].glowColor = (0.25,0.75,0.25);
		level._enemyFlagStatusText[team].glowAlpha = 1;

		self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconKill2D );
		self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconKill3D );
		self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconEscort2D );
		self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconEscort3D );

		level._capZones[otherTeam] maps\mp\gametypes\_gameobjects::allowUse( "none" );
		level._capZones[otherTeam] maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
		//level.capZones[otherTeam] maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level.iconKill3D );
		//level.capZones[otherTeam] maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level.iconKill3D );

		if ( !level._teamFlags[ team ] maps\mp\gametypes\_gameobjects::isHome() )
		{
			level._capZones[ team ].trigger maps\mp\_entityheadIcons::setHeadIcon( player, level._iconWaitForFlag3D, (0,0,85) );	
			
			if ( isDefined( level._teamFlags[ team ].carrier ) )
				level._capZones[ otherTeam ].trigger maps\mp\_entityheadIcons::setHeadIcon( level._teamFlags[ team ].carrier, level._iconWaitForFlag3D, (0,0,85) );				
		}
		
		printAndSoundOnEveryone( team, otherteam, &"MP_ENEMY_FLAG_TAKEN_BY", &"MP_FLAG_TAKEN_BY", "mp_obj_taken", "mp_enemy_obj_taken", player );

		leaderDialog( "enemy_flag_taken", team, "status" );
		leaderDialog( "flag_taken", otherteam, "status" );

		thread teamPlayerCardSplash( "callout_flagpickup", player );
		player thread maps\mp\gametypes\_hud_message::SplashNotify( "flagpickup", maps\mp\gametypes\_rank::getScoreInfoValue( "pickup" ) );
		maps\mp\gametypes\_gamescore::givePlayerScore( "pickup", player );
		player thread [[level._onXPEvent]]( "pickup" );
		player incPlayerStat( "flagscarried", 1 );
		player thread maps\mp\_matchdata::logGameEvent( "pickup", player.origin );
	}
}


returnFlag()
{
	self maps\mp\gametypes\_gameobjects::returnHome();
}


onDrop( player )
{
	team = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	otherTeam = level._otherTeam[team];

	self maps\mp\gametypes\_gameobjects::allowCarry( "any" );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconReturnFlag2D );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconReturnFlag3D );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconCaptureFlag2D );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconCaptureFlag3D );

	level._friendlyFlagStatusText[team] setText( &"OBJECTIVES_FLAG_AWAY" );
	level._friendlyFlagStatusText[team].glowColor = (1,1,1);
	level._friendlyFlagStatusText[team].glowAlpha = 0;	
	level._enemyFlagStatusText[otherTeam] setText( &"OBJECTIVES_FLAG_AWAY" );
	level._enemyFlagStatusText[otherTeam].glowColor = (1,1,1);
	level._enemyFlagStatusText[otherTeam].glowAlpha = 0;	

	level._capZones[otherTeam].trigger maps\mp\_entityheadIcons::setHeadIcon( "none", "", (0,0,0) );

	if ( isDefined( player ) )
	{
 		if ( isDefined( player.carryFlag ) )
			player detachFlag();
		
		printAndSoundOnEveryone( otherTeam, "none", &"MP_ENEMY_FLAG_DROPPED_BY", "", "mp_war_objective_lost", "", player );		
	}
	else
	{
		playSoundOnPlayers( "mp_war_objective_lost", otherTeam );
	}

	leaderDialog( "enemy_flag_dropped", otherTeam, "status" );
	leaderDialog( "flag_dropped", team, "status" );
	
	self thread returnAfterTime();
}

returnAfterTime()
{
	self endon ( "picked_up" );
	
	wait ( level._flagReturnTime );
	
	self maps\mp\gametypes\_gameobjects::returnHome();
}


onReset()
{
	team = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	otherTeam = level._otherTeam[team];

	self maps\mp\gametypes\_gameobjects::allowCarry( "enemy" );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconKill2D );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconKill3D );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconEscort2D );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconEscort3D );

	level._friendlyFlagStatusText[team] setText( &"OBJECTIVES_FLAG_HOME" );
	level._friendlyFlagStatusText[team].glowColor = (1,1,1);
	level._friendlyFlagStatusText[team].glowAlpha = 0;	

	level._enemyFlagStatusText[otherTeam] setText( &"OBJECTIVES_FLAG_HOME" );
	level._enemyFlagStatusText[otherTeam].glowColor = (1,1,1);
	level._enemyFlagStatusText[otherTeam].glowAlpha = 0;	
	
	level._capZones[team] maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
	level._capZones[team] maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	level._capZones[team] maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconDefendFlag2D );
	level._capZones[team] maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconDefendFlag3D );
	level._capZones[team] maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconCaptureFlag2D );
	level._capZones[team] maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconCaptureFlag3D );

	level._capZones[team].trigger maps\mp\_entityheadIcons::setHeadIcon( "none", "", (0,0,0) );
}


onUse( player )
{
	team = player.pers["team"];
	if ( team == "allies" )
		otherTeam = "axis";
	else
		otherTeam = "allies";

	leaderDialog( "enemy_flag_captured", team, "status" );
	leaderDialog( "flag_captured", otherteam, "status" );	

	thread teamPlayerCardSplash( "callout_flagcapture", player );
	maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( team, 1 );	
	player thread maps\mp\gametypes\_hud_message::SplashNotify( "flag_capture", maps\mp\gametypes\_rank::getScoreInfoValue( "capture" ) );
	maps\mp\gametypes\_gamescore::givePlayerScore( "capture", player );
	player thread [[level._onXPEvent]]( "capture" );
	player incPlayerStat( "flagscaptured", 1 );
	player notify( "objective", "captured" );
	player thread maps\mp\_matchdata::logGameEvent( "capture", player.origin );

	printAndSoundOnEveryone( team, otherteam, &"MP_ENEMY_FLAG_CAPTURED_BY", &"MP_FLAG_CAPTURED_BY", "mp_obj_captured", "mp_enemy_obj_captured", player );

	if ( isDefined( player.carryFlag ) )
		player detachFlag();

	level._teamFlags[otherTeam]	returnFlag();
}


onCantUse( player )
{
//	player iPrintLnBold( &"MP_CANT_PLANT_WITHOUT_BOMB" );
}


onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, killId )
{
	if ( isDefined( attacker ) && isPlayer( attacker ) && attacker.pers["team"] != self.pers["team"] )
	{
		if ( isDefined( attacker.carryFlag ) )
			attacker incPlayerStat( "killsasflagcarrier", 1 );

		if ( isDefined( self.carryFlag ) )
		{
			attacker thread [[level._onXPEvent]]( "kill_carrier" );
			maps\mp\gametypes\_gamescore::givePlayerScore( "kill_carrier", attacker );
			attacker incPlayerStat( "flagcarrierkills", 1 );
			
			thread maps\mp\_matchdata::logKillEvent( killId, "carrying" );
			
			self detachFlag();
		}
	}
}


attachFlag()
{
	otherTeam = level._otherTeam[self.pers["team"]];
	
	self attach( level._carryFlag[otherTeam], "J_spine4", true );
	self.carryFlag = level._carryFlag[otherTeam];
}

detachFlag()
{
	self detach( self.carryFlag, "J_spine4" );
	self.carryFlag = undefined;
}

initGametypeAwards()
{
	maps\mp\_awards::initStatAward( "flagscaptured",		0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "flagsreturned", 		0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "flagcarrierkills", 	0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "flagscarried",			0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "killsasflagcarrier", 	0, maps\mp\_awards::highestWins );
}
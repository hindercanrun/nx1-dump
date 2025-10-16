#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
/*
	Domination
	Objective: 	Capture all the flags by touching them
	Map ends:	When one team captures all the flags, or time limit is reached
	Respawning:	No wait / Near teammates

	Level requirements
	------------------
		Spawnpoints:
			classname		mp_tdm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of owned flags, teammates and 
			enemies at the time of spawn. Players generally spawn behind their teammates relative to the direction of enemies.
			Optionally, give a spawnpoint a script_linkto to specify which flag it "belongs" to (see Flag Descriptors).

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.

		Flags:
			classname       trigger_radius
			targetname      flag_primary or flag_secondary
			Flags that need to be captured to win. Primary flags take time to capture; secondary flags are instant.
		
		Flag Descriptors:
			classname       script_origin
			targetname      flag_descriptor
			Place one flag descriptor close to each flag. Use the script_linkname and script_linkto properties to say which flags
			it can be considered "adjacent" to in the level. For instance, if players have a primary path from flag1 to flag2, and 
			from flag2 to flag3, flag2 would have a flag_descriptor with these properties:
			script_linkname flag2
			script_linkto flag1 flag3
			
			Set scr_domdebug to 1 to see flag connections and what spawnpoints are considered connected to each flag.
*/

/*QUAKED mp_dom_spawn (0.5 0.5 1.0) (-16 -16 0) (16 16 72)
Players spawn near their flags at one of these positions.*/

/*QUAKED mp_dom_spawn_axis_start (1.0 0.0 1.0) (-16 -16 0) (16 16 72)
Axis players spawn away from enemies and near their team at one of these positions at the start of a round.*/

/*QUAKED mp_dom_spawn_allies_start (0.0 1.0 1.0) (-16 -16 0) (16 16 72)
Allied players spawn away from enemies and near their team at one of these positions at the start of a round.*/

main()
{
	if(getdvar("mapname") == "mp_background")
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
	level._onStartGameType = ::onStartGameType;
	level._getSpawnPoint = ::getSpawnPoint;
	level._onPlayerKilled = ::onPlayerKilled;
	level._onPrecacheGameType = ::onPrecacheGameType;
	level._initGametypeAwards = ::initGametypeAwards;
	level._onSpawnPlayer = ::onSpawnPlayer;
	
	game["dialog"]["gametype"] = "domination";

	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level._gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";

	game["dialog"]["offense_obj"] = "capture_objs";
	game["dialog"]["defense_obj"] = "capture_objs";
}


onPrecacheGameType()
{
	precacheShader( "waypoint_captureneutral" );
	precacheShader( "waypoint_capture" );
	precacheShader( "waypoint_defend" );
	precacheShader( "waypoint_captureneutral_a" );
	precacheShader( "waypoint_capture_a" );
	precacheShader( "waypoint_defend_a" );
	precacheShader( "waypoint_captureneutral_b" );
	precacheShader( "waypoint_capture_b" );
	precacheShader( "waypoint_defend_b" );
	precacheShader( "waypoint_captureneutral_c" );
	precacheShader( "waypoint_capture_c" );
	precacheShader( "waypoint_defend_c" );

	precacheShader( "waypoint_captureneutral" );
	precacheShader( "waypoint_capture" );
	precacheShader( "waypoint_defend" );
	precacheShader( "waypoint_captureneutral_a" );
	precacheShader( "waypoint_capture_a" );
	precacheShader( "waypoint_defend_a" );
	precacheShader( "waypoint_captureneutral_b" );
	precacheShader( "waypoint_capture_b" );
	precacheShader( "waypoint_defend_b" );
	precacheShader( "waypoint_captureneutral_c" );
	precacheShader( "waypoint_capture_c" );
	precacheShader( "waypoint_defend_c" );
}


onStartGameType()
{	
	setObjectiveText( "allies", &"OBJECTIVES_DOM" );
	setObjectiveText( "axis", &"OBJECTIVES_DOM" );

	if ( level._splitscreen )
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_DOM" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_DOM" );
	}
	else
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_DOM_SCORE" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_DOM_SCORE" );
	}
	setObjectiveHintText( "allies", &"OBJECTIVES_DOM_HINT" );
	setObjectiveHintText( "axis", &"OBJECTIVES_DOM_HINT" );

	setClientNameMode("auto_change");

	level._spawnMins = ( 0, 0, 0 );
	level._spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_dom_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_dom_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dom_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dom_spawn" );
	
	level._mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level._spawnMins, level._spawnMaxs );
	setMapCenter( level._mapCenter );
	
	level._spawn_all = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dom_spawn" );
	level._spawn_axis_start = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dom_spawn_axis_start" );
	level._spawn_allies_start = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dom_spawn_allies_start" );
	
	level._startPos["allies"] = level._spawn_allies_start[0].origin;
	level._startPos["axis"] = level._spawn_axis_start[0].origin;
	
	level._flagBaseFXid[ "allies" ] = loadfx( maps\mp\gametypes\_teams::getTeamFlagFX( "allies" ) );
	level._flagBaseFXid[ "axis"   ] = loadfx( maps\mp\gametypes\_teams::getTeamFlagFX( "axis" ) );
	
	allowed[0] = "dom";
//	allowed[1] = "hardpoint";
	maps\mp\gametypes\_gameobjects::main(allowed);

	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 10 );

	maps\mp\gametypes\_rank::registerScoreInfo( "capture", 150 );

	maps\mp\gametypes\_rank::registerScoreInfo( "defend", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "defend_assist", 10 );

	maps\mp\gametypes\_rank::registerScoreInfo( "assault", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assault_assist", 10 );
		
	thread domFlags();
	thread updateDomScores();	
}


getSpawnPoint()
{
	spawnpoint = undefined;
	
	if ( !level._useStartSpawns )
	{
		flagsOwned = 0;
		enemyFlagsOwned = 0;
		myTeam = self.pers["team"];
		enemyTeam = getOtherTeam( myTeam );
		for ( i = 0; i < level._flags.size; i++ )
		{
			team = level._flags[i] getFlagTeam();
			if ( team == myTeam )
				flagsOwned++;
			else if ( team == enemyTeam )
				enemyFlagsOwned++;
		}
		
		if ( flagsOwned == level._flags.size )
		{
			// own all flags! pretend we don't own the last one we got, so enemies can spawn there
			enemyBestSpawnFlag = level._bestSpawnFlag[ getOtherTeam( self.pers["team"] ) ];
			
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level._spawn_all, getSpawnsBoundingFlag( enemyBestSpawnFlag ) );
		}
		else if ( flagsOwned > 0 )
		{
			// spawn near any flag we own that's nearish something we can capture
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level._spawn_all, getBoundaryFlagSpawns( myTeam ) );
		}
		else
		{
			// own no flags!
			bestFlag = undefined;
			if ( enemyFlagsOwned > 0 && enemyFlagsOwned < level._flags.size )
			{
				// there should be an unowned one to use
				bestFlag = getUnownedFlagNearestStart( myTeam );
			}
			if ( !isdefined( bestFlag ) )
			{
				// pretend we still own the last one we lost
				bestFlag = level._bestSpawnFlag[ self.pers["team"] ];
			}
			level._bestSpawnFlag[ self.pers["team"] ] = bestFlag;
			
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level._spawn_all, bestFlag.nearbyspawns );
		}
	}
	
	if ( !isdefined( spawnpoint ) )
	{
		if (self.pers["team"] == "axis")
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level._spawn_axis_start);
		else
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level._spawn_allies_start);
	}
	
	//spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level.spawn_all );
	
	assert( isDefined(spawnpoint) );
	
	return spawnpoint;
}


domFlags()
{
	level._lastStatus["allies"] = 0;
	level._lastStatus["axis"] = 0;
	
	game["flagmodels"] = [];
	game["flagmodels"]["neutral"] = "prop_flag_neutral";

	game["flagmodels"]["allies"] = maps\mp\gametypes\_teams::getTeamFlagModel( "allies" );
	game["flagmodels"]["axis"] = maps\mp\gametypes\_teams::getTeamFlagModel( "axis" );
	
	precacheModel( game["flagmodels"]["neutral"] );
	precacheModel( game["flagmodels"]["allies"] );
	precacheModel( game["flagmodels"]["axis"] );
	
	precacheString( &"MP_SECURING_POSITION" );	
	
	primaryFlags = getEntArray( "flag_primary", "targetname" );
	secondaryFlags = getEntArray( "flag_secondary", "targetname" );
	
	if ( (primaryFlags.size + secondaryFlags.size) < 2 )
	{
		printLn( "^1Not enough domination flags found in level!" );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}
	
	level._flags = [];
	for ( index = 0; index < primaryFlags.size; index++ )
		level._flags[level._flags.size] = primaryFlags[index];
	
	for ( index = 0; index < secondaryFlags.size; index++ )
		level._flags[level._flags.size] = secondaryFlags[index];
	
	level._domFlags = [];
	for ( index = 0; index < level._flags.size; index++ )
	{
		trigger = level._flags[index];
		if ( isDefined( trigger.target ) )
		{
			visuals[0] = getEnt( trigger.target, "targetname" );
		}
		else
		{
			visuals[0] = spawn( "script_model", trigger.origin );
			visuals[0].angles = trigger.angles;
		}

		visuals[0] setModel( game["flagmodels"]["neutral"] );

		domFlag = maps\mp\gametypes\_gameobjects::createUseObject( "neutral", trigger, visuals, (0,0,100) );
		domFlag maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
		domFlag maps\mp\gametypes\_gameobjects::setUseTime( 10.0 );
		domFlag maps\mp\gametypes\_gameobjects::setUseText( &"MP_SECURING_POSITION" );
		label = domFlag maps\mp\gametypes\_gameobjects::getLabel();
		domFlag.label = label;
		domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_defend" + label );
		domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" + label );
		domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_captureneutral" + label );
		domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_captureneutral" + label );
		domFlag maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		domFlag.onUse = ::onUse;
		domFlag.onBeginUse = ::onBeginUse;
		domFlag.onUseUpdate = ::onUseUpdate;
		domFlag.onEndUse = ::onEndUse;
		
		
		traceStart = visuals[0].origin + (0,0,32);
		traceEnd = visuals[0].origin + (0,0,-32);
		trace = bulletTrace( traceStart, traceEnd, false, undefined );
	
		upangles = vectorToAngles( trace["normal"] );
		domFlag.baseeffectforward = anglesToForward( upangles );
		domFlag.baseeffectright = anglesToRight( upangles );
		
		domFlag.baseeffectpos = trace["position"];
		
		// legacy spawn code support
		level._flags[index].useObj = domFlag;
		level._flags[index].adjflags = [];
		level._flags[index].nearbyspawns = [];
		
		domFlag.levelFlag = level._flags[index];
		
		level._domFlags[level._domFlags.size] = domFlag;
	}
	
	// level.bestSpawnFlag is used as a last resort when the enemy holds all flags.
	level._bestSpawnFlag = [];
	level._bestSpawnFlag[ "allies" ] = getUnownedFlagNearestStart( "allies", undefined );
	level._bestSpawnFlag[ "axis" ] = getUnownedFlagNearestStart( "axis", level._bestSpawnFlag[ "allies" ] );
	
	flagSetup();
	
	/#
	thread domDebug();
	#/
}

getUnownedFlagNearestStart( team, excludeFlag )
{
	best = undefined;
	bestdistsq = undefined;
	for ( i = 0; i < level._flags.size; i++ )
	{
		flag = level._flags[i];
		
		if ( flag getFlagTeam() != "neutral" )
			continue;
		
		distsq = distanceSquared( flag.origin, level._startPos[team] );
		if ( (!isDefined( excludeFlag ) || flag != excludeFlag) && (!isdefined( best ) || distsq < bestdistsq) )
		{
			bestdistsq = distsq;
			best = flag;
		}
	}
	return best;
}

/#
domDebug()
{
	while(1)
	{
		if (getdvar("scr_domdebug") != "1") {
			wait 2;
			continue;
		}
		
		while(1)
		{
			if (getdvar("scr_domdebug") != "1")
				break;
			// show flag connections and each flag's spawnpoints
			for (i = 0; i < level._flags.size; i++) {
				for (j = 0; j < level._flags[i].adjflags.size; j++) {
					line(level._flags[i].origin, level._flags[i].adjflags[j].origin, (1,1,1));
				}
				
				for (j = 0; j < level._flags[i].nearbyspawns.size; j++) {
					line(level._flags[i].origin, level._flags[i].nearbyspawns[j].origin, (.2,.2,.6));
				}
				
				if ( level._flags[i] == level._bestSpawnFlag["allies"] )
					print3d( level._flags[i].origin, "allies best spawn flag" );
				if ( level._flags[i] == level._bestSpawnFlag["axis"] )
					print3d( level._flags[i].origin, "axis best spawn flag" );
			}
			wait .05;
		}
	}
}
#/

onBeginUse( player )
{
	ownerTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	self.didStatusNotify = false;

	if ( ownerTeam == "neutral" )
	{
		statusDialog( "securing"+self.label, player.pers["team"] );
		self.objPoints[player.pers["team"]] thread maps\mp\gametypes\_objpoints::startFlashing();
		return;
	}
		
	if ( ownerTeam == "allies" )
		otherTeam = "axis";
	else
		otherTeam = "allies";

	self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::startFlashing();
	self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::startFlashing();
}


onUseUpdate( team, progress, change )
{
	if ( progress > 0.05 && change && !self.didStatusNotify )
	{
		ownerTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
		if ( ownerTeam == "neutral" )
		{
			statusDialog( "securing"+self.label, team );
		}
		else
		{
			statusDialog( "losing"+self.label, ownerTeam );
			statusDialog( "securing"+self.label, team );
		}

		self.didStatusNotify = true;
	}
}


statusDialog( dialog, team, forceDialog )
{
	time = getTime();
	
	if ( getTime() < level._lastStatus[team] + 5000 && (!isDefined( forceDialog ) || !forceDialog) )
		return;
		
	thread delayedLeaderDialog( dialog, team );
	level._lastStatus[team] = getTime();	
}


onEndUse( team, player, success )
{
	self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::stopFlashing();
	self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::stopFlashing();
}


resetFlagBaseEffect()
{
	if ( isdefined( self.baseeffect ) )
		self.baseeffect delete();
	
	team = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	
	if ( team != "axis" && team != "allies" )
		return;
	
	fxid = level._flagBaseFXid[ team ];

	self.baseeffect = spawnFx( fxid, self.baseeffectpos, self.baseeffectforward, self.baseeffectright );
	triggerFx( self.baseeffect );
}

onUse( player )
{
	team = player.pers["team"];
	oldTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	label = self maps\mp\gametypes\_gameobjects::getLabel();
	
	//player logString( "flag captured: " + self.label );
	
	self.captureTime = getTime();
	
	self maps\mp\gametypes\_gameobjects::setOwnerTeam( team );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_capture" + label );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_capture" + label );
	self.visuals[0] setModel( game["flagmodels"][team] );
	
	self resetFlagBaseEffect();
	
	level._useStartSpawns = false;
	
	assert( team != "neutral" );
	
	if ( oldTeam == "neutral" )
	{
		otherTeam = getOtherTeam( team );
		thread printAndSoundOnEveryone( team, otherTeam, undefined, undefined, "mp_war_objective_taken", undefined, player );
		
		statusDialog( "secured"+self.label, team, true );
		statusDialog( "enemy_has"+self.label, otherTeam, true );
	}
	else
	{
		thread printAndSoundOnEveryone( team, oldTeam, undefined, undefined, "mp_war_objective_taken", "mp_war_objective_lost", player );
		
//		thread delayedLeaderDialogBothTeams( "obj_lost", oldTeam, "obj_taken", team );

		if ( getTeamFlagCount( team ) == level._flags.size )
		{
			statusDialog( "secure_all", team );
			statusDialog( "lost_all", oldTeam );
		}
		else
		{	
			statusDialog( "secured"+self.label, team, true );
			statusDialog( "lost"+self.label, oldTeam, true );
		}
		
		level._bestSpawnFlag[ oldTeam ] = self.levelFlag;
	}
	
	player notify( "objective", "captured" );
	self thread giveFlagCaptureXP( self.touchList[team] );
}

giveFlagCaptureXP( touchList )
{
	level endon ( "game_ended" );
	
	players = getArrayKeys( touchList );
	for ( index = 0; index < players.size; index++ )
	{
		player = touchList[players[index]].player;
		player thread maps\mp\gametypes\_hud_message::SplashNotify( "capture", maps\mp\gametypes\_rank::getScoreInfoValue( "capture" ) );
		player thread updateCPM();
		player thread maps\mp\gametypes\_rank::giveRankXP( "capture", maps\mp\gametypes\_rank::getScoreInfoValue( "capture" ) * player getCapXPScale() );
		printLn( maps\mp\gametypes\_rank::getScoreInfoValue( "capture" ) * player getCapXPScale() );
		maps\mp\gametypes\_gamescore::givePlayerScore( "capture", player );
		if ( players.size == 1 )
		{
			player incPlayerStat( "dompointscapturedsingular", 1 );
		}
		player incPlayerStat( "pointscaptured", 1 );
	}
	
	player = self maps\mp\gametypes\_gameobjects::getEarliestClaimPlayer();

	level thread teamPlayerCardSplash( "callout_securedposition" + self.label, player );

	player thread maps\mp\_matchdata::logGameEvent( "capture", player.origin );	
}

delayedLeaderDialog( sound, team )
{
	level endon ( "game_ended" );
	wait .1;
	WaitTillSlowProcessAllowed();
	
	leaderDialog( sound, team );
}
delayedLeaderDialogBothTeams( sound1, team1, sound2, team2 )
{
	level endon ( "game_ended" );
	wait .1;
	WaitTillSlowProcessAllowed();
	
	leaderDialogBothTeams( sound1, team1, sound2, team2 );
}


updateDomScores()
{
	level endon ( "game_ended" );
	
	while ( !level._gameEnded )
	{
		domFlags = getOwnedDomFlags();
		
		if ( domFlags.size )
		{
			for ( i = 1; i < domFlags.size; i++ )
			{
				domFlag = domFlags[i];
				flagScore = getTime() - domFlag.captureTime;
				for ( j = i - 1; j >= 0 && flagScore > (getTime() - domFlags[j].captureTime); j-- )
					domFlags[j + 1] = domFlags[j];
				domFlags[j + 1] = domFlag;
			}
			
			foreach( domFlag in domFlags )
			{
				team = domFlag maps\mp\gametypes\_gameobjects::getOwnerTeam();
				assert( team == "allies" || team == "axis" );
				maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( team, 1 );	
			}
		}
		
		// end the game if people aren't playing
		if ( (((getTimePassed() / 1000) > 120 && domFlags.size < 2) || ((getTimePassed() / 1000) > 300 && domFlags.size < 3)) && matchMakingGame() )
		{
			thread maps\mp\gametypes\_gamelogic::endGame( "none", game["strings"]["time_limit_reached"] );
			return;			
		}
		
		wait ( 5.0 );
		maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
	}
}


onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, killId )
{
	if ( !isPlayer( attacker ) || (!self.touchTriggers.size && !attacker.touchTriggers.size) || attacker.pers["team"] == self.pers["team"] )
		return;

	awardedAssault = false;
	awardedDefend = false;

	foreach ( trigger in self.touchTriggers )
	{
		// TODO: way to check for dom specific triggers
		if ( !isDefined( trigger.useObj ) )
			continue;
		
		ownerTeam = trigger.useObj.ownerTeam;
		team = self.pers["team"];

		if ( ownerTeam == "neutral" )
			continue;
		
		if ( team == ownerTeam )
		{
			awardedAssault = true;
			attacker thread maps\mp\gametypes\_hud_message::SplashNotify( "assault", maps\mp\gametypes\_rank::getScoreInfoValue( "assault" ) );
			attacker thread maps\mp\gametypes\_rank::giveRankXP( "assault" );
			maps\mp\gametypes\_gamescore::givePlayerScore( "assault", attacker );

			thread maps\mp\_matchdata::logKillEvent( killId, "defending" );
		}
		else
		{
			awardedDefend = true;
			attacker thread maps\mp\gametypes\_hud_message::SplashNotify( "defend", maps\mp\gametypes\_rank::getScoreInfoValue( "defend" ) );
			attacker thread maps\mp\gametypes\_rank::giveRankXP( "defend" );
			maps\mp\gametypes\_gamescore::givePlayerScore( "defend", attacker );

			if ( maps\mp\gametypes\_weapons::isEquipment ( sWeapon ))
			{
				attacker incPlayerStat( "domdefendwithequipment", 1 );
			}

			thread maps\mp\_matchdata::logKillEvent( killId, "assaulting" );
		}
	}

	foreach ( trigger in attacker.touchTriggers )
	{
		// TODO: way to check for dom specific triggers
		if ( !isDefined( trigger.useObj ) )
			continue;
		
		ownerTeam = trigger.useObj.ownerTeam;
		team = attacker.pers["team"];
		
		if ( ownerTeam == "neutral" )
			continue;
		
		if ( team == ownerTeam )
		{
			if ( !awardedDefend )
				attacker thread maps\mp\gametypes\_hud_message::SplashNotify( "defend", maps\mp\gametypes\_rank::getScoreInfoValue( "defend" ) );
			attacker thread maps\mp\gametypes\_rank::giveRankXP( "defend" );
			maps\mp\gametypes\_gamescore::givePlayerScore( "defend", attacker );
			
			if ( maps\mp\gametypes\_weapons::isEquipment ( sWeapon ))
			{
					attacker incPlayerStat( "domdefendwithequipment", 1 );
			}

			thread maps\mp\_matchdata::logKillEvent( killId, "assaulting" );
		}
		else
		{
			if ( !awardedAssault )
				attacker thread maps\mp\gametypes\_hud_message::SplashNotify( "assault", maps\mp\gametypes\_rank::getScoreInfoValue( "assault" ) );
			attacker thread maps\mp\gametypes\_rank::giveRankXP( "assault" );
			maps\mp\gametypes\_gamescore::givePlayerScore( "assault", attacker );		

			thread maps\mp\_matchdata::logKillEvent( killId, "defending" );
		}
	}
}


getOwnedDomFlags()
{
	domFlags = [];
	foreach ( domFlag in level._domFlags )
	{
		if ( domFlag maps\mp\gametypes\_gameobjects::getOwnerTeam() != "neutral" && isDefined( domFlag.captureTime ) )
			domFlags[domFlags.size] = domFlag;
	}
	
	return domFlags;
}


getTeamFlagCount( team )
{
	score = 0;
	for (i = 0; i < level._flags.size; i++) 
	{
		if ( level._domFlags[i] maps\mp\gametypes\_gameobjects::getOwnerTeam() == team )
			score++;
	}	
	return score;
}

getFlagTeam()
{
	return self.useObj maps\mp\gametypes\_gameobjects::getOwnerTeam();
}

getBoundaryFlags()
{
	// get all flags which are adjacent to flags that aren't owned by the same team
	bflags = [];
	for (i = 0; i < level._flags.size; i++)
	{
		for (j = 0; j < level._flags[i].adjflags.size; j++)
		{
			if (level._flags[i].useObj maps\mp\gametypes\_gameobjects::getOwnerTeam() != level._flags[i].adjflags[j].useObj maps\mp\gametypes\_gameobjects::getOwnerTeam() )
			{
				bflags[bflags.size] = level._flags[i];
				break;
			}
		}
	}
	
	return bflags;
}

getBoundaryFlagSpawns(team)
{
	spawns = [];
	
	bflags = getBoundaryFlags();
	for (i = 0; i < bflags.size; i++)
	{
		if (isdefined(team) && bflags[i] getFlagTeam() != team)
			continue;
		
		for (j = 0; j < bflags[i].nearbyspawns.size; j++)
			spawns[spawns.size] = bflags[i].nearbyspawns[j];
	}
	
	return spawns;
}

getSpawnsBoundingFlag( avoidflag )
{
	spawns = [];

	for (i = 0; i < level._flags.size; i++)
	{
		flag = level._flags[i];
		if ( flag == avoidflag )
			continue;
		
		isbounding = false;
		for (j = 0; j < flag.adjflags.size; j++)
		{
			if ( flag.adjflags[j] == avoidflag )
			{
				isbounding = true;
				break;
			}
		}
		
		if ( !isbounding )
			continue;
		
		for (j = 0; j < flag.nearbyspawns.size; j++)
			spawns[spawns.size] = flag.nearbyspawns[j];
	}
	
	return spawns;
}

// gets an array of all spawnpoints which are near flags that are
// owned by the given team, or that are adjacent to flags owned by the given team.
getOwnedAndBoundingFlagSpawns(team)
{
	spawns = [];

	for (i = 0; i < level._flags.size; i++)
	{
		if ( level._flags[i] getFlagTeam() == team )
		{
			// add spawns near this flag
			for (s = 0; s < level._flags[i].nearbyspawns.size; s++)
				spawns[spawns.size] = level._flags[i].nearbyspawns[s];
		}
		else
		{
			for (j = 0; j < level._flags[i].adjflags.size; j++)
			{
				if ( level._flags[i].adjflags[j] getFlagTeam() == team )
				{
					// add spawns near this flag
					for (s = 0; s < level._flags[i].nearbyspawns.size; s++)
						spawns[spawns.size] = level._flags[i].nearbyspawns[s];
					break;
				}
			}
		}
	}
	
	return spawns;
}

// gets an array of all spawnpoints which are near flags that are
// owned by the given team
getOwnedFlagSpawns(team)
{
	spawns = [];

	for (i = 0; i < level._flags.size; i++)
	{
		if ( level._flags[i] getFlagTeam() == team )
		{
			// add spawns near this flag
			for (s = 0; s < level._flags[i].nearbyspawns.size; s++)
				spawns[spawns.size] = level._flags[i].nearbyspawns[s];
		}
	}
	
	return spawns;
}

flagSetup()
{
	maperrors = [];
	descriptorsByLinkname = [];

	// (find each flag_descriptor object)
	descriptors = getentarray("flag_descriptor", "targetname");
	
	flags = level._flags;
	
	for (i = 0; i < level._domFlags.size; i++)
	{
		closestdist = undefined;
		closestdesc = undefined;
		for (j = 0; j < descriptors.size; j++)
		{
			dist = distance(flags[i].origin, descriptors[j].origin);
			if (!isdefined(closestdist) || dist < closestdist) {
				closestdist = dist;
				closestdesc = descriptors[j];
			}
		}
		
		if (!isdefined(closestdesc)) {
			maperrors[maperrors.size] = "there is no flag_descriptor in the map! see explanation in dom.gsc";
			break;
		}
		if (isdefined(closestdesc.flag)) {
			maperrors[maperrors.size] = "flag_descriptor with script_linkname \"" + closestdesc.script_linkname + "\" is nearby more than one flag; is there a unique descriptor near each flag?";
			continue;
		}
		flags[i].descriptor = closestdesc;
		closestdesc.flag = flags[i];
		descriptorsByLinkname[closestdesc.script_linkname] = closestdesc;
	}
	
	if (maperrors.size == 0)
	{
		// find adjacent flags
		for (i = 0; i < flags.size; i++)
		{
			if (isdefined(flags[i].descriptor.script_linkto))
				adjdescs = strtok(flags[i].descriptor.script_linkto, " ");
			else
				adjdescs = [];
			for (j = 0; j < adjdescs.size; j++)
			{
				otherdesc = descriptorsByLinkname[adjdescs[j]];
				if (!isdefined(otherdesc) || otherdesc.targetname != "flag_descriptor") {
					maperrors[maperrors.size] = "flag_descriptor with script_linkname \"" + flags[i].descriptor.script_linkname + "\" linked to \"" + adjdescs[j] + "\" which does not exist as a script_linkname of any other entity with a targetname of flag_descriptor (or, if it does, that flag_descriptor has not been assigned to a flag)";
					continue;
				}
				adjflag = otherdesc.flag;
				if (adjflag == flags[i]) {
					maperrors[maperrors.size] = "flag_descriptor with script_linkname \"" + flags[i].descriptor.script_linkname + "\" linked to itself";
					continue;
				}
				flags[i].adjflags[flags[i].adjflags.size] = adjflag;
			}
		}
	}
	
	// assign each spawnpoint to nearest flag
	spawnpoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dom_spawn" );
	for (i = 0; i < spawnpoints.size; i++)
	{
		if (isdefined(spawnpoints[i].script_linkto)) {
			desc = descriptorsByLinkname[spawnpoints[i].script_linkto];
			if (!isdefined(desc) || desc.targetname != "flag_descriptor") {
				maperrors[maperrors.size] = "Spawnpoint at " + spawnpoints[i].origin + "\" linked to \"" + spawnpoints[i].script_linkto + "\" which does not exist as a script_linkname of any entity with a targetname of flag_descriptor (or, if it does, that flag_descriptor has not been assigned to a flag)";
				continue;
			}
			nearestflag = desc.flag;
		}
		else {
			nearestflag = undefined;
			nearestdist = undefined;
			for (j = 0; j < flags.size; j++)
			{
				dist = distancesquared(flags[j].origin, spawnpoints[i].origin);
				if (!isdefined(nearestflag) || dist < nearestdist)
				{
					nearestflag = flags[j];
					nearestdist = dist;
				}
			}
		}
		nearestflag.nearbyspawns[nearestflag.nearbyspawns.size] = spawnpoints[i];
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
}

initGametypeAwards()
{
	maps\mp\_awards::initStatAward( "pointscaptured", 0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStat( "dompointscapturedsingular", 0 );
	maps\mp\_awards::initStat( "domdefendwithequipment", 0 );
}

onSpawnPlayer()
{
}

updateCPM()
{
	if ( !isDefined( self.CPM ) )
	{
		self.numCaps = 0;
		self.CPM = 0;
	}
	
	self.numCaps++;
	
	if ( getMinutesPassed() < 1 )
		return;
		
	self.CPM = self.numCaps / getMinutesPassed();
}

getCapXPScale()
{
	if ( self.CPM < 4 )
		return 1;
	else
		return 0.25;
}
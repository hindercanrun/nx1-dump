#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
/*
	Mtdm
	Objective: 	Score points for your team by eliminating players on the opposing teams
	Map ends:	When one team reaches the score limit, or time limit is reached
	Respawning:	No wait / Near teammates

	Level requirementss
	------------------
		Spawnpoints:
			classname		mp_tdm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of teammates and enemies
			at the time of spawn. Players generally spawn behind their teammates relative to the direction of enemies.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.
*/

//generic in game spawns for the mtdm match

/*QUAKED mp_mtdm_spawn (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_mtdm_spawn_team_0_start (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 0 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_1_start (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 1 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_2_start (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 2 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_3_start (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 3 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_4_start (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 4 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_5_start (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 5 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_6_start (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 6 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_7_start (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 7 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_8_start (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 8 players spawn at one of these positions at the start of a round.*/


//Specific spawns for the 3 team case!
/*QUAKED mp_mtdm_spawn_team_0_start_3_teams (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 0 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_1_start_3_teams (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 1 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_2_start_3_teams (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 2 players spawn at one of these positions at the start of a round.*/


//Specific spawns for the 4 team case!
/*QUAKED mp_mtdm_spawn_team_0_start_4_teams (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 0 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_1_start_4_teams (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 1 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_2_start_4_teams (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 2 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_3_start_4_teams (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 3 players spawn at one of these positions at the start of a round.*/


//Specific spawns for the 5 team case!
/*QUAKED mp_mtdm_spawn_team_0_start_5_teams (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 0 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_1_start_5_teams (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 1 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_2_start_5_teams (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 2 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_3_start_5_teams (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 3 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_4_start_5_teams (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 4 players spawn at one of these positions at the start of a round.*/


//Designated spawn points ( mostly for dev )
/*QUAKED mp_mtdm_spawn_team_0_designated (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 0 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_1_designated (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 1 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_2_designated (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 2 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_3_designated (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 3 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_4_designated (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 4 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_5_designated (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 5 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_6_designated (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 6 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_7_designated (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 7 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_mtdm_spawn_team_8_designated (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Team 8 players spawn at one of these positions at the start of a round.*/

main()
{
	if(getdvar("mapname") == "mp_background")
		return;
	
	/* a few things to be awar of...
	maps\mp\gametypes\_globallogic::init();
	- This call will set up several things that alrady assume 2 teams.  There is a list below
	
	//i cut these out, just because it is conceptually impossable to use logic like this in mtdm
	level._otherTeam["allies"] = "axis";
	level._otherTeam["axis"] = "allies";
	
	//these may still need attention for multiteam
	level._placement["allies"] = [];
	level._placement["axis"] = [];
	level._placement["all"] = [];
	
	//these should be cleared up by the init loop below
	level._teamCount[] = 0;
	level._aliveCount[] = 0;
	level._livesCount[] = 0;
	level._hasSpawned[] = 0;
	*/
	
	maps\mp\gametypes\_globallogic::init();
	
	numTeams = getDvarInt( "g_MTDM_NumTeams" );
	
	level._maxNumTeams = numTeams;		//9 is max supported at the moment.
	level._teamNameList = [];
	
	for( i = 0; i < level._maxNumTeams; i++ )
	{
		level._teamNameList[i] = "team_" + i;
		
		/*  TagZP<NOTE> not sure if i want to do this or not... gonna sleep on it for now
		if( i == 0 )
		{
			level._teamNameList[i] = "axis";
		}
		else if( i == 1 )
		{
			level._teamNameList[i] = "allies";
		}
		*/
	}
	
	/#
	println( "printing team name list" );
	for( i = 0; i <  level._teamNameList.size; i++ )
	{
		println( level._teamNameList[i] );
	}
	#/
	
	//these fields have been initialized in the global logic init call, this initializes the mtdm fields necessary.
	//remember level._<whatever>["axis" || "allies"] is still munged in there with the rest at the moment.
	for( i = 0; i < level._teamNameList.size; i++ )
	{
		level._teamCount[level._teamNameList[i]] = 0;
		level._aliveCount[level._teamNameList[i]] = 0;
		level._livesCount[level._teamNameList[i]] = 0;
		level._hasSpawned[level._teamNameList[i]] = 0;
	}
	
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	registerRoundSwitchDvar( level._gameType, 0, 0, 9 );
	registerTimeLimitDvar( level._gameType, 10, 0, 1440 );
	registerScoreLimitDvar( level._gameType, 500, 0, 5000 );
	registerRoundLimitDvar( level._gameType, 1, 0, 10 );
	registerWinLimitDvar( level._gameType, 1, 0, 10 );
	registerRoundSwitchDvar( level._gameType, 3, 0, 30 );
	registerNumLivesDvar( level._gameType, 0, 0, 10 );
	registerHalfTimeDvar( level._gameType, 0, 0, 1 );

	level._teamBased = true;

	level._multiTeamBased = true;
	
	level._onStartGameType = ::onStartGameType;
	level._getSpawnPoint = ::getSpawnPoint;
	level._onNormalDeath = ::onNormalDeath;
	//level.onTimeLimit = ::onTimeLimit;	// overtime not fully supported yet

	game["dialog"]["gametype"] = "tm_death";
	
	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level._gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";
	
	game["strings"]["overtime_hint"] = &"MP_FIRST_BLOOD";
	
	level._postRoundTime = 5.0;
	
	//this makes the scoreboard look a little better
	setdvar( "cg_scoreboardBannerHeight", 10 );

	//Debug force intel to on for testing in MTDM
	//setdvar( "prototype_intel_enabled", 1 );
	//setdvar( "prototype_intel_percentage", 100 );
}


onStartGameType()
{
	setClientNameMode("auto_change");

	//TagZP<NOTE> removed switch sides logic, that will not be supported in MTDM ( at least not for now )

	//TagZP<NOTE> sould be fine to use the objective strings from tdm for now
	//TagZP<TODO> may want to create custon objective strings for MTDM
	setObjectiveText( "allies", &"OBJECTIVES_WAR" );
	setObjectiveText( "axis", &"OBJECTIVES_WAR" );
	
	if ( level._splitscreen )
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_WAR" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_WAR" );
		
		for( i = 0; i < level._teamNameList.size; i++ )
		{
			setObjectiveScoreText( level._teamNameList[i], &"OBJECTIVES_WAR" );
		}
	}
	else
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_WAR_SCORE" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_WAR_SCORE" );
		
		for( i = 0; i < level._teamNameList.size; i++ )
		{
			setObjectiveScoreText( level._teamNameList[i], &"OBJECTIVES_WAR_SCORE" );
		}
		
	}
	setObjectiveHintText( "allies", &"OBJECTIVES_WAR_HINT" );
	setObjectiveHintText( "axis", &"OBJECTIVES_WAR_HINT" );
	
	for( i = 0; i < level._teamNameList.size; i++ )
	{
		setObjectiveHintText( level._teamNameList[i], &"OBJECTIVES_WAR_HINT" );
	}

	//SPAWNING SETUP!!
			
	//Using TDM spawn points for now, will eventually want custom spawn points for MTDM
	level._spawnMins = ( 0, 0, 0 );
	level._spawnMaxs = ( 0, 0, 0 );
	
	//TagZP<NOTE> using mp_tdm_spawn_allies_start as a backup if no starting spawn can be found for the team at hand.
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	//maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	//maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	//maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );

	//Here is a check to see if ingame MTDM spawners have been set up in the map we are running.  If they have not been setup we will use tdm spawners.
	level._using_ingame_mtdm_spawners = 0;
	mtdm_spawnpoint_list = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_mtdm_spawn" );
	if( mtdm_spawnpoint_list.size > 0 )
	{
		level._using_ingame_mtdm_spawners = 1;
	}
	else
	{
		//if we are not using mtdm spawners, we will fall back on tdm spawners, go ahead and assert that at least one exists
		temp = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn" );
		assert( temp.size > 0 );
	}

	for( i = 0; i < level._teamNameList.size; i++ )
	{	
		//This call will init each starting spawn point... drop to groun, orientation...
		str_team_starting_spawn_pts = "mp_mtdm_spawn_" + level._teamNameList[i] + "_start";
		spawnpoints_check = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( str_team_starting_spawn_pts );
		if( spawnpoints_check.size )
		{
			maps\mp\gametypes\_spawnlogic::placeSpawnPoints( str_team_starting_spawn_pts );
		}

		//place spawnpoints for MTDM preset num team start spawns
		str_team_starting_spawn_pts = "mp_mtdm_spawn_" + level._teamNameList[i] + "_start_" + level._maxNumTeams + "_teams";
		spawnpoints_check = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( str_team_starting_spawn_pts );
		if( spawnpoints_check.size )
		{
			maps\mp\gametypes\_spawnlogic::placeSpawnPoints( str_team_starting_spawn_pts );
		}

		//either assign a team the set of mtdm spawners, or if that does not exist just give them them tdm spawners.
		if( level._using_ingame_mtdm_spawners )
		{
			maps\mp\gametypes\_spawnlogic::addSpawnPoints( level._teamNameList[i], "mp_mtdm_spawn" );
		}
		else
		{
			maps\mp\gametypes\_spawnlogic::addSpawnPoints( level._teamNameList[i], "mp_tdm_spawn" );
		}
	}

	//END SPAWNING SETUP!!
	
	level._mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level._spawnMins, level._spawnMaxs );
	setMapCenter( level._mapCenter );
	
	allowed[0] = level._gameType;
	allowed[1] = "airdrop_pallet";
	
	maps\mp\gametypes\_gameobjects::main( allowed );
	
	level._useDesignatedSpawns = false;	
}


getSpawnPoint()
{
	spawnteam = self.pers["team"];

	usingDesignatedSpawns = false;
	if( isDefined( level._useDesignatedSpawns ))
	{
		if( level._useDesignatedSpawns == true )
		{
			usingDesignatedSpawns = true;		
		}
	}
	
 	if ( level._inGracePeriod )
 	{
		//attempt to find a start spawn based on the number of teams in the match
		//spawn point name example - mp_mtdm_spawn_team_0_start_3_teams
		spawnpoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_mtdm_spawn_" + spawnteam + "_start_" + level._maxNumTeams + "_teams" );

		//if we could not find a starting point specific to the number of teams in the game then we can 
		//grab a random staring point in the list of generic starting points for this team.
		if( spawnPoints.size == 0 )
		{
 			spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_mtdm_spawn_" + spawnteam + "_start" );
		}
 		
 		//incase MTDM starting points are not set up, use some backups...
		if( spawnPoints.size == 0 )
		{
			//println( "Warning level does not contain the proper MTDM spawn points, using tdm spawn points" );
			spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn_allies_start" );
		}
 		
 		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
 	}
 	else
 	{ 	
		if( usingDesignatedSpawns )
		{
			spawnPoints = getMTDMDesignatedTeamSpawns( spawnteam );
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
		}
		else
		{
			spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnteam );
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
		}
	}
	return spawnPoint;
}

getMTDMDesignatedTeamSpawns( team )
{
	spawnPointName = "mp_mtdm_spawn_" + team + "_designated";
	spawnpoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( spawnPointName );

	if( spawnpoints.size <= 0 )
	{
		println( "WARNING: no MTDM designated spawns were found using tdm spawns" );
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( team );
	}

	return spawnpoints;
}

onNormalDeath( victim, attacker, lifeId )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
	assert( isDefined( score ) );
	
	attacker maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( attacker.pers["team"], score );
	
	if ( game["state"] == "postgame" )
	{
		if( game["teamScores"][attacker.team] >= getWatchedDvar( "scorelimit" ))
		{
			attacker.finalKill = true;
		}
	}
}


onTimeLimit()
{
	if ( game["status"] == "overtime" )
	{
		winner = "forfeit";
	}
	else 
	{
		winner = maps\mp\gametypes\_gamescore::getWinningTeam();
	}
	
	thread maps\mp\gametypes\_gamelogic::endGame( winner, game["strings"]["time_limit_reached"] );
}
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
/*
	American Gladiator Events
	Objective: 	Play through American Gladiator modeled events. Rack up the most points based on each game's rules and your role.
	Map ends:	After all player have played in all roles for al events selected for the match
	Respawning:	Dependent on event.  Most of the time, player will not one life per round.

	Level requirements
	------------------
		Spawnpoints:
			classname		mp_dm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of enemies at the time of spawn.
			Players generally spawn away from enemies.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.
*/

/*QUAKED mp_glad_assault_gladiator_spawn (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
Player spawns in this location if they are in the gladiator role in the assault event.*/

/*QUAKED mp_glad_assault_challenger_spawn (0.0 1.0 0.0) (-16 -16 0) (16 16 72)
Player spawns in this location if they are in the challenger role in the assault event.*/

main()
{
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	registerTimeLimitDvar( level._gameType, 10, 0, 1440 );
	registerScoreLimitDvar( level._gameType, 1000, 0, 5000 );
	registerWinLimitDvar( level._gameType, 1, 0, 5000 );
	registerRoundLimitDvar( level._gameType, 1, 0, 10 );
	registerNumLivesDvar( level._gameType, 0, 0, 10 );
	registerHalfTimeDvar( level._gameType, 0, 0, 1 );

	level._onStartGameType = ::onStartGameType;
	level._getSpawnPoint = ::getSpawnPoint;
	level._onSpawnPlayer = ::onSpawnPlayer;

	game["dialog"]["gametype"] = "gladiator";

	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level._gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";

	//setting up the valid event types
	game["glad_events"][0] = "assault";

	//setting up event values
	game["event_info"]["assault"]["max_gladiators"] = 1;
	game["event_info"]["assault"]["cur_num_gladiators"] = 0;
	game["event_info"]["assault"]["max_challengers"] = 1;
	game["event_info"]["assault"]["cur_num_challengers"] = 0;

	//Setting up flags needed for individual events
	level._round_over_array = [];
	maps\mp\gametypes\glad_ass::assault_flag_inits();

	//thread to assign players to appropriate events and roles as they connect
	level thread on_new_player_connect();

	//tagCT<TODO> create a thread to handle disconnects

	//Assigning players to an event and role
	/*foreach( player in level._players )
	{
		for( i = 0; i < game["glad_events"].size; i++ )
		{
			player.eventplayed[i]["gladiator"] = false;
			player.eventplayed[i]["challenger"] = false;
		}
		for( i = 0; i < game["glad_events"].size; i++ )
		{
			//event is full
			if( game["event_info"][ game["glad_events"][i] ]["max_challengers"] == game["event_info"][ game["glad_events"][i] ]["cur_num_challengers"] 
				&& game["event_info"][ game["glad_events"][i] ]["max_gladiators"] == game["event_info"][ game["glad_events"][i] ]["cur_num_gladiators"] )
			{
				continue;
			}
			else if( game["event_info"][ game["glad_events"][i] ]["cur_num_challengers"] > game["event_info"][ game["glad_events"][i] ]["cur_num_gladiators"] 
				&& game["event_info"][ game["glad_events"][i] ]["max_gladiators"] != game["event_info"][ game["glad_events"][i] ]["cur_num_gladiators"] )
			{
				player.cur_event = game["glad_events"][i];
				player.gladiator = true;
				game["event_info"][ game["glad_events"][i] ]["cur_num_gladiators"]++;
			}
			else if( game["event_info"][ game["glad_events"][i] ]["cur_num_challengers"] <= game["event_info"][ game["glad_events"][i] ]["cur_num_gladiators"] 
				&& game["event_info"][ game["glad_events"][i] ]["max_challengers"] != game["event_info"][ game["glad_events"][i] ]["cur_num_challengers"] )
			{
				player.cur_event = game["glad_events"][i];
				player.gladiator = false;
				game["event_info"][ game["glad_events"][i] ]["cur_num_challengers"]++;
			}
		}
		if( !isDefined( player.cur_event ) )
		{
			assertMsg( "I was unable to assign " + player.name + " to an event. There are " + level._players.size + " currently in the match." );
		}
	}*/
}


onStartGameType()
{
	setClientNameMode("auto_change");

	setObjectiveText( "allies", &"OBJECTIVES_DM" );
	setObjectiveText( "axis", &"OBJECTIVES_DM" );

	if ( level._splitscreen )
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_DM" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_DM" );
	}
	else
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_DM_SCORE" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_DM_SCORE" );
	}
	setObjectiveHintText( "allies", &"OBJECTIVES_DM_HINT" );
	setObjectiveHintText( "axis", &"OBJECTIVES_DM_HINT" );

	level._spawnMins = ( 0, 0, 0 );
	level._spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
	level._mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level._spawnMins, level._spawnMaxs );
	setMapCenter( level._mapCenter );

	//Setting up scoring
	maps\mp\gametypes\glad_ass::assault_scoring_init();

	allowed[0] = "glad";
	maps\mp\gametypes\_gameobjects::main(allowed);

	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );
	
	level._QuickMessageToAll = true;

	//turning off killstreaks
	level._killstreakRewards = false;

	thread waittill_round_over();
}


//self = current player
getSpawnPoint()
{
	assert( isDefined( self.cur_event ) && isDefined( self.gladiator ) );

 	if ( level._inGracePeriod )
 	{
		if( self.gladiator )
		{
			spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_glad_" + self.cur_event + "_gladiator_spawn" );
		}
		else
		{
			spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_glad_" + self.cur_event + "_challenger_spawn" );
		}
 		
		assert( spawnPoints.size != 0 );
 		
 		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
 	}
 	else
 	{ 	
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );
	}
	return spawnPoint;
}

//self = the player who is currently spawning
onSpawnPlayer()
{
	assert( isDefined( self.cur_event ) );
	switch( self.cur_event )
	{
		case "assault":
			self thread maps\mp\gametypes\glad_ass::on_player_spawned();
			break;
		default:
			assertMsg( self.name + " has an invalid current event. Current Event value: " + self.cur_event );
			break;
	}
}

//self = level
on_new_player_connect()
{
	//Let the thread run infinitely while the game is running.
	while(1)
	{
		//Wait until a new player has connected.
		self waittill( "connected", player );

		//Try to assign a role and event for the newly connected player.
		for( i = 0; i < game["glad_events"].size; i++ )
		{
			player.event_played[i]["gladiator"] = false;
			player.event_played[i]["challenger"] = false;
		}
		for( i = 0; i < game["glad_events"].size; i++ )
		{
			//event is full
			if( game["event_info"][ game["glad_events"][i] ]["max_challengers"] == game["event_info"][ game["glad_events"][i] ]["cur_num_challengers"] 
				&& game["event_info"][ game["glad_events"][i] ]["max_gladiators"] == game["event_info"][ game["glad_events"][i] ]["cur_num_gladiators"] )
			{
				continue;
			}
			else if( game["event_info"][ game["glad_events"][i] ]["cur_num_challengers"] > game["event_info"][ game["glad_events"][i] ]["cur_num_gladiators"] 
				&& game["event_info"][ game["glad_events"][i] ]["max_gladiators"] != game["event_info"][ game["glad_events"][i] ]["cur_num_gladiators"] )
			{
				player.cur_event = game["glad_events"][i];
				player.gladiator = true;
				game["event_info"][ game["glad_events"][i] ]["cur_num_gladiators"]++;

				//for spawn debugging purposes
				println( player.name + " is a gladiator in " + player.cur_event );
			}
			else if( game["event_info"][ game["glad_events"][i] ]["cur_num_challengers"] <= game["event_info"][ game["glad_events"][i] ]["cur_num_gladiators"] 
				&& game["event_info"][ game["glad_events"][i] ]["max_challengers"] != game["event_info"][ game["glad_events"][i] ]["cur_num_challengers"] )
			{
				player.cur_event = game["glad_events"][i];
				player.gladiator = false;
				game["event_info"][ game["glad_events"][i] ]["cur_num_challengers"]++;
			}
		}
		if( !isDefined( player.cur_event ) )
		{
			assertMsg( "I was unable to assign " + player.name + " to an event. There are " + level._players.size + " currently in the match." );
		}
	}
}

//This is a function to do all of the post-round cleanup I need to do, and then force the round end.
waittill_round_over()
{
	for( i=0; i < level._round_over_array.size; i++)
	{
		flag_wait( level._round_over_array[i] );
		flag_clear( level._round_over_array[i] );
	}
	println( "I got here." );

	//tagCT<TODO> Whatever house cleaning I need to do to force players into a new role.
	//tagCT<HACK> The below is a hack because I know the only event is assault and there should only be 2 players in the game.
	foreach ( player in level._players )
	{
		player.gladiator = !player.gladiator;
	}

	SetGameEndTime( 0 );
}

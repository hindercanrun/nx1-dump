//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Assault functionality for Gladiator MP Game Mode             **
//    Created: 5/27/11 - Corey Teblum                                       **
//                                                                          **
//****************************************************************************

#include common_scripts\utility;


assault_flag_inits()
{
	//tagCT<HACK> I should create a better setup function that calls all necessary init groups.
	PreCacheItem( "m79_glad_mp" );

	flag_init( "assault_round_over" );
	level._round_over_array[level._round_over_array.size] = "assault_round_over";
	flag_init( "assault_challenger_proceed" );
	flag_init( "kill_gladiator" );
}

assault_scoring_init()
{
	level._assault_weapon_fired_score = GetDvarInt( "scr_glad_assault_weapon_fired_score" );
	maps\mp\gametypes\_rank::registerScoreInfo( "assault_weapon_fired", level._assault_weapon_fired_score );
	level._assault_finish_line_score = GetDvarInt( "scr_glad_assault_finish_line_score" );
	maps\mp\gametypes\_rank::registerScoreInfo( "assault_finish_line", level._assault_finish_line_score );
	level._assault_max_score = GetDvarInt( "scr_glad_assault_max_score" );
	maps\mp\gametypes\_rank::registerScoreInfo( "assault_jackpot", level._assault_max_score );
}


//self = the player who is currently spawning
on_player_spawned()
{
	//test to see if I can remove player's weapons when they spawn
	self waittill( "spawned_player" );
	self takeAllWeapons();
	self SetActionSlot( 1, "" );

	//begin running gameplay tracking for assault based on role
	if( self.gladiator )
	{
		self thread assault_gladiator_gameplay();
	}
	else
	{
		self thread assault_challenger_gameplay();
	}

	/*
	//tagCT<TODO> Copy over these functions
	//Setup timers for match
	thread MatchTimers();

	//Begin cheat detection
	array_thread( level.cheatAreas, ::CheatLocationWatch );
	thread CheatWatch();
	*/
}

//self = the player we are tracking
assault_challenger_gameplay()
{
	self assault_challenger_gameplay_init();

	//Thread to watch whether the player hit the bullseye
	self thread assault_target_hit_detection();

	//Function to setup and dynamically update weapons
	self assault_challenger_dynamic_weapons();
}

//self = the player we are tracking
assault_challenger_gameplay_init()
{
	//Setting this up, so I can control when and how players die
	self.health = 5000;
	self thread assault_challenger_auto_regen();

	//Tracking Stations Due To Radius Damage of Some Weapons
	self.active_station = 0;

	//Thread to watch to see if the player gets hit
	self thread assault_challenger_hit_detection();
}

//tagCT<TODO> This function does not seem to work. I need to figure out how to handle this in MP.
//self=the player we trying to make immortal
assault_challenger_auto_regen()
{
	level endon( "assault_round_over" );
	//This function is used to maintain max heath for a unit, faking invincibility, but allowing to take damage
	max_health = self.health;
	while( 1 )
	{
		self waittill( "damage", amount, who, normal, loc );
		//tagCT<TODO> Removing temporarily to make game work.
		//self.health = max_health;
		if ( who != self )
		{
			self notify( "hit" );
			maps\mp\gametypes\_gamescore::givePlayerScore( "assault_jackpot", who );
		}
	}
}

assault_challenger_hit_detection()
{
	//tagCT<TODO> add back in player_wins flag endon when we're ready to work with the flags.
	//level endon( "player_wins" );
	level endon( "assault_round_over" );

	self waittill( "hit" );

	//tagCT<TODO> Setup UI for game mode.
	//Carry over from SP version, probably need to handle UI eventually.
	//Print( "Challenger Hit. Round Over." );

	//tagCT<TODO> Figure out what this function did in the SP version and possibly port over
	//thread GameEndText( &"NX_COREY_TEST_HIT", ( 1.0, 0.0, 0.0 ) );

	//tagCT<TODO> Figure out a better way to do this in MP
	/*
	level._player freezeControls( true );
	level.gladiator set_ignoreall( true );
	*/

	flag_set( "assault_round_over" );
}

//self=assault challenger currently running event
assault_challenger_dynamic_weapons()
{
	//Stops spawning new weapons when game's over
	level endon( "assault_round_over" );


	//tagCT<TODO> Find someone who can get this working
	//Testing Spinning Lights
	//Removed lights because they did not work like I had hoped
	//finishLights = GetEntArray( "finishline_light", "targetname" );
	//array_thread( finishLights, ::lightSpin );


	//Setting up all weapons into an array to make them easier to manage
	//Station 1 is index 0
	stationWeapons = [];
	stationWeaponsNames = [];
	stationWeapons[0] = GetEnt( "station1weapon", "targetname" );
	stationWeaponsNames[0] = "wa2000_mp";
	stationWeapons[1] = GetEnt( "station2weapon", "targetname" );
	stationWeaponsNames[1] = "rpg_glad_mp";
	stationWeapons[2] = GetEnt( "station3weapon", "targetname" );
	stationWeaponsNames[2] = "m79_mp";
	stationWeapons[3] = GetEnt( "station4weapon", "targetname" );
	stationWeaponsNames[3] = "deserteagle_mp";
	stationWeapons[4] = GetEnt( "station5weapon", "targetname" );
	stationWeaponsNames[4] = "frag_grenade_assault_mp";

	//I shouldn't need this with the new grenade pickup I'm using for MP
	/*
	//Setting up trigger to pickup grenades
	grenadeTrigger = GetEnt( "frag_pickup", "targetname" );
	grenadeTrigger setHintString( &"NX_COREY_TEST_FRAG_PICKUP" );
	grenadeTrigger trigger_off();
	*/

	//I don't think objectives work in MP.
	//tagCT<TODO> I need to figure out a way to do this correctly in MP
	/*
	//Setting up objectives
	objectives = [];
	objectives[0] = GetEnt( "station1", "targetname" );
	objectives[1] = GetEnt( "station2", "targetname" );
	objectives[2] = GetEnt( "station3", "targetname" );
	objectives[3] = GetEnt( "station4", "targetname" );
	objectives[4] = GetEnt( "station5", "targetname" );
	objectives[5] = GetEnt( "finish_node", "targetname" );

	Objective_Add( 0, "current", &"NX_COREY_TEST_OBJECTIVE_TEXT", objectives[0].origin );

	for( i = 1; i < objectives.size; i++ )
	{
		Objective_Add( i, "invisible", &"NX_COREY_TEST_OBJECTIVE_TEXT", objectives[i].origin );
	}

	thread objectiveCleanup();
	*/

	//A loop to hide unavailable weapons at event start
	for( i = 0; i < stationWeapons.size; i++ )
	{
		stationWeapons[i] Hide();
		stationWeapons[i] MakeUnusable();
	}

	for( i = 0; i < stationWeapons.size; i++ )
	{
		//Activate next weapon
		stationWeapons[i] Show();
		stationWeapons[i] MakeUsable();

		//tagCT<TODO> Another place I need to figure out how to replace objectives
		//Activate next objective
		//Objective_State( i, "current" );

		//Wait for the player to pick up the current weapon
		while( ! (self HasWeapon( stationWeaponsNames[i] )) )
		{
			wait .05;
		}

		/*tagCT<HACK> This code makes assumptions and requires knowledge of what is going on within the weapons array.
		/* It would probably be better to do something that would work without needing to have knowledge of how the array
		/* is laid out.
		*/
		//Doing this within the if statement because challenger is given 3 grenades
		if (i != 4)
		{
			self SetWeaponAmmoClip( stationWeaponsNames[i], 1 );
			self SetWeaponAmmoStock( stationWeaponsNames[i], 0 );
		}
		//Give 3 grenades for the final station.
		else
		{
			self SetWeaponAmmoClip( stationWeaponsNames[i], 3 );
		}

		//tagCT<TODO> Another place I need to figure out how to replace objectives
		//Objective_Delete( i );

		self.active_station++;

		maps\mp\gametypes\_rank::registerScoreInfo( "assault_jackpot", level._assault_max_score - ( self.active_station * level._assault_weapon_fired_score ) );

		//Wait for player to fire current weapon
		while ( self AnyAmmoForWeaponModes( stationWeaponsNames[i] ) )
		{
			wait .05;
		}
		flag_set( "assault_challenger_proceed" );

		//Remove player's weapon
		//tagCT<TODO> Force input to drop weapon
		self takeAllWeapons();

		//Give player a point for succesfully firing a weapon
		maps\mp\gametypes\_gamescore::givePlayerScore( "assault_weapon_fired", self );
	}

	//tagCT<TODO> Turn on finishline lights

	//tagCT<TODO> Another place I need to figure out how to replace objectives
	//Objective_State( 5, "current" );

	/*tagCT<TODO> Allow the player to freeze the timer for the event upon crossing the finish line, 
	/* without triggering end of game until the player is inside a more appropriate volume.
	*/
	finishline = GetEnt( "finishline", "targetname" );
	finishline waittill( "trigger" );

	//Give player a point for crossing the finishline
	maps\mp\gametypes\_gamescore::givePlayerScore( "assault_finish_line", self );

	/*
	Print( "Challenger Reached Finish Line. Round Over." );

	thread GameEndText( &"NX_COREY_TEST_FINISH", ( 0.0, 0.0, 1.0 ) );

	level._player freezeControls( true );
	*/

	flag_set( "kill_gladiator" );

	flag_set( "assault_round_over" );
}

//self=assault challenger currently running event
assault_target_hit_detection()
{
	level endon( "assault_round_over" );

	while(1)
	{
		target = GetEnt( "bullseye", "targetname" );
		target SetCanDamage( true );
		target SetCanRadiusDamage( false );
		target waittill( "damage", amount, who, normal, loc );
		/*if ( ( level.activeStation == 2 || level.activeStation == 3 ) && amount < 1000 )
		{
			//Debug
			Print( "Close Hit with AoE weapon");

			continue;
		}
		else*/ if ( who == self )
		{
			break;
		}
	}
	wait .1;

	println( "Target Hit." );
	
	//tagCT<TODO> Setup scoring properly
	/*
	level.score = level.maxScore;
	Print( "Score: " + level.score );
	flag_set( "score_update" );
	*/
	maps\mp\gametypes\_gamescore::givePlayerScore( "assault_jackpot", self );

	/*
	Print( "Target Hit. Round Over." );

	thread GameEndText( &"NX_COREY_TEST_TARGET_HIT", ( 0.0, 1.0, 0.0 ) );

	level._player freezeControls( true );
	level.gladiator set_ignoreall( true );

	flag_set( "player_wins" );
	*/

	flag_set( "kill_gladiator" );

	flag_set( "assault_round_over" );
}

//self = the player we are tracking
assault_gladiator_gameplay()
{
	self assault_gladiator_gameplay_init();

	//tagCT<TODO> Figure out what else needs to go in here.
}

//self = the player we are tracking
assault_gladiator_gameplay_init()
{
	/*
	//Setting this up, so I can control when and how players die
	self.health = 5000;
	self thread assault_gladiator_auto_regen();
	*/

	//Not going to work. The function is SP only.
	//self EnableInvulnerability();

	//tagCT<HACK>This is a quick and dirty way to allow the gladiator to have a weapon and fire on the the player.
	self GiveWeapon( "m79_glad_mp" );

	self SetSpawnWeapon( "m79_glad_mp" );

	self GiveMaxAmmo( "m79_glad_mp" );

	self thread assault_gladiator_target_reaction_watch();
}

//tagCT<TODO> This function does not seem to work. I need to figure out how to handle this in MP.
//self=the player we trying to make immortal
assault_gladiator_auto_regen()
{
	level endon( "assault_round_over" );
	//This function is used to maintain max heath for a unit, faking invincibility, but allowing to take damage
	max_health = self.health;
	while( 1 )
	{
		self waittill( "damage", amount, who, normal, loc );
		//tagCT<TODO> Removing temporarily to make game work.
		//self.health = max_health;
		//tagCT<TODO> Determine if we should do anything if the challenger hits the gladiator.
	}
}

//self = gladiator
assault_gladiator_target_reaction_watch()
{
	flag_wait( "kill_gladiator" );

	//Not going to work the function is SP Only
	//self DisableInvulnerability();

	self suicide();
}

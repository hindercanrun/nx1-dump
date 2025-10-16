//*******************************************************************
//																	*
//																	*
//*******************************************************************
//	Function:	levelutil_levelvar_set()
//	Purpose:	To set a level var
//	Author:		Eric Milota
//	Returns:	None
levelutil_levelvar_set( levelvarname, levelvarvalue )
{
	level.levelvar[ levelvarname ] = levelvarvalue;
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
//	Function:	levelutil_levelvar_get()
//	Purpose:	To get a level var
//	Author:		Eric Milota
//	Returns:	None
levelutil_levelvar_get( levelvarname, levelvarvalue )
{
	return level.levelvar[ levelvarname ];
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
//	Function:	levelutil_show_group()
//	Purpose:	To show (or hide) a group of entities
//	Author:		Eric Milota
//	Returns:	true if did something, else false if not
levelutil_show_group( targetname, showflag )
{
	nodearray = GetEntArray( targetname, "targetname" );
	if( !IsDefined( nodearray[0] ) )
	{
		return false;
	}
	
	for( x = 0; x < nodearray.size; x++ )
	{
		node = nodearray[ x ];		
		if( showflag )
		{
			node show();
		}
		else
		{
			node hide();
		}
	}
	return true;
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
//	Function:	levelutil_timed_single_entity_hider_thread()
//	Purpose:	To handle timed hider logic
//	Author:		Eric Milota
//	Returns:	None
levelutil_timed_single_entity_hider_thread( timehidden )
{
	if( !IsDefined( self ) )
	{
		return;
	}
	
	self.blank1switchsupressor = true;
	self hide();
	wait timehidden;
	self show();
	self.blank1switchsupressor = false;
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
//	Function:	levelutil_switch_thread()
//	Purpose:	To handle switch logic
//	Author:		Eric Milota
//	Returns:	None
levelutil_switch_thread( nodeid, nodeid_off, nodeid_on, range, interval_wait_time, touch_callback, levelvarname )
{
	nodearray = GetEntArray( nodeid, "targetname" );
	if( !IsDefined( nodearray[0] ) )
	{
		levelutil_show_group( nodeid_off, false );
		levelutil_show_group( nodeid_on, false );
		return;
	}
	
	touching = 0;
	levelutil_show_group( nodeid_off, true );
	levelutil_show_group( nodeid_on, false );
	
	while( 1 )
	{
		touchingplayerarray = [];
		touchingswitcharray = [];
		
		playerlist = GetEntArray( "player", "classname" );	
		if( IsDefined( playerlist[0] ) )
		{
			for( x = 0; x < playerlist.size; x++ )
			{
				playerentity = playerlist[ x ];
				
				for( y = 0; y < nodearray.size; y++ )
				{
					node = nodearray[y];
					
					do_check = 0;
					dist = distance( playerentity.origin, node.origin );
					if ( IsDefined( node.blank1switchsupressor ) )
					{
						if( !node.blank1switchsupressor )
						{
							do_check = 1;
						}
					}		
					else
					{
						do_check = 1;
					}		
			
					if( do_check != 0 )
					{
						dist = distance( playerentity.origin, node.origin );
						if ( dist <= range )
						{
							touchingplayerarray[ touchingplayerarray.size ] = playerentity;
							touchingswitcharray[ touchingswitcharray.size ] = node;
						}
					}
				}
			}
		}

		if( touchingplayerarray.size > 0 )
		{
			if( touching == 0 )
			{
				touching = 1;

				// touching!
				//iPrintLnBold( "TOUCHING " + nodeid + "!!!" );
			
				if( ( IsDefined( levelvarname ) ) && ( levelvarname != "" ) )
				{
					levelutil_levelvar_set( levelvarname, 1 );
				}
				
				if( IsDefined( touch_callback ) )
				{
					[[ touch_callback ]]( touchingplayerarray[0], touchingswitcharray[0], nodeid );
				}
				
				levelutil_show_group( nodeid_off, false );
				levelutil_show_group( nodeid_on, true );
			}
		}
		else
		{
			if( touching == 1 )
			{
				touching = 0;
				
				// no longer touching!
				//iPrintLnBold( "NO LONGER TOUCHING " + nodeid + "!!!" );

				if( ( IsDefined( levelvarname ) ) && ( levelvarname != "" ) )
				{
					levelutil_levelvar_set( levelvarname, 0 );
				}
				
				levelutil_show_group( nodeid_off, true );
				levelutil_show_group( nodeid_on, false );				
			}
		}
		
		wait interval_wait_time;
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
//	Function:	levelutil_try_give_killstreak_verbose()
//	Purpose:	To try to give a kill streak to a player
//	Author:		Eric Milota
//	Returns:	true if ok, else false if not
levelutil_try_give_killstreak_verbose( streakname )
{
	if( !IsDefined( self ) )
	{
		return false;
	}
	if( self level1_try_give_killstreak( streakname ) )
	{
		iPrintLnBold( "Awarded killstreak '" + streakname + "'!!!!" );
		return true;
	}
	iPrintLnBold( "Killstreak '" + streakname + "' FAILED!!!!" );
	return false;
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
//	Function:	level1_try_give_killstreak()
//	Purpose:	To try to give a kill streak to a player
//	Author:		Eric Milota
//	Returns:	true if ok, else false if not
level1_try_give_killstreak( streakname )
{
	// Kill streak setup/init code:	C:\trees\nx1\game\share\raw\maps\mp\killstreaks\_killstreaks.gsc
	// Kill streak table:			C:\trees\nx1\game\share\raw\mp\killstreakTable.csv
	// Kill streak spash table:		C:\trees\nx1\game\share\raw\mp\splashTable.csv
	// Kill streak unlock table:	C:\trees\nx1\game\share\raw\mp\unlockTable.csv

	if( !IsDefined( self ) )
	{
		return false;
	}
	if ( !IsDefined( level._killstreakFuncs[ streakname ] ) )
	{
		iPrintLnBold( "level.killstreakFuncs[" + streakname + "] not defined!!!!" );
		return false;
	}

	if ( IsDefined( self.selectingLocation ) )
	{
		iPrintLnBold( "self.selectingLocation not defined!!!!" );
		return false;
	}

//	if ( IsDefined( self.pers[ "killstreak" ] ) )
//	{
//		if ( getStreakCost( streakName ) < getStreakCost( self.pers[ "killstreak" ] ) )
//			return false;
//	}

	self thread maps\mp\killstreaks\_killstreaks::rewardNotify( streakname, undefined );	//streakVal );
	self maps\mp\killstreaks\_killstreaks::giveKillstreak( streakname );
	return true;
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
//	Function:	levelutil_reload_player()
//	Purpose:	To reload a player
//	Author:		Eric Milota
//	Returns:	None
levelutil_reload_player()
{
	weaponlist = self GetWeaponsListAll();
	if( IsDefined( weaponlist[0] ) )
	{
		for( x = 0; x < weaponlist.size; x++ )
		{
			weaponname = weaponlist[ x ];
			if( weaponname != "none" )
			{
				ammo_fraction = self GetFractionMaxAmmo( weaponname );
				if ( ammo_fraction < 1.0 )	// 0.2
				{
					//iPrintLnBold( "Reloading '" + weaponname + "'!" );
					self GiveMaxAmmo( weaponname );
				}
			}
		}
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
//	Function:	levelutil_player_touched_switch_callback()
//	Purpose:	To handle when a player touches a switch
//	Author:		Eric Milota
//	Returns:	None
levelutil_player_touched_switch_callback( playerentity, switchentity, switchtargetname )
{
	if( !IsDefined( playerentity ) )
	{
		return;
	}
	if( !IsDefined( switchentity ) )
	{
		return;
	}
	if( !IsDefined( switchtargetname ) )
	{
		return;
	}
	
	switch ( switchtargetname )
	{	
		case "killstreakswitch1":
			{
				num_tries = level.killstreakswitcharray.size;
				while( num_tries > 0 )
				{
					num_tries--;
					killstreakstring = level.killstreakswitcharray[ level.killstreakswitcharrayindex ];
					level.killstreakswitcharrayindex++;
					if( level.killstreakswitcharrayindex >= level.killstreakswitcharray.size )
					{
						level.killstreakswitcharrayindex = 0;
					}
					
					//playerentity maps\mp\killstreaks\_killstreaks::giveKillstreak( killstreakstring );
					if( playerentity levelutil_try_give_killstreak_verbose( killstreakstring ) )
					{
						switchentity thread levelutil_timed_single_entity_hider_thread( 3.0 );
						break;
					}
					else
					{
						////// to skip and move to next one, comment this break out.
						break;
					}			
				}
				break;
			}
		case "killstreakswitch_helicopter":
			{
				killstreakstring = "helicopter";
				if( playerentity levelutil_try_give_killstreak_verbose( killstreakstring ) )
				{
					switchentity thread levelutil_timed_single_entity_hider_thread( 10.0 );
				}
				break;
			}
		case "killstreakswitch_harrier_airstrike":
			{
				killstreakstring = "harrier_airstrike";
				if( playerentity levelutil_try_give_killstreak_verbose( killstreakstring ) )
				{
					switchentity thread levelutil_timed_single_entity_hider_thread( 10.0 );
				}
				break;
			}
		case "killstreakswitch_atbr":	// Air Targeted Burst Round
			{
//				foreach( weapon in level._test_weapons )
//				{
//					playerentity giveWeapon( weapon );
//					playerentity givemaxammo( weapon );
//				}
		
			
//				weaponname = "weapon_atbr";
//				playerentity giveWeapon( weaponname );
//				playerentity giveMaxAmmo( weaponname );
//				//playerentity setOffHandPrimaryClass( "other" );
//				//playerentity setOffHandSecondaryClass( "other" );
//				playerentity switchToWeapon( weaponname );

				killstreakstring = "atbr";
				if( playerentity levelutil_try_give_killstreak_verbose( killstreakstring ) )
				{
					switchentity thread levelutil_timed_single_entity_hider_thread( 10.0 );
				}
				break;
			}
		case "giftbox_ammo_reload":
			{
				playerentity levelutil_reload_player();
				switchentity thread levelutil_timed_single_entity_hider_thread( 5.0 );		
				break;
			}
		case "free_claymore":
			{
				weaponname = "claymore_mp";
				playerentity giveWeapon( weaponname );
				playerentity giveMaxAmmo( weaponname );
				//playerentity setOffHandPrimaryClass( "other" );
				playerentity setOffHandSecondaryClass( "other" );
				//playerentity switchToWeapon( weaponname );
			
				switchentity thread levelutil_timed_single_entity_hider_thread( 5.0 );		
				break;
			}
		default:
			{
				break;
			}
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
//	Function:	levelutil_freeweaponspawner_init()
//	Purpose:	To init the free weapon spawner system
//	Author:		Eric Milota
//	Returns:	None
levelutil_freeweaponspawner_init()
{
	thread levelutil_freeweaponspawner_thread();
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
//	Function:	levelutil_freeweaponspawner_thread()
//	Purpose:	To manager the free weapon spawner thread
//	Author:		Eric Milota
//	Returns:	None
levelutil_freeweaponspawner_thread()
{
	//entity 84
	//{
	//	"origin" "-113.6 -340.8 -55.8"
	//	"freeweaponspawner_radius" "50"
	//	"freeweaponspawner_respawntime" "10"
	//	"freeweaponspawner_weapon" "claymore_mp"
	//	"freeweaponspawner_model" "weapon_claymore"
	//	"targetname" "freeweaponspawner"
	//	"classname" "script_origin"
	//}

	nodearraytemp = GetEntArray( "freeweaponspawner", "targetname" );
	if( !IsDefined( nodearraytemp[0] ) )
	{
		return;	// no freeweaponspawner nodes
	}
	
	//radius = 50.0;
	//respawntime = 5.0;
	//weaponname = "claymore_mp";
	//weaponmodelname = "weapon_claymore";	
	
	nodearray = [];
	modelarray = [];
	touchingarray = [];
	hiddenarray = [];
	hiddentimearray = [];
	radiusarray = [];
	respawntimearray = [];
	weaponnamearray = [];
	weaponmodelnamearray = [];
	
	for( x = 0; x < nodearraytemp.size; x++ )
	{
		node = nodearraytemp[ x ];
		
		radius = 50.0;
		respawntime = 5.0;
		weaponname = "claymore_mp";
		weaponmodelname = "weapon_claymore";
		if( 1 )
//		if(	   IsDefined( node.freeweaponspawner_radius ) 
//			&& IsDefined( node.freeweaponspawner_respawntime )
//			&& IsDefined( node.freeweaponspawner_weaponname )
//			&& IsDefined( node.freeweaponspawner_weaponmodelname ) )
		{
//			radius = node.freeweaponspawner_radius;
//			respawntime = node.freeweaponspawner_respawntime;
//			weaponname = node.freeweaponspawner_weaponname;
//			weaponmodelname = node.freeweaponspawner_weaponmodelname;
			
			
			model = spawn( "script_model", node.origin );
			
			nodearray[ nodearray.size ] = node;
			modelarray[ modelarray.size ] = model;
			touchingarray[ touchingarray.size ] = 0;	// not touching for now
			hiddenarray[ hiddenarray.size ] = 0;
			hiddentimearray[ hiddentimearray.size ] = 0;
			radiusarray[ radiusarray.size ] = radius;
			respawntimearray[ respawntimearray.size ] = respawntime;
			weaponnamearray[ weaponnamearray.size ] = weaponname;	//"claymore_mp";
			weaponmodelnamearray[ weaponmodelnamearray.size ] = weaponmodelname;	//"weapon_claymore";

			//model.angles = nodeentity.angles;	//(-40,0,20);
			model SetModel( weaponmodelname );	//"weapon_claymore" );	
			model Show();
		}
	}

	while( 1 )
	{	
		timenow = GetTime();
		for( nodeindex = 0; nodeindex < nodearray.size; nodeindex++ )
		{
			node = nodearray[ nodeindex ];
			model = modelarray[ nodeindex ];
			if( hiddenarray[ nodeindex ] == 0 )
			{
				playerfound = 0;

				player = undefined;
				
				do_check = 1;

				if( do_check == 1 )
				{
					playerlist = GetEntArray( "player", "classname" );	
					if( IsDefined( playerlist[0] ) )
					{			
						for( playerindex = 0; playerindex < playerlist.size; playerindex++ )
						{
							playerentity = playerlist[ playerindex ];							
							dist = distance( playerentity.origin, node.origin );
							if ( dist <= radiusarray[ nodeindex ] )
							{
								player = playerentity;
								playerfound = 1;
							}
						}
					}
				}
					
				if( playerfound == 1 )
				{
					// this player is touching this node!
					
					if( touchingarray[ nodeindex ] == 0 )
					{
						// player is touching now
						touchingarray[ nodeindex ] = 1;
						
						weaponname = weaponnamearray[ nodeindex ];
						 
						player giveWeapon( weaponname );
						player giveMaxAmmo( weaponname );
						//player setOffHandPrimaryClass( "other" );
						//player setOffHandSecondaryClass( "other" );
						player switchToWeapon( weaponname );


						hiddentimearray[ nodeindex ] = GetTime();
						hiddenarray[ nodeindex ] = 1;

						//model.freeweaponspawner_supressor = true;
						model Hide();
					}
				}
				else
				{
					// nobody is touching this guy
					if( touchingarray[ nodeindex ] == 1 )
					{
						// nobody is touching now
						touchingarray[ nodeindex ] = 0;
					}
				}
			}
			else
			{
				// this node is hidden....see if we should unhide it

				if( ( timenow - hiddentimearray[ nodeindex ] ) > ( respawntimearray[ nodeindex ] * 1000 ) )
				{
					hiddenarray[ nodeindex ] = 0;
					
					model Show();				
				}
			}
		}

		wait 0.5;
	}


	//radius = 50.0;
	//respawntime = 5.0;
	//weaponname = "claymore_mp";
	//weaponmodelname = "weapon_claymore";	
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
//	Function:	main()
//	Purpose:	To handle level initialization
//	Author:		Eric Milota
//	Returns:	None
main()
{
	maps\mp\mp_nx_blank1_precache::main();
	maps\createart\mp_nx_blank1_art::main();
	maps\mp\mp_nx_blank1_fx::main();
	
	maps\mp\_load::main();
	
	maps\mp\_gce::gce_setup();
	maps\mp\_doorbreach::doorbreach_setup( 0, 1 );	// 0=start with no doors/walls, 1=start with doors/walls, -1=default (no doors, yes walls)
	maps\mp\_pushobject::pushobject_setup();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_nx_blank1" );

	game["attackers"] = "allies";
	game["defenders"] = "axis";
	
	//----------------------------------------------------------------------------------------------------
	// EXTRA GOODIES....
	level.killstreakswitcharray = [];
	
	// These killstreaks come from "c:\trees\iw4\game\share\raw\maps\mp\killstreaks\killstreakTable.csv"
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "uav";						
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "helicopter";					
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "ac130";						
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "predator_missile";			
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "helicopter_minigun";			
	/////////////////////////////////level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "nuke";		// works!
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "precision_airstrike";		
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "counter_uav";				
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "sentry";						
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "airdrop";					
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "airdrop_sentry_minigun";		
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "helicopter_flares";			
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "emp";						
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "airdrop_mega";				
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "stealth_airstrike";			
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "harrier_airstrike";			

	//zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
	//level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "sentry_gl";
	//level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "double_uav";
	//level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "airstrike";
	//level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "airdrop_predator_missile";
	//level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "helicopter_blackbox";
	//level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "helicopter_mk19";	
	//level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "super_airstrike";
	//level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "auto_shotgun";
	//level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "thumper";
	//level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "littlebird_support";
	level.killstreakswitcharray[ level.killstreakswitcharray.size ] = "tank";
	//zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz

	level.killstreakswitcharrayindex = 0;
	
	thread levelutil_switch_thread( "killstreakswitch1", "", "", 80.0, 0.5, ::levelutil_player_touched_switch_callback, undefined );

	thread levelutil_switch_thread( "killstreakswitch_helicopter", "", "", 150.0, 0.5, ::levelutil_player_touched_switch_callback, undefined );
	thread levelutil_switch_thread( "killstreakswitch_harrier_airstrike", "", "", 150.0, 0.5, ::levelutil_player_touched_switch_callback, undefined );
	thread levelutil_switch_thread( "killstreakswitch_atbr", "", "", 150.0, 0.5, ::levelutil_player_touched_switch_callback, undefined );

	thread levelutil_switch_thread( "giftbox_ammo_reload", "", "", 50.0, 0.5, ::levelutil_player_touched_switch_callback, undefined );

	thread levelutil_switch_thread( "free_claymore", "", "", 50.0, 0.5, ::levelutil_player_touched_switch_callback, undefined );

	levelutil_freeweaponspawner_init();
		
	//----------------------------------------------------------------------------------------------------
	
}
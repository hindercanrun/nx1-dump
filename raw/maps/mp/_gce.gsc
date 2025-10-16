//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  _GCE.GSC														**
//                                                                          **
//    Created: 12/10/2010 - Eric Milota                                     **
//                                                                          **
//****************************************************************************

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
gce_setup()
{
	//precacheItem( "knife" );
	//precacheItem( "throwingknife_mp" );
	//precacheItem( "beretta_mp" );

	//level._playerspawnweaponoverridecallback = ::gce_on_player_spawn;
	level._gceradius = 40.0;
	level._gceeffectduration = (60 * 1000);
	level._gcewaittostartamount = (15 * 1000);
	
	level._gceshow = false;
	level._gceeffect = false;
	level._gcetimestamp = GetTime();	// now!
	level._gcedebugmessagetimestamp = GetTime();	// now!
	level._gcedevices = [];
	
	entarray = GetEntArray( "gcedevice", "targetname" );
	if( IsDefined( entarray[0] ) )
	{
		// we've got some devices!
		level._gcedevices = entarray;

		gce_hide_all_gce_devices();
		
		level thread onPlayerConnect();

		thread gce_pump();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		player thread onPlayerSpawned();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );
		
		if( level._gceeffect )
		{
			gce_setup_player( self );
			
			//setExpFog( 6858.57, 37959.6, 0.627451, 0.717647, 0.745098, 0.38927, 0, 0.839216, 0.690196, 0.568627, (0.00390755, 0.00323934, -1), 83.5416, 92.7872, 2.25266 );
			VisionSetNaked( "end_game", 0 );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
gce_drawcircles()
{
	for( i = 0; i < level._gcedevices.size; i++ )
	{
		ent = level._gcedevices[ i ];
		x = ent.origin[0];
		y = ent.origin[1];
		z = ent.origin[2];
		radius = level._gceradius;
		
		radius2 = radius * 0.707;
		Print3d( ( x + radius, y, z ),		      "'",  (1,0,0), 1, 1, 10 );	// 0
		Print3d( ( x + radius2, y + radius2, z ), "'",  (1,0,0), 1, 1, 10 );	// 45
		Print3d( ( x, y + radius, z ),			  "'",  (1,0,0), 1, 1, 10 );	// 90
		Print3d( ( x - radius2, y + radius2, z ), "'",  (1,0,0), 1, 1, 10 );	// 135
		Print3d( ( x - radius, y, z ),		      "'",  (1,0,0), 1, 1, 10 );	// 180
		Print3d( ( x - radius2, y - radius2, z ), "'",  (1,0,0), 1, 1, 10 );	// 225
		Print3d( ( x, y - radius, z ),			  "'",  (1,0,0), 1, 1, 10 );	// 270
		Print3d( ( x + radius2, y - radius2, z ), "'",  (1,0,0), 1, 1, 10 );	// 315
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
gce_hide_all_gce_devices()
{
	level._gceshow = false;
	for( x = 0; x < level._gcedevices.size; x++ )
	{
		ent = level._gcedevices[ x ];	
		ent hide();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
gce_show_all_gce_devices()
{
	level._gceshow = true;
	for( x = 0; x < level._gcedevices.size; x++ )
	{
		ent = level._gcedevices[ x ];	
		ent show();
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
gce_pump()
{
	while( 1 )
	{
		//gce_drawcircles();
		
		if( level._gceeffect )
		{
			gce_effect_pump();		
			wait 1.0;
		}
		else if( level._gceshow )
		{
			if( gce_player_touching_gce_device() )
			{
				gce_effect_start();			
			}
			else
			{
				wait 0.25;
			}
		}
		else
		{
			if( GetTime() > ( level._gcetimestamp + level._gcewaittostartamount ) )
			{
				gce_show_all_gce_devices();
				level._gcetimestamp = GetTime();	// now!
			}
			else
			{
				wait 0.25;
			}
		}	
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
gce_player_touching_gce_device()
{
	if( level._gceshow )
	{
		playerlist = GetEntArray( "player", "classname" );	
		if( IsDefined( playerlist[0] ) )
		{
			for( x = 0; x < playerlist.size; x++ )
			{
				playerentity = playerlist[ x ];
				
				for( y = 0; y < level._gcedevices.size; y++ )
				{
					gcedevice = level._gcedevices[ y ];
					
					dist = distance( playerentity.origin, gcedevice.origin );
					if ( dist <= level._gceradius )
					{
						return true;	// touching!
					}
				}
			}
		}
	}
	
	return false;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
gce_effect_start()
{
	iPrintLnBold( "GCE EFFECT STARTED!!!" );
	
	gce_hide_all_gce_devices();

	level._gceeffect = true;
	level._gcetimestamp = GetTime();	// now!
	level._gcedebugmessagetimestamp = GetTime();	// now!

	playerlist = GetEntArray( "player", "classname" );	
	if( IsDefined( playerlist[0] ) )
	{
		for( x = 0; x < playerlist.size; x++ )
		{
			playerentity = playerlist[ x ];
			
			gce_setup_player( playerentity );
		}
	}

	//setExpFog( 6858.57, 37959.6, 0.627451, 0.717647, 0.745098, 0.38927, 0, 0.839216, 0.690196, 0.568627, (0.00390755, 0.00323934, -1), 83.5416, 92.7872, 2.25266 );
	VisionSetNaked( "end_game", 2 );
	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
gce_effect_stop()
{
	iPrintLnBold( "GCE EFFECT DONE!!!" );
	level._gceeffect = false;
	level._gcetimestamp = GetTime();	// now!

	//setExpFog( 6858.57, 37959.6, 0.627451, 0.717647, 0.745098, 0.38927, 0, 0.839216, 0.690196, 0.568627, (0.00390755, 0.00323934, -1), 83.5416, 92.7872, 2.25266 );
	VisionSetNaked( "mp_nx_sandstorm", 8 );

	playerlist = GetEntArray( "player", "classname" );	
	if( IsDefined( playerlist[0] ) )
	{
		for( x = 0; x < playerlist.size; x++ )
		{
			playerentity = playerlist[ x ];

			//playerentity maps\mp\killstreaks\_killstreaks::giveKillstreak( "airdrop_ammo" );
			playerentity maps\mp\killstreaks\_killstreaks::giveKillstreak( "airdrop_mega" );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
gce_effect_pump()
{
	time = GetTime();
	if( time > ( level._gcedebugmessagetimestamp + 500 ) )
	{
		numsecondsleft = ( ( level._gcetimestamp + level._gceeffectduration ) - time ) / 1000;
		if( numsecondsleft >= 0 )
		{
			iPrintLnBold( "GCE EFFECT (" + numsecondsleft + ")" );
		}
		level._gcedebugmessagetimestamp = GetTime();	// now!
	}

	if( time > ( level._gcetimestamp + level._gceeffectduration ) )
	{
		gce_effect_stop();		
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//gce_on_player_spawn(player)
//{
//	if( level._gceeffect )
//	{
//		gce_setup_player( player );
//		
//		//setExpFog( 6858.57, 37959.6, 0.627451, 0.717647, 0.745098, 0.38927, 0, 0.839216, 0.690196, 0.568627, (0.00390755, 0.00323934, -1), 83.5416, 92.7872, 2.25266 );
//		VisionSetNaked( "end_game", 0 );
//	}
//}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
gce_setup_player(player)
{
	player takeAllWeapons();

	//player giveWeapon( "knife" );
	//player giveWeapon( "throwingknife_mp" );
	player giveWeapon( "beretta_mp" );
	player giveWeapon( "frag_grenade_mp" );
	
	//player SetOffhandPrimaryClass( weaponname );

	//player SwitchToWeapon( "knife" );
	//player SwitchToWeapon( "throwingknife_mp" );
	player SwitchToWeapon( "beretta_mp" );
}

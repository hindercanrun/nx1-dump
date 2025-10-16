//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  _pushobject.gsc												**
//                                                                          **
//    Created: 11/21/2011 - Eric Milota                                      **
//                                                                          **
//****************************************************************************

#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

//****************************************************************************
// How to add push object tech to your levels.
//
// (1) Add "rawfile,maps/mp/_pushobject.gsc" to your level CSV file.
// (2) Add the following to your level main() function:
//		maps\mp\_pushobject::pushobject_setup();
// (3) Drop down one or more push object prefab throughout your level.
//     Once example is "\\DEPOT\TREES\NX1\GAME\MAP_SOURCE\PREFABS\MP\PUSHOBJECT_CAR1.MAP"
//
// Compile your map and build and run your level.  That should be it!
//
// --------------------------------------------------------------------
// Known bugs/issues:
//         
// * Timings are currently hard coded.  See pushobject_setup() for info.
//         
// --------------------------------------------------------------------
// What's in those prefabs?
//         
// Push object prefabs:
//
//		* Script origin with "targetname" equal to "pushobjectorigin".
//		  This object should be at the center of your push object.
//		* Script brush with "targetname" equal to "pushobjectmodel".
//		  This object should be a model of your object that you want to push.
//		* Script model with "targetname" equal to "pushobjectnogo".
//		  This object should be the brush that will give your model some collision.
//		* Script origin with "targetname" equal to "pushobjecttriggerfront".
//		  This object will be the place where players must stand to push your push object (forward).
//		* Script origin with "targetname" equal to "pushobjectnodefront".
//		  This object is where pushing on the "pushobjecttriggerfront" will eventually
//        make it go.
//		* Script origin with "targetname" equal to "pushobjecttriggerback".
//		  This object will be the place where players must stand to push your push object (backward).
//		* Script origin with "targetname" equal to "pushobjectnodeback".
//		  This object is where pushing on the "pushobjecttriggerback" will eventually
//        make it go.
//
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_setup()
{
	originarray = GetEntArray( "pushobjectorigin", "targetname" );
	if( !IsDefined( originarray[0] ) )
	{
		return;	// no push object origin objects, therefore there is nothing to do
	}

	level._pushobject_origins								= [];	// let's default to empty list

	level._pushobject_distance_max							= 1000.0;	// 1000.0 / 12.0 = 83.2 feet
	level._pushobject_disable_trigger_distance				= 12.0;		// 12.0 = 1 foot.  If object less than this distance from their target node, disable this trigger
	level._pushobject_amount_to_move_per_frame_start		= 1.0;
	level._pushobject_amount_to_move_per_frame_increment	= 1.0;
	level._pushobject_accelerate_counter_max						= 2;		// only increment every OTHER frame... (cause apparently incrementing by anything < 1.0 causes shutters)
	level._pushobject_amount_to_move_per_frame_max			= 3.0;		// 3.0 = 3"/serverframe, or 3*20=60"/sec or 5 feet/sec
	level._pushobject_decelerate_num_frames					= 4.0;
	level._pushobject_decelerate_scale						= 0.2;

	level._pushobject_origins							= originarray;
	
	modelarray			= GetEntArray( "pushobjectmodel",		 "targetname" );
	nogoarray			= GetEntArray( "pushobjectnogo",		 "targetname" );
	triggerfrontarray	= GetEntArray( "pushobjecttriggerfront", "targetname" );
	nodefrontarray		= GetEntArray( "pushobjectnodefront",	 "targetname" );
	triggerbackarray	= GetEntArray( "pushobjecttriggerback",  "targetname" );
	nodebackarray		= GetEntArray( "pushobjectnodeback",	 "targetname" );

	level._pushobject_text_press_and_hold_to_push	= &"MP_PUSHOBJECT_PRESS_AND_HOLD_TO_PUSH";	// "Press and hold ^3 &&1 ^7to push
	level._pushobject_text_pushing0					= &"MP_PUSHOBJECT_PUSHING0";				// "Pushing"
	level._pushobject_text_pushing1					= &"MP_PUSHOBJECT_PUSHING1";				// "Pushing."
	level._pushobject_text_pushing2					= &"MP_PUSHOBJECT_PUSHING2";				// "Pushing.."
	level._pushobject_text_pushing3					= &"MP_PUSHOBJECT_PUSHING3";				// "Pushing..."

	precacheString( level._pushobject_text_press_and_hold_to_push );	// &"MP_PUSHOBJECT_PRESS_AND_HOLD_TO_PUSH"	// "Press and hold ^3 &&1 ^7to push
	precacheString( level._pushobject_text_pushing0 );					// &"MP_PUSHOBJECT_PUSHING0"				// "Pushing"
	precacheString( level._pushobject_text_pushing1 );					// &"MP_PUSHOBJECT_PUSHING1"				// "Pushing."
	precacheString( level._pushobject_text_pushing2 );					// &"MP_PUSHOBJECT_PUSHING2"				// "Pushing.."
	precacheString( level._pushobject_text_pushing3 );					// &"MP_PUSHOBJECT_PUSHING3"				// "Pushing..."

	for( i = 0; i < level._pushobject_origins.size; i++ )
	{
		originobject = level._pushobject_origins[ i ];
		
		// find models
		modelobject = pushobject_find_best_object( modelarray, originobject );
		if( IsDefined( modelobject ) )
		{
			modelarray = pushobject_remove_object_from_list( modelarray, modelobject );
		}
		nogoobject = pushobject_find_best_object( nogoarray, originobject );
		if( IsDefined( nogoobject ) )
		{
			nogoarray = pushobject_remove_object_from_list( nogoarray, nogoobject );
		}
		triggerfrontobject = pushobject_find_best_object( triggerfrontarray, originobject );
		if( IsDefined( triggerfrontobject ) )
		{
			triggerfrontarray = pushobject_remove_object_from_list( triggerfrontarray, triggerfrontobject );
		}
		nodefrontobject = pushobject_find_best_object( nodefrontarray, originobject );
		if( IsDefined( nodefrontobject ) )
		{
			nodefrontarray = pushobject_remove_object_from_list( nodefrontarray, nodefrontobject );
		}
		triggerbackobject = pushobject_find_best_object( triggerbackarray, originobject );
		if( IsDefined( triggerbackobject ) )
		{
			triggerbackarray = pushobject_remove_object_from_list( triggerbackarray, triggerbackobject );
		}	
		nodebackobject = pushobject_find_best_object( nodebackarray, originobject );
		if( IsDefined( nodebackobject ) )
		{
			nodebackarray = pushobject_remove_object_from_list( nodebackarray, nodebackobject );
		}	
		
		// start this guy
		originobject thread pushobject_MainThread( originobject, modelobject, nogoobject, triggerfrontobject, nodefrontobject, triggerbackobject, nodebackobject );
	}
	
	// start!
	level thread onPlayerConnect();
	//thread pushobject_DebugPump();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_find_best_object( list, node )
{
	if( !IsDefined( node ) )
	{
		return undefined;
	}
	if( !IsDefined( list[0] ) )
	{
		return undefined;
	}
	
	best_dist = -1;
	best_item = undefined;
	
	for( x = 0; x < list.size; x++ )
	{
		item = list[ x ];	
		if( IsDefined( item ) )
		{
			dist = distance( node.origin, item.origin );
			if( dist <= level._pushobject_distance_max )
			{
				if( !IsDefined( best_item ) )
				{
					best_item = item;
					best_dist = dist;
				}
				else if ( dist < best_dist )
				{
					best_item = item;
					best_dist = dist;
				}
			}
		}
	}
	
	return best_item;
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_remove_object_from_list( list, node )
{
	if( !IsDefined( node ) )
	{
		return list;
	}
	if( !IsDefined( list[0] ) )
	{
		return list;
	}
	
	best_dist = -1;
	best_item = undefined;
	
	newlist = [];
	found = false;
	
	for( x = 0; x < list.size; x++ )
	{
		item = list[ x ];	
		if( IsDefined( item ) )
		{
			if( item == node )
			{
				// found match!
				found = true;
			}
			else
			{
				newlist[ newlist.size ] = item;
			}		
		}
	}
	
	if( !found )
	{
		return list;	// item not in list
	}
	
	return newlist;
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
		pushobject_setup_player( self );		
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_setup_player( player )
{
	for( i = 0; i < level._pushobject_origins.size; i++ )
	{
		originobject = level._pushobject_origins[ i ];

		if( IsDefined( originobject._pushobject_triggerfrontobject ) )
		{
			triggerobject = originobject._pushobject_triggerfrontobject;					
			//triggerobject disablePlayerUse( player );
			triggerobject enablePlayerUse( player );
		}
		if( IsDefined( originobject._pushobject_triggerbackobject ) )
		{
			triggerobject = originobject._pushobject_triggerbackobject;					
			//triggerobject disablePlayerUse( player );
			triggerobject enablePlayerUse( player );
		}
		//originobject disablePlayerUse( player );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_draw_circle( radius )
{
	x = self.origin[0];
	y = self.origin[1];
	z = self.origin[2];
	
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



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_draw_circles( radius )
{
	for( i = 0; i < level._pushobject_origins.size; i++ )
	{
		originobject = level._pushobject_origins[ i ];	
		originobject pushobject_draw_circle( radius );
	
		//if( IsDefined( originobject._pushobject_triggerfrontobject ) )
		//{
		//	originobject._pushobject_triggerfrontobject pushobject_draw_circle( radius * 0.5 );	
		//}
		//if( IsDefined( originobject._pushobject_triggerbackobject ) )
		//{
		//	originobject._pushobject_triggerbackobject pushobject_draw_circle( radius * 0.5 );					//
		//}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_gameHasStarted()
{
	if ( level._teamBased )
	{
		return( level._hasSpawned[ "axis" ] || level._hasSpawned[ "allies" ] );
	}
	else
	{
		return( level._maxPlayerCount > 0 );
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_gameHasEnded()
{
	return level._gameEnded;
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_DebugPump()
{
	showing = false;
	timestarted = GetTime();
	
	while( 1 )
	{
		timenow = GetTime();
		if( ( pushobject_gameHasStarted() ) && ( !pushobject_gameHasEnded() ) )
		{
			if( showing )
			{
				pushobject_draw_circles( 25.0 );
				if( timenow > ( timestarted + ( 1.0 * 1000 ) ) )
				{
					showing = false;
					timestarted = timenow;			
				}
			}
			else
			{
				if( timenow > ( timestarted + ( 0.5 * 1000 ) ) )
				{
					showing = true;
					timestarted = timenow;				
				}
			}
		}
	
		wait 0.25;
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_TriggerEnableForAllPlayers()
{
	playerlist = GetEntArray( "player", "classname" );	
	if( IsDefined( playerlist[0] ) )
	{
		foreach ( player in playerlist )
		{
			self enablePlayerUse( player );
		}
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_TriggerDisableForAllPlayers()
{
	playerlist = GetEntArray( "player", "classname" );	
	if( IsDefined( playerlist[0] ) )
	{
		foreach ( player in playerlist )
		{
			self disablePlayerUse( player );
		}
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_ActionNotPushable()
{
	if( IsDefined( self._pushobject_triggerfrontobject ) )
	{
		triggerobject = self._pushobject_triggerfrontobject;
		triggerobject makeUnusable();
		triggerobject pushobject_TriggerDisableForAllPlayers();
		//triggerobject notify( "pushobjectremovetrigger" );
	}
	if( IsDefined( self._pushobject_triggerbackobject ) )
	{
		triggerobject = self._pushobject_triggerbackobject;
		triggerobject makeUnusable();
		triggerobject pushobject_TriggerDisableForAllPlayers();	
		//triggerobject notify( "pushobjectremovetrigger" );
	}	
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_ActionPushable()
{
	if( IsDefined( self._pushobject_triggerfrontobject ) )
	{
		triggerobject = self._pushobject_triggerfrontobject;
		len = Distance( self.origin, self._pushobject_nodebackobject.origin );
		//Print3d( triggerobject.origin, "F=" + len,  (1,0,0), 1, 1, 10 );
		if( len > level._pushobject_disable_trigger_distance )
		{	
			triggerobject SetCursorHint( "HINT_ACTIVATE" );
			triggerobject setHintString( level._pushobject_text_press_and_hold_to_push );	// &"MP_PUSHOBJECT_PRESS_AND_HOLD_TO_PUSH" );	//	"Press and hold ^3 &&1 ^7to push"
			triggerobject makeUsable();
			triggerobject pushobject_TriggerEnableForAllPlayers();
			triggerobject thread pushobject_TriggerThread( self, "pushobject_forward_start", "pushobject_forward_stop" );
		}
		else
		{
			triggerobject makeUnusable();
			triggerobject pushobject_TriggerDisableForAllPlayers();	
			//triggerobject notify( "pushobjectremovetrigger" );
		}
	}

	if( IsDefined( self._pushobject_triggerbackobject ) )
	{
		triggerobject = self._pushobject_triggerbackobject;
		len = Distance( self.origin, self._pushobject_nodefrontobject.origin );
		//Print3d( triggerobject.origin, "B=" + len,  (1,0,0), 1, 1, 10 );
		if( len > level._pushobject_disable_trigger_distance )
		{		
			triggerobject SetCursorHint( "HINT_ACTIVATE" );
			triggerobject setHintString( level._pushobject_text_press_and_hold_to_push );	// &"MP_PUSHOBJECT_PRESS_AND_HOLD_TO_PUSH" //	"Press and hold ^3 &&1 ^7to push"
			triggerobject makeUsable();
			triggerobject pushobject_TriggerEnableForAllPlayers();	
			triggerobject thread pushobject_TriggerThread( self, "pushobject_backward_start", "pushobject_backward_stop" );
		}
		else
		{
			triggerobject makeUnusable();
			triggerobject pushobject_TriggerDisableForAllPlayers();	
			//triggerobject notify( "pushobjectremovetrigger" );
		}
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_DisplayNormal()
{
	// make sure our "triggerfront" and "triggerback" objects are in SHOW() mode, so that triggers will work.

	if( IsDefined( self._pushobject_originobject ) )
	{
		self._pushobject_originobject show();
	}
	if( IsDefined( self._pushobject_modelobject ) )
	{
		self._pushobject_modelobject show();
	}
	if( IsDefined( self._pushobject_nogoobject ) )
	{
		self._pushobject_nogoobject show();
	}
	if( IsDefined( self._pushobject_triggerfrontobject ) )
	{
		self._pushobject_triggerfrontobject Show();
	}
	if( IsDefined( self._pushobject_nodefrontobject ) )
	{
		self._pushobject_nodefrontobject Show();
	}
	if( IsDefined( self._pushobject_triggerbackobject ) )
	{
		self._pushobject_triggerbackobject Show();
	}
	if( IsDefined( self._pushobject_nodebackobject ) )
	{
		self._pushobject_nodebackobject Show();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_GotoState( state )
{
	if( self._pushobject_state == state )
	{
		return;	// we're already in this state!
	}

	// leaving current state
	switch( self._pushobject_state )
	{
		case "not_pushable":
			self pushobject_ActionNotPushable();
			break;
		case "pushable":
			self pushobject_ActionNotPushable();
			break;
		case "pushing":
			self pushobject_ActionNotPushable();
			break;
		default:
			break;
	}

	// enter this state!	
	self._pushobject_state = state;
	
	// entering new state
	switch( self._pushobject_state )
	{
		case "not_pushable":
			self pushobject_ActionNotPushable();
			break;
		case "pushable":
			self pushobject_ActionPushable();
			break;
		case "pushing":
			self pushobject_ActionNotPushable();
			break;
		default:
			self pushobject_GotoState( "not_pushable" );
			break;
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_TriggerThread( originnode, notification1, notification2 )
{
	level endon ( "game_ended" );
	self endon( "pushobjectremovetrigger" );
	
	while ( true )
	{
		self waittill ( "trigger", player );
	
		self pushobject_TriggerManageHold( originnode, notification1, notification2, player );
	}

}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_personalUseBar( object, originnode )
{
	self endon("disconnect");
	
	useBar = createPrimaryProgressBar();
	useBarText = createPrimaryProgressBarText();

	useBarText setText( level._pushobject_text_pushing0 );	// &"MP_PUSHOBJECT_PUSHING0" // "Pushing"
	counter1 = 0;
	counter2 = 0;

	lastRate = -1;
	lastHostMigrationState = isDefined( level._hostMigrationTimer );
	while ( isReallyAlive( self ) && object.inUse && !level._gameEnded )
	{
		if( originnode._pushobject_state != "pushing" )
		{
			break;
		}
		if ( lastRate != object.useRate || lastHostMigrationState != isDefined( level._hostMigrationTimer ) )
		{
			if( object.curProgress > object.useTime)
			{
				object.curProgress = object.useTime;
			}
			
			progress = object.curProgress / object.useTime;
			rate = (1000 / object.useTime) * object.useRate;
			if ( isDefined( level._hostMigrationTimer ) )
			{
				rate = 0;
			}
			
			useBar updateBar( progress, rate );

			useBar hideElem();
			useBarText showElem();
		}	
		lastRate = object.useRate;
		lastHostMigrationState = isDefined( level._hostMigrationTimer );
		wait ( 0.05 );

		counter1++;
		if( counter1 >= 10 )
		{
			counter1 = 0;
			counter2++;
			if( counter2 >= 4 )
			{
				counter2 = 0;
			}

			switch( counter2 )
			{
			case 0:
				useBarText setText( level._pushobject_text_pushing0 );	// &"MP_PUSHOBJECT_PUSHING0" // "Pushing"
				break;
			case 1:
				useBarText setText( level._pushobject_text_pushing1 );	// &"MP_PUSHOBJECT_PUSHING1" // "Pushing."
				break;
			case 2:
				useBarText setText( level._pushobject_text_pushing2 );	// &"MP_PUSHOBJECT_PUSHING2" // "Pushing.."
				break;
			case 3:
				useBarText setText( level._pushobject_text_pushing3 );	// &"MP_PUSHOBJECT_PUSHING3" // "Pushing..."
				break;
			}
		}
	}
	
	useBar destroyElem();
	useBarText destroyElem();
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_TriggerManageHold( originnode, notification1, notification2, player )
{
	level endon ( "game_ended" );
	//self endon( "pushobjectremovetrigger" );
	self endon( "disabled" );

	if( originnode._pushobject_state != "pushable" )
	{
		return;
	}

	if ( !isReallyAlive( player ) )
	{
		return;		
	}
		
	if ( !player isOnGround() )
	{
		return;
	}

	player notify ( "use_hold" );
	
	player playerLinkTo( self );
	player PlayerLinkedOffsetEnable();
//	player clientClaimTrigger( self );
//	player.claimTrigger = self;

	self.curProgress = 1;
	self.inUse = true;
	self.useRate = 1;
	self.useTime = 2;
	
	//originnode notify( notification1 );
	originnode pushobject_GotoState( "pushing" );

	player thread pushobject_personalUseBar( self, originnode );

//	if ( player.a.pose != "crouch" )
//	{
//		player SetStance( "crouch" );
//		//player AllowStand( false );
//		//player AllowProne( false );
//		wait( 0.2 );
//	}

	soundcounter = 0;

	amount_to_move_per_frame = level._pushobject_amount_to_move_per_frame_start;
	if( amount_to_move_per_frame > level._pushobject_amount_to_move_per_frame_max )
	{
		amount_to_move_per_frame = level._pushobject_amount_to_move_per_frame_max;
	}

	accelerate_counter = 0;
	while ( true )
	{
		if( !isReallyAlive( player ) )
		{
			break;
		}
		
//		if( !player isTouching( self ) )
//		{
//			break;
//		}
		if( !player useButtonPressed() )
		{
			break;
		}
		
		if( originnode._pushobject_state != "pushing" )	//pushable" )
		{
			break;
		}
	
		soundcounter = soundcounter - 1;
		if( soundcounter < 0 )
		{
			soundcounter = 10;

			//player PlaySound( "foly_gear_rattle_enemy" );
			//player PlaySound( "step_walk_dirt" );
		}	

		//if ( player MeleeButtonPressed() )
		//{
		//	player iPrintLnBold( "Push!!!!!!!!!!!!!!!!!!" );
		//}

		if( notification1 == "pushobject_forward_start" )
		{
			if( IsDefined( originnode._pushobject_nodebackobject ) )
			{
				done = originnode pushobject_MoveToward( originnode._pushobject_nodebackobject.origin, amount_to_move_per_frame );
				if( done )
				{
					break;
				}
			}
		}
		else
		{
			if( IsDefined( originnode._pushobject_nodefrontobject ) )
			{
				done = originnode pushobject_MoveToward( originnode._pushobject_nodefrontobject.origin, amount_to_move_per_frame );
				if( done )
				{
					break;
				}
			}
		}

		accelerate_counter = accelerate_counter + 1;
		if( accelerate_counter >= level._pushobject_accelerate_counter_max )
		{
			accelerate_counter = 0;
			amount_to_move_per_frame = amount_to_move_per_frame + level._pushobject_amount_to_move_per_frame_increment;
			if( amount_to_move_per_frame > level._pushobject_amount_to_move_per_frame_max )
			{
				amount_to_move_per_frame = level._pushobject_amount_to_move_per_frame_max;
			}
		}

		wait 0.05;
		maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
	}
	
	self.inUse = false;
//	player clientReleaseTrigger( self );
//	player.claimTrigger = undefined;	
	player unlink();

	player notify( "done_using" );
	
	self notify ( "finished_use" );
	
	// done!
	//originnode notify( notification2 );

	originnode pushobject_GotoState( "pushable" );

}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_MoveNode( node, numSecsIn, delta_x, delta_y, delta_z )
{
	node moveto( node.origin + ( delta_x, delta_y, delta_z ), numSecsIn, 0.0, 0.0 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_MoveToward( dest_origin, amount_to_move_per_frame )
{
	len = Distance( self.origin, dest_origin );
	if( len < 1.0 )
	{
		return true;	// we're there already
	}

	scale = 1.0;
	if( len > amount_to_move_per_frame )
	{
		scale = 1.0 * amount_to_move_per_frame / len;
	}

	// if we are 'close' to our target, then exponentially slow our rate down till it won't move
	if( len < ( amount_to_move_per_frame * level._pushobject_decelerate_num_frames ) )
	{
		scale = level._pushobject_decelerate_scale;
	}

	delta_x = ( dest_origin[0] - self.origin[0] ) * scale;
	delta_y = ( dest_origin[1] - self.origin[1] ) * scale;
	delta_z = ( dest_origin[2] - self.origin[2] ) * scale;

	numSecs = 0.05;

	pushobject_MoveNode( self,			 numSecs, delta_x, delta_y, delta_z );
	if( IsDefined( self._pushobject_modelobject ) )
	{
		pushobject_MoveNode( self._pushobject_modelobject,			 numSecs, delta_x, delta_y, delta_z );
	}
	if( IsDefined( self._pushobject_nogoobject ) )
	{
		pushobject_MoveNode( self._pushobject_nogoobject,			 numSecs, delta_x, delta_y, delta_z );
	}
	if( IsDefined( self._pushobject_triggerfrontobject ) )
	{
		pushobject_MoveNode( self._pushobject_triggerfrontobject,	 numSecs, delta_x, delta_y, delta_z );
	}
	//////if( IsDefined( self._pushobject_nodefrontobject ) )
	//////{
	//////	pushobject_MoveNode( self._pushobject_nodefrontobject,	numSecs, delta_x, delta_y, delta_z );
	//////}
	if( IsDefined( self._pushobject_triggerbackobject ) )
	{
		pushobject_MoveNode( self._pushobject_triggerbackobject,	 numSecs, delta_x, delta_y, delta_z );
	}
	//////if( IsDefined( self._pushobject_nodebackobject ) )
	//////{
	//////	pushobject_MoveNode( self._pushobject_nodebackobject,	 numSecs, delta_x, delta_y, delta_z );
	//////}

	//wait numSecs;

	return false;
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pushobject_MainThread( originobject, modelobject, nogoobject, triggerfrontobject, nodefrontobject, triggerbackobject, nodebackobject )
{
	// init
	self._pushobject_originobject			= originobject;
	self._pushobject_modelobject			= modelobject;
	self._pushobject_nogoobject				= nogoobject;
	self._pushobject_triggerfrontobject		= triggerfrontobject;
	self._pushobject_nodefrontobject		= nodefrontobject;
	self._pushobject_triggerbackobject		= triggerbackobject;
	self._pushobject_nodebackobject			= nodebackobject;

	self pushobject_DisplayNormal();

	self._pushobject_state = "";			// none right now

	// start as pushable
	self pushobject_GotoState( "pushable" );
	
//	while( 1 )
//	{
//		switch( self._pushobject_state )
//		{
//			case "not_pushable":
//				break;
//
//			case "pushable":
//				msg = self waittill_any_return( "pushobject_forward_start", "pushobject_backward_start" );
//				self pushobject_GotoState( "pushing" );			
//				break;
//
//			case "pushing":
//				msg = self waittill_any_return( "pushobject_forward_stop", "pushobject_backward_stop" );
//				self pushobject_GotoState( "pushable" );			
//				break;
//
//			default:
//				self pushobject_GotoState( "pushable" );
//				break;
//		}
//	}
}

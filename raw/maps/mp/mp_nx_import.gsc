//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************

//#include maps\_utility;
//#include common_scripts\utility;
//#include maps\_anim;
//#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
main()
{
	// External Initialization
	maps\mp_nx_import_precache::main();
	//maps\mp_nx_import_anim::main();
	maps\mp_nx_import_fx::main();
	maps\_load::main();

	// Internal Initialization
	mission_flag_inits();
	mission_precache();
}
*/

HOOK_HEALTH = 150;
CONTAINER_MODEL = "nxcargocontainer_20ft_green";

main()
{
	maps\mp\mp_nx_import_precache::main();
	maps\createart\mp_nx_import_art::main();
	maps\mp\mp_nx_import_fx::main();

	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap("compass_map_mp_nx_import");

	ambientPlay( "ambient_mp_default" );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";

	//tagJC<NOTE>: Addition to handle the explodable hook.
	precacheModel( CONTAINER_MODEL );
	level._dropContainer = getEntArray( "drop_container_collision", "targetname" );
	level._containerCollision = getEnt( level._dropContainer[0].target, "targetname" );
	droppable_container();
}

droppable_container()
{
	level._breakables_fx["hook"]["explode"] 	= loadfx ("props/barrelExp");
	level._breakables_fx["hook"]["burn"]	 	= loadfx ("fire/tank_fire_engine");

	level._hookExpSound = "explo_metal_rand";

	level._hookExplodingThisFrame = false;

	//tagJC<NOTE>: Currently, this implementation is limited to this level specifically.  The following hook-containers relationship
	//             is hard-coded in Radiant.  In the future, if such functionality is desirable in other maps, a more universal
	//             pairing method (such as based on proximity) can be implemented then.
	//tagJC<NOTE>: hook1 is the hook with the yellow container mover.  It hangs two containers.
	//hook1 = getEnt ( "explodable_hook_1","targetname" );
	//hook1.connectedContainers = getEntArray ( "drop_container_1", "targetname" );
	//addCollisionAroundContainers ( hook1.connectedContainers );
	//hook1 thread explodable_hook_think();

	//tagJC<NOTE>: hook2 is the hook with the red container mover.  It hangs one container.
	//hook2 = getEnt ( "explodable_hook_2","targetname" );
	//hook2.connectedContainers = getEntArray ( "drop_container_2", "targetname" );
	//addCollisionAroundContainers ( hook2.connectedContainers );
	//hook2 thread explodable_hook_think();

	//tagJC<NOTE>: hook3 is the hook with the blue container mover.  It hangs two containers.
	//hook3 = getEnt ( "explodable_hook_3","targetname" );
	//hook3.connectedContainers = getEntArray ( "drop_container_3", "targetname" );
	//addCollisionAroundContainers ( hook3.connectedContainers );
	//hook3 thread explodable_hook_think();

	//tagJC<NOTE>: hook4 is the hook in the middle of the map.  It hangs one container.
	//hook4 = getEnt ( "explodable_hook_4","targetname" );
	//hook4.connectedContainers = getEntArray ( "drop_container_4", "targetname" );
	//addCollisionAroundContainers ( hook4.connectedContainers );
	//hook4 thread explodable_hook_think();
}

explodable_hook_think()
{	
	if (self.classname != "script_model")
		return;

	self endon ("exploding");
	
	self.damageTaken = 0;
	self setcandamage(true);
	for (;;)
	{
		self waittill("damage", amount ,attacker, direction_vec, P, type);
		
		self.damagetype = type;
			
		if (level._hookExplodingThisFrame)
			wait randomfloat(1);
		self.damageTaken += amount;
		//tagJC<NOTE>: The following if statement is true when the hook is damaged for the first time.  In this case, start
		//             the burn thread.
		if (self.damageTaken == amount)
			self thread explodable_hook_burn();
	}
}

explodable_hook_burn()
{
	//tagJC<NOTE>: If the damage type is grenade, grenade splash, or direct impact, the if condition below will not be executed.  
	//             The hook will proceed to explode directly.
	if( self.damagetype != "MOD_GRENADE_SPLASH" && self.damagetype != "MOD_GRENADE" && self.damagetype != "MOD_IMPACT" )
	{
		while (self.damageTaken < HOOK_HEALTH)
		{
			playfx (level._breakables_fx["hook"]["burn"], self.origin + (0, 0, -504));
			wait 1;
		}
	}
	self thread explodable_hook_explode();
}

explodable_hook_explode()
{
	self notify ("exploding");
	self notify ("death");
	
	self playsound (level._hookExpSound);

	//tagJC<NOTE>: Because of the current script model that is used, the origin of the model is at the top tip of the rope.
	//             The -504 offset is hard-coded to play the fx at the correct location (the hook).
	playfx (level._breakables_fx["hook"]["explode"], self.origin + (0, 0, -504)); 
	
	level._hookExplodingThisFrame = true;

	self setCanDamage( false );
	
	wait 0.05;
	level._hookExplodingThisFrame = false;

	dropTheContainer( self ); 
}

dropTheContainer( hook ) 
{
	for ( i = 0; i < hook.connectedContainers.size; i++ )
	{
		dropContainer = [];
		dropContainer = createDropContainer( hook.connectedContainers[i] );
		dropContainer.angles = hook.connectedContainers[i].angles;
		//tagJC<NOTE>: Delete the original static script model and show the new physics model for the container.
		dropContainer show();
		hook.connectedContainers[i] delete();
		//tagJC<NOTE>: Drop the physics container.
		dropContainer PhysicsLaunchServer( (0,0,0), (randomInt(5),randomInt(5),randomInt(5)) );	
	}	
}

createDropContainer( ent )
{
	dropContainer = spawn( "script_model", ent.origin );
	dropContainer setModel( CONTAINER_MODEL );
	dropContainer.inUse = false;
	dropContainer CloneBrushmodelToScriptmodel( level._containerCollision );
	return dropContainer;
}

addCollisionAroundContainers( containers )
{
	for ( i = 0; i < containers.size; i ++ )
	{
		containers[i] CloneBrushmodelToScriptmodel( level._containerCollision );
	}
}

// All mission specific PreCache calls
mission_precache()
{
}

// All mission specific flag_init() calls
mission_flag_inits()
{
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

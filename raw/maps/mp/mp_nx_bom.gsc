//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: DATE - Brittany												**
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
	maps\mp_nx_bom_precache::main();
	//maps\mp_nx_bom_anim::main();
	maps\mp_nx_bom_fx::main();
	maps\_load::main();

	// Internal Initialization
	mission_flag_inits();
	mission_precache();
}
*/

main()
{
	maps\mp\mp_nx_bom_precache::main();
	maps\createart\mp_nx_bom_art::main();
	maps\mp\mp_nx_bom_fx::main();
	maps\mp\_load::main();
	thread move_plat();

	maps\mp\_explosive_barrels::main();

	maps\mp\_compass::setupMiniMap("compass_map_mp_nx_bom");

	ambientPlay( "ambient_mp_oilrig_rumble" );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";

}

// All mission specific PreCache calls
mission_precache()
{
}

// All mission specific flag_init() calls
mission_flag_inits()
{
}

//train moving object
move_plat()
{
    plat =  GetEnt( "blackhawkmove", "targetname" );
        wait 60.0;
        plat movez(2000,3);
		while( 1 )
    { 
        wait 10.0;
        plat movey(-2000,3);
		wait 5.0;
		plat movex(-2000,3);
		wait 15.0;
		plat movey(2000,3);
		wait 10.0;
		plat movex(2000,3);
	}
}



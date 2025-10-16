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
	maps\mp_nx_ugvcontact_precache::main();
	//maps\mp_nx_ugvcontact_anim::main();
	maps\mp_nx_ugvcontact_fx::main();
	maps\_load::main();

	// Internal Initialization
	mission_flag_inits();
	mission_precache();
}
*/

main()
{
	maps\mp\mp_nx_ugvcontact_precache::main();
	maps\createart\mp_nx_ugvcontact_art::main();
	maps\mp\mp_nx_ugvcontact_fx::main();

	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap("compass_map_mp_nx_ugvcontact");

	ambientPlay( "ambient_mp_default" );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";


	if( isDefined( level._mode_escortplus ))
	{
		level._missionScript = ::missionScriptEscort;
		level._missionType = ::missionTypeEscort;
	}
	else if( isDefined( level._mode_convoy ))
	{
		level._missionScript = ::missionScriptConvoy;
		level._missionType = ::missionTypeConvoy;
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
//defines the mission types
missionTypeEscort( objective )
{
	rv = "null";
	switch( objective )
	{
		case 1:
			rv = "escort";
			break; 
		case 2:
			rv = "escort";
			break; 
		case 3:
			rv = "escort";
			break; 
		case 4:
			rv = "null";
			break; 
		case 5:
			rv = "null";
			break; 
		default:
			rv = "null";
			break; 
	}
	return rv;
}

missionScriptEscort( objective )
{
	rv = true;
	switch( objective )
	{
		case 0:
			maps\mp\gametypes\escortplus::objectiveSetText( 1, &"OBJECTIVES_UGV_A_PUSH_GENERIC", &"OBJECTIVES_UGV_D_STOP_GENERIC" );
			maps\mp\gametypes\escortplus::objectiveSetText( 2, &"OBJECTIVES_UGV_A_PUSH_GENERIC", &"OBJECTIVES_UGV_D_STOP_GENERIC" );
			maps\mp\gametypes\escortplus::objectiveSetText( 3, &"OBJECTIVES_UGV_A_PUSH_END", &"OBJECTIVES_UGV_D_STOP_END" );
			break; 
		case 1:
			maps\mp\gametypes\escortplus::objectiveCreateEscortVehicle();
			maps\mp\gametypes\escortplus::objectiveEscortToCheckPoint();
			break; 
		case 2:
			maps\mp\gametypes\escortplus::objectiveEscortToCheckPoint();
			break; 
		case 3:
			maps\mp\gametypes\escortplus::objectiveEscortToCheckPoint();
			break; 
		case 4:
			break; 
		case 5:
			break; 
		default:
			rv = false;
			break; 
	}
	return rv;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//defines the mission types
missionTypeConvoy( objective )
{
	rv = "null";
	switch( objective )
	{
		case 1:
			rv = "escort";
			break; 
		case 2:
			rv = "escort";
			break; 
		case 3:
			rv = "escort";
			break; 
		case 4:
			rv = "null";
			break; 
		case 5:
			rv = "null";
			break; 
		default:
			rv = "null";
			break; 
	}
	return rv;
}

missionScriptConvoy( objective )
{
	rv = true;
	switch( objective )
	{
		case 0:
			maps\mp\gametypes\convoy::objectiveSetText( 1, &"OBJECTIVES_UGV_A_PUSH_GENERIC", &"OBJECTIVES_UGV_D_STOP_GENERIC" );
			maps\mp\gametypes\convoy::objectiveSetText( 2, &"OBJECTIVES_UGV_A_PUSH_GENERIC", &"OBJECTIVES_UGV_D_STOP_GENERIC" );
			maps\mp\gametypes\convoy::objectiveSetText( 3, &"OBJECTIVES_UGV_A_PUSH_END", &"OBJECTIVES_UGV_D_STOP_END" );
			break; 
		case 1:
			maps\mp\gametypes\convoy::objectiveCreateConvoy();
			maps\mp\gametypes\convoy::objectiveEscortToCheckPoint();
			break; 
		case 2:
			maps\mp\gametypes\convoy::objectiveEscortToCheckPoint();
			break; 
		case 3:
			maps\mp\gametypes\convoy::objectiveEscortToCheckPoint();
			break; 
		case 4:
			break; 
		case 5:
			break; 
		default:
			rv = false;
			break; 
	}
	return rv;
}
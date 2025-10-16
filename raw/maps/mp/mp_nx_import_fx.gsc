//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  FX Support													**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************

main()
{
	//ambient fx
	level._effect[ "rain_mp_underpass" ]					= loadfx( "weather/rain_mp_underpass" );
	level._effect[ "pipe_steam_looping" ]					= loadfx( "impacts/pipe_steam_looping" );

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\mp_nx_import_fx::main();

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

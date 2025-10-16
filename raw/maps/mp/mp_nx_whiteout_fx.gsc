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
	level._effect[ "chimney_smoke_small" ]					= loadfx( "smoke/chimney_small" );
	level._effect[ "snow_light" ]		                    = loadfx( "snow/snow_light_mp_subbase" );
	level._effect[ "snow_wind" ]		                    = loadfx( "snow/snow_wind" );
	level._effect[ "snow_blowing" ]                         = loadfx( "snow/snow_blower");
	level._effect[ "snow_spray" ]                           = loadfx( "snow/snow_spray_detail_oriented_large_runner" );
	level._effect[ "snow_clifftop" ]                        = loadfx( "snow/snow_clifftop" );

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\mp_nx_whiteout_fx::main();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

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
	level._effect[ "rain_noise_splashes" ]					= loadfx( "weather/rain_noise_splashes" );
	level._effect[ "rain_splash_lite_64x64" ]				= loadfx( "weather/rain_splash_lite_64x64" );
	level._effect[ "rain_splash_lite_128x128" ]				= loadfx( "weather/rain_splash_lite_128x128" );
	level._effect[ "river_splash_small" ]					= loadfx( "water/river_splash_small" );
	level._effect[ "drips_fast" ]							= loadfx( "misc/drips_fast" );
	level._effect[ "lightning" ]							= loadfx( "weather/lightning_mp_underpass" );
	level._effect[ "lite_rain" ]							= loadfx( "weather/rain_5_lite" );
	level._effect[ "fog_ground_200" ]						= loadfx( "weather/fog_ground_200" );
	level._effect[ "horizon_flash" ]						= loadfx( "weather/horizon_flash_3" );

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\mp_nx_asylum_2_fx::main();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

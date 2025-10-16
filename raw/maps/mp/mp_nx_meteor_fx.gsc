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
	level._effect[ "fog_ground_200" ]						= loadfx( "weather/fog_ground_200" );
	level._effect[ "mist" ]						= loadfx( "weather/mist_hunted_add" );
	level._effect[ "mist2" ]						= loadfx( "weather/mist_icbm" );
	level._effect[ "cloudbank" ]						= loadfx( "weather/cloud_bank" );
	level._effect[ "cloudfiller" ]						= loadfx( "weather/cloud_bank_cloud_filler_gulag" );
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\mp_nx_meteor_fx::main();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

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
	level._effect[ "nx_smoke_tall" ]						= loadfx( "nx/smoke/nx_smoke_plume_tall_01" );
	level._effect[ "drips_fast" ]	 						= loadfx( "misc/drips_fast" );
	level._effect[ "smoke_large" ]	 						= loadfx( "smoke/smoke_large" );

	if ( getdvar( "clientSideEffects" ) != "1" && !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\mp_nx_bom_fx::main();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

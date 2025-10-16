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

	level._effect[ "jet_afterburner_harrier" ]			 	= loadfx( "fire/jet_afterburner_harrier" );

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\mp_nx_lockdown_v2_fx::main();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

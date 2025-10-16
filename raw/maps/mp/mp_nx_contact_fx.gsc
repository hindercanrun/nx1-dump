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

#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\mp_nx_contact_fx::main();

	setDevDvar( "scr_fog_disable", "0" );

	VisionSetNaked( "mp_nx_contact", 0 );

	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 722, 10651, 0.3607843, 0.4705882, 0.6392157, 0.787, 0, 0, 0, 0.8431373, 0.9333333, 0.9686275, 0.2901961, 0.3843137, 0.7411765 );

	//skyfog
	//MUST USE SetDVar instead of SetSavedDvar here!!!
	SetDVar ("r_fog_height_blend", 0.75);
	SetDVar ("r_fog_height_start", 1.3);
	SetDVar ("r_fog_height_end", 1.5);
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

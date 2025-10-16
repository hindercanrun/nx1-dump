main()
{
	level._effect[ "test_effect" ]										 = loadfx( "misc/moth_runner" );
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\mp_nx_blank1_fx::main();
}

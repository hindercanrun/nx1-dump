main()
{
	maps\mp\mp_nx_leg_crash_precache::main();
	maps\mp\mp_nx_leg_crash_fx::main();
	maps\createart\mp_nx_leg_crash_art::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_nx_leg_crash" );

	AmbientPlay( "ambient_mp_crash" );

	game["attackers"] = "axis";
	game["defenders"] = "allies";

	SetDvar( "r_specularcolorscale", "1" );
	SetDvar( "compassmaxrange", "1600" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.10 );
	setdvar( "r_lightGridContrast", 1 );
}


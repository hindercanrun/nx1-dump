main()
{
	maps\mp\mp_nx_leg_over_precache::main();
	maps\mp\mp_nx_leg_over_fx::main();
	maps\createart\mp_nx_leg_over_art::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_nx_leg_over" );

	AmbientPlay( "ambient_mp_overgrown" );

	game["attackers"] = "axis";
	game["defenders"] = "allies";

	SetDvar( "r_specularcolorscale", "1" );
	SetDvar( "compassmaxrange", "2200" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.0 );
	setdvar( "r_lightGridContrast", 1 );
}


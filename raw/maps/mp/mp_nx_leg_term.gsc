
main()
{
	maps\mp\mp_nx_leg_term_precache::main();
	maps\createart\mp_nx_leg_term_art::main();
	maps\mp\mp_nx_leg_term_fx::main();
	maps\mp\_explosive_barrels::main();
	maps\mp\_load::main();
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_nx_leg_term" );
	setdvar( "compassmaxrange", "2000" );
	
	ambientPlay( "ambient_mp_airport" );
	
	VisionSetNaked( "mp_nx_leg_term" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.22 );
	setdvar( "r_lightGridContrast", .6 );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
}


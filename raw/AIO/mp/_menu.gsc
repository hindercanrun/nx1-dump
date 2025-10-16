#include maps\mp\gametypes\_hud;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include AIO\mp\_accessability;
#include AIO\mp\_functions;
#include AIO\mp\_hud;
#include AIO\mp\_hud_utilities;
#include AIO\mp\main;
#include AIO\mp\_xTUL_overflow_fix;
#include AIO\mp\_utilities;

CreateMenu()
{
	if(self isVerified())//Verified Menu
	{
		add_menu(self.AIO["menuName"], undefined, self.AIO["menuName"]);
		
			A="A";
			add_option(self.AIO["menuName"], "Verified Menu", ::submenu, A, "Verified Menu");
				add_menu(A, self.AIO["menuName"], "Verified Menu");
					add_option(A, "God Mode", ::InfiniteHealth, true);
					//add_option(A, "Cinematic Teleport", ::cinematictele);
					//add_option(A, "Selector Teleport", ::ipadteleport);
					add_option(A, "Option 2", ::test);
					add_option(A, "Option 3", ::test);
					add_option(A, "Option 4", ::test);
					add_option(A, "Option 5", ::test);
					add_option(A, "Option 6", ::test);
					add_option(A, "Option 7", ::test);
					//add_option(A, "Debug Exit", ::debugexit);//for testing

			B="B";
			add_option(self.AIO["menuName"], "Killstreaks Menu", ::submenu, B, "Killstreaks Menu");
				add_menu(B, self.AIO["menuName"], "Killstreaks Menu");
//nope	     		add_option(B, "Double UAV", maps\mp\killstreaks\_killstreaks::giveKillstreak, "double_uav");
//probably not		add_option(B, "Sentry Gun", maps\mp\killstreaks\_killstreaks::giveKillstreak, "sentry");
//					add_option(B, "Airstrike", maps\mp\killstreaks\_killstreaks::giveKillstreak, "airstrike");
// fix???? 			add_option(B, "Super Airstrike", maps\mp\killstreaks\_killstreaks::giveKillstreak, "super_airstrike");
// fix???? 			add_option(B, "Predator Missile Airdrop", maps\mp\killstreaks\_killstreaks::giveKillstreak, "airdrop_predator_missile"); 
// fix???? 			add_option(B, "Helicopter Blackbox", maps\mp\killstreaks\_killstreaks::giveKillstreak, "helicopter_blackbox");
// fix???? 			add_option(B, "Helicopter MK19", maps\mp\killstreaks\_killstreaks::giveKillstreak, "helicopter_mk19");
// fix???? 			add_option(B, "Tank", maps\mp\killstreaks\_killstreaks::giveKillstreak, "tank");
// fix???? 			add_option(B, "Spider", maps\mp\killstreaks\_killstreaks::giveKillstreak, "spider");
// fix???? 			add_option(B, "GL Turret", maps\mp\killstreaks\_killstreaks::giveKillstreak, "gl_turret");
					add_option(B, "UAV", maps\mp\killstreaks\_killstreaks::giveKillstreak, "uav");
					add_option(B, "Airdrop", maps\mp\killstreaks\_killstreaks::giveKillstreak, "airdrop");
					add_option(B, "X Weapons drop", maps\mp\killstreaks\_killstreaks::giveKillstreak, "weapdrop");
					add_option(B, "Counter UAV", maps\mp\killstreaks\_killstreaks::giveKillstreak, "counter_uav");
					add_option(B, "Sentry Gun (Airdrop)", maps\mp\killstreaks\_killstreaks::giveKillstreak, "airdrop_sentry_minigun");
					add_option(B, "Predator Missile", maps\mp\killstreaks\_killstreaks::giveKillstreak, "predator_missile");
					add_option(B, "Precision Airstrike", maps\mp\killstreaks\_killstreaks::giveKillstreak, "precision_airstrike");
					add_option(B, "Attack Helicopter", maps\mp\killstreaks\_killstreaks::giveKillstreak, "helicopter");
					add_option(B, "Emergency Airdrop", maps\mp\killstreaks\_killstreaks::giveKillstreak, "airdrop_mega");
					add_option(B, "Pave Low", maps\mp\killstreaks\_killstreaks::giveKillstreak, "helicopter_flares");
					add_option(B, "Stealth Bomber", maps\mp\killstreaks\_killstreaks::giveKillstreak, "stealth_airstrike");
					add_option(B, "Chopper Gunner", maps\mp\killstreaks\_killstreaks::giveKillstreak, "helicopter_minigun");
					add_option(B, "AC130", maps\mp\killstreaks\_killstreaks::giveKillstreak, "ac130");
					add_option(B, "EMP", maps\mp\killstreaks\_killstreaks::giveKillstreak, "emp");
					add_option(B, "Tactical Nuke", maps\mp\killstreaks\_killstreaks::giveKillstreak, "nuke");
					add_option(B, "Ares Suit", maps\mp\killstreaks\_killstreaks::giveKillstreak, "exosuit");
					add_option(B, "ATBR", maps\mp\killstreaks\_killstreaks::giveKillstreak, "atbr");
					add_option(B, "Rods of God", maps\mp\killstreaks\_killstreaks::giveKillstreak, "remote_mortar");
					add_option(B, "Reaper", maps\mp\killstreaks\_killstreaks::giveKillstreak, "reaper");
					add_option(B, "Minigun Turret", maps\mp\killstreaks\_killstreaks::giveKillstreak, "minigun_turret");
					add_option(B, "Laser Strike", maps\mp\killstreaks\_killstreaks::giveKillstreak, "uav_strike");
					add_option(B, "Predator Marker", maps\mp\killstreaks\_killstreaks::giveKillstreak, "predator_marker");
					add_option(B, "Jet", maps\mp\killstreaks\_killstreaks::giveKillstreak, "jet");
					add_option(B, "Blueshell", maps\mp\killstreaks\_killstreaks::giveKillstreak, "blueshell");
					add_option(B, "Night Raven", maps\mp\killstreaks\_killstreaks::giveKillstreak, "lockseekdie");
					add_option(B, "Remote Dog", maps\mp\killstreaks\_killstreaks::giveKillstreak, "remote_dog");
					add_option(B, "Harrier Airstrike", maps\mp\killstreaks\_killstreaks::giveKillstreak, "harrier_airstrike");
					add_option(B, "Minigun Turret", maps\mp\killstreaks\_killstreaks::giveKillstreak, "minigun_turret");

			H="H";
			add_option(self.AIO["menuName"], "Give Weapon", ::submenu, H, "Give Weapon");
				add_menu(H, self.AIO["menuName"], "Give Weapon");
					add_option(H, "Take all weapons", ::takeall);
					foreach ( weaponName in level._weaponList )
					{
						add_option(H, weaponName, ::giveweap, weaponName);
					}
					add_option(H, "briefcase_bomb_mp", ::giveweap, "briefcase_bomb_mp");
					add_option(H, "briefcase_bomb_defuse_mp", ::giveweap, "briefcase_bomb_defuse_mp");
					add_option(H, "uav_strike_projectile_mp", ::giveweap, "uav_strike_projectile_mp");
					add_option(H, "remote_mortar_missile_mp", ::giveweap, "remote_mortar_missile_mp");
					add_option(H, "mortar_remote_mp", ::giveweap, "mortar_remote_mp");
					add_option(H, "miniuav_transition_prop", ::giveweap, "miniuav_transition_prop");
					add_option(H, "mortar_remote_zoom_mp", ::giveweap, "mortar_remote_zoom_mp");
					add_option(H, "lock_seek_die_mp", ::giveweap, "lock_seek_die_mp");
					add_option(H, "LSDGuidedMissile_mp", ::giveweap, "LSDGuidedMissile_mp"); 
					add_option(H, "f50_remote_mp", ::giveweap, "f50_remote_mp");
					add_option(H, "harrier_missile_mp", ::giveweap, "harrier_missile_mp");
					add_option(H, "artillery_mp", ::giveweap, "artillery_mp");
					add_option(H, "stealth_bomb_mp", ::giveweap, "stealth_bomb_mp");
					add_option(H, "portable_radar_mp", ::giveweap, "portable_radar_mp");
					add_option(H, "defaultweapon_mp", ::giveweap, "defaultweapon_mp");
					add_option(H, "grapplinghook_mp", ::giveweap, "grapplinghook_mp"); 
					add_option(H, "flare_mp", ::giveweap, "flare_mp");
					add_option(H, "lightstick_mp", ::giveweap, "lightstick_mp");
					add_option(H, "throwingknife_rhand_mp", ::giveweap, "throwingknife_rhand_mp");
					add_option(H, "scavenger_bag_mp", ::giveweap, "scavenger_bag_mp");
					add_option(H, "frag_grenade_short_mp", ::giveweap, "frag_grenade_short_mp");
					add_option(H, "destructible_car", ::giveweap, "destructible_car");
					add_option(H, "ac130_25mm_mp", ::giveweap, "ac130_25mm_mp");
					add_option(H, "ac130_40mm_mp", ::giveweap, "ac130_40mm_mp");
					add_option(H, "ac130_105mm_mp", ::giveweap, "ac130_105mm_mp");
					add_option(H, "airdrop_mega_marker_mp", ::giveweap, "airdrop_mega_marker_mp");
					add_option(H, "airdrop_sentry_marker_mp", ::giveweap, "airdrop_sentry_marker_mp");
					add_option(H, "barrel_mp", ::giveweap, "barrel_mp");
					add_option(H, "cobra_20mm_mp", ::giveweap, "cobra_20mm_mp");
					add_option(H, "cobra_ffar_mp", ::giveweap, "cobra_ffar_mp");
					add_option(H, "cobra_player_minigun_mp", ::giveweap, "cobra_player_minigun_mp");
					add_option(H, "empcloud_grenade_mp", ::giveweap, "empcloud_grenade_mp");
					add_option(H, "g3_grenadier_abg_mp", ::giveweap, "g3_grenadier_abg_mp");
					add_option(H, "harrier_20mm_mp", ::giveweap, "harrier_20mm_mp");
					add_option(H, "harrier_ffar_mp", ::giveweap, "harrier_ffar_mp");
					add_option(H, "heli_remote_mp", ::giveweap, "heli_remote_mp");
					add_option(H, "killstreak_ac130_mp", ::giveweap, "killstreak_ac130_mp");
					add_option(H, "killstreak_ares_mp", ::giveweap, "killstreak_ares_mp");
					add_option(H, "killstreak_counter_uav_mp", ::giveweap, "killstreak_counter_uav_mp");
					add_option(H, "killstreak_emp_mp", ::giveweap, "killstreak_emp_mp");
					add_option(H, "killstreak_harrier_airstrike_mp", ::giveweap, "killstreak_harrier_airstrike_mp");
					add_option(H, "killstreak_helicopter_flares_mp", ::giveweap, "killstreak_helicopter_flares_mp");
					add_option(H, "killstreak_helicopter_minigun_mp", ::giveweap, "killstreak_helicopter_minigun_mp");
					add_option(H, "killstreak_helicopter_mp", ::giveweap, "killstreak_helicopter_mp");
					add_option(H, "killstreak_nuke_mp", ::giveweap, "killstreak_nuke_mp");
					add_option(H, "killstreak_precision_airstrike_mp", ::giveweap, "killstreak_precision_airstrike_mp");
					add_option(H, "killstreak_predator_marker_mp", ::giveweap, "killstreak_predator_marker_mp");
					add_option(H, "killstreak_predator_missile_mp", ::giveweap, "killstreak_predator_missile_mp");
					add_option(H, "killstreak_reaper_mp", ::giveweap, "killstreak_reaper_mp");
					add_option(H, "killstreak_remote_mortar_mp", ::giveweap, "killstreak_remote_mortar_mp");
					add_option(H, "killstreak_sentry_mp", ::giveweap, "killstreak_sentry_mp");
					add_option(H, "killstreak_stealth_airstrike_mp", ::giveweap, "killstreak_stealth_airstrike_mp");
					add_option(H, "killstreak_tank_mp", ::giveweap, "killstreak_tank_mp");
					add_option(H, "killstreak_uav_mp", ::giveweap, "killstreak_uav_mp");
					add_option(H, "killstreak_uav_strike_mp", ::giveweap, "killstreak_uav_strike_mp");
					add_option(H, "lsdnightravenmissile_mp", ::giveweap, "lsdnightravenmissile_mp");
					add_option(H, "manned_gl_turret_mp", ::giveweap, "manned_gl_turret_mp");
					add_option(H, "manned_minigun_turret_mp", ::giveweap, "manned_minigun_turret_mp");
					add_option(H, "nuke_mp", ::giveweap, "nuke_mp");
					add_option(H, "nx_miniuav_rifle_player_mp", ::giveweap, "nx_miniuav_rifle_player_mp");
					add_option(H, "onemanarmy_mp", ::giveweap, "onemanarmy_mp");
					add_option(H, "pavelow_minigun_mp", ::giveweap, "pavelow_minigun_mp");
					add_option(H, "proto_nx_remote_dog_rifle_play_mp", ::giveweap, "proto_nx_remote_dog_rifle_play_mp");
					add_option(H, "proto_robot_dog_turret_mp", ::giveweap, "proto_robot_dog_turret_mp");
					add_option(H, "remotemissile_projectile_mp", ::giveweap, "remotemissile_projectile_mp");
					add_option(H, "sentry_minigun_mp", ::giveweap, "sentry_minigun_mp");
					add_option(H, "uav_strike_missile_mp", ::giveweap, "uav_strike_missile_mp");
					add_option(H, "uavstrikebinoculars_mp", ::giveweap, "uavstrikebinoculars_mp");
					add_option(H, "ugv_robo_turret_mp", ::giveweap, "ugv_robo_turret_mp");
					add_option(H, "xm25_abg_mp", ::giveweap, "xm25_abg_mp");
					add_option(H, "xm25_auto_mp", ::giveweap, "xm25_auto_mp");
					add_option(H, "xm25_flash_mp", ::giveweap, "xm25_flash_mp");
					add_option(H, "xm25_frag_mp", ::giveweap, "xm25_frag_mp");
					add_option(H, "xm25_smoke_mp", ::giveweap, "xm25_smoke_mp");
					add_option(H, "xm25_stick_mp", ::giveweap, "xm25_stick_mp");
					/*
					*/
					//add_option(H, "", ::giveweap, "");
	
	}
	if(self.status == "Host" || self.status == "Co-Host" || self.status == "Admin" || self.status == "VIP")//VIP Menu
	{
			C="C";
			add_option(self.AIO["menuName"], "VIP Menu", ::submenu, C, "VIP Menu");
				add_menu(C, self.AIO["menuName"], "VIP Menu");
					add_option(C, "Option 1", ::test);
					add_option(C, "Option 2", ::test);
					add_option(C, "Option 3", ::test);
					add_option(C, "Option 4", ::test);
					add_option(C, "Option 5", ::test);
	}
	if(self.status == "Host" || self.status == "Co-Host" || self.status == "Admin")//Admin Menu
	{
			D="D";
			add_option(self.AIO["menuName"], "Admin Menu", ::submenu, D, "Admin Menu");
				add_menu(D, self.AIO["menuName"], "Admin Menu");
					add_option(D, "Option 1", ::test);
					add_option(D, "Option 2", ::test);
					add_option(D, "Option 3", ::test);
					add_option(D, "Option 4", ::test);
	}
	if(self.status == "Host" || self.status == "Co-Host")//Co-Host Menu
	{
			E="E";
			add_option(self.AIO["menuName"], "Bot Menu", ::submenu, E, "Bot Menu");
				add_menu(E, self.AIO["menuName"], "Bot Menu");
					add_option(E, "Spawn 1 Bot", ::initTestClients, 1);
					add_option(E, "Spawn 6 Bots", ::initTestClients, 6);
					add_option(E, "Spawn 3 Bots", ::initTestClients, 3);
					add_option(E, "Spawn 17 Bots", ::initTestClients, 17);
					add_option(E, "Kick All Bots", ::kickAllBots);
					add_option(E, "Bots Attack", ::ToggleAttack);
					add_option(E, "Bots Move", ::ToggleMove);
					add_option(E, "Bots Watch Killcam", ::ToggleKillcam);
					add_option(E, "Bots Crouch", ::ToggleCrouch);
					add_option(E, "Bots Reload", ::ToggleReload);
	}
	if(self isHost())//Host only menu
	{
			F="F";
			add_option(self.AIO["menuName"], "Host Menu", ::submenu, F, "Host Menu");
				add_menu(F, self.AIO["menuName"], "Host Menu");
					add_option(F, "Option 1", ::test);
					add_option(F, "Option 2", ::test);
	}
	/* fuck TS
	if(self.status == "Host" || self.status == "Co-Host")//only co-host has access to the player menu 
	{
			add_option(self.AIO["menuName"], "Client Options", ::submenu, "PlayersMenu", "Client Options");
				add_menu("PlayersMenu", self.AIO["menuName"], "Client Options");
					for (i = 0; i < level._players.size; i++)
						add_menu("pOpt " + i, "PlayersMenu", "");

			G="G";
			add_option(self.AIO["menuName"], "All Clients", ::submenu, G, "All Clients");
				add_menu(G, self.AIO["menuName"], "All Clients");
					add_option(G, "Unverify All", ::changeVerificationAllPlayers, "Unverified");
					add_option(G, "Verify All", ::changeVerificationAllPlayers, "Verified");
	}*/
}

updatePlayersMenu()
{
	self endon("disconnect");
	
	self.menu.menucount["PlayersMenu"] = 0;
	
	if(level._players.size != 1)
	{
		for (i = 0; level._players.size; i++)
		{
			player = level._players[i];
			playerName = getPlayerName(player);
			playersizefixed = level._players.size - 1;
		
        	if(self.menu.curs["PlayersMenu"] > playersizefixed)
        	{
        	    self.menu.scrollerpos["PlayersMenu"] = playersizefixed;
        	    self.menu.curs["PlayersMenu"] = playersizefixed;
        	}
		
			add_option("PlayersMenu", "[" + verificationToColor(player.status) + "^7] " + playerName, ::submenu, "pOpt " + i, "[" + verificationToColor(player.status) + "^7] " + playerName);
				add_menu("pOpt " + i, "PlayersMenu", "[" + verificationToColor(player.status) + "^7] " + playerName);
					add_option("pOpt " + i, "Status", ::submenu, "pOpt " + i + "_3", "[" + verificationToColor(player.status) + "^7] " + playerName);
						add_menu("pOpt " + i + "_3", "pOpt " + i, "[" + verificationToColor(player.status) + "^7] " + playerName);
							add_option("pOpt " + i + "_3", "Unverify", ::changeVerificationMenu, player, "Unverified");
							add_option("pOpt " + i + "_3", "^3Verify", ::changeVerificationMenu, player, "Verified");
							add_option("pOpt " + i + "_3", "^4VIP", ::changeVerificationMenu, player, "VIP");
							add_option("pOpt " + i + "_3", "^1Admin", ::changeVerificationMenu, player, "Admin");
							add_option("pOpt " + i + "_3", "^5Co-Host", ::changeVerificationMenu, player, "Co-Host");
						
			if(!player isHost())//makes it so no one can harm the host
			{
					add_option("pOpt " + i, "Options", ::submenu, "pOpt " + i + "_2", "[" + verificationToColor(player.status) + "^7] " + playerName);
						add_menu("pOpt " + i + "_2", "pOpt " + i, "[" + verificationToColor(player.status) + "^7] " + playerName);
							add_option("pOpt " + i + "_2", "Kill Player", ::killPlayer, player);
			}
		}
	}
	else
	{
		add_option("PlayersMenu", "You are alone in the game.", ::test);
	}
}

add_menu(Menu, prevmenu, menutitle)
{
    self.menu.getmenu[Menu] = Menu;
    self.menu.scrollerpos[Menu] = 0;
    self.menu.curs[Menu] = 0;
    self.menu.menucount[Menu] = 0;
    self.menu.subtitle[Menu] = menutitle;
    self.menu.previousmenu[Menu] = prevmenu;
}

add_option(Menu, Text, Func, arg1, arg2)
{
    Menu = self.menu.getmenu[Menu];
    Num = self.menu.menucount[Menu];
    self.menu.menuopt[Menu][Num] = Text;
    self.menu.menufunc[Menu][Num] = Func;
    self.menu.menuinput[Menu][Num] = arg1;
    self.menu.menuinput1[Menu][Num] = arg2;
    self.menu.menucount[Menu] += 1;
}

_openMenu()
{
	self.recreateOptions = true;
	
	self freezeControls(true);
	self setClientDvar("g_hardcore", "1");
	self setClientDvar("cg_crosshairAlpha","0");
	
	self notify("godmode_off");
	self thread godmode();
	
	self playsoundtoplayer("mouse_click", self);//opening menu sound mp_enemy_obj_captured
	self showHud();//opening menu effects
    
	self thread StoreText(self.CurMenu, self.CurTitle);
	self updateScrollbar();
	
	self.menu.open = true;
	self.recreateOptions = false;
}

_closeMenu()
{
	self freezeControls(false);
	
	//do not remove
	if(!self.InfiniteHealth) 
	{
		self.maxhealth=maps\mp\gametypes\_tweakables::getTweakableValue("player","maxhealth");
		self.health=self.maxhealth;
			
		self notify("godmode_off");
	}
	
	self playsoundtoplayer("mouse_submenu_over", self);//closing menu sound missile_locking
	
	self hideHud();//closing menu effects

	self setClientDvar("g_hardcore","0");
	self setClientDvar("cg_crosshairAlpha","1");
	
	self.menu.open = false;
}

giveMenu()
{
	if(self isVerified())
	{
		if(!self.MenuInit)
		{
			self.MenuInit = true;
			self thread MenuInit();
		}
	}
}

destroyMenu()
{
	self.MenuInit = false;
	self notify("destroyMenu");
	
	self freezeControls(false);
	
	//do not remove
	if(!self.InfiniteHealth) 
	{
		self.maxhealth=maps\mp\gametypes\_tweakables::getTweakableValue("player","maxhealth");
		self.health=self.maxhealth;
			
		self notify("godmode_off");
	}
	
	if(isDefined(self.AIO["options"]))//do not remove this
	{
		for(i = 0; i < self.AIO["options"].size; i++)
			self.AIO["options"][i] destroy();
	}

	self setClientDvar("g_hardcore","0");
	self setClientDvar("cg_crosshairAlpha","1");
	
	self.menu.open = false;
	
	wait 0.01;//do not remove this
	//destroys hud elements
	self.AIO["backgroundouter"] destroyElem();
	self.AIO["background"] destroyElem();
	self.AIO["scrollbar"] destroyElem();
	self.AIO["bartop"] destroyElem();
	self.AIO["barbottom"] destroyElem();
	
	//destroys text elements
	self.AIO["title"] destroy();
	self.AIO["status"] destroy();
}

submenu(input, title)
{	
	if(!self.isOverflowing)
	{
		if(isDefined(self.AIO["options"]))//do not remove this
		{		
			for(i = 0; i < self.AIO["options"].size; i++)
				self.AIO["options"][i] affectElement("alpha", undefined, 0);
		}
		self.AIO["title"] affectElement("alpha", undefined, 0);
	}
	
	if (input == self.AIO["menuName"]) 
		self thread StoreText(input, self.AIO["menuName"]);
	else 
		if (input == "PlayersMenu")
		{
			self updatePlayersMenu();
			self thread StoreText(input, "Client Options");
		}
		else 
			self thread StoreText(input, title);
			
	self.CurMenu = input;
	self.CurTitle = title;
	
	self.menu.scrollerpos[self.CurMenu] = self.menu.curs[self.CurMenu];
	self.menu.curs[input] = self.menu.scrollerpos[input];
	
	if(!self.isOverflowing)
	{
		if(isDefined(self.AIO["options"]))//do not remove this
		{		
			for(i = 0; i < self.AIO["options"].size; i++)
				self.AIO["options"][i] affectElement("alpha", .2, 1);
		}
		self.AIO["title"] affectElement("alpha", .2, 1);
	}
	
	self updateScrollbar();
	self.isOverflowing = false;
}



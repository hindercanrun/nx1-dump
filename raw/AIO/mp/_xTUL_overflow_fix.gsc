#include maps\mp\gametypes\_hud;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include AIO\mp\_accessability;
#include AIO\mp\_functions;
#include AIO\mp\_hud;
#include AIO\mp\_hud_utilities;
#include AIO\mp\main;
#include AIO\mp\_utilities;
#include AIO\mp\_menu;

overflowfix()
{
	level endon("game_ended");
	level endon("host_migration_begin");
	
	level.test = createServerFontString("default", 1);
	level.test setText("xTUL");
	level.test.alpha = 0;

	for(;;)
	{
		level waittill("textset");

		if(level.result >= 370)
		{
			level.test ClearAllTextAfterHudElem();
			level.result = 0;

			foreach(player in level._players)
			{
				if(player.menu.open && player isVerified())
				{
					player.isOverflowing = true;
					player submenu(player.CurMenu, player.CurTitle);
					player.AIO["status"] setSafeText("Status: " + player.status);//make sure to change this if changing self.AIO["status"] in hud.gsc
				}
				
				if(!player.menu.open && player isVerified())//gets called if the menu is closed
					player.AIO["status"] setSafeText("Status: " + player.status);//make sure to change this if changing self.AIO["status"] in hud.gsc
			}
		}
	}
}



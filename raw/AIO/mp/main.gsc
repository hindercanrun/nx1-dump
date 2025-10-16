#include maps\mp\gametypes\_hud;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include AIO\mp\_accessability;
#include AIO\mp\_functions;
#include AIO\mp\_hud;
#include AIO\mp\_hud_utilities;
#include AIO\mp\_xTUL_overflow_fix;
#include AIO\mp\_utilities;
#include AIO\mp\_menu;

initAIO()
{
	level.result = 1;//set to 1 for the overflow fix string
	
	level.firstHostSpawned = false;

	precacheitem("lightstick_mp");
	precacheitem("throwingknife_rhand_mp");
	
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		
		player.MenuInit = false;
		
		if(player isHost())
			player.status = "Host";
		else 
			player.status = "Unverified";
			
		if(player isVerified()) 
			player giveMenu();
			
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	level endon("game_ended");
	
	isFirstSpawn = false;
	
	for(;;)
	{
		self waittill("spawned_player");
		
		if(!level.firstHostSpawned && self.status == "Host")//the first host player that spawns calls on the overflow fix
		{
			thread overflowfix();
			level.firstHostSpawned = true;
		}
		
		self resetBooleans();//resets variable bools

		if(self isVerified())
		{
			self iPrintln("Welcome to "+self.AIO["menuName"]);
			
			if(self.menu.open)//if the menu is open when you spawn
				self freezeControls(true);
		}
		if(!isFirstSpawn)//First official spawn
		{
			if(self isHost())
				self freezeControls(false);

			isFirstSpawn = true;
		}
	}
}

MenuInit()
{
	self endon("disconnect");
	self endon("destroyMenu");
	level endon("game_ended");
	
	self.isOverflowing = false;

	self thread initButtons();
	
	self.menu = spawnstruct();
	self.menu.open = false;
	
	self.AIO = [];
	self.AIO["menuName"] = "NX1 Debug Menu";//Put your menu name here
	
	//Setting the menu position for when it's first open
	self.CurMenu = self.AIO["menuName"];
	self.CurTitle = self.AIO["menuName"];
	
	self StoreHuds();
	self CreateMenu();
	
	for(;;)
	{
		if(self adsbuttonpressed() && self meleebuttonpressed() && !self.menu.open) // self isButtonPressed("+actionslot 1") && !self.menu.open
			self _openMenu();
			
		if(self.menu.open)
		{
			//if (self meleebuttonpressed() || self isButtonPressed("+stance"))
			//	self _closeMenu();
		
			if(self meleebuttonpressed()) // self usebuttonpressed()
			{
				if(isDefined(self.menu.previousmenu[self.CurMenu]))
				{
					self submenu(self.menu.previousmenu[self.CurMenu], self.menu.subtitle[self.menu.previousmenu[self.CurMenu]]);
					self playsoundtoplayer("mouse_submenu_over", self);//back button menu sound
				}
				else 
					self _closeMenu();
					
				wait 0.20;
			}
			if(self adsbuttonpressed())//scrolls up
			{
				self.menu.curs[self.CurMenu]--;
				self updateScrollbar();
				self playsoundtoplayer("mouse_over", self);//scroll sound
				wait 0.124;
			}
			if(self attackbuttonpressed())//scrolls down
			{
				self.menu.curs[self.CurMenu]++;
				self updateScrollbar();
				self playsoundtoplayer("mouse_over", self);//scroll sound
				wait 0.124;
			}
			if(self usebuttonpressed()) // self isButtonPressed("+gostand")
			{
				self thread [[self.menu.menufunc[self.CurMenu][self.menu.curs[self.CurMenu]]]](self.menu.menuinput[self.CurMenu][self.menu.curs[self.CurMenu]], self.menu.menuinput1[self.CurMenu][self.menu.curs[self.CurMenu]]);
				self playsoundtoplayer("mouse_click", self);//select sound
				wait 0.20;
			}
		}
		wait 0.05;
	}
}

initButtons()
{
	self endon("disconnect");
	level endon("game_ended");

	self.buttonAction = strTok("weapnext|+gostand|+actionslot 1|+actionslot 2|+actionslot 3|+actionslot 4|+stance|+breathe_sprint|togglecrouch","|");
	self.buttonPressed = [];
	
	for(i = 0; i < self.buttonAction.size; i++)
	{
		loz = self.buttonAction[i];
		self.buttonPressed[loz] = false;
		self thread monitorButtons(i);
	}
}

monitorButtons(buttonIndex)
{
	self endon("disconnect");
	level endon("game_ended");

	self notifyOnPlayerCommand("action_made_"+self.buttonAction[buttonIndex],self.buttonAction[buttonIndex]);
	for(;;)
	{
		self waittill("action_made_"+self.buttonAction[buttonIndex]);
		loz = self.buttonAction[buttonIndex];
		self.buttonPressed[loz] = true;
		wait 0.05;
		self.buttonPressed[loz] = false;
	}
}

isButtonPressed(actionID)
{
	if(self.buttonPressed[actionID])
	{
		self.buttonPressed[actionID] = false;
		return true;
	}
	return false;
}

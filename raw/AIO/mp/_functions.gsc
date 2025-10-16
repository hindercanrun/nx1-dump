#include maps\mp\gametypes\_hud;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include AIO\mp\_accessability;
#include AIO\mp\_hud;
#include AIO\mp\_hud_utilities;
#include AIO\mp\main;
#include AIO\mp\_xTUL_overflow_fix;
#include AIO\mp\_utilities;
#include AIO\mp\_menu;

InfiniteHealth(print)//DO NOT REMOVE THIS FUNCTION
{
	self.InfiniteHealth = booleanOpposite(self.InfiniteHealth);
	if(print) self iPrintlnBold(booleanReturnVal(self.InfiniteHealth, "God Mode ^1OFF", "God Mode ^2ON"));
	
	if(self.InfiniteHealth)
		self thread godmode();
	else 
		if(!self.menu.open)
		{
			self.maxhealth=maps\mp\gametypes\_tweakables::getTweakableValue("player","maxhealth");
			self.health=self.maxhealth;
				
			self notify("godmode_off");
		}
}

godmode()
{
	self endon("disconnect");
	self endon("godmode_off");
	self endon("death");
	level endon("game_ended");
	
	self.maxhealth = 9000;
	self.health = self.maxhealth;
	
	for(;;)
	{
    	self waittill("damage", damage);
    	self.health += damage;
	}	
}

killPlayer(player)//DO NOT REMOVE THIS FUNCTION
{
	if(player!=self)
	{
		if(isAlive(player))
		{
			if(!player.InfiniteHealth && player.menu.open)
			{	
				self iPrintlnBold(getPlayerName(player) + " ^1Was Killed!");
				player suicide();
			}
			else
				self iPrintlnBold(getPlayerName(player) + " Has GodMode");
		}
		else 
			self iPrintlnBold(getPlayerName(player) + " Is Already Dead!");
	}
	else
		self iprintlnBold("Your protected from yourself");
}

initTestClients(num)
{
	for(i = 0; i < num; i++)
	{
		ent[i] = addtestclient();
		if (!isdefined(ent[i]))
		{
			wait 1;
			continue;
		}
		ent[i].pers["isBot"] = true;
		ent[i] thread initIndividualBot();
		wait .1;
	}
}

takeall()
{
	self takeallweapons();
	self iprintlnbold("Took all weapons from you");
}

cinematicTele()
{
    if(!isDefined(self.cinematicTele))
	{
		self iprintlnbold("Cinematic teleport: ENABLED");
        self.cinematicTele = true;
	}
    else
	{
		self.cinematicTele = undefined;
		self iprintlnbold("Cinematic teleport: DISABLED");
	}
		
}

ipadTeleport( team ) //CanSpawn
{
    self _closeMenu();
    wait .8;
    self beginLocationSelection( "map_artillery_selector", false, 500 );  
    self waittill( "confirm_location", location ); 
    pos = BulletTrace( location + (0,0,1000), location - (0,0,1000), false )[ "position" ] + (0,0,80);
    self endLocationSelection();
    self.selectingLocation = undefined;
    self notify( "stop_location_selection" );
    
    while( true )
    {
        pos = BulletTrace( pos - (0,0,5), pos - (0,0,1000), false )[ "position" ]; 
        self SetOrigin( pos );
        wait .1;
        if( CanSpawn( self.origin ) && self IsOnGround() )
            break;
        wait .05;
    }
    
    wait .2;
    
    if(!isDefined(team)) 
        return self thread advancedTele( pos, self.angles );

}

modelSpawner(origin, model, angles, time, collision)
{
    if(isDefined(time))
        wait time;
    obj = spawn( "script_model", origin );
    obj setModel( model );
    if(isDefined( angles ))
        obj.angles = angles;
    if(isDefined( collision ))
        obj cloneBrushmodelToScriptmodel( collision );
    return obj;
}

advancedTele( end, angle )
{
    if(isDefined( self.teleporting ))
        return self iprintlnbold("^1Error^7: Please wait until you have finished teleporting.");
    if(!isDefined( angle )) angle = self.angles;
    
    if(isDefined(self.cinematicTele))
    {
        self.teleporting = true;
        start            = self.origin;
        angles           = vectorToAngles( end - self geteye() );
        camera           = modelSpawner( start + (0,0,40), "tag_origin", angles );
        
        self freezeControls( true );
        self playerlinkto( camera, "tag_origin" );
        self DisableWeapons();
        
        camera moveTo(start + (0,0,5000), 4, 2, 2);
        camera rotateto(angles + (90,0,0), 3, 1, 1);
        wait 3;
        camera moveTo(end, 4, 2, 2);
        wait 1;
        camera rotateto(angle, 3, 1, 1);
        wait 3;
        
        self freezeControls( false );   
        self EnableWeapons();
        self.teleporting = undefined;   
        camera delete();
    }
    else 
    {
        self setOrigin( end );
        self setPlayerAngles( angle );
    }
}

giveweap( weapon )
{
	if(self hasweapon( weapon ))
	{
		self GiveMaxAmmo(weapon);
		self switchtoweapon(weapon);
		self iprintlnbold("Giving ammo for ^2" + weapon);
	}
	else
	{
		weaplist = self GetWeaponsListAll();

		if(weaplist.size != 15)
		{
			self FreezeControls(false);

			if( issubstr( weapon, "akimbo" ))
				self giveweapon(weapon, 0, 1 );
			else
				self giveweapon(weapon, 0, 0 );

			self givemaxammo(weapon);
			self switchtoweapon(weapon);

			wait 0.1;

			self FreezeControls(true);
			if(self hasweapon(weapon))
				self iprintlnbold("Given ^2" + weapon);
			else
				self iprintlnbold("Unable to give ^1" + weapon);

		}
		else
		{
			self iprintlnbold("^1ERROR: ^7Weapon inventory limit reached");
		}
	}
}

initIndividualBot()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	while(!isdefined(self.pers["team"])) wait .05;
	self notify("menuresponse", game["menu_team"], "autoassign");
	wait .5;
	self notify("menuresponse", "changeclass", "class" + randomInt( 4 ));
}

kickAllBots()
{
	foreach ( player in level._players )
	{
		if ( isDefined ( player.pers [ "isBot" ] ) && player.pers [ "isBot" ] )
		kick ( player getEntityNumber(), "EXE_PLAYERKICKED" );
	}
}

ToggleAttack()
{
	if(getDvar("testClients_doAttack") == "0")
	{
		self iprintlnbold("Bots Attack ^2ON");
		self setClientDvar("testClients_doAttack", "1");
	}
	else
	{
		self iprintlnbold("Bots Attack ^1OFF");
		self setClientDvar("testClients_doAttack", "0");
	}
}

ToggleMove()
{
	if(getDvar("testClients_doMove") == "0")
	{
		self iprintlnbold("Bots Move ^2ON");
		self setClientDvar("testClients_doMove", "1");
	}
	else
	{
		self iprintlnbold("Bots Move ^1OFF");
		self setClientDvar("testClients_doMove", "0");
	}
}

ToggleReload()
{
	if(getDvar("testClients_doReload") == "0")
	{
		self iprintlnbold("Bots Reload ^2ON");
		self setClientDvar("testClients_doReload", "1");
	}
	else
	{
		self iprintlnbold("Bots Reload ^1OFF");
		self setClientDvar("testClients_doReload", "0");
	}
}

ToggleKillcam()
{
	if(getDvar("testClients_watchKillcam") == "0")
	{
		self iprintlnbold("Bots Watch Killcam ^2ON");
		self setClientDvar("testClients_watchKillcam", "1");
	}
	else
	{
		self iprintlnbold("Bots Watch Killcam ^1OFF");
		self setClientDvar("testClients_watchKillcam", "0");
	}
}

ToggleCrouch()
{
	if(getDvar("testClients_doCrouch") == "0")
	{
		self iprintlnbold("Bots Crouch ^2ON");
		self setClientDvar("testClients_doCrouch", "1");
	}
	else
	{
		self iprintlnbold("Bots Crouch ^1OFF");
		self setClientDvar("testClients_doCrouch", "0");
	}
}



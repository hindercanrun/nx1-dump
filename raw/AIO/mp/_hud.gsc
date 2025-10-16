#include maps\mp\gametypes\_hud;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include AIO\mp\_accessability;
#include AIO\mp\_functions;
#include AIO\mp\_hud_utilities;
#include AIO\mp\main;
#include AIO\mp\_xTUL_overflow_fix;
#include AIO\mp\_utilities;
#include AIO\mp\_menu;

StoreHuds()
{
	//HUD Elements
	self.AIO["background"] = createRectangle("LEFT", "CENTER", -380, 0, 0, 240, (0, 0, 0), "white", 1, 0);
	self.AIO["backgroundouter"] = createRectangle("LEFT", "CENTER", -380, 0, 0, 243, (0, 0, 0), "white", 1, 0);
	self.AIO["scrollbar"] = createRectangle("CENTER", "CENTER", -379, -75, 2, 0, (0, 0.43, 1), "white", 2, 0);
	self.AIO["bartop"] = createRectangle("CENTER", "CENTER", -300, .2, 160, 30, (0, 0.43, 1), "white", 3, 0);
	self.AIO["barbottom"] = createRectangle("CENTER", "CENTER", -300, .2, 160, 30, (0, 0.43, 1), "white", 3, 0);
	
	//Text Elements
	self.AIO["title"] = drawText("", "default", 1.6, "LEFT", "CENTER", -376, -105, (1,1,1), 0, 5);
	self.AIO["status"] = drawText("Status: " + self.status, "default", 1.6, "LEFT", "CENTER", -376, 105, (1,1,1), 0, 5);
}

StoreText(menu, title)
{
	self.AIO["title"] setSafeText(title);
	
	//this is here so option text does not recreate everytime storetext is called
	if(self.recreateOptions)
		for(x = 0; x < 7; x++)
		self.AIO["options"][x] = drawText("", "default", 1.1, "LEFT", "CENTER", -376, -75+(x*25), (1,1,1), 0, 5);
	else
		for(i = 0; i < 7; i++)
		self.AIO["options"][i] setSafeText(self.menu.menuopt[menu][i]);
}

showHud()//opening menu effects
{
	self endon("destroyMenu");

	self.AIO["bartop"] affectElement("alpha", undefined, .9);
    self.AIO["barbottom"] affectElement("alpha", undefined, .9);
    self.AIO["bartop"] affectElement("y", .25, -105);
    self.AIO["barbottom"] affectElement("y", .25, 105);
    wait .25;
    self.AIO["background"] affectElement("alpha", .2, .5);
    self.AIO["backgroundouter"] affectElement("alpha", .2, .5);
    self.AIO["background"] scaleOverTime(.5, 160, 240);
    self.AIO["backgroundouter"] scaleOverTime(.3, 163, 243);
    wait .25;
    self.AIO["scrollbar"] affectElement("alpha", .2, .9);
    self.AIO["scrollbar"] scaleOverTime(.5, 2, 27);
    self.AIO["title"] affectElement("alpha", .2, 1);
    self.AIO["status"] affectElement("alpha", .2, 1);
}

hideHud()//closing menu effects
{
	self endon("destroyMenu");
	
	self.AIO["title"] affectElement("alpha", undefined, 0);
	self.AIO["status"] affectElement("alpha", undefined, 0);
	
	if(isDefined(self.AIO["options"]))//do not remove this
	{		
		for(i = 0; i < self.AIO["options"].size; i++)
			self.AIO["options"][i] destroy();
	}
	
	self.AIO["backgroundouter"] affectElement("alpha", undefined, 0);
   	self.AIO["background"] affectElement("alpha", undefined, 0);
	self.AIO["scrollbar"] affectElement("alpha", undefined, 0);
	self.AIO["bartop"] affectElement("alpha", undefined, 0);
    self.AIO["barbottom"] affectElement("alpha", undefined, 0);
	
	self.AIO["scrollbar"] setShader("white", 2, 0);///////////
	self.AIO["backgroundouter"] setShader("white", 1, 243);////////Re-creating the shader, width and height
	self.AIO["background"] setShader("white", 1, 240);///////
   	self.AIO["barbottom"] affectElement("y", undefined, .2);
    self.AIO["bartop"] affectElement("y", undefined, .2);
}

updateScrollbar()//infinite scrolling
{
	if(self.menu.curs[self.CurMenu]<0)
		self.menu.curs[self.CurMenu] = self.menu.menuopt[self.CurMenu].size-1;
		
	if(self.menu.curs[self.CurMenu]>self.menu.menuopt[self.CurMenu].size-1)
		self.menu.curs[self.CurMenu] = 0;
		
	if(!isDefined(self.menu.menuopt[self.CurMenu][self.menu.curs[self.CurMenu]-3])||self.menu.menuopt[self.CurMenu].size<=7)
	{
    	for(i = 0; i < 7; i++)
    	{
	    	if(isDefined(self.menu.menuopt[self.CurMenu][i]))
				self.AIO["options"][i] setSafeText(self.menu.menuopt[self.CurMenu][i]);
			else
				self.AIO["options"][i] setSafeText("");
					
			if(self.menu.curs[self.CurMenu] == i)
         		self.AIO["options"][i] affectElement("alpha", .2, 1);//current menu option alpha is 1
         	else
          		self.AIO["options"][i] affectElement("alpha", .2, .3);//every other option besides the current option 
		}
		self.AIO["scrollbar"].y = -75 + (25*self.menu.curs[self.CurMenu]);//when the y value is being changed to move HUDs, make sure to change -75
	}
	else
	{
	    if(isDefined(self.menu.menuopt[self.CurMenu][self.menu.curs[self.CurMenu]+3]))
	    {
			xePixTvx = 0;
			for(i=self.menu.curs[self.CurMenu]-3;i<self.menu.curs[self.CurMenu]+4;i++)
			{
			    if(isDefined(self.menu.menuopt[self.CurMenu][i]))
					self.AIO["options"][xePixTvx] setSafeText(self.menu.menuopt[self.CurMenu][i]);
				else
					self.AIO["options"][xePixTvx] setSafeText("");
					
				if(self.menu.curs[self.CurMenu]==i)
					self.AIO["options"][xePixTvx] affectElement("alpha", .2, 1);//current menu option alpha is 1
         		else
          			self.AIO["options"][xePixTvx] affectElement("alpha", .2, .3);//every other option besides the current option 
               		
				xePixTvx ++;
			}           
			self.AIO["scrollbar"].y = -75 + (25*3);//when the y value is being changed to move HUDs, make sure to change -75
		}
		else
		{
			for(i = 0; i < 7; i++)
			{
				self.AIO["options"][i] setSafeText(self.menu.menuopt[self.CurMenu][self.menu.menuopt[self.CurMenu].size+(i-7)]);
				
				if(self.menu.curs[self.CurMenu]==self.menu.menuopt[self.CurMenu].size+(i-7))
             		self.AIO["options"][i] affectElement("alpha", .2, 1);//current menu option alpha is 1
         		else
          			self.AIO["options"][i] affectElement("alpha", .2, .3);//every other option besides the current option 
			}
			self.AIO["scrollbar"].y = -75 + (25*((self.menu.curs[self.CurMenu]-self.menu.menuopt[self.CurMenu].size)+7));//when the y value is being changed to move HUDs, make sure to change -75
		}
	}
}



#include maps\mp\gametypes\_hud;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include AIO\mp\_accessability;
#include AIO\mp\_functions;
#include AIO\mp\_hud;
#include AIO\mp\main;
#include AIO\mp\_xTUL_overflow_fix;
#include AIO\mp\_utilities;
#include AIO\mp\_menu;

drawText(text, font, fontScale, align, relative, x, y, color, alpha, sort)
{
	hud = self createFontString(font, fontScale);
	hud setPoint(align, relative, x, y);
	hud.color = color;
	hud.alpha = alpha;
	hud.hideWhenInMenu = true;
	hud.sort = sort;
	hud.foreground = true;
	hud setSafeText(text);
	return hud;
}

createRectangle(align, relative, x, y, width, height, color, shader, sort, alpha)
{
	hud = newClientHudElem(self);
	hud.elemType = "icon";
	hud.children = [];
	hud.sort = sort;
	hud.color = color;
	hud.alpha = alpha;
	hud.hideWhenInMenu = true;
	hud.foreground = true;
	if(isdefined(level._uiParent))
		hud setParent(level._uiParent);

	hud setShader(shader, width, height);
	hud setPoint(align, relative, x, y);
	return hud;
}

affectElement(type, time, value)
{
	if(isdefined(time))
	{
		if(type == "x" || type == "y")
        	self moveOverTime(time);
    	else
        	self fadeOverTime(time);
	}
 
    if(type == "x")
        self.x = value;
    if(type == "y")
        self.y = value;
    if(type == "alpha")
        self.alpha = value;
    if(type == "color")
        self.color = value;
}

setSafeText(text)
{
	level.result += 1;
	level notify("textset");
	self setText(text);
}



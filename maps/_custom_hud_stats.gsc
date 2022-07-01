#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

hud_trade_header()
{
	level endon("end_game");
	self endon("disconnect");
	self endon("end_game");

	hud_wait();
	level.tradehud_position = 75;

	level.trade_header = NewHudElem();
	level.trade_header.horzAlign = "center";
	level.trade_header.vertAlign = "middle";
	level.trade_header.alignX = "center";
	level.trade_header.alignY = "middle";
	level.trade_header.y = level.tradehud_position;
	level.trade_header.x = 0;
	level.trade_header.fontScale = 1.4;
	level.trade_header.alpha = 0;

	level.trade_header.color = (1, 1, 1);
	level.trade_header setText("TRADES");

	self thread hud_trade_weapons1();
	self thread hud_trade_weapons2();
	self thread hud_trade_weapons3();
	self thread hud_trade_weapons4();
	self thread hud_trade_boxhits();
	self thread hud_trade_average();
	if (level.script != "zombie_cod5_prototype")
		self thread hud_current_box();
	self thread hud_setup_boxhits();

	while(true)
	{
		if (!getDvarInt("hud_tab") || ((level.script == "zombie_pentagon") && !getDvarInt("trades_include_all")))
			hud_fade(level.trade_header, 0, 0.125);	
		else
			hud_fade(level.trade_header, 1, 0.125);

		wait 0.05;
	}
}

hud_trade_weapons1()
{
	level endon("end_game");
	self endon("disconnect");
	self endon("end_game");

	hud_wait();

	self.trade_weapon1 = NewHudElem();
	self.trade_weapon1.horzAlign = "center";
	self.trade_weapon1.vertAlign = "middle";
	self.trade_weapon1.alignX = "right";
	self.trade_weapon1.alignY = "middle";
	self.trade_weapon1.y = level.tradehud_position + 30;
	self.trade_weapon1.x = -40;
	self.trade_weapon1.fontScale = 1.2;
	self.trade_weapon1.alpha = 0;
	self.trade_weapon1.label = hud_trades_label_handler(1);
	self.trade_weapon1.color = (1, 1, 1);

	while(true)
	{
		if (!getDvarInt("hud_tab") || (hud_traces_pulls_handler(1) == -1))
			hud_fade(self.trade_weapon1, 0, 0.125);	
		else if (getDvarInt("hud_tab"))
		{
			self.trade_weapon1 setValue(hud_traces_pulls_handler(1));
			hud_fade(self.trade_weapon1, 1, 0.125);
		}

		wait 0.05;
	}
}

hud_trade_weapons2()
{
	level endon("end_game");
	self endon("disconnect");
	self endon("end_game");

	hud_wait();

	self.trade_weapon2 = NewHudElem();
	self.trade_weapon2.horzAlign = "center";
	self.trade_weapon2.vertAlign = "middle";
	self.trade_weapon2.alignX = "right";
	self.trade_weapon2.alignY = "middle";
	self.trade_weapon2.y = level.tradehud_position + 50;
	self.trade_weapon2.x = -40;
	self.trade_weapon2.fontScale = 1.2;
	self.trade_weapon2.alpha = 0;
	self.trade_weapon2.label = hud_trades_label_handler(2);
	self.trade_weapon2.color = (1, 1, 1);

	while(true)
	{
		if (!getDvarInt("hud_tab") || (hud_traces_pulls_handler(2) == -1))
			hud_fade(self.trade_weapon2, 0, 0.125);	
		else if (getDvarInt("hud_tab"))
		{
			self.trade_weapon2 setValue(hud_traces_pulls_handler(2));
			hud_fade(self.trade_weapon2, 1, 0.125);
		}

		wait 0.05;
	}
}

hud_trade_weapons3()
{
	level endon("end_game");
	self endon("disconnect");
	self endon("end_game");

	hud_wait();
	
	self.trade_weapon3 = NewHudElem();
	self.trade_weapon3.horzAlign = "center";
	self.trade_weapon3.vertAlign = "middle";
	self.trade_weapon3.alignX = "right";
	self.trade_weapon3.alignY = "middle";
	self.trade_weapon3.y = level.tradehud_position + 70;
	self.trade_weapon3.x = -40;
	self.trade_weapon3.fontScale = 1.2;
	self.trade_weapon3.alpha = 0;
	self.trade_weapon3.label = hud_trades_label_handler(3);
	self.trade_weapon3.color = (1, 1, 1);

	while(true)
	{
		if (!getDvarInt("hud_tab") || (hud_traces_pulls_handler(3) == -1))
			hud_fade(self.trade_weapon3, 0, 0.125);	
		else if (getDvarInt("hud_tab"))
		{
			self.trade_weapon3 setValue(hud_traces_pulls_handler(3));
			hud_fade(self.trade_weapon3, 1, 0.125);
		}

		wait 0.05;
	}
}

hud_trade_weapons4()
{
	level endon("end_game");
	self endon("disconnect");
	self endon("end_game");

	hud_wait();
	
	self.trade_weapon4 = NewHudElem();
	self.trade_weapon4.horzAlign = "center";
	self.trade_weapon4.vertAlign = "middle";
	self.trade_weapon4.alignX = "right";
	self.trade_weapon4.alignY = "middle";
	self.trade_weapon4.y = level.tradehud_position + 90;
	self.trade_weapon4.x = -40;
	self.trade_weapon4.fontScale = 1.2;
	self.trade_weapon4.alpha = 0;
	self.trade_weapon4.label = hud_trades_label_handler(4);
	self.trade_weapon4.color = (1, 1, 1);

	while(true)
	{
		if (!getDvarInt("hud_tab") || (hud_traces_pulls_handler(4) == -1))
			hud_fade(self.trade_weapon4, 0, 0.125);	
		else if (getDvarInt("hud_tab"))
		{
			self.trade_weapon4 setValue(hud_traces_pulls_handler(4));
			hud_fade(self.trade_weapon4, 1, 0.125);
		}

		wait 0.05;
	}
}

hud_trade_boxhits()
{
	level endon("end_game");
	self endon("disconnect");
	self endon("end_game");

	hud_wait();
	
	self.trade_boxhits = NewHudElem();
	self.trade_boxhits.horzAlign = "center";
	self.trade_boxhits.vertAlign = "middle";
	self.trade_boxhits.alignX = "left";
	self.trade_boxhits.alignY = "middle";
	self.trade_boxhits.y = level.tradehud_position + 30;
	self.trade_boxhits.x = 40;
	self.trade_boxhits.fontScale = 1.2;
	self.trade_boxhits.alpha = 0;
	self.trade_boxhits.label = "Box Hits: ";
	self.trade_boxhits.color = (1, 1, 1);

	while(true)
	{		
		if (!getDvarInt("hud_tab"))
			hud_fade(self.trade_boxhits, 0, 0.125);	
		else
		{
			self.trade_boxhits setValue(level.boxhits);
			hud_fade(self.trade_boxhits, 1, 0.125);
		}

		wait 0.05;
	}
}

hud_trade_average()
{
	level endon("end_game");
	self endon("disconnect");
	self endon("end_game");

	hud_wait();
	
	self.trade_ww_average = NewHudElem();
	self.trade_ww_average.horzAlign = "center";
	self.trade_ww_average.vertAlign = "middle";
	self.trade_ww_average.alignX = "left";
	self.trade_ww_average.alignY = "middle";
	self.trade_ww_average.y = level.tradehud_position + 50;
	self.trade_ww_average.x = 40;
	self.trade_ww_average.fontScale = 1.2;
	self.trade_ww_average.alpha = 0;
	self.trade_ww_average.label = "Trade AVG: ";
	self.trade_ww_average.color = (1, 1, 1);

	while(true)
	{
		if (!getDvarInt("hud_tab"))
			hud_fade(self.trade_ww_average, 0, 0.125);	
		else
		{
			self.trade_ww_average setValue(level.trade_average);
			hud_fade(self.trade_ww_average, 1, 0.125);
		}

		wait 0.05;
	}
}

hud_current_box()
{
	level endon("end_game");
	self endon("disconnect");
	self endon("end_game");

	hud_wait();
	
	self.trade_current_box_location = NewHudElem();
	self.trade_current_box_location.horzAlign = "center";
	self.trade_current_box_location.vertAlign = "middle";
	self.trade_current_box_location.alignX = "left";
	self.trade_current_box_location.alignY = "middle";
	self.trade_current_box_location.y = level.tradehud_position + 70;
	self.trade_current_box_location.x = 40;
	self.trade_current_box_location.fontScale = 1.2;
	self.trade_current_box_location.alpha = 0;
	self.trade_current_box_location.label = "Box Position: ";
	self.trade_current_box_location.color = (1, 1, 1);

	while(true)
	{
		if (!getDvarInt("hud_tab"))
			hud_fade(self.trade_current_box_location, 0, 0.125);	
		else
		{
			hud_fade(self.trade_current_box_location, 1, 0.125);

			// Set current box location
			self.trade_current_box_location setText(box_map());
		}

		wait 0.05;
	}
}

hud_setup_boxhits()
{
	level endon("end_game");
	self endon("disconnect");
	self endon("end_game");

	hud_wait();
	
	self.trade_setup_boxhits = NewHudElem();
	self.trade_setup_boxhits.horzAlign = "center";
	self.trade_setup_boxhits.vertAlign = "middle";
	self.trade_setup_boxhits.alignX = "left";
	self.trade_setup_boxhits.alignY = "middle";
	self.trade_setup_boxhits.y = level.tradehud_position + 90;
	self.trade_setup_boxhits.x = 40;
	self.trade_setup_boxhits.fontScale = 1.2;
	self.trade_setup_boxhits.alpha = 0;
	self.trade_setup_boxhits.label = "Setup Box Hits: ";
	self.trade_setup_boxhits.color = (1, 1, 1);

	while(true)
	{
		if (!getDvarInt("hud_tab"))
			hud_fade(self.trade_setup_boxhits, 0, 0.125);	
		else
		{
			if (flag("setup_completed"))
				self.trade_setup_boxhits setText(level.setup_box_hits);
			else
				self.trade_setup_boxhits setText(level.boxhits);

			hud_fade(self.trade_setup_boxhits, 1, 0.125);
		}

		wait 0.05;
	}
}

hud_trades_label_handler(label)
{
	if (label == 1)
		return "RayGun: ";
	else if (label == 2)
	{
		switch(level.script)
		{
			case "zombie_theater":
			case "zombie_cosmodrome":
			case "zombie_cod5_prototype":
				return "Thunder Gun: ";
			case "zombie_pentagon":
				return "Winter's Howl: ";
			case "zombie_coast":
				return "V-R11: ";
			case "zombie_temple":
				return "Baby Gun: ";
			case "zombie_moon":
				return "Wave Gun: ";
			case "zombie_cod5_asylum":
			case "zombie_cod5_sumpf":
			case "zombie_cod5_factory":
				return "Wunderwaffe: ";
		}
	}
	else if (label == 3)
	{
		switch(level.script)
		{
			case "zombie_cosmodrome":
			case "zombie_moon":
				return "Gersh Device: ";
			case "zombie_coast":
				return "Scavenger: ";
			case "zombie_cod5_asylum":
				return "Winter's Howl: ";
		}
	}
	else if (label == 4)
	{
		switch(level.script)
		{
			case "zombie_cosmodrome":
				return "Dolls: ";
			case "zombie_moon":
				return "QED: ";
		}
	}
}

hud_traces_pulls_handler(hud_number)
{
	if (hud_number == 1)
		return level.box_raygun;
	else if (hud_number == 2)
	{
		switch(level.script)
		{
			case "zombie_theater":
			case "zombie_cosmodrome":
			case "zombie_cod5_prototype":
				return level.box_thundergun;
			case "zombie_pentagon":
				return level.box_wintershowl;
			case "zombie_coast":
				return level.box_vr;
			case "zombie_temple":
				return level.box_babygun;
			case "zombie_moon":
				return level.box_wavegun;
			case "zombie_cod5_asylum":
			case "zombie_cod5_sumpf":
			case "zombie_cod5_factory":
				return level.box_waffe;
			default:
				return -1;
		}
	}
	else if (hud_number == 3)
	{
		switch(level.script)
		{
			case "zombie_cosmodrome":
			case "zombie_moon":
				return level.box_gersh;
			case "zombie_coast":
				return level.box_scavenger;
			case "zombie_cod5_asylum":
				return level.box_wintershowl;
			default:
				return -1;
		}
	}
	else if (hud_number == 4)
	{
		switch(level.script)
		{
			case "zombie_cosmodrome":
				return level.box_doll;
			case "zombie_moon":
				return level.box_qed;
			default:
				return -1;
		}
	}
}

box_map()
{
	if (level.zombie_vars["zombie_powerup_fire_sale_on"])
		return "FIRE SALE!!!";	

	box_script = "none";
	for (i = 0; i < level.chests.size; i++)
	{
		if (!level.chests[i].hidden)
		{
			box_script = level.chests[i].script_noteworthy;
			break;
		}
	}

	switch(box_script)
	{
		// General
		case "none":
			return "Not set yet";

		// Kino + FIVE
		case "start_chest":
			if (level.script == "zombie_theater")
				return "VIP Room";
			else if (level.script == "zombie_pentagon")
				return "Level 3 - Morgue";

		// Kino + Ascension
		case "foyer_chest":
			if (level.script == "zombie_theater")
				return "Spawn kino";
			else if (level.script == "zombie_cosmodrome")
				return "Power";

		// Kino + COTD
		case "dining_chest":
			if (level.script == "zombie_theater")
				return "Dining Room";
			else if (level.script == "zombie_coast")
				return "Ship";

		// Kino + Moon
		case "dressing_chest":
			if (level.script == "zombie_theater")
				return "Dressing Room";
			else if (level.script == "zombie_moon")
				return "Power";

		// Kino + Verruckt
		case "stage_chest":
			if (level.script == "zombie_theater")
				return "Stage";	
			else if (level.script == "zombie_cod5_asylum")
				return "Power";	

		// Kino + Shino	
		case "theater_chest":
			if (level.script == "zombie_theater")
				return "Theater";
			else if (level.script == "zombie_cod5_sumpf")
				return "Center Building Downstairs";

		// Kino + Der Riese
		case "control_chest":
			if (level.script == "zombie_theater")
				return "Control Room";
			else if (level.script == "zombie_cod5_factory")
				return "Power";

		// Ascension + Der Riese
		case "chest2":
			if (level.script == "zombie_cosmodrome")
				return "Spawn";
			else if (level.script == "zombie_cod5_factory")
				return "Teleport B (Type100)";
		case "chest5":
			if (level.script == "zombie_cosmodrome")
				return "Catwalk Lander";
			else if (level.script == "zombie_cod5_factory")
				return "Garage";
		case "chest1":
			if (level.script == "zombie_cosmodrome")
				return "Mule Kick";
			else if (level.script == "zombie_cod5_factory")
				return "Teleport A (MP40)";

		// Shang + Moon
		case "bridge_chest":
			if (level.script == "zombie_temple")
				return "Waterfall";		
			else if (level.script == "zombie_moon")
				return "Spawn moon";		

		// Kino
		case "alleyway_chest":
			return "Alley";
		case "crematorium_chest":
			return "Fire Room";

		// FIVE
		case "level1_chest2":
			return "Level 1 - Quick Revive";
		case "level1_chest":
			return "Level 1 - Hallway";
		case "level2_chest":
			return "Level 2 - War Room";
		case "start_chest2":
			return "Level 3 - Pig";
		case "start_chest3":
			return "Level 3 - Weapon Testing";

		// Ascension
		case "storage_area_chest":
			return "Stamin-Up";
		case "warehouse_lander_chest":
			return "Warehouse Lander";
		case "base_entry_chest":
			return "PHD Lander";
		case "chest6":
			return "Rocket";

		// Call of the Dead
		case "beach_chest":
			return "Spawn cotd";
		case "residence_chest":
			return "Lighthouse - Front";
		case "lighthouse_chest":
			return "Lighthouse - Catwalk";
		case "lagoon_chest":
			return "Lighthouse - Stamin-Up";
		case "shiphouse_chest":
			return "Power";

		// ShangriLa
		case "blender_chest":
			return "Spawn shang";
		case "caves1_chest":
			return "Cave";
		case "power_chest":
			return "Power";
		
		// Moon
		case "forest_chest":
			return "Biodome";
		case "tower_east_chest":
			return "Outside";
		
		// Verruckt
		case "opened_chest":
			return "Spawn verr";
		case "magic_box_bathroom":
			return "Balcony";
		case "magic_box_south":
			return "Showers";
		case "magic_box_hallway":
			return "Thompson";
		
		// Shi No Numa
		case "attic_chest":
			return "Center Building Upstairs";
		case "ne_chest":
			return "Doctor's Quarters";
		case "se_chest":
			return "Storage";
		case "sw_chest":
			return "Comm Room";
		
		// Der Riese
		case "chest4":
			return "Hallway";

		default:
			return box_script;
	}
}
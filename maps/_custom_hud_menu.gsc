#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

// WTF
send_message_to_csc(name, message)
{
	csc_message = name + ":" + message;

	if(isdefined(self) && IsPlayer(self))
		setClientSysState("client_systems", csc_message, self);
	else
	{
		players = get_players();

		for(i = 0; i < players.size; i++)
		{
			setClientSysState("client_systems", csc_message, players[i]);
		}
	}
}

hud_color_watcher()
{
	raw_color = "";
	while (true)
	{
		wait 0.05;
		if (raw_color != getDvar("cg_ScoresColor_Gamertag_0"))
		{
			raw_color = getDvar("cg_ScoresColor_Gamertag_0");
			color = strTok(raw_color, " ");
			SetDvar("hud_color_r", color[0]);
			SetDvar("hud_color_g", color[1]);
			SetDvar("hud_color_b", color[2]);
		}
	}
}

zone_hud()
{
	self endon("disconnect");

	current_name = " ";

	while(1)
	{
		wait_network_frame();

		name = choose_zone_name(self get_current_zone(), current_name);

		if(current_name == name)
		{
			continue;
		}

		current_name = name;

		self send_message_to_csc("hud_anim_handler", "hud_zone_name_out");
		wait .25;
		self SetClientDvar("hud_zone_name", name);
		self send_message_to_csc("hud_anim_handler", "hud_zone_name_in");
	}
}

choose_zone_name(zone, current_name)
{
	if(self.sessionstate == "spectator")
	{
		zone = undefined;
	}

	if(IsDefined(zone))
	{
		if(level.script == "zombie_pentagon")
		{
			if(zone == "labs_elevator")
			{
				zone = "war_room_zone_elevator";
			}
		}
		else if(level.script == "zombie_cosmodrome")
		{
			if(IsDefined(self.lander) && self.lander)
			{
				zone = undefined;
			}
		}
		else if(level.script == "zombie_coast")
		{
			if(IsDefined(self.is_ziplining) && self.is_ziplining)
			{
				zone = undefined;
			}
		}
		else if(level.script == "zombie_temple")
		{
			if(zone == "waterfall_tunnel_a_zone")
			{
				zone = "waterfall_tunnel_zone";
			}
		}
		else if(level.script == "zombie_moon")
		{
			if(IsSubStr(zone, "airlock"))
			{
				return current_name;
			}
		}
	}

	name = " ";

	if(IsDefined(zone))
	{
		name = "reimagined_" + level.script + "_" + zone;
	}

	return name;
}

remaining_hud()
// level thread
{
	level endon("disconnect");
	level endon("end_game");

	setDvar("hud_remaining_number", 0);
	while(true)
	{
		wait 0.05;
		tracked_zombies = level.zombie_total + get_enemy_count();
		if (tracked_zombies == GetDvarInt("hud_remaining_number"))
			continue;

		setDvar("hud_remaining_number", tracked_zombies);
	}
}

health_bar_hud()
// player thread
{
	health_bar_width_max = 110;

	while (1)
	{
		health_ratio = self.health / self.maxhealth;

		// There is a conflict while trying to import _laststand
		if (isDefined(self.revivetrigger) || (isDefined(level.intermission) && level.intermission))
			self SetClientDvar("health_bar_value_hud", 0);
		else
			self SetClientDvar("health_bar_value_hud", self.health);

		self SetClientDvar("health_bar_width_hud", health_bar_width_max * health_ratio);

		wait 0.05;
	}
} 
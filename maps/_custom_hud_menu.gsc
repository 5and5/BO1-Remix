#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init_hud_dvars()
// They hold values for menu files, not used for triggering HUD elements
{
	players = get_players();
	for(i = 0; i < players.size; i++)
	{
		players[i] setClientDvar("time_summary_text", " ");
		players[i] setClientDvar("time_summary_value", 0);
		players[i] setClientDvar("show_time_summary", 0);
		players[i] setClientDvar("hud_remaining_number", 0);
		players[i] setClientDvar("hud_drops_number", 0);
		players[i] setClientDvar("round_time_value", "0");
		players[i] setClientDvar("total_time_value", "0");
		players[i] setClientDvar("predicted_value", "0");
		players[i] setClientDvar("sph_value", 0);
		players[i] setClientDvar("oxygen_time_value", "0");
		players[i] setClientDvar("oxygen_time_show", 0);
		players[i] setClientDvar("excavator_name", "null");
		players[i] setClientDvar("excavator_time_value", 0);
		players[i] setClientDvar("excavator_time_show", 0);
		players[i] setClientDvar("hud_kills_value", 0);
		players[i] setClientDvar("george_bar_show", 0);
		players[i] setClientDvar("george_bar_ratio", 0);
		players[i] setClientDvar("george_bar_health", 0);
	}
	if(level.script == "zombie_moon")
		setDvar("show_nml_kill_tracker", 1);
	else
		setDvar("show_nml_kill_tracker", 0);

	setDvar("rt_displayed", 0);

}

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

set_summary_text( text, dvar )
{
	self setClientDvar("time_summary_text", text);
	self setClientDvar("time_summary_value", getDvar(dvar) );
}

hud_menu_fade( name, time )
{
	self send_message_to_csc("hud_anim_handler", name);
	wait time;
}

display_time_summary()
{
	level endon("end_of_round");
	level endon("end_game");

	wait_time = 5;
	fade_time = 0.75;

	self setClientDvar("show_time_summary", 1);	// Prevents bugs with fast restart
	wait 0.15; 	// Prevents the timer from sliding between positions

	self set_summary_text("@HUD_HUD_ZOMBIES_ROUNDTIME", "round_time_value");
	self hud_menu_fade("hud_time_summary_in", fade_time);
	wait wait_time;

	if ((level.round_number >= 50) && (level.round_number != level.last_special_round + 1))
	{
		self hud_menu_fade("hud_time_summary_out", fade_time);
		self set_summary_text("@HUD_HUD_ZOMBIES_SPH", "sph_value");
		self hud_menu_fade("hud_time_summary_in", fade_time);
		wait wait_time;
		self hud_menu_fade("hud_time_summary_out", fade_time);
	}
	else
	{
		wait wait_time + (2 * fade_time);
		self hud_menu_fade("hud_time_summary_out", fade_time);
	}

	self set_summary_text("@HUD_HUD_ZOMBIES_TOTALTIME", "total_time_value");
	self hud_menu_fade("hud_time_summary_in", fade_time);
	wait wait_time;
	self hud_menu_fade("hud_time_summary_out", fade_time);

	// if (level.round_number != level.last_special_round)
	// {
	// 	set_summary_text("@HUD_HUD_ZOMBIES_PREDICTED", "predicted_value");
	// 	hud_menu_fade("hud_time_summary_in", fade_time);
	// 	wait wait_time;
	// 	hud_menu_fade("hud_time_summary_out", fade_time);
	// }
	self setClientDvar("show_time_summary", 0);
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

health_bar_hud()
{
	self endon("disconnect");
	self endon("end_game");

	health_bar_width_max = 110;

	while (true)
	{
		wait 0.05;

		health_ratio = self.health / self.maxhealth;

		// There is a conflict while trying to import _laststand
		if (isDefined(self.revivetrigger) || (isDefined(level.intermission) && level.intermission))
			self SetClientDvar("health_bar_value_hud", 0);
		else
			self SetClientDvar("health_bar_value_hud", self.health);

		self SetClientDvar("health_bar_width_hud", health_bar_width_max * health_ratio);
	}
} 

remaining_hud()
{
	self endon("disconnect");
	level endon("end_game");

	dvar_state = -1;
	tab_state = -1;

	while (true)
	{
		if (getDvarInt("show_nml_kill_tracker"))
		{
			wait 0.5;
			self send_message_to_csc("hud_anim_handler", "hud_remaining_out");

			while (getDvarInt("show_nml_kill_tracker"))
				wait 0.05;
			dvar_state = -1;		// Reset this to make sure it won't get stuck
		}

		wait 0.05;
		// Level var for round timer
		level.tracked_zombies = level.zombie_total + get_enemy_count();

		self setClientDvar("hud_remaining_number", level.tracked_zombies);

		if (dvar_state == getDvarInt("hud_remaining") && tab_state == getDvarInt("hud_tab"))
			continue;

		if (getDvarInt("hud_remaining") || (!getDvarInt("hud_remaining") && getDvarInt("hud_tab")))
			self send_message_to_csc("hud_anim_handler", "hud_remaining_in");
		else
			self send_message_to_csc("hud_anim_handler", "hud_remaining_out");

		dvar_state = getDvarInt("hud_remaining");
		tab_state = getDvarInt("hud_tab");
	}
}

kill_hud()
{
	level endon("disconnect");
	level endon("end_game");

	flag_wait( "all_players_spawned" );

	// Tracker always on while on NML
	setDvar("show_nml_kill_tracker", 1);
	wait 0.5;
	self send_message_to_csc("hud_anim_handler", "hud_kills_in");

	while (true)
	{
		if (isDefined(level.left_nomans_land) && level.left_nomans_land > 0)
			break;

		wait 0.05;
		level.total_nml_kills = 0;

		players = get_players();
		for (i = 0; i < players.size; i++)
			level.total_nml_kills += players[i].kills;

		if (level.total_nml_kills == getDvarInt("hud_kills_value"))
			continue;

		self setClientDvar("hud_kills_value", level.total_nml_kills);
	}
	self send_message_to_csc("hud_anim_handler", "hud_kills_out");
	wait 0.5;
	setDvar("show_nml_kill_tracker", 0);
}

drop_tracker_hud()
{
	self endon("disconnect");
	level endon("end_game");

	dvar_state = -1;
	tab_state = -1;

	while (true)
	{
		wait 0.05;
		if (isDefined(level.drop_tracker_index))
			tracked_drops = level.drop_tracker_index;
		else
			tracked_drops = 0;

		self setClientDvar("hud_drops_number", tracked_drops);

		if (dvar_state == getDvarInt("hud_drops") && tab_state == getDvarInt("hud_tab"))
			continue;

		if (getDvarInt("hud_drops") || (!getDvarInt("hud_drops") && getDvarInt("hud_tab")))
			self send_message_to_csc("hud_anim_handler", "hud_drops_in");
		else
			self send_message_to_csc("hud_anim_handler", "hud_drops_out");

		dvar_state = getDvarInt("hud_drops");
		tab_state = getDvarInt("hud_tab");
	}
}

// level thread
time_summary_hud()
{
	level endon("disconnect");
	level endon("end_game");

	// Settings
	settings_splits = array(30, 50, 70, 100);	// For later

	// Initialize vars
	last_zombie_count = get_zombie_number(1);
	rt_array = array();
	rt = 0;

	// NML handle
	while (!isdefined(level.left_nomans_land) && level.script == "zombie_moon")
		wait 0.05;

	while (true)
	{
		level waittill("start_of_round");

		// NML handle
		if (isdefined(level.on_the_moon) && !level.on_the_moon)
			continue;

		// Pause handle
		if (isdefined(flag("game_paused")))
		{
			round_start_time = int(getTime() / 1000);
			// Calculate total time at the beginning of next round
			gt = round_start_time - level.beginning_timestamp;
			self setClientDvar("total_time_value", to_mins_short(gt));

			if (flag("game_paused"))
			{
				while (flag("game_paused"))
					wait 0.05;

				// Overwrite the variable if coop pause was active
				round_start_time = int(getTime() / 1000);
			}
		}
		else
			continue;

		// Grab zombie count from current round for SPH
		if(flag("dog_round") || flag("thief_round") || flag("monkey_round"))
			current_zombie_count = get_zombie_number(level.round_number - 1);
		else
			current_zombie_count = get_zombie_number();

		// Calculate predicted round time
		if ((level.round_number == level.last_special_round + 1) && (level.round_number > 4))
		{
			rt = rt_array[rt_array.size - 1];
			rt_array = array();		// Reset the array
		}
		predicted = (rt / last_zombie_count) * current_zombie_count;
		self setClientDvar("predicted_value", to_mins_short(int(predicted)));

		level waittill("end_of_round");

		// NML Handle
		if(isDefined(flag("enter_nml")) && flag("enter_nml"))
		{
			level waittill("end_of_round"); //end no man's land
			level waittill("end_of_round"); //end actual round
		}

		// Calculate round time at the end of the round
		round_end_time = int(getTime() / 1000);
		rt = round_end_time - round_start_time;
		rt_array[rt_array.size] = rt;
		self setClientDvar("round_time_value", to_mins_short(rt));

		// Calculate SPH
		sph = rt / (current_zombie_count / 24);
		wait 0.05;
		self setClientDvar("sph_value", sph);
			
		// Save last rounds zombie count
		last_zombie_count = current_zombie_count;
		
		self thread display_time_summary();
	}
}

oxygen_hud()
{
	level endon("end_game");

	self thread oxygen_hud_watcher();

    while (true)
    {
		if (isDefined(self.time_in_low_gravity) && isDefined(self.time_to_death))
		{
			oxygen_time = (self.time_to_death - self.time_in_low_gravity) / 1000;
			oxygen_left = to_mins_short(oxygen_time);
			self setClientDvar("oxygen_time_value", oxygen_left);

			if (getDvarInt("hud_oxygen_timer") || (!getDvarInt("hud_oxygen_timer") && getDvarInt("hud_tab")))
			{
				if(self.time_in_low_gravity > 0 && !self maps\_laststand::player_is_in_laststand() && isAlive(self))
					self setClientDvar("oxygen_time_show", 1);
				else
					self setClientDvar("oxygen_time_show", 0);
			}

			else
				self setClientDvar("oxygen_time_show", 0);
		}
    
        wait 0.5;
    }
}

oxygen_hud_watcher()
{
	dvar_state = -1;
	while (true)
	{
		if (getDvarInt("oxygen_time_show"))
		{
			self send_message_to_csc("hud_anim_handler", "hud_oxygen_in");

			while (getDvarInt("oxygen_time_show"))
				wait 0.05;
		}
		else
		{
			self send_message_to_csc("hud_anim_handler", "hud_oxygen_out");

			while (!getDvarInt("oxygen_time_show"))
				wait 0.05;
		}

		wait 0.05;
	}
}

excavator_hud()
{
	level endon("end_game");

	self thread excavator_hud_watcher();

	current_excavator = "null";
	saved_excavator = "null";
	excavator_area = "null";

    while (true)
    {		
		if (isDefined(level.digger_time_left) && isDefined(level.digger_to_activate))
		{
			// iPrintLn(level.excavator_timer);
			switch (level.digger_to_activate) 
			{
			case "teleporter":
				current_excavator = "Pi";
				// excavator_area = "Tunnel 6";
				break;
			case "hangar":
				current_excavator = "Omicron";
				// excavator_area = "Tunnel 11";
				break;
			case "biodome":
				current_excavator = "Epsilon";
				// excavator_area = "Biodome";
				break;
			default:
				current_excavator = "null";
			}

			if (current_excavator != "null")
			{
				self setClientDvar("excavator_name", current_excavator);

				if (getDvarInt("hud_excavator_timer") || (!getDvarInt("hud_excavator_timer") && getDvarInt("hud_tab")))
				{
					if(level.digger_to_activate != "null")
						self setClientDvar("excavator_time_show", 1);
					else if(level.digger_to_activate == "null")
						self setClientDvar("excavator_time_show", 0);
				}

				else
					self setClientDvar("excavator_time_show", 0);

				self setClientDvar("excavator_time_value", to_mins_short(int(level.digger_time_left)));
			}
			else
			{
				self setClientDvar("excavator_time_show", 0);

				while (current_excavator == "null")
					wait 0.05;
			}
		}
		wait 0.5;
    }
}

excavator_hud_watcher()
{
	dvar_state = -1;
	while (true)
	{
		if (getDvarInt("excavator_time_show"))
		{
			self send_message_to_csc("hud_anim_handler", "hud_excavator_in");

			while (getDvarInt("excavator_time_show"))
				wait 0.05;
		}
		else
		{
			self send_message_to_csc("hud_anim_handler", "hud_excavator_out");

			while (!getDvarInt("excavator_time_show"))
				wait 0.05;
		}

		wait 0.05;
	}
}

george_health_bar()
{
	// self endon("disconnect");
	level endon("end_game");

	level thread maps\_zombiemode_powerups::cotd_powerup_offset();

	level waittill("start_of_round");

	george_max_health = 250000 * level.players_playing;
	george_bar_width_max = 250;	// Make sure it matches with menu file

	while (true)
	{
		wait 0.05;

		// Amount of damage dealt to director, prevent going beyond the scale
		if (isDefined(level.director_damage))
			local_director_damage = level.director_damage;
		else
			local_director_damage = 0;

		if (local_director_damage > george_max_health)
			local_director_damage = george_max_health;

		george_health = george_max_health - local_director_damage;
		george_ratio = (george_health / george_max_health) * george_bar_width_max;

		if (flag("director_alive") && getDvarInt("hud_george_bar"))
		{
			self setClientDvar("george_bar_ratio", george_ratio);
			self setClientDvar("george_bar_health", george_health);
			if(!getDvarInt("george_bar_show"))
			{
				self setClientDvar("george_bar_show", 1);
				self send_message_to_csc("hud_anim_handler", "hud_georgebar_background_in");
				self send_message_to_csc("hud_anim_handler", "hud_georgebar_image_in");
				self send_message_to_csc("hud_anim_handler", "hud_georgebar_value_in");
			}
		}
		else
		{
			if(getDvarInt("george_bar_show"))
			{
				self setClientDvar("george_bar_show", 0);
				self send_message_to_csc("hud_anim_handler", "hud_georgebar_background_out");
				self send_message_to_csc("hud_anim_handler", "hud_georgebar_image_out");
				self send_message_to_csc("hud_anim_handler", "hud_georgebar_value_out");
			}
		}
	}
}

just_spawned_exception()
{
	while (1)
	{
		level waittill ("all_players_connected");
		flag_set ( "spawn_init" );
		wait 15;
		flag_clear ( "spawn_init" );
	}
}
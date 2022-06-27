#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init_hud_dvars()
{
	setDvar("summary_visible0", 0);
	setDvar("summary_visible1", 0);
	setDvar("summary_visible2", 0);
	setDvar("summary_visible3", 0);
	setDvar("hud_remaining_number", 0);
	setDvar("hud_drops_number", 0);
	setDvar("round_time_value", "0");
	setDvar("total_time_value", "0");
	setDvar("predicted_value", "0");
	setDvar("sph_value", 0);
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

summary_visible(mode, len, sph_round)
{
	level endon("start_of_round");
	level endon("end_of_round");
	level endon("disconnected");

	if (len > 5.5)
		len = 5.25;

	if (mode == "start")
	{
		setDvar("summary_visible2", 1);
		wait len;
		setDvar("summary_visible2", 0);
		wait 0.75;

		if (level.round_number % 4 != 1)
		{
			setDvar("summary_visible3", 1);
			wait len;
		}
		setDvar("summary_visible3", 0);
	}

	else
	{
		setDvar("summary_visible0", 1);
		wait len;
		setDvar("summary_visible0", 0);
		wait 0.75;

		if ((level.round_number >= sph_round) && (level.round_number % 4 != 1))
		{
			setDvar("summary_visible1", 1);
			wait len;
		}
		setDvar("summary_visible1", 0);
	}

	return;
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

health_bar_hud()
// player thread
{
	self endon("disconnect");
	self endon("end_game");

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

remaining_hud()
// level thread
{
	level endon("disconnect");
	level endon("end_game");

	setDvar("hud_remaining_number", 0);
	while(true)
	{
		wait 0.05;
		// Level var for round timer
		level.tracked_zombies = level.zombie_total + get_enemy_count();
		if (level.tracked_zombies == GetDvarInt("hud_remaining_number"))
			continue;

		setDvar("hud_remaining_number", level.tracked_zombies);
	}
}

drop_tracker_hud()
// level thread
{
	level endon("disconnect");
	level endon("end_game");

	setDvar("hud_drops_number", 0);
	while(true)
	{
		wait 0.05;
		if (isDefined(level.drop_tracker_index))
			tracked_drops = level.drop_tracker_index;
		else
			tracked_drops = 0;

		if (tracked_drops == GetDvarInt("hud_drops_number"))
			continue;

		setDvar("hud_drops_number", tracked_drops);
	}
}

game_stat_hud()
// level thread
{
	level endon("disconnect");
	level endon("end_game");

	// Settings
	settings_splits = array(30, 50, 70, 100);
	settings_sph = 1;
	player_count = get_players().size;

	// Handle round 1 outside of the loop
	level waittill("start_of_round");
	// NML handle
	while (isdefined(level.on_the_moon) && !level.on_the_moon)
		wait 0.05;

	round_start_time = int(getTime() / 1000);

	current_zombie_count = level.zombie_total + get_enemy_count();
	last_zombie_count = level.zombie_total + get_enemy_count();
	sph = 0;
	predicted = "0";
	rt_array = array();

	level waittill("end_of_round");
	round_end_time = int(getTime() / 1000);

	rt = round_end_time - round_start_time;
	setDvar("round_time_value", get_time_friendly(rt));

	wait 0.05;
	thread summary_visible("end", 6, settings_sph);	// Keep it on 6 for this one

	while (true)
	{
		level waittill("start_of_round");

		// NML handle
		if (isdefined(level.on_the_moon) && !level.on_the_moon)
			continue;

		// Pause handle
		if (isdefined(flag("game_paused")))
		{
			if (!flag("game_paused"))
				round_start_time = int(getTime() / 1000);
			else
			{
				while (flag("game_paused"))
					wait 0.05;

				round_start_time = int(getTime() / 1000);
			}
		}
		else
			continue;

		// Calculate total time at the beginning of next round
		gt = round_start_time - level.beginning_timestamp;
		setDvar("total_time_value", get_time_friendly(gt));

		// Grab zombie count from current round for SPH
		if(flag("dog_round") || flag("thief_round") || flag("monkey_round"))
			current_zombie_count = get_zombie_number(level.round_number - 1);
		else
			current_zombie_count = get_zombie_number();

		// Calculate predicted round time
		if (level.round_number % 4 == 2 && level.round_number > 4)
		{
			rt = rt_array[rt_array.size - 1];
			rt_array = array();
		}
		predicted = (rt / last_zombie_count) * current_zombie_count;
		setDvar("predicted_value", get_time_friendly(int(predicted)));

		thread summary_visible("start", 6, settings_sph);	// Trigger HUD

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
		setDvar("round_time_value", get_time_friendly(rt));

		// Calculate SPH
		sph = rt / (current_zombie_count / 24);
		wait 0.05;
		setDvar("sph_value", sph);
			
		// Save last rounds zombie count
		last_zombie_count = current_zombie_count;

		thread summary_visible("end", 6, settings_sph);	// Trigger HUD
	}
}


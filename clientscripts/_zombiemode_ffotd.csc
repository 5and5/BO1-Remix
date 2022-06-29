#include clientscripts\_utility;


main_start()
{
    players = GetLocalPlayers();
	for(i = 0; i < players.size; i++)
	{	
		players[i] thread set_fov();
		players[i] thread set_fovScale();
	}

	registerSystem("client_systems", ::client_systems_message_handler);
	register_client_system("hud_anim_handler", ::hud_message_handler);
}

set_fov()
{
	self endon("disconnect");

	while(1)
	{	
		if(GetDvarInt("cg_fov_enable") == 1)
		{
			fov = GetDvarFloat("cg_fov_settings");
			if(fov == GetDvarFloat("cg_fov"))
			{
				wait .05;
				continue;
			}

			SetClientDvar("cg_fov", fov);
		}
		wait .05;
	}
}

set_fovScale()
{
	self endon("disconnect");

	while(1)
	{	
		if(GetDvarInt("cg_fov_enable") == 1)
		{
			fovScale = GetDvarFloat("cg_fovScale_settings");
			if(fovScale == GetDvarFloat("cg_fovScale"))
			{
				wait .05;
				continue;
			}

			SetClientDvar("cg_fovScale", fovScale);
		}
		wait .05;
	}
}

// Infinate client systems
register_client_system(name, func)
{
	if(!isdefined(level.client_systems))
		level.client_systems = [];
	if(isdefined(func))
		level.client_systems[name] = func;
}

client_systems_message_handler(clientnum, state, oldState)
{
	tokens = StrTok(state, ":");

	name = tokens[0];
	message = tokens[1];

	if(isdefined(level.client_systems) && isdefined(level.client_systems[name]))
		level thread [[level.client_systems[name]]](clientnum, message);
}

main_end()
{
}

hud_message_handler(clientnum, state)
{
	// MUST MATCH MENU FILE DEFINES
	menu_name = "";
	item_name = "";
	fade_type = "";
	fade_time = 0;

	tab_fade_time = 75;

	if(state == "hud_zone_name_in")
	{
		menu_name = "left_bottom_hud";
		item_name = "zone_name_text";
		fade_type = "fadein";
		fade_time = 250;
	}
	else if(state == "hud_zone_name_out")
	{
		menu_name = "left_bottom_hud";
		item_name = "zone_name_text";
		fade_type = "fadeout";
		fade_time = 250;
	}
	else if(state == "hud_time_summary_in")
	{
		menu_name = "right_top_hud";
		item_name = "time_summary";
		fade_type = "fadein";
		fade_time = 750;
	}
	else if(state == "hud_time_summary_out")
	{
		menu_name = "right_top_hud";
		item_name = "time_summary";
		fade_type = "fadeout";
		fade_time = 750;
	}
	else if(state == "hud_remaining_in")
	{
		menu_name = "left_top_hud";
		item_name = "zombie_counter";
		fade_type = "fadein";
		fade_time = tab_fade_time;
	}
	else if(state == "hud_remaining_out")
	{
		menu_name = "left_top_hud";
		item_name = "zombie_counter";
		fade_type = "fadeout";
		fade_time = tab_fade_time;
	}
	else if(state == "hud_kills_in")
	{
		menu_name = "left_top_hud";
		item_name = "zombie_kill";
		fade_type = "fadein";
		fade_time = tab_fade_time;
	}
	else if(state == "hud_kills_out")
	{
		menu_name = "left_top_hud";
		item_name = "zombie_kill";
		fade_type = "fadeout";
		fade_time = tab_fade_time;
	}
	else if(state == "hud_drops_in")
	{
		menu_name = "left_top_hud";
		item_name = "zombie_drops";
		fade_type = "fadein";
		fade_time = tab_fade_time;
	}
	else if(state == "hud_drops_out")
	{
		menu_name = "left_top_hud";
		item_name = "zombie_drops";
		fade_type = "fadeout";
		fade_time = tab_fade_time;
	}
	else if(state == "hud_kinobox_in")
	{
		menu_name = "middle_hud";
		item_name = "kino_box_indicator";
		fade_type = "fadein";
		fade_time = 400;
	}
	else if(state == "hud_kinobox_out")
	{
		menu_name = "middle_hud";
		item_name = "kino_box_indicator";
		fade_type = "fadeout";
		fade_time = 400;
	}
	else if(state == "hud_nml_summary_in")
	{
		menu_name = "middle_hud";
		item_name = "nml_summary";
		fade_type = "fadein";
		fade_time = 250;
	}
	else if(state == "hud_nml_summary_out")
	{
		menu_name = "middle_hud";
		item_name = "nml_summary";
		fade_type = "fadeout";
		fade_time = 250;
	}
	else if(state == "hud_oxygen_in")
	{
		menu_name = "right_hud";
		item_name = "zombie_oxygen";
		fade_type = "fadein";
		fade_time = 250;
	}
	else if(state == "hud_oxygen_out")
	{
		menu_name = "right_hud";
		item_name = "zombie_oxygen";
		fade_type = "fadeout";
		fade_time = 250;
	}
	else if(state == "hud_excavator_in")
	{
		menu_name = "right_hud";
		item_name = "zombie_excavator";
		fade_type = "fadein";
		fade_time = 250;
	}
	else if(state == "hud_excavator_out")
	{
		menu_name = "right_hud";
		item_name = "zombie_excavator";
		fade_type = "fadeout";
		fade_time = 250;
	}
	else if(state == "hud_georgebar_image_in")
	{
		menu_name = "bottom_hud";
		item_name = "george_health_bar";
		fade_type = "fadein";
		fade_time = 125;
	}
	else if(state == "hud_georgebar_image_out")
	{
		menu_name = "bottom_hud";
		item_name = "george_health_bar";
		fade_type = "fadeout";
		fade_time = 125;
	}
	else if(state == "hud_georgebar_value_in")
	{
		menu_name = "bottom_hud";
		item_name = "george_health";
		fade_type = "fadein";
		fade_time = 125;
	}
	else if(state == "hud_georgebar_value_out")
	{
		menu_name = "bottom_hud";
		item_name = "george_health";
		fade_type = "fadeout";
		fade_time = 125;
	}
	else if(state == "hud_georgebar_background_in")
	{
		menu_name = "bottom_hud";
		item_name = "george_health_background";
		fade_type = "fadein";
		fade_time = 125;
	}
	else if(state == "hud_georgebar_background_out")
	{
		menu_name = "bottom_hud";
		item_name = "george_health_background";
		fade_type = "fadeout";
		fade_time = 125;
	}

	AnimateUI(clientnum, menu_name, item_name, fade_type, fade_time);
}

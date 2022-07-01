#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

create_hud( side, top )
{
	hud = NewClientHudElem( self );
	hud.horzAlign = side;
	hud.vertAlign = top;
	hud.alignX = side;
	hud.alignY = top;
	hud.alpha = 0;
	hud.fontscale = 1.3;
	hud.color = ( 1.0, 1.0, 1.0 );
	hud.hidewheninmenu = 1;
	return hud;
}

hud_level_wait()
{
	flag_wait( "all_players_spawned" );
	wait 3.15;
}

hud_wait()
{
	flag_wait( "all_players_spawned" );
	wait 2;
}

hud_end( hud )
{
	self endon("disconnect");

	level waittill ( "end_game" );
	hud destroy_hud();
}

hud_fade( hud, alpha, duration )
{
	hud fadeOverTime(duration);
	hud.alpha = alpha;
}

toggled_hud_fade(hud, alpha)
{
    duration = 0.1;
	hud fadeOverTime(duration);
	hud.alpha = alpha;
}

tab_hud()
{	
	self endon("disconnect");
	level endon("end_game");
	
	if(getDvar( "hud_button" ) == "")
		self setClientDvar( "hud_button", "tab" );

	while(1)
	{	
		if(self buttonPressed( getDvar( "hud_button" ) ))
		{	
			flag_set( "hud_pressed" );
			self setClientDvar( "hud_tab", 1 );
		}
		else
		{
			flag_clear( "hud_pressed" );
			self setClientDvar( "hud_tab", 0 );
		}

		wait 0.05;
	}
}

timer_hud()
{
	hud_level_wait();

	if(getDvarInt("hud_pluto"))
		pluto_offset = 12;
	else
		pluto_offset = 0;

	level.timer = NewHudElem();
	level.timer.horzAlign = "right";
	level.timer.vertAlign = "top";
	level.timer.alignX = "right";
	level.timer.alignY = "top";
	level.timer.x = -4;
	level.timer.y = 2 + pluto_offset;
	level.timer.fontScale = 1.3;
	level.timer.alpha = 1;
	level.timer.hidewheninmenu = 0;
	level.timer.foreground = 1;
	level.timer.color = (1, 1, 1); // Awaiting new color func

	level.timer SetTimerUp(0);
	level.beginning_timestamp = int(getTime() / 1000);

	level thread coop_pause(level.timer, level.beginning_timestamp);

	while (true)
	{
		current_time = int(getTime() / 1000);
		level.total_time = current_time - level.total_pause_time - level.beginning_timestamp;

		// reset 43200
		if ((level.total_time >= 43200) && (isDefined(level.paused) && !level.paused)) // 12h
		{
			level.win_game = true;
			level notify( "end_game" );
			players = get_players();
			for(i = 0; players.size > i; i++)
			{
				players[i] freezecontrols(false);
			}
			break;
		}

		wait 0.05;
	}

	while (true)
	{
		level.timer setTimer(level.total_time - 0.1);
		wait 0.5;
	}
}

round_timer_hud()
{
	level endon("end_game");

	hud_level_wait();

	if(getDvarInt("hud_pluto"))
		pluto_offset = 12;
	else
		pluto_offset = 0;

	level.round_timer = NewHudElem();
	level.round_timer.horzAlign = "right";
	level.round_timer.vertAlign = "top";
	level.round_timer.alignX = "right";
	level.round_timer.alignY = "top";
	level.round_timer.x = -4;
	level.round_timer.y = 17 + pluto_offset;
	level.round_timer.fontScale = 1.3;
	level.round_timer.alpha = 0;
	level.round_timer.color = (1, 1, 1); // Awaiting new color func

	// Prevent round time from working on first NML
	while (!isDefined(level.left_nomans_land) && level.script == "zombie_moon")
		wait 0.05;

	while (true)
	{
		level waittill ( "start_of_round" );

		// Don't want to start the round if ppl ain't on the moon
		if (isdefined(level.on_the_moon) && !level.on_the_moon)
		{
			wait 0.05;
			continue;
		}

		// Exclude time spent in pause
		if (isdefined(flag( "game_paused" )))
		{
			while (flag("game_paused"))
				wait 0.05;
		}

		current_round = level.round_number;
		level.round_timer setTimerUp(0);
		dvar_state = 0;
		tab_state = 0;

		tick = 0;
		while (current_round == level.round_number)
		{
			wait 0.05;

			// Ticks so the timer doesn't dissapear immidiately
			if (level.tracked_zombies == 0 && tick >= 200)
			{
				wait 0.5;
				hud_fade(level.round_timer, 0, 0.125);
				set_client_dvars("rt_displayed", 0);
				break;
			}
			else if (tick < 200)
				tick++;

			if (dvar_state == getDvarInt("hud_round_timer") && tab_state == getDvarInt("hud_tab"))
				continue;

			if (getDvarInt("hud_round_timer") || getDvarInt("hud_tab"))
			{
				hud_fade(level.round_timer, 1, 0.125);
				set_client_dvars("rt_displayed", 1);
			}
			else
			{
				hud_fade(level.round_timer, 0, 0.125);
				set_client_dvars("rt_displayed", 0);
			}

			dvar_state = getDvarInt("hud_round_timer");
			tab_state = getDvarInt("hud_tab");
		}
		hud_fade(level.round_timer, 0, 0.125);
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
	round_time_array = array();
	round_time = 0;

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
			round_time = round_time_array[rt_array.size - 1];
			round_time_array = array();		// Reset the array
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
		round_time = round_end_time - round_start_time;
		round_time_array[round_time_array.size] = rt;
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

set_client_dvars( dvar, value )
{
	players = get_players();
	for(i = 0; i < players.size; i++)
	{
		players[i] setClientDvar(dvar, value);
	}
}

coop_pause(timer_hud, start_time)
{
	level.paused = false;

    SetDvar( "coop_pause", 0 );
	flag_clear( "game_paused" );

	players = GetPlayers();
	if( players.size == 1 )
	{
		return;
	}

	paused_time = 0;
	paused_start_time = 0;

	while (true)
	{
		if( getDvarInt( "coop_pause" ) )
		{
			players = GetPlayers();
			if(level.zombie_total + get_enemy_count() != 0 || flag( "dog_round" ) || flag( "thief_round" ) || flag( "monkey_round" ))
			{
				iprintln("finish the round");
				level waittill( "end_of_round" );
			}
			if (!flag("director_alive"))
				iprintln("wait for the round change");

			wait 1; 	// To make sure the round changes
			// Don't allow breaks while George is alive or is possible to spawn

			// debug
			// iPrintLn("director_alive", flag("director_alive"));
			// iPrintLn("potential_director", flag("potential_director"));

			flagged = false;
			director_exception = false;
			if (flag("director_alive") || flag("potential_director"))
			{
				while (true)
				{
					if (!flag("director_alive") && !flag("potential_director"))
						break;

					if (!flagged)
					{
						iPrintLn("Kill George first");
						flagged = true;
					}

					wait 0.1;
				}
			}
			if (flagged)
				continue;

			players[0] SetClientDvar( "ai_disableSpawn", "1" );
			flag_set( "game_paused" );

			level waittill( "start_of_round" );

			black_hud = newhudelem();
			black_hud.horzAlign = "fullscreen";
			black_hud.vertAlign = "fullscreen";
			//black_hud.foreground = true;
			black_hud SetShader( "black", 640, 480 );
			black_hud.alpha = 0;

			black_hud FadeOverTime( 1.0 );
			black_hud.alpha = 0.65;

			paused_hud = newhudelem();
			paused_hud.horzAlign = "center";
			paused_hud.vertAlign = "middle";
			paused_hud setText(&"HUD_HUD_ZOMBIES_COOP_PAUSE");
			paused_hud.foreground = true;
			paused_hud.fontScale = 2.3;
			paused_hud.x = -63;
			paused_hud.y = -20;
			paused_hud.alpha = 0;
			paused_hud.color = ( 1.0, 1.0, 1.0 );

			paused_hud FadeOverTime( 1.0 );
			paused_hud.alpha = 0.8;

			level.paused = true;
			paused_start_time = int(getTime() / 1000);
			total_time = 0 - (paused_start_time - level.total_pause_time - start_time) - 0.05;
			previous_paused_time = level.paused_time;

			while(level.paused)
			{
				for(i = 0; players.size > i; i++)
				{
					players[i] freezecontrols(true);
				}
				
				timer_hud SetTimerUp(total_time);
				wait 0.2;

				current_time = int(getTime() / 1000);
				current_paused_time = current_time - paused_start_time;

				if( !getDvarInt( "coop_pause" ) )
				{
					level.total_pause_time += current_paused_time;
					level.paused = false;

					for(i = 0; players.size > i; i++)
					{
						players[i] freezecontrols(false);
					}

					players[0] SetClientDvar( "ai_disableSpawn", "0");
					flag_clear( "game_paused" );

					paused_hud FadeOverTime( 0.5 );
					paused_hud.alpha = 0;
					black_hud FadeOverTime( 0.5 );
					black_hud.alpha = 0;
					wait 0.5;
					black_hud destroy();
					paused_hud destroy();
				}
			}
		}
		wait 0.05;
	}
}

instakill_timer_hud()
{
    self.vr_timer = NewClientHudElem( self );
    self.vr_timer.horzAlign = "right";
    self.vr_timer.vertAlign = "bottom";
    self.vr_timer.alignX = "right";
    self.vr_timer.alignY = "bottom";
    self.vr_timer.alpha = 1.3;
    self.vr_timer.fontscale = 1.0;
    self.vr_timer.foreground = true;
    self.vr_timer.y = -57;
    self.vr_timer.x = -86;
    self.vr_timer.hidewheninmenu = 1;
    self.vr_timer.alpha = 0;
	self.vr_timer.color = (1, 1, 1);

    while (true)
    {
        insta_time = self.humangun_player_ignored_timer - level.total_time;
        //iprintln(insta_time);
        if(self.personal_instakill)
            self.vr_timer.alpha = 1;
        else
            self.vr_timer.alpha = 0;

        self.vr_timer setTimer(insta_time - 0.1);
        wait 0.05;
    }
}

box_notifier()
{
	hud_level_wait();
	
	box_notifier_hud = NewHudElem();
	box_notifier_hud.horzAlign = "center";
	box_notifier_hud.vertAlign = "middle";
	box_notifier_hud.alignX = "center";
	box_notifier_hud.alignY = "middle";
	box_notifier_hud.x = 0;
	box_notifier_hud.y = -150;
	box_notifier_hud.fontScale = 1.6;
	box_notifier_hud.alpha = 0;
	box_notifier_hud.label = "^7BOX SET: ";
	box_notifier_hud.color = ( 1.0, 1.0, 1.0 );

	while(!isdefined(level.box_set))
		wait 0.5;

	box_notifier_hud setText("^0UNDEFINED");
	if (level.box_set == 0)
	{
		box_notifier_hud setText("^2DINING");
	}
	else if (level.box_set == 1)
	{
		box_notifier_hud setText("^3HELLROOM");
	}
	else if (level.box_set == 2)
	{
		box_notifier_hud setText("^5NO POWER");
	}
	hud_fade(box_notifier_hud, 1, 0.25);
	wait 4;
	hud_fade(box_notifier_hud, 0, 0.25);
	wait 0.25;
	box_notifier_hud destroy();
}

// color_hud()
// {
// 	self thread color_hud_watcher();
// 	self thread color_health_bar_watcher();
// }

// color_hud_watcher()
// {
// 	hud_level_wait();
// 	wait 0.05;
// 	self endon("disconnect");

// 	if(getDvar("hud_color") == "")
// 		setDvar("hud_color", "1 1 1");

// 	color = getDvar("hud_color");
// 	prev_color = "1 1 1";

// 	while( 1 )
// 	{
// 		while( color == prev_color )
// 		{
// 			color = getDvar( "hud_color" );
// 			wait 0.1;
// 		}

// 		colors = strTok( color, " ");
// 		if( colors.size != 3 )
// 			continue;

// 		prev_color = color;

// 		level.timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		level.round_timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		level.print_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		level.sph_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		self.remaining_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		self.drops_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		self.health_text.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		self.oxygen_timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		// self.vr_timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		level.excavator_timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		level.trade_header.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 	}
// }

// color_health_bar_watcher()
// {
// 	self endon("disconnect");

// 	if(getDvar("hud_color_health") == "")
// 		setDvar("hud_color_health", "1 1 1");

// 	color = getDvar( "hud_color_health" );
// 	prev_color = "1 1 1";

// 	while( 1 )
// 	{
// 		while( color == prev_color )
// 		{
// 			color = getDvar( "hud_color_health" );
// 			wait 0.1;
// 		}

// 		colors = strTok( color, " ");
// 		if( colors.size != 3 )
// 			continue;

// 		prev_color = color;

// 		self.barElem.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		self.george_bar.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 	}
// }

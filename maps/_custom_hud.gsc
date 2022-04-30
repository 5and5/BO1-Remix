#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

timer_hud()
{
	hud_level_wait();

	level.timer = NewHudElem();
	level.timer.horzAlign = "right";
	level.timer.vertAlign = "top";
	level.timer.alignX = "right";
	level.timer.alignY = "top";
	level.timer.y += 2;
	level.timer.x -= 5;
	level.timer.fontScale = 1.3;
	level.timer.alpha = 1;
	level.timer.hidewheninmenu = 0;
	level.timer.foreground = 1;
	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
	level.timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );

	level.timer SetTimerUp(0);

	start_time = int(getTime() / 1000);
	level.paused_time = 0;
	level thread coop_pause(level.timer, start_time);

	while(1)
	{
		current_time = int(getTime() / 1000);
		level.total_time = current_time - level.paused_time - start_time;

		// reset
		if (level.total_time >= 43200) // 12h
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

	while (1)
	{
		level.timer setTimer(level.total_time - 0.1);
		wait 0.5;
	}
}

coop_pause(timer_hud, start_time)
{
	paused_time = 0;
	paused_start_time = 0;
	paused = false;

    SetDvar( "coop_pause", 0 );
	flag_clear( "game_paused" );

	players = GetPlayers();
	if( players.size == 1 )
	{
		// return;
	}

	while(1)
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
			iPrintLn("director_alive", flag("director_alive"));
			iPrintLn("potential_director", flag("potential_director"));

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
			paused_hud setText("GAME PAUSED");
			paused_hud.foreground = true;
			paused_hud.fontScale = 2.3;
			paused_hud.x -= 63;
			paused_hud.y -= 20;
			paused_hud.alpha = 0;
			paused_hud.color = ( 1.0, 1.0, 1.0 );

			paused_hud FadeOverTime( 1.0 );
			paused_hud.alpha = 0.8;

			for(i = 0; players.size > i; i++)
			{
				players[i] freezecontrols(true);
			}

			paused = true;
			paused_start_time = int(getTime() / 1000);
			total_time = 0 - (paused_start_time - level.paused_time - start_time) - 0.05;
			previous_paused_time = level.paused_time;

			while(paused)
			{
				timer_hud SetTimerUp(total_time);
				wait 0.2;

				current_time = int(getTime() / 1000);
				current_paused_time = current_time - paused_start_time;
				level.paused_time = previous_paused_time + current_paused_time;

				if( !getDvarInt( "coop_pause" ) )
				{
					paused = false;

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

round_timer()
{
	level endon("end_game");

	hud_level_wait();

	level.round_timer = NewHudElem();
	level.round_timer.horzAlign = "right";
	level.round_timer.vertAlign = "top";
	level.round_timer.alignX = "right";
	level.round_timer.alignY = "top";
	level.round_timer.y += 18;
	level.round_timer.x -= 5;
	level.round_timer.fontScale = 1.3;
	level.round_timer.alpha = 0;
	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
	level.round_timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );

	timestamp_game = int(getTime() / 1000);
	level thread round_timer_watcher( level.round_timer );

	while(1)
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
			if (!flag( "game_paused" ))
			{		
				timestamp_start = int(getTime() / 1000);
			}
			else
			{
				while ( 1 )
				{
					if (!flag( "game_paused" ))
					{
						break;
					}
					wait 0.05;
				}
				timestamp_start = int(getTime() / 1000);
			}
		}
		else
		{
			wait 0.05;
			continue;
		}

		// Setup round timer if always show rt dvar is true
		if (!getDvarInt("hud_round_timer"))
		{
			hud_fade(level.round_timer, 0, 0.25);
		}
		else
		{
			hud_fade(level.round_timer, 1, 0.25);
		}
		current_round = level.round_number;
		level.round_timer setTimerUp(0);

		// Print total time
		timestamp_current = int(getTime() / 1000);
		total_time = timestamp_current - timestamp_game;

		if (level.round_number > 1)
		{		
			col = 2;
			if (getDvarInt("hud_round_timer"))
			{
				col++;
			}
			level thread display_times( "Total time", total_time, 5, 0.5, col );
		}
		if (!getDvarInt("hud_round_timer"))
		{
			wait 6;
		}
		level.displaying_time = 0;

		// Exceptions for special round cases
		if((level.script == "zombie_cod5_sumpf" || level.script == "zombie_cod5_factory" || level.script == "zombie_theater") && flag( "dog_round" ))
		{
			level waittill( "last_dog_down" );
		}
		else if(level.script == "zombie_pentagon" && flag( "thief_round" ))
		{
			flag_wait( "last_thief_down" );
		}
		else if(level.script == "zombie_cosmodrome" && flag( "monkey_round" ))
		{
			flag_wait( "last_monkey_down" );
		}
		else
		{
			level waittill( "end_of_round" );
		}

		if(flag( "enter_nml" ))
		{
			level waittill( "end_of_round" ); //end no man's land
			level waittill( "end_of_round" ); //end actual round
		}

		// Print round time
		if (getDvarInt("hud_round_timer") && (level.round_timer.alpha != 0))
		{
			hud_fade(level.round_timer, 0, 0.25);
		}
		level.displaying_time = 1;
		timestamp_end = int(getTime() / 1000);
		round_time = timestamp_end - timestamp_start;
		level thread display_times( "Round time", round_time, 5, 0.5, 2 );		
	}
}

round_timer_watcher( hud )
{
	level.displaying_time = 0;

	while(1)
	{
		if(getDvarInt( "hud_round_timer") && !level.displaying_time)
		{
			if(hud.alpha != 1)
			{
                toggled_hud_fade(hud, 1);
			}
		}
		else
		{
			if(hud.alpha != 0)
			{
                toggled_hud_fade(hud, 0);
			}
		}

		if( getDvarInt( "hud_tab" ) && !getDvarInt( "hud_round_timer" ) && !level.displaying_time )
		{
			if(hud.alpha != 1)
			{
                toggled_hud_fade(hud, 1);
			}
		}
		
		wait 0.05;
	}
}

display_sph()
{	
	level endon("end_game");

	hud_level_wait();

	level.sph_hud = NewHudElem();
	level.sph_hud.horzAlign = "right";
	level.sph_hud.vertAlign = "top";
	level.sph_hud.alignX = "right";
	level.sph_hud.alignY = "top";
	level.sph_hud.y = 18;
	level.sph_hud.x = -5;
	level.sph_hud.fontScale = 1.3;
	level.sph_hud.alpha = 0;
	level.sph_hud.label = "SPH: ";
	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
	level.sph_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );

	level.sph_hud setValue(0);
	sph_round_display = 50;		// Start displaying on r50

	// Initialize variables
	round_time = 0;			
	zc_last = 0;

	while ( 1 )
	{
		level waittill( "start_of_round" );

		// Don't want to start the round if ppl ain't on the moon
		if (isdefined(level.on_the_moon) && !level.on_the_moon)
		{
			wait 0.05;
			continue;
		}

		if (level.round_number >= sph_round_display && !flag( "dog_round" ) && !flag( "thief_round" ) && !flag( "monkey_round" ))
		{
			// Don't count pause time
			if (isdefined(flag( "game_paused" )))
			{
				if (!flag( "game_paused" ))
				{		
					rt_start = int(getTime() / 1000);
				}
				else
				{
					while ( 1 )
					{
						if (!flag( "game_paused" ))
						{
							break;
						}
						wait 0.05;
					}
					rt_start = int(getTime() / 1000);
				}
			}
			else
			{
				wait 0.05;
				// iPrintLn("waiting");
				continue;
			}
			// Get zombie count from current round
			zc_current = level.zombie_total + get_enemy_count();

			// Calculate and display SPH
			wait 7;
			y_offset = 0;
			if(getDvarInt("hud_round_timer"))
			{
				y_offset = 15;
			}
			level.sph_hud.y = (18 + y_offset);

			if (level.round_number > sph_round_display && isdefined(round_time))
			{
				sph = round_time / (zc_last / 24);
				level.sph_hud setValue(sph);
				hud_fade(level.sph_hud, 1, 0.15);
				wait 6;
				hud_fade(level.sph_hud, 0, 0.15);
			}

			level waittill( "end_of_round" );
			if(flag( "enter_nml" ))
			{
				level waittill( "end_of_round" ); //end no man's land
				level waittill( "end_of_round" ); //end actual round
			}			
			
			zc_last = zc_current;	// Save zc from this round to separate var
			rt_end = int(getTime() / 1000);
			round_time = rt_end - rt_start;
			// iPrintLn("debug_rt: ^5" + round_time);
		}
		wait 0.05;
	}
}

display_times( label, time, duration, delay, col )
{
	level endon("end_game");

	y_offset = 0;
	if (isdefined(col))
	{
		while (col > 1)
		{
			y_offset += 15;
			col--;
		}
	}

	wait delay;
	level.print_hud = NewHudElem();
	level.print_hud.horzAlign = "right";
	level.print_hud.vertAlign = "top";
	level.print_hud.alignX = "right";
	level.print_hud.alignY = "top";
	level.print_hud.y = (2 + y_offset);
	level.print_hud.x = -5;
	level.print_hud.fontScale = 1.3;
	level.print_hud.alpha = 0;
	level.print_hud.label = (label + ": ");
    colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
    level.print_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );

	time_in_mins = print_time_friendly( time );	
	level.print_hud setText( time_in_mins );

	hud_fade( level.print_hud, 1, 0.25 );
	wait duration;
	hud_fade( level.print_hud, 0, 0.25 );
	wait 2;
	level.print_hud destroy_hud();
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

drop_tracker_hud()
{
	self endon("disconnect");
	self endon("end_game");

	hud_wait();

	self.drops_hud = create_hud( "left", "top" );
	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
	self.drops_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
	self.drops_hud.y += 18;
	self.drops_hud.x += 5;
	self.drops_hud.label = "Drops: ";

	hud_fade(self.drops_hud, 1 , 0.3);
	self thread hud_end(self.drops_hud);

	while(1)
	{
		if(getDvarInt( "hud_drops" ) == 0)
		{
			if(self.drops_hud.alpha != 0 )
			{
				toggled_hud_fade(self.drops_hud, 0);
			}
		}
		else
		{
			if(self.drops_hud.alpha != 1 )
			{
				toggled_hud_fade(self.drops_hud, 1);
			}
			self.drops_hud setValue(level.drop_tracker_index);
		}

		if( getDvarInt( "hud_tab" ) && !getDvarInt( "hud_drops" ) )
		{
			if(self.drops_hud.alpha != 1 )
			{
                toggled_hud_fade(self.drops_hud, 1);
			}
			self.drops_hud setValue(level.drop_tracker_index);
		}

		wait 0.05;
	}
}

zombies_remaining_hud()
{
	level endon("disconnect");
	level endon("end_game");

	hud_wait();

	self.remaining_hud = create_hud("left", "top");
	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
	self.remaining_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
	self.remaining_hud.y += 2;
	self.remaining_hud.x += 5;
	self.remaining_hud.label = "Remaining: ";

	hud_fade(self.remaining_hud, 1, 0.3);
	self thread hud_end(self.remaining_hud);

	while(1)
	{
		// Kill tracker for NML only
		if (!isDefined(level.left_nomans_land) && level.script == "zombie_moon")
		{
			self.remaining_hud.label = "Kills: ";

			if(self.remaining_hud.alpha != 1)
			{
				hud_fade(self.remaining_hud, 1, 0.25);			
			}

			tracked_kills = 0;
			players = get_players();
			for (i = 0; i < players.size; i++)
			{
				tracked_kills = players[i].kills;
			}

			self.remaining_hud setValue(tracked_kills);
		}
		// Else use normal remaining tracker
		else
		{
			self.remaining_hud.label = "Remaining: ";

			if( !getDvarInt( "hud_remaining" ) )
			{
				if(self.remaining_hud.alpha != 0)
				{
				    toggled_hud_fade(self.remaining_hud, 0);
				}
			}
			else
			{
				if(self.remaining_hud.alpha != 1)
				{
					toggled_hud_fade(self.remaining_hud, 1);			
				}

				zombies = level.zombie_total + get_enemy_count();
				self.remaining_hud setValue(zombies);
			}

			if( getDvarInt( "hud_tab" ) && !getDvarInt( "hud_remaining" ) )
			{
				if(self.remaining_hud.alpha != 1)
				{
                    toggled_hud_fade(self.remaining_hud, 1);
				}

				zombies = level.zombie_total + get_enemy_count();
				self.remaining_hud setValue(zombies);
			}
		}
		
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

	i = 0;
	while(i < 5)
	{
		if (isdefined(level.box_set))
		{
			box_notifier_hud setText("^0UNDEFINED");
			// iPrintLn(level.box_set); // debug
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
			break;
		}
		else
		{
			// iPrintLn("undefined"); // debug
			wait 0.5;
			i++;
		}
	}
}

health_bar_hud()
{
	self endon("disconnect");
	self endon("end_game");

	hud_wait();

	width = 113;
	height = 6;

	self.barElemBackround = create_hud( "left", "bottom");
	self.barElemBackround.x = 0;
	self.barElemBackround.y = -100;
	self.barElemBackround.width = width + 2;
	self.barElemBackround.height = height + 2;
	self.barElemBackround.foreground = 0;
	self.barElemBackround.shader = "black";
	self.barElemBackround setShader( "black", width + 2, height + 2 );

	self.barElem = create_hud( "left", "bottom");
	self.barElem.x = 1;
	self.barElem.y = -101;
	self.barElem.width = width;
	self.barElem.height = height;
	self.barElem.foreground = 1;
	self.barElem.shader = "white";
	self.barElem setShader( "white", width, height );

	self.health_text = create_hud( "left", "bottom");
	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
	self.health_text.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
	self.health_text.x = 49;
	self.health_text.y = -107;
	self.health_text.fontScale = 1.3;

	hud_fade(self.health_text, 0.8, 0.3);
	hud_fade(self.barElem, 0.55, 0.3);
	hud_fade(self.barElemBackround, 0.75, 0.3);

	self thread hud_end(self.health_text);
	self thread hud_end(self.barElem);
	self thread hud_end(self.barElemBackround);

	while (1)
	{
		if( getDvarInt( "hud_health_bar" ) == 0)
		{
			if(self.barElem.alpha != 0 && self.health_text.alpha != 0)
			{
				self.barElem.alpha = 0;
				self.barElemBackround.alpha = 0;
				self.health_text.alpha = 0;
			}
		}
		else
		{
			self.barElem updateHealth(self.health / self.maxhealth);
			self.health_text setValue(self.health);

			if(is_true( self.waiting_to_revive ) || self maps\_laststand::player_is_in_laststand())
			{
				self.barElem.alpha = 0;
				self.barElemBackround.alpha = 0;
				self.health_text.alpha = 0;

				wait 0.05;
				continue;
			}

			if (self.health_text.alpha != 0.8)
	        {
	            self.barElem.alpha = 0.55;
	            self.barElemBackround.alpha = 0.55;
				self.health_text.alpha = 0.8;
	        }
    	}
		wait 0.05;
	}
}

updateHealth( barFrac )
{
	barWidth = int(self.width * barFrac);
	self setShader( self.shader, barWidth, self.height );
}

george_health_bar()
{
	// self endon("disconnect");
	level endon("end_game");

	// hud_wait();
	level waittill("start_of_round");

	george_max_health = 250000 * level.players_playing;

	width = 250;
	height = 8;
	hudx = "center";
	hudy = "bottom";
	posx = 0;
	posy = -3;

	self.george_bar_background = create_hud(hudx, hudy);
	self.george_bar_background.x = posx;
	self.george_bar_background.y = posy;
	self.george_bar_background.width = width + 2;
	self.george_bar_background.height = height + 1;
	self.george_bar_background.foreground = 0;
	self.george_bar_background.shader = "black";
	self.george_bar_background.alpha = 0;
	self.george_bar_background setShader( "black", width + 2, height + 2 );

	self.george_bar = create_hud(hudx, hudy);
	self.george_bar.x = posx;
	self.george_bar.y = posy - 1;
	self.george_bar.width = width;
	self.george_bar.height = height;
	self.george_bar.foreground = 1;
	self.george_bar.shader = "white";
	self.george_bar.alpha = 0;
	self.george_bar setShader( "white", width, height );

	self.george_health = create_hud(hudx, hudy);
	self.george_health.x = posx;
	self.george_health.y = posy - 8;
	self.george_health.fontScale = 1.3;
	self.george_health.alpha = 0;

	self thread hud_end(self.george_health);
	self thread hud_end(self.george_bar);
	self thread hud_end(self.george_bar_background);

	current_george_hp = 0;

	while (1)
	{
		// iPrintLn(flag("director_alive"));	// debug
		// iPrintLn(flag("spawn_init"));		// debug

		// Amount of damage dealt to director, prevent going beyond the scale
		local_director_damage = level.director_damage;
		if (local_director_damage > george_max_health)
			local_director_damage = george_max_health;

		current_george_hp = (george_max_health - local_director_damage);

		if (flag( "director_alive" ))
		{
			self.george_health setValue(current_george_hp);
			// Prevent visual glitches with bar while george has 0 health
			if (current_george_hp == 0)
			{
				self.george_bar updateHealth(width);	// Smallest possible size
				self.george_bar.alpha = 1;
			}
			else
				self.george_bar updateHealth(current_george_hp / george_max_health);	
					
			self.george_health.color = (0.2, 0.6, 1);				// Blue
			if (current_george_hp < george_max_health * .66)
			{
				self.george_health.color = (1, 1, 0.2);				// Yellow
				if (current_george_hp < george_max_health * .33)
				{
					self.george_health.color = (1, 0.6, 0.2);		// Orange
					if (current_george_hp <= 1)
					{
						self.george_health.color = (1, 0.2, 0.2);	// Red
					}
				}
			}
		}
		else
		{
			hud_fade(self.george_bar, 0, 0.3);
			self.george_health setValue(0);
			self.george_health.color = (1, 0.2, 0.2);				// Red
		}

		if(!getDvarInt("hud_george_bar"))
		{
			if(self.george_health.alpha != 0)
			{
				hud_fade(self.george_health, 0, 0.3);
				hud_fade(self.george_bar, 0, 0.3);
				hud_fade(self.george_bar_background, 0, 0.3);
			}
		}
		else
		{
			// If it's not asked for alpha of that particular hud it won't reappear after george health is set
			if (self.george_bar.alpha != 0.5 && current_george_hp > 0)
			{
				hud_fade(self.george_health, 0.8, 0.3);
				hud_fade(self.george_bar, 0.55, 0.3);
				hud_fade(self.george_bar_background, 0.55, 0.3);
			}
			else if (self.george_health.alpha != 0 && !flag("director_alive")) //temp_director
			{
				wait 5;
				// hud_fade(george_bar, 0, 0.3);	// Not needed anymore
				hud_fade(self.george_health, 0, 0.3);
				hud_fade(self.george_bar_background, 0, 0.3);
			}
    	}

		if (flag("director_alive") && !getDvarInt("hud_george_bar") && getDvarInt("hud_tab"))
		{
			hud_fade(self.george_health, 0.8, 0.3);
			hud_fade(self.george_bar_background, 0.55, 0.3);	
			if (current_george_hp > 0)
				hud_fade(self.george_bar, 0.55, 0.3);
		}
		wait 0.05;
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

color_hud()
{
	self thread color_hud_watcher();
	self thread color_health_bar_watcher();
}

color_hud_watcher()
{
	hud_level_wait();
	wait 0.05;
	self endon("disconnect");

	if(getDvar("hud_color") == "")
		setDvar("hud_color", "1 1 1");

	color = getDvar("hud_color");
	prev_color = "1 1 1";

	while( 1 )
	{
		while( color == prev_color )
		{
			color = getDvar( "hud_color" );
			wait 0.1;
		}

		colors = strTok( color, " ");
		if( colors.size != 3 )
			continue;

		prev_color = color;

		level.timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
		level.round_timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
		level.print_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
		level.sph_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
		self.remaining_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
		self.drops_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
		self.health_text.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
	}
}

color_health_bar_watcher()
{
	self endon("disconnect");

	if(getDvar("hud_color_health") == "")
		setDvar("hud_color_health", "1 1 1");

	color = getDvar( "hud_color_health" );
	prev_color = "1 1 1";

	while( 1 )
	{
		while( color == prev_color )
		{
			color = getDvar( "hud_color_health" );
			wait 0.1;
		}

		colors = strTok( color, " ");
		if( colors.size != 3 )
			continue;

		prev_color = color;

		self.barElem.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
		self.george_bar.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
	}
}

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

// copy of to_mins() with modified output
print_time_friendly( seconds )
{
	hours = 0; 
	minutes = 0; 
	
	if( seconds > 59 )
	{
		minutes = int( seconds / 60 );

		seconds = int( seconds * 1000 ) % ( 60 * 1000 );
		seconds = seconds * 0.001; 

		if( minutes > 59 )
		{
			hours = int( minutes / 60 );
			minutes = int( minutes * 1000 ) % ( 60 * 1000 );
			minutes = minutes * 0.001; 		
		}
	}

	if( hours < 10 )
	{
		hours = "0" + hours; 
	}

	if( minutes < 10 )
	{
		minutes = "0" + minutes; 
	}

	seconds = Int( seconds ); 
	if( seconds < 10 )
	{
		seconds = "0" + seconds; 
	}

	if (hours == 0)
	{
		combined = "" + minutes  + ":" + seconds; 
	}
	else
	{
		combined = "" + hours  + ":" + minutes  + ":" + seconds; 
	}

	return combined; 
}

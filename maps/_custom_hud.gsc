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
				hud_fade(level.round_timer, 0, 0.075);
				setDvar("rt_displayed", 0);
				break;
			}
			else if (tick < 200)
				tick++;

			if (dvar_state == getDvarInt("hud_round_timer") && tab_state == getDvarInt("hud_tab"))
				continue;

			if (getDvarInt("hud_round_timer") || getDvarInt("hud_tab"))
			{
				hud_fade(level.round_timer, 1, 0.075);
				setDvar("rt_displayed", 1);
			}
			else
			{
				hud_fade(level.round_timer, 0, 075.25);
				setDvar("rt_displayed", 0);
			}

			dvar_state = getDvarInt("hud_round_timer");
			tab_state = getDvarInt("hud_tab");
		}
		hud_fade(level.round_timer, 0, 0.075);
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
			hud_fade(level.trade_header, 0, 0.1);	
		else
			hud_fade(level.trade_header, 1, 0.2);

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
			hud_fade(self.trade_weapon1, 0, 0.1);	
		else if (getDvarInt("hud_tab"))
		{
			self.trade_weapon1 setValue(hud_traces_pulls_handler(1));
			hud_fade(self.trade_weapon1, 1, 0.2);
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
			hud_fade(self.trade_weapon2, 0, 0.1);	
		else if (getDvarInt("hud_tab"))
		{
			self.trade_weapon2 setValue(hud_traces_pulls_handler(2));
			hud_fade(self.trade_weapon2, 1, 0.2);
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
			hud_fade(self.trade_weapon3, 0, 0.1);	
		else if (getDvarInt("hud_tab"))
		{
			self.trade_weapon3 setValue(hud_traces_pulls_handler(3));
			hud_fade(self.trade_weapon3, 1, 0.2);
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
			hud_fade(self.trade_weapon4, 0, 0.1);	
		else if (getDvarInt("hud_tab"))
		{
			self.trade_weapon4 setValue(hud_traces_pulls_handler(4));
			hud_fade(self.trade_weapon4, 1, 0.2);
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
			hud_fade(self.trade_boxhits, 0, 0.1);	
		else
		{
			self.trade_boxhits setValue(level.boxhits);
			hud_fade(self.trade_boxhits, 1, 0.2);
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
			hud_fade(self.trade_ww_average, 0, 0.1);	
		else
		{
			self.trade_ww_average setValue(level.trade_average);
			hud_fade(self.trade_ww_average, 1, 0.2);
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
			hud_fade(self.trade_current_box_location, 0, 0.1);	
		else
		{
			hud_fade(self.trade_current_box_location, 1, 0.2);

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
			hud_fade(self.trade_setup_boxhits, 0, 0.1);	
		else
		{
			if (flag("setup_completed"))
				self.trade_setup_boxhits setText(level.setup_box_hits);
			else
				self.trade_setup_boxhits setText(level.boxhits);

			hud_fade(self.trade_setup_boxhits, 1, 0.2);
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

// round_timer_hud()
// {
// 	level endon("end_game");

// 	hud_level_wait();

// 	if(getDvarInt("hud_pluto"))
// 		pluto_offset = 12;
// 	else
// 		pluto_offset = 0;

// 	level.round_timer = NewHudElem();
// 	level.round_timer.horzAlign = "right";
// 	level.round_timer.vertAlign = "top";
// 	level.round_timer.alignX = "right";
// 	level.round_timer.alignY = "top";
// 	level.round_timer.x = -4;
// 	level.round_timer.y = 17 + pluto_offset;
// 	level.round_timer.fontScale = 1.3;
// 	level.round_timer.alpha = 0;
// 	level.round_timer.color = (1, 1, 1); // Awaiting new color func

// 	// timestamp_game = int(getTime() / 1000);
// 	// level thread round_timer_watcher( level.round_timer );

// 	// Prevent round time from working on first NML
// 	while (!isDefined(level.left_nomans_land) && level.script == "zombie_moon")
// 		wait 0.05;

// 	while (true)
// 	{
// 		level waittill ( "start_of_round" );

// 		// Don't want to start the round if ppl ain't on the moon
// 		if (isdefined(level.on_the_moon) && !level.on_the_moon)
// 		{
// 			wait 0.05;
// 			continue;
// 		}

// 		// Exclude time spent in pause
// 		if (isdefined(flag( "game_paused" )))
// 		{
// 			while (flag("game_paused"))
// 				wait 0.05;
// 		}

// 		current_round = level.round_number;
// 		level.round_timer setTimerUp(0);
// 		dvar_state = 0;

// 		tick = 0;
// 		while (current_round == level.round_number)
// 		{
// 			wait 0.05;

// 			if (level.tracked_zombies == 0 && tick >= 200)
// 			{
// 				wait 0.5;
// 				hud_fade(level.round_timer, 0, 0.25);
// 				setDvar("rt_displayed", 0);
// 				break;
// 			}
// 			else if (tick < 200)
// 				tick++;

// 			if (dvar_state == getDvarInt("hud_round_timer"))
// 				continue;

// 			if (getDvarInt("hud_round_timer") || getDvarInt("hud_tab"))
// 			{
// 				hud_fade(level.round_timer, 1, 0.25);
// 				setDvar("rt_displayed", 1);
// 			}
// 			else
// 			{
// 				hud_fade(level.round_timer, 0, 0.25);
// 				setDvar("rt_displayed", 0);
// 			}

// 			dvar_state = getDvarInt("hud_round_timer");
// 		}
// 		hud_fade(level.round_timer, 0, 0.25);

		// // Print total time
		// timestamp_current = int(getTime() / 1000);
		// total_time = (timestamp_current - level.total_pause_time) - timestamp_game;

		// if (level.round_number > 1)
		// {		
		// 	col = 2;
		// 	if (getDvarInt("hud_round_timer"))
		// 	{
		// 		col++;
		// 	}
		// 	level thread display_times( "Total time", total_time, 5, 0.5, col );
		// }
		// if (!getDvarInt("hud_round_timer"))
		// {
		// 	wait 6;
		// }
		// level.displaying_time = 0;

		// // Exceptions for special round cases
		// if((level.script == "zombie_cod5_sumpf" || level.script == "zombie_cod5_factory" || level.script == "zombie_theater") && flag( "dog_round" ))
		// {
		// 	level waittill( "last_dog_down" );
		// }
		// else if(level.script == "zombie_pentagon" && flag( "thief_round" ))
		// {
		// 	flag_wait( "last_thief_down" );
		// }
		// else if(level.script == "zombie_cosmodrome" && flag( "monkey_round" ))
		// {
		// 	flag_wait( "last_monkey_down" );
		// }
		// else
		// {
		// 	level waittill( "end_of_round" );
		// }

		// if(flag( "enter_nml" ))
		// {
		// 	level waittill( "end_of_round" ); //end no man's land
		// 	level waittill( "end_of_round" ); //end actual round
		// }

		// // Print round time
		// if (getDvarInt("hud_round_timer") && (level.round_timer.alpha != 0))
		// {
		// 	hud_fade(level.round_timer, 0, 0.25);
		// }
		// level.displaying_time = 1;
		// timestamp_end = int(getTime() / 1000);
		// round_time = timestamp_end - timestamp_start;
		// level thread display_times( "Round time", round_time, 5, 0.5, 2 );		
// 	}
// }

// round_timer_watcher( hud )
// {
// 	level.displaying_time = 0;

// 	while(1)
// 	{
// 		if(getDvarInt( "hud_round_timer") && !level.displaying_time)
// 		{
// 			if(hud.alpha != 1)
// 			{
//                 toggled_hud_fade(hud, 1);
// 			}
// 		}
// 		else
// 		{
// 			if(hud.alpha != 0)
// 			{
//                 toggled_hud_fade(hud, 0);
// 			}
// 		}

// 		if( getDvarInt( "hud_tab" ) && !getDvarInt( "hud_round_timer" ) && !level.displaying_time )
// 		{
// 			if(hud.alpha != 1)
// 			{
//                 toggled_hud_fade(hud, 1);
// 			}
// 		}
		
// 		wait 0.05;
// 	}
// }

// display_sph()
// {	
// 	level endon("end_game");

// 	hud_level_wait();

// 	level.sph_hud = NewHudElem();
// 	level.sph_hud.horzAlign = "right";
// 	level.sph_hud.vertAlign = "top";
// 	level.sph_hud.alignX = "right";
// 	level.sph_hud.alignY = "top";
// 	level.sph_hud.y = 18 + level.pluto_offset;
// 	level.sph_hud.x = -5;
// 	level.sph_hud.fontScale = 1.3;
// 	level.sph_hud.alpha = 0;
// 	level.sph_hud.label = "SPH: ";
// 	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
// 	level.sph_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );

// 	level.sph_hud setValue(0);
// 	sph_round_display = 50;		// Start displaying on r50

// 	// Initialize variables
// 	round_time = 0;			
// 	zc_last = 0;

// 	while ( 1 )
// 	{
// 		level waittill( "start_of_round" );

// 		// Don't want to start the round if ppl ain't on the moon
// 		if (isdefined(level.on_the_moon) && !level.on_the_moon)
// 		{
// 			wait 0.05;
// 			continue;
// 		}

// 		// Don't count pause time
// 		if (isdefined(flag( "game_paused" )))
// 		{
// 			if (!flag( "game_paused" ))
// 			{		
// 				rt_start = int(getTime() / 1000);
// 			}
// 			else
// 			{
// 				while ( 1 )
// 				{
// 					if (!flag( "game_paused" ))
// 					{
// 						break;
// 					}
// 					wait 0.05;
// 				}
// 				rt_start = int(getTime() / 1000);
// 			}
// 		}
// 		else
// 		{
// 			wait 0.05;
// 			// iPrintLn("waiting");
// 			continue;
// 		}
// 		// Get zombie count from current round
// 		zc_current = level.zombie_total + get_enemy_count();

// 		// Calculate and display SPH
// 		wait 7;
// 		y_offset = 0;
// 		if(getDvarInt("hud_round_timer"))
// 		{
// 			y_offset = 15;
// 		}
// 		level.sph_hud.y = (18 + y_offset + level.pluto_offset);

// 		if ((level.round_number != (level.last_special_round + 1)) && (level.round_number >= sph_round_display))
// 		{
// 			sph = round_time / (zc_last / 24);
// 			level.sph_hud setValue(sph);
// 			hud_fade(level.sph_hud, 1, 0.15);
// 			wait 6;
// 			hud_fade(level.sph_hud, 0, 0.15);
// 		}

// 		level waittill( "end_of_round" );
// 		if(flag( "enter_nml" ))
// 		{
// 			level waittill( "end_of_round" ); //end no man's land
// 			level waittill( "end_of_round" ); //end actual round
// 		}			
		
// 		zc_last = zc_current;	// Save zc from this round to separate var
// 		rt_end = int(getTime() / 1000);
// 		round_time = rt_end - rt_start;
// 		// iPrintLn("debug_rt: ^5" + round_time);
// 		wait 0.05;
// 	}
// }

// display_times( label, time, duration, delay, col )
// {
// 	level endon("end_game");
// 	self endon("disconnect");

// 	y_offset = 0;
// 	if (isdefined(col))
// 	{
// 		while (col > 1)
// 		{
// 			y_offset += 15;
// 			col--;
// 		}
// 	}

// 	wait delay;
// 	level.print_hud = NewHudElem();
// 	level.print_hud.horzAlign = "right";
// 	level.print_hud.vertAlign = "top";
// 	level.print_hud.alignX = "right";
// 	level.print_hud.alignY = "top";
// 	level.print_hud.y = (2 + y_offset + level.pluto_offset);
// 	level.print_hud.x = -5;
// 	level.print_hud.fontScale = 1.3;
// 	level.print_hud.alpha = 0;
// 	level.print_hud.label = (label + ": ");
// 	// Reading it directly will cause it to bug up, middle-man level var required
// 	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
// 	level.print_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );

// 	time_in_mins = get_time_friendly( time );	
// 	level.print_hud setText( time_in_mins );

// 	hud_fade( level.print_hud, 1, 0.25 );
// 	wait duration;
// 	hud_fade( level.print_hud, 0, 0.25 );
// 	wait 2;
// 	level.print_hud destroy_hud();
// }

// drop_tracker_hud()
// {
// 	self endon("disconnect");
// 	self endon("end_game");

// 	hud_wait();

// 	self.drops_hud = create_hud( "left", "top" );
// 	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
// 	self.drops_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 	self.drops_hud.y += 18;
// 	self.drops_hud.x += 5;
// 	self.drops_hud.label = "Drops: ";

// 	hud_fade(self.drops_hud, 1 , 0.3);
// 	self thread hud_end(self.drops_hud);

// 	while(1)
// 	{
// 		if(getDvarInt( "hud_drops" ) == 0)
// 		{
// 			if(self.drops_hud.alpha != 0 )
// 			{
// 				toggled_hud_fade(self.drops_hud, 0);
// 			}
// 		}
// 		else
// 		{
// 			if(self.drops_hud.alpha != 1 )
// 			{
// 				toggled_hud_fade(self.drops_hud, 1);
// 			}
// 			self.drops_hud setValue(level.drop_tracker_index);
// 		}

// 		if( getDvarInt( "hud_tab" ) && !getDvarInt( "hud_drops" ) )
// 		{
// 			if(self.drops_hud.alpha != 1 )
// 			{
//                 toggled_hud_fade(self.drops_hud, 1);
// 			}
// 			self.drops_hud setValue(level.drop_tracker_index);
// 		}

// 		wait 0.05;
// 	}
// }

// zombies_remaining_hud()
// {
// 	level endon("disconnect");
// 	level endon("end_game");

// 	hud_wait();

// 	self.remaining_hud = create_hud("left", "top");
// 	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
// 	self.remaining_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 	self.remaining_hud.y += 2;
// 	self.remaining_hud.x += 5;
// 	self.remaining_hud.label = "Remaining: ";

// 	hud_fade(self.remaining_hud, 1, 0.3);
// 	self thread hud_end(self.remaining_hud);

// 	while(1)
// 	{
// 		// Kill tracker for NML only
// 		if (!isDefined(level.left_nomans_land) && level.script == "zombie_moon")
// 		{
// 			self.remaining_hud.label = "Kills: ";

// 			if(self.remaining_hud.alpha != 1)
// 			{
// 				hud_fade(self.remaining_hud, 1, 0.25);			
// 			}

// 			tracked_kills = 0;
// 			players = get_players();
// 			for (i = 0; i < players.size; i++)
// 			{
// 				tracked_kills = players[i].kills;
// 			}

// 			self.remaining_hud setValue(tracked_kills);
// 		}
// 		// Else use normal remaining tracker
// 		else
// 		{
// 			self.remaining_hud.label = "Remaining: ";

// 			if( !getDvarInt( "hud_remaining" ) )
// 			{
// 				if(self.remaining_hud.alpha != 0)
// 				{
// 				    toggled_hud_fade(self.remaining_hud, 0);
// 				}
// 			}
// 			else
// 			{
// 				if(self.remaining_hud.alpha != 1)
// 				{
// 					toggled_hud_fade(self.remaining_hud, 1);			
// 				}

// 				zombies = level.zombie_total + get_enemy_count();
// 				self.remaining_hud setValue(zombies);
// 			}

// 			if( getDvarInt( "hud_tab" ) && !getDvarInt( "hud_remaining" ) )
// 			{
// 				if(self.remaining_hud.alpha != 1)
// 				{
//                     toggled_hud_fade(self.remaining_hud, 1);
// 				}

// 				zombies = level.zombie_total + get_enemy_count();
// 				self.remaining_hud setValue(zombies);
// 			}
// 		}
		
// 		wait 0.05;
// 	}
// }

// box_notifier()
// {
// 	hud_level_wait();
	
// 	box_notifier_hud = NewHudElem();
// 	box_notifier_hud.horzAlign = "center";
// 	box_notifier_hud.vertAlign = "middle";
// 	box_notifier_hud.alignX = "center";
// 	box_notifier_hud.alignY = "middle";
// 	box_notifier_hud.x = 0;
// 	box_notifier_hud.y = -150;
// 	box_notifier_hud.fontScale = 1.6;
// 	box_notifier_hud.alpha = 0;
// 	box_notifier_hud.label = "^7BOX SET: ";
// 	box_notifier_hud.color = ( 1.0, 1.0, 1.0 );

// 	i = 0;
// 	while(i < 5)
// 	{
// 		if (isdefined(level.box_set))
// 		{
// 			box_notifier_hud setText("^0UNDEFINED");
// 			// iPrintLn(level.box_set); // debug
// 			if (level.box_set == 0)
// 			{
// 				box_notifier_hud setText("^2DINING");
// 			}
// 			else if (level.box_set == 1)
// 			{
// 				box_notifier_hud setText("^3HELLROOM");
// 			}
// 			else if (level.box_set == 2)
// 			{
// 				box_notifier_hud setText("^5NO POWER");
// 			}
// 			hud_fade(box_notifier_hud, 1, 0.25);
// 			wait 4;
// 			hud_fade(box_notifier_hud, 0, 0.25);
// 			break;
// 		}
// 		else
// 		{
// 			// iPrintLn("undefined"); // debug
// 			wait 0.5;
// 			i++;
// 		}
// 	}
// }

// health_bar_hud()
// {
// 	self endon("disconnect");
// 	self endon("end_game");

// 	hud_wait();

// 	width = 113;
// 	height = 6;

// 	self.barElemBackround = create_hud( "left", "bottom");
// 	self.barElemBackround.x = 0;
// 	self.barElemBackround.y = -100;
// 	self.barElemBackround.width = width + 2;
// 	self.barElemBackround.height = height + 2;
// 	self.barElemBackround.foreground = 0;
// 	self.barElemBackround.shader = "black";
// 	self.barElemBackround setShader( "black", width + 2, height + 2 );

// 	self.barElem = create_hud( "left", "bottom");
// 	self.barElem.x = 1;
// 	self.barElem.y = -101;
// 	self.barElem.width = width;
// 	self.barElem.height = height;
// 	self.barElem.foreground = 1;
// 	self.barElem.shader = "white";
// 	self.barElem setShader( "white", width, height );

// 	self.health_text = create_hud( "left", "bottom");
// 	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
// 	self.health_text.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 	self.health_text.x = 49;
// 	self.health_text.y = -107;
// 	self.health_text.fontScale = 1.3;

// 	hud_fade(self.health_text, 0.9, 0.3);
// 	hud_fade(self.barElem, 0.75, 0.3);
// 	hud_fade(self.barElemBackround, 0.75, 0.3);

// 	self thread hud_end(self.health_text);
// 	self thread hud_end(self.barElem);
// 	self thread hud_end(self.barElemBackround);

// 	while (1)
// 	{
// 		if( getDvarInt( "hud_health_bar" ) == 0)
// 		{
// 			if(self.barElem.alpha != 0 && self.health_text.alpha != 0)
// 			{
// 				self.barElem.alpha = 0;
// 				self.barElemBackround.alpha = 0;
// 				self.health_text.alpha = 0;
// 			}
// 		}
// 		else
// 		{
// 			self.barElem updateHealth(self.health / self.maxhealth);
// 			self.health_text setValue(self.health);

// 			if(is_true( self.waiting_to_revive ) || self maps\_laststand::player_is_in_laststand())
// 			{
// 				self.barElem.alpha = 0;
// 				self.barElemBackround.alpha = 0;
// 				self.health_text.alpha = 0;

// 				wait 0.05;
// 				continue;
// 			}

// 			if (self.health_text.alpha != 0.8)
// 	        {
// 	            self.barElem.alpha = 0.75;
// 	            self.barElemBackround.alpha = 0.55;
// 				self.health_text.alpha = 0.9;
// 	        }
//     	}
// 		wait 0.05;
// 	}
// }

// updateHealth( barFrac )
// {
// 	barWidth = int(self.width * barFrac);
// 	self setShader( self.shader, barWidth, self.height );
// }

// oxygen_timer_hud()
// {
// 	level endon("end_game");

//     self.oxygen_timer = NewClientHudElem( self );
//     self.oxygen_timer.horzAlign = "right";
//     self.oxygen_timer.vertAlign = "middle";
//     self.oxygen_timer.alignX = "right";
//     self.oxygen_timer.alignY = "middle";
//     self.oxygen_timer.alpha = 1.4;
//     self.oxygen_timer.fontscale = 1.0;
//     self.oxygen_timer.foreground = true;
//     self.oxygen_timer.y = 8;
//     self.oxygen_timer.x = -10;
//     self.oxygen_timer.hidewheninmenu = 1;
//     self.oxygen_timer.alpha = 0;
// 	self.oxygen_timer.label = "Oxygen left: ";

// 	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
// 	self.oxygen_timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );

//     while(1)
//     {
// 		if (isDefined(self.time_in_low_gravity) && isDefined(self.time_to_death))
// 		{
// 			oxygen_left = (self.time_to_death - self.time_in_low_gravity) / 1000;
// 			self.oxygen_timer setTimer(oxygen_left - 0.05);

// 			// iprintln(oxygen_left);
// 			// iPrintLn("time_to_death" + self.time_to_death);
// 			// iPrintLn("time_in_low_gravity" + self.time_in_low_gravity);

// 			if (getDvarInt("hud_oxygen_timer") || (!getDvarInt("hud_oxygen_timer") && getDvarInt("hud_tab")))
// 			{
// 				if(self.time_in_low_gravity > 0 && !self maps\_laststand::player_is_in_laststand() && isAlive(self))
// 					hud_fade(self.oxygen_timer, 1, 0.15);
// 				else
// 					hud_fade(self.oxygen_timer, 0, 0.15);
// 			}

// 			else
// 				hud_fade(self.oxygen_timer, 0, 0.15);
// 		}
    
//         wait 0.05;
//     }
// }

// excavator_timer_hud()
// {
// 	level endon("end_game");

//     level.excavator_timer = NewHudElem();
//     level.excavator_timer.horzAlign = "right";
//     level.excavator_timer.vertAlign = "middle";
//     level.excavator_timer.alignX = "right";
//     level.excavator_timer.alignY = "middle";
//     level.excavator_timer.alpha = 1.4;
//     level.excavator_timer.fontscale = 1.0;
//     level.excavator_timer.foreground = true;
//     level.excavator_timer.y = -8;
//     level.excavator_timer.x = -10;
//     level.excavator_timer.hidewheninmenu = 1;
//     level.excavator_timer.alpha = 0;
// 	level.excavator_timer.label = "Excavator: ";

// 	colors = strTok( getDvar( "cg_ScoresColor_Gamertag_0"), " " ); //default 1 1 1 1
// 	level.excavator_timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );

// 	current_excavator = "null";
// 	excavator_area = "null";

//     while(1)
//     {
// 		// debug
// 		// iprintln("digger_time_left" + level.digger_time_left);
// 		// iPrintLn("digger_to_activate" + level.digger_to_activate);
		
// 		if (isDefined(level.digger_time_left) && isDefined(level.digger_to_activate))
// 		{
// 			switch (level.digger_to_activate) 
// 			{
// 			case "teleporter":
// 				current_excavator = "Pi";
// 				// excavator_area = "Tunnel 6";
// 				break;
// 			case "hangar":
// 				current_excavator = "Omicron";
// 				// excavator_area = "Tunnel 11";
// 				break;
// 			case "biodome":
// 				current_excavator = "Epsilon";
// 				// excavator_area = "Biodome";
// 				break;
// 			}

// 			if (current_excavator == "null")
// 				continue;

// 			level.excavator_timer.label = "Excavator " + current_excavator + ": ";

// 			level.excavator_timer setTimer(level.digger_time_left - 0.05);

// 			if (getDvarInt("hud_excavator_timer") || (!getDvarInt("hud_excavator_timer") && getDvarInt("hud_tab")))
// 			{
// 				if((level.digger_to_activate != "null") && (level.excavator_timer.alpha != 1))
// 					hud_fade(level.excavator_timer, 1, 0.15);
// 				else if((level.digger_to_activate == "null") && (level.excavator_timer.alpha != 0))
// 					hud_fade(level.excavator_timer, 0, 0.15);
// 			}

// 			else
// 				hud_fade(level.excavator_timer, 0, 0.15);
// 		}
    
//         wait 0.05;
//     }
// }

// george_health_bar()
// {
// 	// self endon("disconnect");
// 	level endon("end_game");

// 	// hud_wait();
// 	level waittill("start_of_round");

// 	george_max_health = 250000 * level.players_playing;

// 	width = 250;
// 	height = 8;
// 	hudx = "center";
// 	hudy = "bottom";
// 	posx = 0;
// 	posy = -3;

// 	self.george_bar_background = create_hud(hudx, hudy);
// 	self.george_bar_background.x = posx;
// 	self.george_bar_background.y = posy;
// 	self.george_bar_background.width = width + 2;
// 	self.george_bar_background.height = height + 1;
// 	self.george_bar_background.foreground = 0;
// 	self.george_bar_background.shader = "black";
// 	self.george_bar_background.alpha = 0;
// 	self.george_bar_background setShader( "black", width + 2, height + 2 );

// 	self.george_bar = create_hud(hudx, hudy);
// 	self.george_bar.x = posx;
// 	self.george_bar.y = posy - 1;
// 	self.george_bar.width = width;
// 	self.george_bar.height = height;
// 	self.george_bar.foreground = 1;
// 	self.george_bar.shader = "white";
// 	self.george_bar.alpha = 0;
// 	self.george_bar setShader( "white", width, height );

// 	self.george_health = create_hud(hudx, hudy);
// 	self.george_health.x = posx;
// 	self.george_health.y = posy - 8;
// 	self.george_health.fontScale = 1.3;
// 	self.george_health.alpha = 0;

// 	self thread hud_end(self.george_health);
// 	self thread hud_end(self.george_bar);
// 	self thread hud_end(self.george_bar_background);

// 	current_george_hp = 0;

// 	while (1)
// 	{
// 		// iPrintLn(flag("director_alive"));	// debug
// 		// iPrintLn(flag("spawn_init"));		// debug

// 		// Amount of damage dealt to director, prevent going beyond the scale
// 		local_director_damage = level.director_damage;
// 		if (local_director_damage > george_max_health)
// 			local_director_damage = george_max_health;

// 		current_george_hp = (george_max_health - local_director_damage);

// 		if (flag( "director_alive" ))
// 		{
// 			self.george_health setValue(current_george_hp);
// 			// Prevent visual glitches with bar while george has 0 health
// 			if (current_george_hp == 0)
// 			{
// 				self.george_bar updateHealth(width);	// Smallest possible size
// 				self.george_bar.alpha = 0;
// 			}
// 			else
// 				self.george_bar updateHealth(current_george_hp / george_max_health);	
					
// 			self.george_health.color = (0.2, 0.6, 1);				// Blue
// 			if (current_george_hp < george_max_health * .66)
// 			{
// 				self.george_health.color = (1, 1, 0.2);				// Yellow
// 				if (current_george_hp < george_max_health * .33)
// 				{
// 					self.george_health.color = (1, 0.6, 0.2);		// Orange
// 					if (current_george_hp <= 1)
// 					{
// 						self.george_health.color = (1, 0.2, 0.2);	// Red
// 					}
// 				}
// 			}
// 		}
// 		else
// 		{
// 			hud_fade(self.george_bar, 0, 0.3);
// 			self.george_health setValue(0);
// 			self.george_health.color = (1, 0.2, 0.2);				// Red
// 		}

// 		if(!getDvarInt("hud_george_bar"))
// 		{
// 			if(self.george_health.alpha != 0 || self.george_bar != 0 || self.george_bar_background != 0)
// 			{
// 				hud_fade(self.george_health, 0, 0.3);
// 				hud_fade(self.george_bar, 0, 0.3);
// 				hud_fade(self.george_bar_background, 0, 0.3);
// 			}
// 		}
// 		else
// 		{
// 			// If it's not asked for alpha of that particular hud it won't reappear after george health is set
// 			if (self.george_bar.alpha != 0.5 && current_george_hp > 0)
// 			{
// 				hud_fade(self.george_health, 0.8, 0.3);
// 				hud_fade(self.george_bar, 0.55, 0.3);
// 				hud_fade(self.george_bar_background, 0.55, 0.3);
// 			}
// 			else if (self.george_health.alpha != 0 && !flag("director_alive")) //temp_director
// 			{
// 				wait 5;
// 				// hud_fade(george_bar, 0, 0.3);	// Not needed anymore
// 				hud_fade(self.george_health, 0, 0.3);
// 				hud_fade(self.george_bar_background, 0, 0.3);
// 			}
//     	}

// 		if (flag("director_alive") && !getDvarInt("hud_george_bar") && getDvarInt("hud_tab"))
// 		{
// 			hud_fade(self.george_health, 0.8, 0.3);
// 			hud_fade(self.george_bar_background, 0.55, 0.3);	
// 			if (current_george_hp > 0)
// 				hud_fade(self.george_bar, 0.55, 0.3);
// 		}
// 		wait 0.05;
// 	}
// }


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
